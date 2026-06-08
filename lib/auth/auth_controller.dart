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
import "local_auth_gate.dart";

enum AuthState { checking, needsSetup, locked, unlocked, busy }

enum AuthMessage {
  couldNotCreateVault,
  tooManyPinAttemptsTryAgain,
  wrongPassword,
  vaultIsLocked,
  couldNotSaveDatabase,
  useAtLeast12CharactersForPassword,
  currentPasswordIncorrectOrVaultDamaged,
  useAtLeast4DigitsForPin,
  pinMustContainOnlyNumbers,
  couldNotEnableQuickUnlock,
  tooManyPinAttemptsWaitThenUseMasterPassword,
  quickUnlockDisabledUseMasterPassword,
  wrongPinTryAgain,
  wrongPin,
  localAuthenticationUnavailable,
  localAuthenticationFailed,
}

class AuthFeedbackMessage {
  const AuthFeedbackMessage(this.message, {this.duration});

  final AuthMessage message;
  final Duration? duration;
}

class AuthController extends ChangeNotifier {
  AuthController({
    this.store = const VaultFileStore(),
    this.builder = const VaultBuilder(),
    this.unlocker = const VaultUnlocker(),
    this.databaseEncrypter = const DatabaseEncrypter(),
    this.localUnlockService = const LocalUnlockService(),
    this.masterKeyDeriver = const MasterKeyDeriver(),
    this.onDatabaseSaved,
    LocalAuthGate? localAuthGate,
  }) : localAuthGate = localAuthGate ?? LocalAuthGate();

  final VaultFileStore store;
  final VaultBuilder builder;
  final VaultUnlocker unlocker;
  final DatabaseEncrypter databaseEncrypter;
  final LocalUnlockService localUnlockService;
  final MasterKeyDeriver masterKeyDeriver;
  final LocalAuthGate localAuthGate;
  final VoidCallback? onDatabaseSaved;

  AuthState _state = AuthState.checking;
  UnlockedVault? _unlockedVault;
  AuthFeedbackMessage? _errorMessage;
  DateTime? _unlockBlockedUntil;
  bool _unlockBlockedRequiresMasterPassword = false;
  bool _shouldAutoPromptFingerprint = false;

  AuthState get state => _state;
  UnlockedVault? get unlockedVault => _unlockedVault;
  PasswordDatabase? get database => _unlockedVault?.database;
  AuthFeedbackMessage? get errorMessage => _errorMessage;
  DateTime? get unlockBlockedUntil => _unlockBlockedUntil;
  bool get unlockBlockedRequiresMasterPassword =>
      _unlockBlockedRequiresMasterPassword;
  bool get shouldAutoPromptFingerprint => _shouldAutoPromptFingerprint;

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setBusy() {
    _errorMessage = null;
    _shouldAutoPromptFingerprint = false;
    _setState(AuthState.busy);
  }

  void _setErrorMessage(AuthMessage message, {Duration? duration}) {
    _errorMessage = AuthFeedbackMessage(message, duration: duration);
  }

  void lock({bool autoPromptFingerprint = false}) {
    _unlockedVault?.clearSecrets();
    _unlockedVault = null;
    _errorMessage = null;
    _shouldAutoPromptFingerprint = autoPromptFingerprint;
    _setState(AuthState.locked);
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

  Future<void> _restoreFingerprintUnlockIfNeeded() async {
    final unlockedVault = _unlockedVault;

    if (unlockedVault == null) {
      return;
    }

    await localUnlockService.restoreFingerprintUnlockIfNeeded(
      vaultKey: unlockedVault.vaultKey,
    );
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
      _shouldAutoPromptFingerprint = true;
      _setState(AuthState.locked);
    } else {
      _shouldAutoPromptFingerprint = false;
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
      _shouldAutoPromptFingerprint = false;
      _setState(AuthState.unlocked);

      return true;
    } catch (_) {
      _setErrorMessage(AuthMessage.couldNotCreateVault);
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
      await _restoreFingerprintUnlockIfNeeded();

      await localUnlockService.clearThrottleState();
      _clearUnlockBlock();
      _errorMessage = null;
      _shouldAutoPromptFingerprint = false;
      _setState(AuthState.unlocked);

      return true;
    } on QuickUnlockLockedException catch (error) {
      _setUnlockBlock(
        error.remainingLockTime,
        requiresMasterPassword: error.requiresMasterPassword,
      );

      _unlockedVault?.clearSecrets();
      _unlockedVault = null;
      _setErrorMessage(
        AuthMessage.tooManyPinAttemptsTryAgain,
        duration: error.remainingLockTime,
      );
      _setState(AuthState.locked);

      return false;
    } catch (_) {
      _unlockedVault?.clearSecrets();
      _unlockedVault = null;
      _setErrorMessage(AuthMessage.wrongPassword);
      _setState(AuthState.locked);

      return false;
    }
  }

  Future<bool> saveDatabase(
    PasswordDatabase database, {
    bool notifyDatabaseSaved = true,
  }) async {
    final unlockedVault = _unlockedVault;

    if (unlockedVault == null) {
      _setErrorMessage(AuthMessage.vaultIsLocked);
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

      if (notifyDatabaseSaved) {
        onDatabaseSaved?.call();
      }

      return true;
    } catch (_) {
      _setErrorMessage(AuthMessage.couldNotSaveDatabase);
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
      _setErrorMessage(AuthMessage.vaultIsLocked);
      notifyListeners();
      return false;
    }

    if (newPassword.length < 12) {
      _setErrorMessage(AuthMessage.useAtLeast12CharactersForPassword);
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
      await localUnlockService.disableFingerprintUnlock();

      _errorMessage = null;
      _shouldAutoPromptFingerprint = false;
      notifyListeners();

      return true;
    } catch (_) {
      _setErrorMessage(AuthMessage.currentPasswordIncorrectOrVaultDamaged);
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
      _setErrorMessage(AuthMessage.vaultIsLocked);
      notifyListeners();
      return false;
    }

    if (pin.length < 4) {
      _setErrorMessage(AuthMessage.useAtLeast4DigitsForPin);
      notifyListeners();
      return false;
    }

    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      _setErrorMessage(AuthMessage.pinMustContainOnlyNumbers);
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
      _setErrorMessage(AuthMessage.couldNotEnableQuickUnlock);
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
      await _restoreFingerprintUnlockIfNeeded();

      _clearUnlockBlock();

      _errorMessage = null;
      _shouldAutoPromptFingerprint = false;
      _setState(AuthState.unlocked);

      return true;
    } on QuickUnlockLockedException catch (error) {
      _unlockedVault?.clearSecrets();
      _unlockedVault = null;
      if (error.requiresMasterPassword) {
        _setErrorMessage(
          AuthMessage.tooManyPinAttemptsWaitThenUseMasterPassword,
          duration: error.remainingLockTime,
        );
      } else {
        _setErrorMessage(
          AuthMessage.tooManyPinAttemptsTryAgain,
          duration: error.remainingLockTime,
        );
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
      _setErrorMessage(AuthMessage.quickUnlockDisabledUseMasterPassword);

      _setState(AuthState.locked);

      _unlockBlockedUntil = null;
      _unlockBlockedRequiresMasterPassword = true;

      return false;
    } on QuickUnlockRejectedException catch (error) {
      _unlockedVault?.clearSecrets();
      _unlockedVault = null;

      if (error.requiresMasterPassword) {
        _setErrorMessage(
          AuthMessage.tooManyPinAttemptsWaitThenUseMasterPassword,
          duration: error.cooldown!,
        );
      } else if (error.cooldown != null) {
        _setErrorMessage(
          AuthMessage.wrongPinTryAgain,
          duration: error.cooldown!,
        );
      } else {
        _setErrorMessage(AuthMessage.wrongPin);
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
      _setErrorMessage(AuthMessage.wrongPin);
      _setState(AuthState.locked);

      return false;
    }
  }

  Future<bool> isPinUnlockEnabled() {
    return localUnlockService.isEnabled();
  }

  Future<bool> isFingerprintUnlockEnabled() {
    return localUnlockService.isFingerprintUnlockEnabled();
  }

  Future<bool> enableFingerprintUnlock({required String promptTitle}) async {
    final unlockedVault = _unlockedVault;

    if (unlockedVault == null) {
      _setErrorMessage(AuthMessage.vaultIsLocked);
      notifyListeners();
      return false;
    }

    if (!await localAuthGate.canUseFingerprint()) {
      _setErrorMessage(AuthMessage.localAuthenticationUnavailable);
      notifyListeners();
      return false;
    }

    try {
      final authenticated = await localAuthGate.authenticateFingerprint(
        reason: promptTitle,
      );

      if (!authenticated) {
        _setErrorMessage(AuthMessage.localAuthenticationFailed);
        notifyListeners();
        return false;
      }

      await localUnlockService.enableFingerprintUnlock(
        vaultKey: unlockedVault.vaultKey,
      );

      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (_) {
      _setErrorMessage(AuthMessage.couldNotEnableQuickUnlock);
      notifyListeners();
      return false;
    }
  }

  Future<void> disableFingerprintUnlock() async {
    await localUnlockService.disableFingerprintUnlock();
    _errorMessage = null;
    _shouldAutoPromptFingerprint = false;
    notifyListeners();
  }

  Future<bool> unlockWithFingerprint({required String promptTitle}) async {
    _shouldAutoPromptFingerprint = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final authenticated = await localAuthGate.authenticateFingerprint(
        reason: promptTitle,
      );

      if (!authenticated) {
        return false;
      }

      final vaultKey = await localUnlockService.unlockWithFingerprint();
      final vaultFile = await store.load();

      _unlockedVault = await unlocker.unlockWithVaultKey(
        vaultFile: vaultFile,
        vaultKey: vaultKey,
      );

      _errorMessage = null;
      _shouldAutoPromptFingerprint = false;
      _setState(AuthState.unlocked);
      return true;
    } catch (error, stackTrace) {
      debugPrint("Fingerprint unlock did not complete: $error");
      debugPrintStack(stackTrace: stackTrace);

      _unlockedVault?.clearSecrets();
      _unlockedVault = null;

      if (error is StateError) {
        _setErrorMessage(AuthMessage.quickUnlockDisabledUseMasterPassword);
        await localUnlockService.disableFingerprintUnlock();
      } else {
        _setErrorMessage(AuthMessage.localAuthenticationFailed);
      }

      _setState(AuthState.locked);
      return false;
    }
  }
}
