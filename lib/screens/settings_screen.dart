import 'package:flutter/material.dart';

import '../widgets/screen_frame.dart';
// import "../widgets/section_card.dart";

import "../crypto/fake_vault_factory.dart";
import "../storage/vault_file_store.dart";

import "../vault/password_database.dart";

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      title: 'Settings',
      subtitle:
          'A simple place for preferences, appearance, and any later configuration options.',
      icon: Icons.settings_rounded,
      children: [
        FilledButton(
          onPressed: () async {
            final store = VaultFileStore();
            final fakeVault = createFakeVaultFile();

            await store.save(fakeVault);

            final loadedVault = await store.load();

            if (!context.mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Loaded vault version ${loadedVault.version}; salt: ${loadedVault.kdf.saltBase64}"),
              ),
            );
          },
          child: const Text("Test vault salting"),
        ),

        FilledButton(
          onPressed: () async {
            final database = PasswordDatabase.sample();
            final text = database.toJsonText();
            final restored = PasswordDatabase.fromJsonText(text);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Entries ${restored.entries.length}, first: ${restored.entries.first.title}"),
              ),
            );
          },
          child: const Text("Test database"),
        ),
      ],
    );
  }
}