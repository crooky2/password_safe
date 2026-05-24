// import "dart:typed_data";

import "package:flutter/foundation.dart";

import "../crypto/vault_builder.dart";
import "../crypto/vault_unlocker.dart";
import "../crypto/database_encrypter.dart";

import "../storage/vault_file_store.dart";

import "../vault/password_database.dart";
import "../vault/unlocked_vault.dart";

import "local_unlock_service.dart";

enum AuthState { checking, needsSetup, locked, unlocked, busy }

class AuthController extends ChangeNotifier {
  AuthController({
    this.store = const VaultFileStore(),
    this.builder = const VaultBuilder(),
    this.unlocker = const VaultUnlocker(),
    this.databaseEncrypter = const DatabaseEncrypter(),
    this.localUnlockService = const LocalUnlockService(),
  });

  final VaultFileStore store;
  final VaultBuilder builder;
  final VaultUnlocker unlocker;
  final DatabaseEncrypter databaseEncrypter;
  final LocalUnlockService localUnlockService;

  AuthState _state = AuthState.checking;
  UnlockedVault? _unlockedVault;
  String? _errorMessage;

  AuthState get state => _state;
  UnlockedVault? get unlockedVault => _unlockedVault;
  PasswordDatabase? get database => _unlockedVault?.database;
  String? get errorMessage => _errorMessage;

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
      final vaultFile = await store.load();
      _unlockedVault = await unlocker.unlock(
        vaultFile: vaultFile,
        masterPassword: masterPassword,
      );

      _errorMessage = null;
      _setState(AuthState.unlocked);

      return true;
    } catch (_) {
      _unlockedVault?.clearSecrets();
      _unlockedVault = null;
      _errorMessage = "Wrong password or damaged vault file.";
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
      await localUnlockService.enableQuickUnlock(pin: pin, vaultKey: unlockedVault.vaultKey);

      _errorMessage = null;
      notifyListeners();

      return true;
    } catch (_) {
      _errorMessage = "Could not enable quick unlock.";
      notifyListeners();

      return false;
    }
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

      _errorMessage = null;
      _setState(AuthState.unlocked);

      return true;
    } catch (_) {
      _unlockedVault?.clearSecrets();
      _unlockedVault = null;
      _errorMessage = "Wrong PIN.";
      _setState(AuthState.locked);

      return false;
    }
  }

  Future<void> disableQuickUnlock() async {
    await localUnlockService.disable();
    _errorMessage = null;
    notifyListeners();
  }
}
