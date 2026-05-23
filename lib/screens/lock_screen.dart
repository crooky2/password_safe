import 'package:flutter/material.dart';

import '../widgets/screen_frame.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key, required this.onUnlock});

  final VoidCallback onUnlock;

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

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      title: 'App Locked',
      subtitle: 'Enter your password to unlock the app.',
      icon: Icons.lock_rounded,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: TextField(
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
        ),
        FilledButton.icon(
          onPressed: widget.onUnlock,
          icon: const Icon(Icons.lock_open_rounded),
          label: const Text('Unlock'),
        ),
      ],
    );
  }
}