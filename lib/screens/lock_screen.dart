import 'package:flutter/material.dart';

import '../widgets/screen_frame.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key, required this.onUnlock, this.errorMessage});

  final Future<bool> Function(String) onUnlock;
  final String? errorMessage;

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final TextEditingController _passwordController = TextEditingController();

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

    final success = await widget.onUnlock(password);

    if (!mounted) {
      return;
    }

    if (!success) {
      _passwordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      title: 'App Locked',
      subtitle: "Enter your password to unlock.",
      icon: Icons.lock_rounded,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelText: 'Password',
                  hintText: 'Enter your password',
                ),
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
      ],
    );
  }
}
