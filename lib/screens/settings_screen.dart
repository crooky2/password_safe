import 'package:flutter/material.dart';

import "../theme_controller.dart";

import '../widgets/screen_frame.dart';
import "../widgets/section_card.dart";

import "../auth/auth_controller.dart";

import "../storage/vault_file_store.dart";

import "settings/security_tab.dart";
import "settings/debug_tab.dart";
import "settings/appearance.dart";

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key, 
    required this.authController,
    required this.themeController,
  });

  final AuthController authController;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      title: 'Settings',
      icon: Icons.settings_rounded,
      headerActions: [
        FilledButton.icon(
          onPressed: authController.lock,
          icon: const Icon(Icons.lock_rounded),
          label: const Text("Lock app"),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            foregroundColor: Theme.of(context).colorScheme.onTertiary,
          ),
        ),
      ],
      children: [
        SectionCard(
          title: "Appearance",
          icon: Icons.palette_rounded,
          action: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AppearanceTab(
                  themeController: themeController,
                ),
              ),
            );
          },
        ),

        SectionCard(
          title: "Security",
          icon: Icons.security_rounded,
          action: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SecurityTab(authController: authController),
              ),
            );
          },
        ),

        SectionCard(
          title: "Debug",
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
            await VaultFileStore().delete();

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Reset app data.")));
          },
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          child: const Text("Reset App Data"),
        ),
      ],
    );
  }
}
