import 'package:flutter/material.dart';

import '../widgets/screen_frame.dart';
import "../widgets/section_card.dart";

import "../auth/auth_controller.dart";

import "../storage/vault_file_store.dart";

import "../vault/password_database.dart";


import "settings/security_tab.dart";

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      title: 'Settings',
      icon: Icons.settings_rounded,
      children: [
        FilledButton(
          onPressed: () async {
            await VaultFileStore().delete();

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Deleted.")));
          },
          child: const Text("Delete vault file"),
        ),

        FilledButton.icon(
          onPressed: authController.lock,
          icon: const Icon(Icons.lock_rounded),
          label: const Text("Lock app"),
        ),
        FilledButton.icon(
          onPressed: () async {
            final database = authController.database;

            if (database == null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("No vault loaded.")));
              return;
            }

            final newEntry = PasswordEntry(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              title: "test entry",
              username: "testuser",
              password: "testpassword",
              notes: "test entry notes",
            );

            final updatedDatabase = database.addEntry(newEntry);

            final success = await authController.saveDatabase(updatedDatabase);

            if (!context.mounted) {
              return;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? 'Saved entries: ${updatedDatabase.entries.length}'
                      : authController.errorMessage ?? 'Save failed.',
                ),
              ),
            );
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text("Add test entry"),
        ),

        SectionCard(
          title: "Security",
          subtitle: "Manage security settings and preferences.",
          icon: Icons.security_rounded,
          children: [
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SecurityTab(authController: authController),
                  ),
                );
              },
              child: const Text("Security"),
            )
          ],
        ),
      ],
    );
  }
}
