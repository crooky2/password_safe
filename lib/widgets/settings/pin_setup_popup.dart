import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "../screen_popup.dart ";

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
    final pin = _pinController.text;
    final confirm = _confirmController.text;

    if (pin.length < 4) {
      setState(() {
        _errorMessage = "Use at least 4 characters.";
      });
      return;
    }

    if (pin != confirm) {
      setState(() {
        _errorMessage = "PINs do not match.";
      });
      return;
    }

    Navigator.of(context).pop(pin);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenPopup(
      title: "Set PIN",
      onClose: () {
        Navigator.of(context).pop();
      },

      children: [
        TextField(
          controller: _pinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "PIN"),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _confirmController,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Confirm PIN"),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
          label: const Text("Enable PIN")
        )
      ]
    );
  }
}