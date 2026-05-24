import 'package:flutter/material.dart';

import '../widgets/screen_frame.dart';
// import "../widgets/section_card.dart";

import "../crypto/fake_vault_factory.dart";
import "../crypto/text_bytes.dart";
import "../crypto/secure_bytes.dart";
import "../crypto/vault_cipher.dart";
import "../crypto/master_key_deriver.dart";
import "../crypto/vault_builder.dart";
import "../crypto/vault_unlocker.dart";

import "../storage/vault_file_store.dart";

import "../vault/password_database.dart";

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      title: 'Settings',
      enableSmallTitle: true,
      icon: Icons.settings_rounded,
      children: [
        FilledButton(
          onPressed: () async {
            final database = PasswordDatabase.sample();
            final plaintext = textToBytes(database.toJsonText());

            final deriver = MasterKeyDeriver();
            final params = deriver.createDefaultParams();
            
            final key = await deriver.deriveKey(
              password: "learning-password-123",
              params: params,
            );

            final cipher = VaultCipher();

            final encrypted = await cipher.encrypt(
              plaintext: plaintext,
              key: key,
            );


            final sameKeyAgain = await deriver.deriveKey(
              password: "learning-password-123",
              params: params,
            );

            final decryptedBytes = await cipher.decrypt(
              blob: encrypted,
              key: sameKeyAgain,
            );

            final restoredText = bytesToText(decryptedBytes);
            final restoredDatabase = PasswordDatabase.fromJsonText(restoredText);

            final message = "Encrypted + restored: ${restoredDatabase.entries.first.title}";

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
              ),
            );
          },
          child: const Text("Test database"),
        ),
        FilledButton(
          onPressed: () async {
            await VaultFileStore().delete();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Deleted."),
              ),
            );
          },
          child: const Text("Delete vault file"),
        )
      ],
    );
  }
}