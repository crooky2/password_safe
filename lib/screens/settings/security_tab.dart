import "package:flutter/material.dart";

import "../../widgets/screen_frame.dart";
import "../../widgets/section_card.dart";
import "../../widgets/settings/settings_dropdown.dart";
import "../../widgets/settings/popup_pin_setup.dart";
import "../../widgets/settings/popup_master_password.dart";

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
      },
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
      _message = success ? null : "Failed to enable quick unlock.";
    });
  }

  Future<void> _changeMasterPassword() async {
    final change = await showGeneralDialog<MasterPasswordChange>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close master password change",
      barrierColor: Colors.transparent,
      pageBuilder: (context, animation, secondaryAnimation) {
        return const MasterPasswordPopup();
      },
    );

    if (!mounted || change == null) {
      return;
    }

    final success = await widget.authController.changeMasterPassword(
      currentPassword: change.currentPassword,
      newPassword: change.newPassword,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _quickUnlockMode = QuickUnlockMode.disabled;
      _message = success
          ? "Master password changed successfully. Quick unlock has been disabled."
          : "Failed to change master password. Current password may be incorrect or vault file may be damaged.";
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
            if (_message != null) ...[
              const SizedBox(height: 12),
              Text(
                _message!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],

            SectionCard(
              title: "Quick unlock",
              subtitle: "Use quick unlock for faster access.",
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
              ],
            ),

            SectionCard(
              title: "Master password",
              subtitle: "Change your master password.",
              icon: Icons.lock_reset_rounded,
              children: [
                FilledButton.icon(
                  onPressed: _changeMasterPassword,
                  icon: const Icon(Icons.lock_reset_rounded),
                  label: const Text("Change password"),
                ),
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
