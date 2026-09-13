import 'package:flutter/material.dart';
import "package:flutter/foundation.dart";

import "../theme_controller.dart";

import '../widgets/screen_frame.dart';
import "../widgets/section_card.dart";

import "../auth/auth_controller.dart";
import "../cloud/cloud_controller.dart";

import "settings/security_tab.dart";
import "settings/debug_tab.dart";
import "settings/appearance_tab.dart";
import "../l10n/app_localizations.dart";
import "../widgets/components/popups/reset_data_popup.dart";

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.authController,
    required this.cloudController,
    required this.themeController,
  });

  final AuthController authController;
  final CloudController cloudController;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ScreenFrame(
      title: l10n.settings,
      icon: Icons.settings_rounded,
      headerActions: [
        FilledButton.icon(
          onPressed: () => authController.lock(),
          icon: const Icon(Icons.lock_rounded),
          label: Text(l10n.lockApp),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            foregroundColor: Theme.of(context).colorScheme.onTertiary,
          ),
        ),
      ],
      children: [
        SectionCard(
          title: l10n.appearance,
          icon: Icons.palette_rounded,
          action: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AppearanceTab(themeController: themeController),
              ),
            );
          },
        ),

        SectionCard(
          title: l10n.security,
          icon: Icons.security_rounded,
          action: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SecurityTab(
                  authController: authController,
                  cloudController: cloudController,
                ),
              ),
            );
          },
        ),

        if (kDebugMode)
          SectionCard(
            title: l10n.debug,
            icon: Icons.bug_report_rounded,
            action: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DebugTab(authController: authController),
                ),
              );
            },
          ),

        FilledButton(
          onPressed: () async {
            await showGeneralDialog<void>(
              context: context,
              barrierDismissible: false,
              barrierColor: Colors.transparent,
              pageBuilder: (dialogContext, animation, secondaryAnimation) {
                return ResetDataPopup(
                  onReset: (password) {
                    return authController.resetLocalVault(
                      masterPassword: password,
                      beforeDelete: () async {
                        if (cloudController.isBusy) {
                          throw StateError("Cloud synchronization is running.");
                        }

                        await cloudController.setMode(CloudSyncMode.disabled);

                        if (cloudController.isBusy ||
                            cloudController.mode != CloudSyncMode.disabled) {
                          throw StateError(
                            "Cloud synchronization is still enabled.",
                          );
                        }
                        await cloudController.microsoftAuthService.signOut();
                      },
                    );
                  },
                );
              },
            );
          },
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          child: Text(l10n.resetAppData),
        ),

        Center(
          child: Text(
            'Version 1.2.3+3',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
