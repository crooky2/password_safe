import 'package:flutter/material.dart';

import 'screens/lock_screen.dart';
import 'app_shell.dart';

class RootGate extends StatefulWidget {
  const RootGate({super.key});

  @override
  State<RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<RootGate> {
  bool _isUnlocked = false;

  void _unlock() {
    setState(() {
      _isUnlocked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isUnlocked) {
      return Scaffold(
        body: SafeArea(
          child: LockScreen(onUnlock: _unlock),
        ),
      );
    }

    return const AppShell();
  }
}
