import 'package:flutter/material.dart';

import 'app_shell.dart';
import "theme_controller.dart";

import 'screens/lock_screen.dart';
import "screens/setup_screen.dart";

import "auth/auth_controller.dart";

class RootGate extends StatefulWidget {
  const RootGate({
    super.key,
    required this.themeController,
  });

  final ThemeController themeController;

  @override
  State<RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<RootGate> {
  AuthController _authController = AuthController();

  @override
  void initState() {
    super.initState();
    _authController.initialize();
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
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
              )
            )
          ),

          AuthState.locked => Scaffold(
            body: SafeArea(
              child: LockScreen(
                onUnlock: _authController.unlock,
                onUnlockWithPin: _authController.unlockWithPin,
                isQuickUnlockEnabled: _authController.isQuickUnlockEnabled,
                errorMessage: _authController.errorMessage,
              ),
            ),
          ),

          AuthState.unlocked => AppShell(
            authController: _authController,
            themeController: widget.themeController,
          ),
        };
      },
    );
  }
}
