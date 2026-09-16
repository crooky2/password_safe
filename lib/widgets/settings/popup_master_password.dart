import "package:flutter/material.dart";

import "../../l10n/app_localizations.dart";
import "../screen_popup.dart";
import "../secret_text_field.dart";

enum _MasterPasswordError { currentPasswordRequired, passwordTooShort, passwordsDoNotMatch }

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

  _MasterPasswordError? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    final currentPassword = _currentController.text;
    final newPassword = _newController.text;
    final confirmPassword = _confirmController.text;

    if (currentPassword.isEmpty) {
      setState(() {
        _error = _MasterPasswordError.currentPasswordRequired;
      });
      return;
    }

    if (newPassword.length < 12) {
      setState(() {
        _error = _MasterPasswordError.passwordTooShort;
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _error = _MasterPasswordError.passwordsDoNotMatch;
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
    final errorMessage = switch (_error) {
      _MasterPasswordError.currentPasswordRequired => l10n.enterCurrentPassword,
      _MasterPasswordError.passwordTooShort => l10n.useAtLeast12Characters,
      _MasterPasswordError.passwordsDoNotMatch => l10n.passwordsDoNotMatch,
      null => null,
    };

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

        if (errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            errorMessage,
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
