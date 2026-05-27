import "package:flutter/material.dart";

import "../../widgets/screen_frame.dart";
import "../../widgets/section_card.dart";
import "../../widgets/settings/settings_dropdown.dart";
import "../../widgets/settings/popup_pin_setup.dart";
import "../../widgets/settings/popup_master_password.dart";


import "../../auth/auth_controller.dart";

import "../../cloud/cloud_controller.dart";


enum QuickUnlockMode { disabled, pin }

class SecurityTab extends StatefulWidget {
  const SecurityTab({
    super.key, 
    required this.authController,
    required this.cloudController,
  });

  final AuthController authController;
  final CloudController cloudController;

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
              subtitle: "Use quick unlock for faster access. This does not replace your master password, is only stored on this device, and your vault remains encrypted with the master password.",
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
              subtitle: "The master password is used to encrypt and decrypt your vault data.",
              icon: Icons.lock_reset_rounded,
              children: [
                FilledButton.icon(
                  onPressed: _changeMasterPassword,
                  icon: const Icon(Icons.lock_reset_rounded),
                  label: const Text("Change password"),
                ),
              ],
            ),

            AnimatedBuilder(
              animation: widget.cloudController,
              builder: (context, _) {
                final cloud = widget.cloudController;

                return SectionCard(
                  title: "Cloud sync",
                  subtitle: "Store an encrypted vault copy in the cloud. You can still access your vault without internet connection, and your data is never shared unencrypted.",
                  icon: Icons.cloud_sync_rounded,
                  children: [
                    SettingsDropdown<CloudSyncMode>(
                      title: "Provider",
                      value: cloud.mode,
                      options: const [
                        SettingsDropdownOption(
                          label: "Disabled",
                          value: CloudSyncMode.disabled,
                        ),
                        SettingsDropdownOption(
                          label: "OneDrive",
                          value: CloudSyncMode.oneDrive,
                        ),
                      ],
                      onChanged: cloud.setMode,
                    ),
                    if (cloud.mode == CloudSyncMode.oneDrive)... [
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: cloud.isBusy ? null : cloud.syncNow,
                        icon: cloud.isBusy 
                            ? const SizedBox(
                              width: 12, height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.sync_rounded),
                        label: Text(cloud.isBusy ? "Syncing..." : "Sync now"),
                      )
                    ],

                    if (cloud.syncHeld) ...[
                      const SizedBox(height: 12),
                      Text(
                        "Cloud sync is paused. Use Sync now after choosing which vault should win.",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ]
                );
              }
            )
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
