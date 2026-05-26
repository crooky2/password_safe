// import "dart:typed_data";

import "package:flutter/foundation.dart";

import "../crypto/vault_builder.dart";
import "../crypto/vault_unlocker.dart";
import "../crypto/database_encrypter.dart";
import "../crypto/master_key_deriver.dart";
import "../crypto/vault_cipher.dart";

import "../storage/vault_file_store.dart";

import "../vault/password_database.dart";
import "../vault/unlocked_vault.dart";

import "local_unlock_service.dart";
import "local_unlock_models.dart";

enum AuthState { checking, needsSetup, locked, unlocked, busy }

class AuthController extends ChangeNotifier {
  AuthController({
    this.store = const VaultFileStore(),
    this.builder = const VaultBuilder(),
    this.unlocker = const VaultUnlocker(),
    this.databaseEncrypter = const DatabaseEncrypter(),
    this.localUnlockService = const LocalUnlockService(),
    this.masterKeyDeriver = const MasterKeyDeriver(),
  });

  final VaultFileStore store;
  final VaultBuilder builder;
  final VaultUnlocker unlocker;
  final DatabaseEncrypter databaseEncrypter;
  final LocalUnlockService localUnlockService;
  final MasterKeyDeriver masterKeyDeriver;

  AuthState _state = AuthState.checking;
  UnlockedVault? _unlockedVault;
  String? _errorMessage;
  DateTime? _unlockBlockedUntil;
  bool _unlockBlockedRequiresMasterPassword = false;

  AuthState get state => _state;
  UnlockedVault? get unlockedVault => _unlockedVault;
  PasswordDatabase? get database => _unlockedVault?.database;
  String? get errorMessage => _errorMessage;
  DateTime? get unlockBlockedUntil => _unlockBlockedUntil;
  bool get unlockBlockedRequiresMasterPassword =>
      _unlockBlockedRequiresMasterPassword;

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setBusy() {
    _errorMessage = null;
    _setState(AuthState.busy);
  }

  void lock() {
    _unlockedVault?.clearSecrets();
    _unlockedVault = null;
    _errorMessage = null;
    _setState(AuthState.locked);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);

    if (minutes > 0 && seconds > 0) {
      return "$minutes minute(s) and $seconds second(s)";
    }
    if (minutes > 0) {
      return "$minutes minute(s)";
    }
    return "$seconds second(s)";
  }

  void _setUnlockBlock(
    Duration remaining, {
    required bool requiresMasterPassword,
  }) {
    _unlockBlockedUntil = remaining <= Duration.zero
        ? null
        : DateTime.now().add(remaining);
    _unlockBlockedRequiresMasterPassword = requiresMasterPassword;
  }

  void _clearUnlockBlock() {
    _unlockBlockedUntil = null;
    _unlockBlockedRequiresMasterPassword = false;
  }

  Future<void> refreshUnlockBlock() async {
    final state = await localUnlockService.readThrottleState();
    final now = DateTime.now();

    _unlockBlockedUntil = state.isLocked(now)
        ? DateTime.fromMillisecondsSinceEpoch(state.lockedUntilMs)
        : null;
    _unlockBlockedRequiresMasterPassword = state.requiresMasterPassword;
    notifyListeners();
  }

  Future<void> initialize() async {
    _setState(AuthState.checking);
    final vaultExists = await store.exists();

    if (vaultExists) {
      _setState(AuthState.locked);
    } else {
      _setState(AuthState.needsSetup);
    }
  }

  Future<bool> createVault(String masterPassword) async {
    _setBusy();

    try {
      final createdVault = await builder.createNewVault(
        masterPassword: masterPassword,
        initialDatabase: PasswordDatabase.empty(),
      );

      await store.save(createdVault.vaultFile);

      _unlockedVault = createdVault.unlockedVault;
      _errorMessage = null;
      _setState(AuthState.unlocked);

      return true;
    } catch (_) {
      _errorMessage = "Could not create vault.";
      _setState(AuthState.needsSetup);

      return false;
    }
  }

  Future<bool> unlock(String masterPassword) async {
    _setBusy();

    try {
      await localUnlockService.ensureMasterUnlockAllowed();

      final vaultFile = await store.load();
      _unlockedVault = await unlocker.unlock(
        vaultFile: vaultFile,
        masterPassword: masterPassword,
      );

      await localUnlockService.clearThrottleState();
      _clearUnlockBlock();
      _errorMessage = null;
      _setState(AuthState.unlocked);

      return true;
    } on QuickUnlockLockedException catch (error) {
      _setUnlockBlock(
        error.remainingLockTime,
        requiresMasterPassword: error.requiresMasterPassword,
      );

      _unlockedVault?.clearSecrets();
      _unlockedVault = null;
      _errorMessage =
          "Too many PIN attempts. Try again in ${_formatDuration(error.remainingLockTime)}.";
      _setState(AuthState.locked);

      return false;
    } catch (_) {
      _unlockedVault?.clearSecrets();
      _unlockedVault = null;
      _errorMessage = "Wrong password.";
      _setState(AuthState.locked);

      return false;
    }
  }

  Future<bool> saveDatabase(PasswordDatabase database) async {
    final unlockedVault = _unlockedVault;

    if (unlockedVault == null) {
      _errorMessage = "Vault is locked.";
      notifyListeners();
      return false;
    }

    try {
      final vaultFile = await store.load();

      final encryptedDatabase = await databaseEncrypter.encryptDatabase(
        database: database,
        vaultKey: unlockedVault.vaultKey,
      );

      final updatedVaultFile = vaultFile.copyWith(
        encryptedDatabase: encryptedDatabase,
      );

      await store.save(updatedVaultFile);

      unlockedVault.database = database;
      _errorMessage = null;
      notifyListeners();

      return true;
    } catch (_) {
      _errorMessage = "Could not save Database.";
      notifyListeners();

      return false;
    }
  }

  Future<bool> changeMasterPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final unlockedVault = _unlockedVault;

    if (unlockedVault == null) {
      _errorMessage = "Vault is locked.";
      notifyListeners();
      return false;
    }

    if (newPassword.length < 12) {
      _errorMessage = "Use at least 12 characters for the password.";
      notifyListeners();
      return false;
    }

    try {
      final vaultFile = await store.load();
      await unlocker.unlock(
        vaultFile: vaultFile,
        masterPassword: currentPassword,
      );

      final newKdfParams = masterKeyDeriver.createDefaultParams();

      final newKeyEncryptionKey = await masterKeyDeriver.deriveKey(
        password: newPassword,
        params: newKdfParams,
      );

      final wrappedVaultKey = await VaultCipher().encrypt(
        plaintext: unlockedVault.vaultKey,
        key: newKeyEncryptionKey,
      );

      final updatedVaultFile = vaultFile.copyWith(
        kdf: newKdfParams,
        wrappedVaultKey: wrappedVaultKey,
      );

      await store.save(updatedVaultFile);
      await localUnlockService.disable();

      _errorMessage = null;
      notifyListeners();

      return true;
    } catch (_) {
      _errorMessage = "Current password is incorrect or vault file is damaged.";
      notifyListeners();
      return false;
    }
  }

  Future<bool> isQuickUnlockEnabled() {
    return localUnlockService.isEnabled();
  }

  Future<bool> enableQuickUnlock(String pin) async {
    final unlockedVault = _unlockedVault;

    if (unlockedVault == null) {
      _errorMessage = "Vault is locked.";
      notifyListeners();
      return false;
    }

    if (pin.length < 4) {
      _errorMessage = "Use at least 4 digits for the PIN.";
      notifyListeners();
      return false;
    }

    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      _errorMessage = 'PIN must contain only numbers.';
      notifyListeners();
      return false;
    }

    try {
      await localUnlockService.enableQuickUnlock(
        pin: pin,
        vaultKey: unlockedVault.vaultKey,
      );

      _errorMessage = null;
      notifyListeners();

      return true;
    } catch (_) {
      _errorMessage = "Could not enable quick unlock.";
      notifyListeners();

      return false;
    }
  }

  Future<void> disableQuickUnlock() async {
    await localUnlockService.disable();
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> unlockWithPin(String pin) async {
    _setBusy();

    try {
      final vaultKey = await localUnlockService.unlockWithPin(pin: pin);
      final vaultFile = await store.load();

      _unlockedVault = await unlocker.unlockWithVaultKey(
        vaultFile: vaultFile,
        vaultKey: vaultKey,
      );
      
      _clearUnlockBlock();

      _errorMessage = null;
      _setState(AuthState.unlocked);

      

      return true;
    } on QuickUnlockLockedException catch (error) {
      _unlockedVault?.clearSecrets();
      _unlockedVault = null;
      if (error.requiresMasterPassword) {
        _errorMessage =
            "Too many PIN attempts. Wait ${_formatDuration(error.remainingLockTime)}, then use your master password.";
      } else {
        _errorMessage =
            "Too many PIN attempts. Try again in ${_formatDuration(error.remainingLockTime)}.";
      }

      _setState(AuthState.locked);

      _setUnlockBlock(
        error.remainingLockTime,
        requiresMasterPassword: error.requiresMasterPassword,
      );

      return false;
    } on QuickUnlockMasterPasswordRequiredException {
      _unlockedVault?.clearSecrets();
      _unlockedVault = null;
      _errorMessage = "Quick unlock is disabled. Use your master password.";

      _setState(AuthState.locked);

      _unlockBlockedUntil = null;
      _unlockBlockedRequiresMasterPassword = true;

      return false;
    } on QuickUnlockRejectedException catch (error) {
      _unlockedVault?.clearSecrets();
      _unlockedVault = null;

      if (error.requiresMasterPassword) {
        _errorMessage =
            "Too many PIN attempts. Wait ${_formatDuration(error.cooldown!)}, then use your master password.";
      } else if (error.cooldown != null) {
        _errorMessage =
            "Wrong PIN. Try again in ${_formatDuration(error.cooldown!)}.";
      } else {
        _errorMessage = "Wrong PIN.";
      }

      _setState(AuthState.locked);

      if (error.cooldown != null) {
        _setUnlockBlock(
          error.cooldown!,
          requiresMasterPassword: error.requiresMasterPassword,
        );
      } else {
        _clearUnlockBlock();
      }

      return false;
    } catch (_) {
      _unlockedVault?.clearSecrets();
      _unlockedVault = null;
      _errorMessage = "Wrong PIN.";
      _setState(AuthState.locked);

      return false;
    }
  }
}
