import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "../../l10n/app_localizations.dart";
import "../screen_popup.dart";
import "../secret_text_field.dart";

class PinSetupPopup extends StatefulWidget {
  const PinSetupPopup({
    super.key,
    // required this.onSubmit,
  });

  // final Future<bool> Function(String pin) onSubmit;

  @override
  State<PinSetupPopup> createState() => _PinSetupPopupState();
}

class _PinSetupPopupState extends State<PinSetupPopup> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = AppLocalizations.of(context)!;
    final pin = _pinController.text;
    final confirm = _confirmController.text;

    if (pin.length < 4) {
      setState(() {
        _errorMessage = l10n.useAtLeast4Characters;
      });
      return;
    }

    if (pin != confirm) {
      setState(() {
        _errorMessage = l10n.pinsDoNotMatch;
      });
      return;
    }

    Navigator.of(context).pop(pin);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ScreenPopup(
      title: l10n.setPin,
      onClose: () {
        Navigator.of(context).pop();
      },

      children: [
        SecretTextField(
          controller: _pinController,
          labelText: l10n.pin,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          enableBorder: false,
        ),
        const SizedBox(height: 12),
        SecretTextField(
          controller: _confirmController,
          labelText: l10n.confirmPin,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          enableBorder: false,
          onSubmitted: (_) => _submit(),
        ),

        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],

        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.lock_rounded),
          label: Text(l10n.enablePin),
        ),
      ],
    );
  }
}
