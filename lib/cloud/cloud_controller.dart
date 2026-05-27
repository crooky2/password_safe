import "package:flutter/foundation.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../storage/vault_file_store.dart";

import "microsoft_auth_service.dart";
import "onedrive_vault_store.dart";

enum CloudSyncMode { disabled, oneDrive }

enum CloudMessage {
  syncDisabled,
  syncPaused,
  oneDriveConnectedNoVault,
  uploadedToOneDrive,
  downloadedFromOneDrive,
  alreadyInSync,
  vaultsDiffer,
  signInCanceled,
  enableOneDriveFailed,
  syncFailed,
  uploadedLocalConflict,
  downloadedCloudConflict,
  keptBothPaused,
  saveConflictFailed,
}

class CloudSyncConflict {
  const CloudSyncConflict({required this.localText, required this.remoteText});

  final String localText;
  final String remoteText;
}

class CloudController extends ChangeNotifier {
  CloudController({
    this.vaultFileStore = const VaultFileStore(),
    MicrosoftAuthService? microsoftAuthService,
  }) : microsoftAuthService = microsoftAuthService ?? MicrosoftAuthService() {
    oneDriveVaultStore = OneDriveVaultStore(
      authService: this.microsoftAuthService,
    );
  }

  static const _modeKey = "cloud_sync_mode";
  static const _syncHeldKey = "cloud_sync_held";

  final VaultFileStore vaultFileStore;
  final MicrosoftAuthService microsoftAuthService;
  late final OneDriveVaultStore oneDriveVaultStore;

  CloudSyncMode _mode = CloudSyncMode.disabled;
  bool _isBusy = false;
  bool _syncHeld = false;
  CloudMessage? _message;
  CloudSyncConflict? _pendingConflict;

  CloudSyncMode get mode => _mode;
  bool get isBusy => _isBusy;
  bool get syncHeld => _syncHeld;
  CloudMessage? get message => _message;
  CloudSyncConflict? get pendingConflict => _pendingConflict;
  bool get hasPendingConflict => _pendingConflict != null;

  Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    final storedMode = preferences.getString(_modeKey);

    _mode = switch (storedMode) {
      "oneDrive" => CloudSyncMode.oneDrive,
      _ => CloudSyncMode.disabled,
    };

    _syncHeld = preferences.getBool(_syncHeldKey) ?? false;

    notifyListeners();

    if (_mode == CloudSyncMode.oneDrive && !_syncHeld) {
      await checkForCloudChanges();
    }
  }

  Future<void> setMode(CloudSyncMode mode) async {
    if (_isBusy || mode == _mode) {
      return;
    }

    if (mode == CloudSyncMode.oneDrive) {
      await _enableOneDrive();
      return;
    }

    await _disable();
  }

  Future<void> syncNow() async {
    if (_isBusy || _mode == CloudSyncMode.disabled) {
      return;
    }

    if (_syncHeld) {
      _message = CloudMessage.syncPaused;
      notifyListeners();
      return;
    }

    await checkForCloudChanges();
  }

  Future<void> checkForCloudChanges() async {
    if (_isBusy || _mode == CloudSyncMode.disabled || _syncHeld) {
      return;
    }

    _setBusy(true);

    try {
      switch (_mode) {
        case CloudSyncMode.oneDrive:
          await microsoftAuthService.connect();
          _message = await _syncOneDrive();
          break;
        case CloudSyncMode.disabled:
          // Should literally never happen :)
          _message = CloudMessage.syncDisabled;
          break;
      }
    } on MicrosoftSignInCanceledException {
      _message = CloudMessage.signInCanceled;
    } catch (_) {
      _message = CloudMessage.syncFailed;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> useLocalVaultForConflict() async {
    final conflict = _pendingConflict;
    if (conflict == null || _isBusy) {
      return;
    }

    _setBusy(true);

    try {
      switch (_mode) {
        case CloudSyncMode.oneDrive:
          await microsoftAuthService.connect();
          await oneDriveVaultStore.uploadText(conflict.localText);
          _message = CloudMessage.uploadedLocalConflict;
          break;
        case CloudSyncMode.disabled:
          // Should again literally never happen :)
          _message = CloudMessage.syncDisabled;
          break;
      }
    } catch (_) {
      _message = CloudMessage.syncFailed;
    } finally {
      _pendingConflict = null;
      await _setSyncHeld(false);
      _setBusy(false);
    }
  }

  Future<void> useCloudVaultForConflict() async {
    final conflict = _pendingConflict;
    if (conflict == null || _isBusy) {
      return;
    }

    _setBusy(true);

    try {
      switch (_mode) {
        case CloudSyncMode.oneDrive:
          await vaultFileStore.saveText(conflict.remoteText);
          _message = CloudMessage.downloadedCloudConflict;
          break;
        case CloudSyncMode.disabled:
          // Should again literally never happen :)
          _message = CloudMessage.syncDisabled;
          break;
      }
    } on MicrosoftSignInCanceledException {
      _message = CloudMessage.signInCanceled;
    } catch (_) {
      _message = CloudMessage.syncFailed;
    } finally {
      _pendingConflict = null;
      await _setSyncHeld(false);
      _setBusy(false);
    }
  }

  Future<void> keepBothVaultsForConflict() async {
    final conflict = _pendingConflict;
    if (conflict == null || _isBusy) {
      return;
    }

    _setBusy(true);

    try {
      await vaultFileStore.saveConflictText(
        conflict.remoteText,
        source: "onedrive",
      );
      _message = CloudMessage.keptBothPaused;
    } catch (error) {
      _message = CloudMessage.saveConflictFailed;
    } finally {
      _pendingConflict = null;
      await _setSyncHeld(true);
      _setBusy(false);
    }
  }

  Future<void> _enableOneDrive() async {
    _setBusy(true);

    try {
      await microsoftAuthService.connect();

      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_modeKey, "oneDrive");
      await preferences.setBool(_syncHeldKey, false);

      _mode = CloudSyncMode.oneDrive;
      _message = await _syncOneDrive();
    } on MicrosoftSignInCanceledException {
      _message = CloudMessage.signInCanceled;
    } catch (_) {
      _message = CloudMessage.syncFailed;
    } finally {
      await _setSyncHeld(false);
      _setBusy(false);
    }
  }

  Future<void> _disable() async {
    _setBusy(true);

    switch (_mode) {
      case CloudSyncMode.oneDrive:
        await microsoftAuthService.signOut();
        break;
      case CloudSyncMode.disabled:
        break;
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_modeKey, "disabled");
    await preferences.setBool(_syncHeldKey, false);

    _mode = CloudSyncMode.disabled;
    _pendingConflict = null;
    _message = CloudMessage.syncDisabled;

    await _setSyncHeld(false);
    _setBusy(false);
  }

  Future<CloudMessage> _syncOneDrive() async {
    final localText = await vaultFileStore.loadTextIfExists();
    final remoteText = await oneDriveVaultStore.downloadText();

    if (localText == null && remoteText == null) {
      return CloudMessage.oneDriveConnectedNoVault;
    }

    if (localText != null && remoteText == null) {
      await oneDriveVaultStore.uploadText(localText);
      return CloudMessage.uploadedLocalConflict;
    }

    if (localText == null && remoteText != null) {
      await vaultFileStore.saveText(remoteText);
      return CloudMessage.downloadedCloudConflict;
    }

    if (localText == remoteText) {
      return CloudMessage.alreadyInSync;
    }

    _pendingConflict = CloudSyncConflict(
      localText: localText!,
      remoteText: remoteText!,
    );

    return CloudMessage.vaultsDiffer;
  }

  void _setBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }

  Future<void> _setSyncHeld(bool value) async {
    _syncHeld = value;

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_syncHeldKey, value);

    notifyListeners();
  }
}
