import 'package:flutter/material.dart';
import "package:flutter/services.dart";

import '../widgets/screen_frame.dart';
import "../widgets/secret_text_field.dart";

class LockScreen extends StatefulWidget {
  const LockScreen({
    super.key, 
    required this.onUnlock, 
    required this.onUnlockWithPin,
    required this.isQuickUnlockEnabled,
    this.errorMessage
  });

  final Future<bool> Function(String) onUnlock;
  final Future<bool> Function(String) onUnlockWithPin;
  final Future<bool> Function() isQuickUnlockEnabled;
  final String? errorMessage;

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final TextEditingController _passwordController = TextEditingController();

  bool _isCheckingQuickUnlock = true;
  bool _quickUnlockAvailable = false;
  bool _usePinUnlock = false;

  @override
  void initState() {
    super.initState();
    _loadQuickUnlockMode();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _passwordController.text;

    if (password.trim().isEmpty) {
      return;
    }

    final success = _usePinUnlock
        ? await widget.onUnlockWithPin(password)
        : await widget.onUnlock(password);

    if (!mounted) {
      return;
    }

    if (!success) {
      _passwordController.clear();
    }
  }

  Future<void> _loadQuickUnlockMode() async {
    final enabled = await widget.isQuickUnlockEnabled();

    if (!mounted) {
      return;
    }

    setState(() {
      _quickUnlockAvailable = enabled;
      _usePinUnlock = enabled;
      _isCheckingQuickUnlock = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingQuickUnlock) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final unlockLabel = _usePinUnlock ? "PIN" : "Password";
    final unlockHint = _usePinUnlock ? "Enter your PIN" : "Enter your password";

    return ScreenFrame(
      title: 'App Locked',
      subtitle: _usePinUnlock
          ? "Enter your PIN to unlock."
          : "Enter your password to unlock.",
      icon: Icons.lock_rounded,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SecretTextField(
                controller: _passwordController,
                labelText: unlockLabel,
                hintText: unlockHint,
                enableBorder: true,
                keyboardType: _usePinUnlock 
                    ? TextInputType.number 
                    : TextInputType.text,

                inputFormatters: _usePinUnlock 
                    ? [FilteringTextInputFormatter.digitsOnly] 
                    : null,

                onSubmitted: (_) => _submit(),
              ),
              if (widget.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    widget.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.lock_open_rounded),
          label: const Text('Unlock'),
        ),
        
        if (_usePinUnlock)
          TextButton(
            onPressed: () {
              setState(() {
                _usePinUnlock = false;
                _passwordController.clear();
              });
            },
            child: const Text("Use master password"),
          )
        else if (_quickUnlockAvailable)
          TextButton(
            onPressed: () {
              setState(() {
                _usePinUnlock = true;
                _passwordController.clear();
              });
            },
            child: const Text("Use quick unlock"),
          ),
      ],
    );
  }
}
