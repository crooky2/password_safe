import "package:flutter/material.dart";

import "../widgets/screen_frame.dart";
import "../widgets/secret_text_field.dart";

class SetupScreen extends StatefulWidget {
  const SetupScreen({
    super.key,
    required this.onCreateVault,
    this.errorMessage,
  });

  final Future<bool> Function(String password) onCreateVault;
  final String? errorMessage;

  @override
  State<SetupScreen> createState() => _SetupVaultScreenState();
}

class _SetupVaultScreenState extends State<SetupScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  String? _localError;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    setState(() {
      _localError = null;
    });

    if (password.length < 12) {
      setState(() {
        _localError = 'Use at least 12 characters.';
      });
      return;
    }

    if (password != confirm) {
      setState(() {
        _localError = 'Passwords do not match.';
      });
      return;
    }

    final success = await widget.onCreateVault(password);

    if (!mounted) {
      return;
    }

    if (!success) {
      _passwordController.clear();
      _confirmController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final errorMessage = _localError ?? widget.errorMessage;

    return ScreenFrame(
      title: "Setup Vault",
      icon: Icons.security_rounded,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SecretTextField(
            controller: _passwordController,
            labelText: "Master password",
            hintText: "At least 12 characters",
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SecretTextField(
            controller: _confirmController,
            labelText: "Confirm password",
            onSubmitted: (_) => _submit(),
          ),
        ),

        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              errorMessage,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),

        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.lock_rounded),
          label: const Text("Create Vault"),
        )
      ],
    );
  }
}
