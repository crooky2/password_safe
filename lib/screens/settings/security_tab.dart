import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "../../widgets/screen_frame.dart";
import "../../widgets/section_card.dart";
import "../../widgets/screen_popup.dart";
import "../../widgets/settings/settings_dropdown.dart";
import "../../widgets/settings/pin_setup_popup.dart";

import "../../auth/auth_controller.dart";

enum QuickUnlockMode { disabled, pin }

class SecurityTab extends StatefulWidget {
  const SecurityTab({super.key, required this.authController});

  final AuthController authController;

  @override
  State<SecurityTab> createState() => _SecurityTabState();
}

class _SecurityTabState extends State<SecurityTab> {
  String? _message;

  QuickUnlockMode _quickUnlockMode = QuickUnlockMode.disabled;

  @override
  void initState() {
    super.initState();
    _loadQuickUnlockMode();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _changeQuickUnlockMode(QuickUnlockMode mode) async {
    if (mode == _quickUnlockMode) {
      return;
    }

    if (mode == QuickUnlockMode.disabled) {
      await widget.authController.disableQuickUnlock();

    if (!mounted) {
      return;
    }

    setState(() {
      _quickUnlockMode = QuickUnlockMode.disabled;
    });
    return;
    }

    final pin = await showGeneralDialog<String>(
        context: context,
        barrierDismissible: true,
        barrierLabel: "Close PIN setup",
        barrierColor: Colors.transparent,
        pageBuilder: (context, animation, secondaryAnimation) {
          return const PinSetupPopup();
        }
      );

      if (!mounted) {
        return;
      }
      if (pin == null) {
        return;
      }

      final success = await widget.authController.enableQuickUnlock(pin);
      if (!mounted) {
        return;
      }

      setState(() {
        _quickUnlockMode = success
            ? QuickUnlockMode.pin
            : QuickUnlockMode.disabled;
        _message = success
            ? null
            : "Failed to enable quick unlock.";
      });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ScreenFrame(
          title: "Security",
          enableReturnButton: true,
          returnButtonAction: () {
            Navigator.of(context).pop();
          },
          children: [
            SectionCard(
              title: "Quick unlock",
              subtitle:
                  "Use quick unlock for faster access.",
              icon: Icons.pin_rounded,
              children: [
                SettingsDropdown<QuickUnlockMode>(
                  title: "Type",
                  value: _quickUnlockMode,
                  options: const [
                    SettingsDropdownOption(
                      label: "Disabled",
                      value: QuickUnlockMode.disabled,
                    ),
                    SettingsDropdownOption(
                      label: "PIN",
                      value: QuickUnlockMode.pin,
                    ),
                  ],
                  onChanged: _changeQuickUnlockMode,
                ),
                if (_message != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _message!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadQuickUnlockMode() async {
    final enabled = await widget.authController.isQuickUnlockEnabled();

    if (!mounted) {
      return;
    }

    setState(() {
      _quickUnlockMode = enabled
          ? QuickUnlockMode.pin
          : QuickUnlockMode.disabled;
    });
  }
}
