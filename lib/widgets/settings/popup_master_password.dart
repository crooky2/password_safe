import "package:flutter/material.dart";

import "../../l10n/app_localizations.dart";
import "../screen_popup.dart";
import "../secret_text_field.dart";

class MasterPasswordChange {
  const MasterPasswordChange({
    required this.currentPassword,
    required this.newPassword,
  });

  final String currentPassword;
  final String newPassword;
}

class MasterPasswordPopup extends StatefulWidget {
  const MasterPasswordPopup({super.key});

  @override
  State<MasterPasswordPopup> createState() => _MasterPasswordPopupState();
}

class _MasterPasswordPopupState extends State<MasterPasswordPopup> {
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  String? _errorMessage;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = AppLocalizations.of(context)!;
    final currentPassword = _currentController.text;
    final newPassword = _newController.text;
    final confirmPassword = _confirmController.text;

    if (currentPassword.isEmpty) {
      setState(() {
        _errorMessage = l10n.enterCurrentPassword;
      });
      return;
    }

    if (newPassword.length < 12) {
      setState(() {
        _errorMessage = l10n.useAtLeast12Characters;
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = l10n.passwordsDoNotMatch;
      });
      return;
    }

    Navigator.of(context).pop(
      MasterPasswordChange(
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ScreenPopup(
      title: l10n.changeMasterPassword,
      subtitle: l10n.quickUnlockDisabledAfterPasswordChange,
      onClose: () {
        Navigator.of(context).pop();
      },
      children: [
        SecretTextField(
          controller: _currentController,
          labelText: l10n.currentPassword,
        ),
        SecretTextField(
          controller: _newController,
          labelText: l10n.newPassword,
        ),
        SecretTextField(
          controller: _confirmController,
          labelText: l10n.confirmNewPassword,
          onSubmitted: (_) => _submit(),
        ),

        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.lock_reset_rounded),
          label: Text(l10n.changePassword),
        ),
      ],
    );
  }
}
