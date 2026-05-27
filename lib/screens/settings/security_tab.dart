import "package:flutter/material.dart";

import "../../widgets/screen_frame.dart";
import "../../widgets/section_card.dart";
import "../../widgets/settings/settings_dropdown.dart";
import "../../widgets/settings/popup_pin_setup.dart";
import "../../widgets/settings/popup_master_password.dart";

import "../../auth/auth_controller.dart";

import "../../cloud/cloud_controller.dart";
import "../../l10n/app_localizations.dart";
import "../../l10n/localized_messages.dart";

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
    final l10n = AppLocalizations.of(context)!;

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
      barrierLabel: l10n.closePinSetup,
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
      _message = success ? null : l10n.failedToEnableQuickUnlock;
    });
  }

  Future<void> _changeMasterPassword() async {
    final l10n = AppLocalizations.of(context)!;

    final change = await showGeneralDialog<MasterPasswordChange>(
      context: context,
      barrierDismissible: true,
      barrierLabel: l10n.closeMasterPasswordChange,
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
          ? l10n.masterPasswordChangedQuickUnlockDisabled
          : l10n.failedToChangeMasterPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ScreenFrame(
          title: l10n.security,
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
              title: l10n.quickUnlock,
              subtitle: l10n.quickUnlockDescription,
              icon: Icons.pin_rounded,
              children: [
                SettingsDropdown<QuickUnlockMode>(
                  title: l10n.type,
                  value: _quickUnlockMode,
                  options: [
                    SettingsDropdownOption(
                      label: l10n.disabled,
                      value: QuickUnlockMode.disabled,
                    ),
                    SettingsDropdownOption(
                      label: l10n.pin,
                      value: QuickUnlockMode.pin,
                    ),
                  ],
                  onChanged: _changeQuickUnlockMode,
                ),
              ],
            ),

            SectionCard(
              title: l10n.masterPassword,
              subtitle: l10n.masterPasswordDescription,
              icon: Icons.lock_reset_rounded,
              children: [
                FilledButton.icon(
                  onPressed: _changeMasterPassword,
                  icon: const Icon(Icons.lock_reset_rounded),
                  label: Text(l10n.changePassword),
                ),
              ],
            ),

            AnimatedBuilder(
              animation: widget.cloudController,
              builder: (context, _) {
                final cloud = widget.cloudController;
                final cloudMessage = cloud.message;

                return SectionCard(
                  title: l10n.cloudSync,
                  subtitle: l10n.cloudSyncDescription,
                  icon: Icons.cloud_sync_rounded,
                  children: [
                    SettingsDropdown<CloudSyncMode>(
                      title: l10n.provider,
                      value: cloud.mode,
                      options: [
                        SettingsDropdownOption(
                          label: l10n.disabled,
                          value: CloudSyncMode.disabled,
                        ),
                        SettingsDropdownOption(
                          label: l10n.oneDrive,
                          value: CloudSyncMode.oneDrive,
                        ),
                      ],
                      onChanged: cloud.setMode,
                    ),
                    if (cloud.mode == CloudSyncMode.oneDrive) ...[
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: cloud.isBusy ? null : cloud.syncNow,
                        icon: cloud.isBusy
                            ? const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.sync_rounded),
                        label: Text(cloud.isBusy ? l10n.syncing : l10n.syncNow),
                      ),
                    ],

                    if (cloudMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        l10n.cloudFeedback(cloudMessage),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],

                    if (cloud.syncHeld) ...[
                      const SizedBox(height: 12),
                      Text(
                        l10n.cloudSyncPausedResolve,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                );
              },
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
