import "package:flutter/material.dart";

import "../widgets/screen_frame.dart";
import "../widgets/secret_text_field.dart";
import "../auth/auth_controller.dart";
import "../l10n/app_localizations.dart";
import "../l10n/localized_messages.dart";

class SetupScreen extends StatefulWidget {
  const SetupScreen({
    super.key,
    required this.onCreateVault,
    this.errorMessage,
  });

  final Future<bool> Function(String password) onCreateVault;
  final AuthFeedbackMessage? errorMessage;

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
    final l10n = AppLocalizations.of(context)!;
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    setState(() {
      _localError = null;
    });

    if (password.length < 12) {
      setState(() {
        _localError = l10n.useAtLeast12Characters;
      });
      return;
    }

    if (password != confirm) {
      setState(() {
        _localError = l10n.passwordsDoNotMatch;
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
    final l10n = AppLocalizations.of(context)!;
    final errorMessage =
        _localError ??
        (widget.errorMessage == null
            ? null
            : l10n.authFeedback(widget.errorMessage!));

    return ScreenFrame(
      title: l10n.setupVault,
      icon: Icons.security_rounded,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SecretTextField(
            controller: _passwordController,
            labelText: l10n.masterPassword,
            hintText: l10n.atLeast12Characters,
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SecretTextField(
            controller: _confirmController,
            labelText: l10n.confirmPassword,
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
          label: Text(l10n.createVault),
        ),
      ],
    );
  }
}
