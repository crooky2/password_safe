import "dart:typed_data";

import "package:flutter/foundation.dart";

import "../crypto/vault_builder.dart";
import "../crypto/vault_unlocker.dart";

import "../storage/vault_file_store.dart";

import "../vault/password_database.dart";
import "../vault/unlocked_vault.dart";

enum AuthState { checking, needsSetup, locked, unlocked, busy }

class AuthController extends ChangeNotifier {
  AuthController({
    this.store = const VaultFileStore(),
    this.builder = const VaultBuilder(),
    this.unlocker = const VaultUnlocker(),
  });

  final VaultFileStore store;
  final VaultBuilder builder;
  final VaultUnlocker unlocker;

  AuthState _state = AuthState.checking;
  UnlockedVault? _unlockedVault;
  String? _errorMessage;

  AuthState get state => _state;
  UnlockedVault? get unlockedVault => _unlockedVault;
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
}
