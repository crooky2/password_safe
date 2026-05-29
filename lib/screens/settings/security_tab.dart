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

enum QuickUnlockSetting { disabled, enabled }

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

  QuickUnlockSetting _pinUnlockSetting = QuickUnlockSetting.disabled;
  QuickUnlockSetting _fingerprintUnlockSetting = QuickUnlockSetting.disabled;

  @override
  void initState() {
    super.initState();
    _loadQuickUnlockMode();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _changePinUnlockSetting(QuickUnlockSetting setting) async {
    final l10n = AppLocalizations.of(context)!;

    if (setting == _pinUnlockSetting) {
      return;
    }

    if (setting == QuickUnlockSetting.disabled) {
      await widget.authController.disableQuickUnlock();

      if (!mounted) {
        return;
      }

      setState(() {
        _pinUnlockSetting = QuickUnlockSetting.disabled;
        _message = null;
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

    if (!mounted || pin == null) {
      return;
    }

    final success = await widget.authController.enableQuickUnlock(pin);

    if (!mounted) {
      return;
    }

    setState(() {
      _pinUnlockSetting = success
          ? QuickUnlockSetting.enabled
          : QuickUnlockSetting.disabled;
      _message = success ? null : _quickUnlockFailureMessage(l10n);
    });
  }

  Future<void> _changeFingerprintUnlockSetting(
    QuickUnlockSetting setting,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    if (setting == _fingerprintUnlockSetting) {
      return;
    }

    if (setting == QuickUnlockSetting.disabled) {
      await widget.authController.disableFingerprintUnlock();

      if (!mounted) {
        return;
      }

      setState(() {
        _fingerprintUnlockSetting = QuickUnlockSetting.disabled;
        _message = null;
      });
      return;
    }

    final success = await widget.authController.enableFingerprintUnlock(
      promptTitle: l10n.confirmDeviceAuthForQuickUnlock,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _fingerprintUnlockSetting = success
          ? QuickUnlockSetting.enabled
          : QuickUnlockSetting.disabled;
      _message = success ? null : _quickUnlockFailureMessage(l10n);
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
      _pinUnlockSetting = QuickUnlockSetting.disabled;
      _fingerprintUnlockSetting = QuickUnlockSetting.disabled;
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
              icon: Icons.lock_open_rounded,
              children: [
                SettingsDropdown<QuickUnlockSetting>(
                  title: l10n.pin,
                  value: _pinUnlockSetting,
                  options: [
                    SettingsDropdownOption(
                      label: l10n.disabled,
                      value: QuickUnlockSetting.disabled,
                    ),
                    SettingsDropdownOption(
                      label: l10n.enabled,
                      value: QuickUnlockSetting.enabled,
                    ),
                  ],
                  onChanged: _changePinUnlockSetting,
                ),
                const SizedBox(height: 12),
                SettingsDropdown<QuickUnlockSetting>(
                  title: l10n.fingerprint,
                  value: _fingerprintUnlockSetting,
                  options: [
                    SettingsDropdownOption(
                      label: l10n.disabled,
                      value: QuickUnlockSetting.disabled,
                    ),
                    SettingsDropdownOption(
                      label: l10n.enabled,
                      value: QuickUnlockSetting.enabled,
                    ),
                  ],
                  onChanged: _changeFingerprintUnlockSetting,
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
    final pinEnabled = await widget.authController.isPinUnlockEnabled();
    final fingerprintEnabled = await widget.authController
        .isFingerprintUnlockEnabled();

    if (!mounted) {
      return;
    }

    setState(() {
      _pinUnlockSetting = pinEnabled
          ? QuickUnlockSetting.enabled
          : QuickUnlockSetting.disabled;
      _fingerprintUnlockSetting = fingerprintEnabled
          ? QuickUnlockSetting.enabled
          : QuickUnlockSetting.disabled;
    });
  }

  String _quickUnlockFailureMessage(AppLocalizations l10n) {
    final feedback = widget.authController.errorMessage;

    if (feedback == null) {
      return l10n.failedToEnableQuickUnlock;
    }

    return l10n.authFeedback(feedback);
  }
}
