import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "../../widgets/screen_frame.dart";
import "../../widgets/section_card.dart";

import "../../auth/auth_controller.dart";

class SecurityTab extends StatefulWidget {
  const SecurityTab({super.key, required this.authController});

  final AuthController authController;

  @override
  State<SecurityTab> createState() => _SecurityTabState();
}

class _SecurityTabState extends State<SecurityTab> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _isSaving = false;
  String? _message;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _enableQuickUnlock() async {
    final pin = _pinController.text;
    final confirm = _confirmController.text;

    if (pin != confirm) {
      setState(() {
        _message = "PINs do not match.";
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _message = null;
    });

    final success = await widget.authController.enableQuickUnlock(pin);

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
      _message = success
          ? "Quick unlock enabled."
          : widget.authController.errorMessage ??
                "Failed to enable quick unlock.";
    });

    if (success) {
      _pinController.clear();
      _confirmController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ScreenFrame(
          title: "Security",
          icon: Icons.security_rounded,
          enableReturnButton: true,
          returnButtonAction: () {
            Navigator.of(context).pop();
          },
          children: [
            SectionCard(
              title: "PIN quick unlock",
              subtitle:
                  "Use an at least 4 digit PIN to unlock this device. Your master password is still required on new devices.",
              icon: Icons.pin_rounded,
              children: [
                TextField(
                  controller: _pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: "PIN",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: "Confirm PIN",
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _enableQuickUnlock(),
                ),

                if (_message != null) ...[
                  const SizedBox(height: 12),
                  Text(_message!),
                ],

                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _enableQuickUnlock,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.lock_rounded),
                  label: Text(_isSaving ? "Saving..." : "Enable PIN"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
