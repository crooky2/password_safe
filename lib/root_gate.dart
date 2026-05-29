import 'package:flutter/material.dart';

import 'app_shell.dart';
import "theme_controller.dart";
import "l10n/app_localizations.dart";

import 'screens/lock_screen.dart';
import "screens/setup_screen.dart";

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
  final AuthController _authController = AuthController();
  final CloudController _cloudController = CloudController();

  bool _isShowingCloudConflict = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _cloudController.addListener(_handleCloudControllerChanged);

    _authController.initialize();
    _cloudController.initialize();
  }

  @override
  void dispose() {
    _cloudController.removeListener(_handleCloudControllerChanged);
    _authController.dispose();
    _cloudController.dispose();

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      if (_authController.state == AuthState.unlocked) {
        _authController.lock();
      }
    }
  }

  void _handleCloudControllerChanged() {
    if (_isShowingCloudConflict || !_cloudController.hasPendingConflict) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted ||
          _isShowingCloudConflict ||
          !_cloudController.hasPendingConflict) {
        return;
      }

      _isShowingCloudConflict = true;
      final l10n = AppLocalizations.of(context)!;

      final choice = await showGeneralDialog<CloudConflictChoice>(
        context: context,
        barrierDismissible: false,
        barrierLabel: l10n.closeCloudSyncConflict,
        pageBuilder: (context, animation, secondaryAnimation) {
          return const CloudSyncConflictPopup();
        },
      );

      if (!mounted) {
        _isShowingCloudConflict = false;
        return;
      }

      switch (choice) {
        case CloudConflictChoice.useLocal:
          await _cloudController.useLocalVaultForConflict();
          break;
        case CloudConflictChoice.useCloud:
          await _cloudController.useCloudVaultForConflict();
          _authController.lock();
          break;
        case CloudConflictChoice.keepBoth:
          // Treat dismissing the dialog as choosing the local version, to avoid data loss.
          await _cloudController.keepBothVaultsForConflict();
          break;
        case null:
          break;
      }

      _isShowingCloudConflict = false;
    });
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
