import "package:flutter/material.dart";

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
    final currentPassword = _currentController.text;
    final newPassword = _newController.text;
    final confirmPassword = _confirmController.text;

    if(currentPassword.isEmpty) {
      setState(() {
        _errorMessage = "Enter current password.";
      });
      return;
    }

    if (newPassword.length < 12) {
      setState(() {
        _errorMessage = "Use at least 12 characters.";
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = "Passwords do not match.";
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
    return ScreenPopup(
      title: "Change master password",
      subtitle: "Quick unlock will be disabled after this change.",
      onClose: () {
        Navigator.of(context).pop();
      },
      children: [
        SecretTextField(
          controller: _currentController,
          labelText: "Current password",
        ),
        SecretTextField(
          controller: _newController,
          labelText: "New password",
        ),
        SecretTextField(
          controller: _confirmController,
          labelText: "Confirm new password",
          onSubmitted: (_) => _submit(),
        ),

        if(_errorMessage != null) ...[
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
          label: const Text("Change password"),
        ),
      ]
    );
  }
}