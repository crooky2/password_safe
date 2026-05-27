import "package:flutter/material.dart";

import "../../widgets/screen_frame.dart";

import "../../auth/auth_controller.dart";

import "../../vault/password_database.dart";

import "../../storage/vault_file_store.dart";

import "../../cloud/microsoft_auth_service.dart";
import "../../cloud/onedrive_vault_store.dart";

class DebugTab extends StatefulWidget {
  const DebugTab({super.key, required this.authController});

  final AuthController authController;

  @override
  State<DebugTab> createState() => _DebugTabState();
}

class _DebugTabState extends State<DebugTab> {
  late final MicrosoftAuthService _microsoftAuth = MicrosoftAuthService();
  late final OneDriveVaultStore _oneDrive = OneDriveVaultStore(
    authService: _microsoftAuth,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ScreenFrame(
          title: "Debug",
          enableReturnButton: true,
          returnButtonAction: () {
            Navigator.of(context).pop();
          },
          children: [
            FilledButton(
              onPressed: () async {
                final database = widget.authController.database;

                if (database == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("No vault loaded.")),
                  );
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

                final success = await widget.authController.saveDatabase(
                  updatedDatabase,
                );

                if (!context.mounted) {
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Saved entries: ${updatedDatabase.entries.length}'
                          : widget.authController.errorMessage ??
                                'Save failed.',
                    ),
                  ),
                );
              },
              child: const Text("Add test entry"),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  await _microsoftAuth.connect();

                  final info = await _oneDrive.getInfo();

                  if (!context.mounted) {
                    return;
                  }

                  if (info == null) {
                    final localVaultText = await VaultFileStore().loadTextIfExists();

                    if (!context.mounted) {
                      return;
                    }

                    if (localVaultText == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "No local vault and no OneDrive vault found.",
                          ),
                        ),
                      );
                      return;
                    }

                    final uploadedInfo = await _oneDrive.uploadText(
                      localVaultText,
                    );

                    if (!context.mounted) {
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Uploaded vault to OneDrive: ${uploadedInfo.eTag}",
                        ),
                      ),
                    );
                    return;
                  }
                } on MicrosoftSignInCanceledException {
                  if (!context.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Microsoft sign-in canceled."),
                    ),
                  );
                } catch (error) {
                  if (!context.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error during OneDrive sync: $error"),
                    ),
                  );
                }
              },
              child: const Text("Test OneDrive sync"),
            ),
            FilledButton(
              onPressed: () async {
                await _microsoftAuth.signOut();
                if (!context.mounted) {
                  return;
                }
                await _microsoftAuth.connect();
              },
              child: const Text("Test Microsoft sign-out and re-sign-in"),
            )
          ],
        ),
      ),
    );
  }
}
