import "dart:async";

import 'package:flutter/material.dart';
import "package:flutter/foundation.dart";

import 'app_shell.dart';
import "theme_controller.dart";
import "l10n/app_localizations.dart";

import 'screens/lock_screen.dart';
import "screens/setup_screen.dart";
import "screens/cloud_screen.dart";

import "auth/auth_controller.dart";

import "cloud/cloud_controller.dart";

import "widgets/settings/popup_cloud_sync_conflict.dart";

class RootGate extends StatefulWidget {
  const RootGate({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  State<RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<RootGate> with WidgetsBindingObserver {
  late final AuthController _authController;
  final CloudController _cloudController = CloudController();

  bool _isShowingCloudConflict = false;

  bool get _canShowCloudConflictPopup {
    return mounted &&
        !_isShowingCloudConflict &&
        !_cloudController.isBusy &&
        _authController.state == AuthState.unlocked &&
        _cloudController.hasPendingConflict;
  }

  void _handleCloudConflictMaybeChanged() {
    if (!_canShowCloudConflictPopup) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_canShowCloudConflictPopup) {
        return;
      }

      _showConflictPopup();
    });
  }

  Future<void> _showConflictPopup() async {
    _isShowingCloudConflict = true;

    final l10n = AppLocalizations.of(context)!;

    bool? shouldResolve;

    try {
      shouldResolve = await showGeneralDialog<bool>(
        context: context,
        barrierDismissible: false,
        barrierLabel: l10n.closeCloudSyncConflict,
        pageBuilder: (context, animation, secondaryAnimation) {
          return const CloudSyncConflictPopup();
        },
      );
    } finally {
      if (mounted) {
        _isShowingCloudConflict = false;
      }
    }

    if (!mounted ||
        shouldResolve != true ||
        _authController.state != AuthState.unlocked ||
        !_cloudController.hasPendingConflict) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CloudScreen(
          authController: _authController,
          cloudController: _cloudController,
        ),
      ),
    );
  }

  void _syncSavedDatabaseIfSafe() {
    if (!_cloudController.canAutoSyncLocalChange) {
      _handleCloudConflictMaybeChanged();
      return;
    }

    unawaited(_cloudController.syncLocalChange());
  }

  @override
  void initState() {
    super.initState();

    _authController = AuthController(onDatabaseSaved: _syncSavedDatabaseIfSafe);

    WidgetsBinding.instance.addObserver(this);

    _authController.addListener(_handleCloudConflictMaybeChanged);
    _cloudController.addListener(_handleCloudConflictMaybeChanged);

    _authController.initialize();
    _cloudController.initialize();
  }

  @override
  void dispose() {
    _authController.removeListener(_handleCloudConflictMaybeChanged);
    _cloudController.removeListener(_handleCloudConflictMaybeChanged);

    _authController.dispose();
    _cloudController.dispose();

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final isNativeAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

    if (isNativeAndroid && state != AppLifecycleState.detached) {
      return;
    }

    final shouldLock = state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached;

    if (shouldLock && _authController.state == AuthState.unlocked) {
      _authController.lock();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _authController,

      builder: (context, _) {
        return switch (_authController.state) {
          AuthState.checking || AuthState.busy => Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),

          AuthState.needsSetup => Scaffold(
            body: SafeArea(
              child: SetupScreen(
                onCreateVault: _authController.createVault,
                errorMessage: _authController.errorMessage,
              ),
            ),
          ),

          AuthState.locked => Scaffold(
            body: SafeArea(
              child: LockScreen(
                onUnlock: _authController.unlock,
                onUnlockWithPin: _authController.unlockWithPin,
                onUnlockWithFingerprint: _authController.unlockWithFingerprint,
                isPinUnlockEnabled: _authController.isPinUnlockEnabled,
                isFingerprintUnlockEnabled:
                    _authController.isFingerprintUnlockEnabled,
                refreshUnlockBlock: _authController.refreshUnlockBlock,
                unlockBlockedUntil: _authController.unlockBlockedUntil,
                unlockBlockedRequiresMasterPassword:
                    _authController.unlockBlockedRequiresMasterPassword,
                autoPromptFingerprint:
                    _authController.shouldAutoPromptFingerprint,
                errorMessage: _authController.errorMessage,
              ),
            ),
          ),

          AuthState.unlocked => AppShell(
            authController: _authController,
            cloudController: _cloudController,
            themeController: widget.themeController,
          ),
        };
      },
    );
  }
}
