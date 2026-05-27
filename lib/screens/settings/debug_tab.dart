import "package:flutter/material.dart";

import "../../widgets/screen_frame.dart";

import "../../auth/auth_controller.dart";

import "../../vault/password_database.dart";

import "../../storage/vault_file_store.dart";

import "../../cloud/microsoft_auth_service.dart";
import "../../cloud/onedrive_vault_store.dart";
import "../../l10n/app_localizations.dart";
import "../../l10n/localized_messages.dart";

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ScreenFrame(
          title: l10n.debug,
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
                    SnackBar(content: Text(l10n.debugNoVaultLoaded)),
                  );
                  return;
                }

                final newEntry = PasswordEntry(
                  id: DateTime.now().microsecondsSinceEpoch.toString(),
                  title: l10n.debugTestEntryTitle,
                  username: l10n.debugTestEntryUsername,
                  password: l10n.debugTestEntryPassword,
                  notes: l10n.debugTestEntryNotes,
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
                          ? l10n.debugSavedEntries(
                              updatedDatabase.entries.length,
                            )
                          : widget.authController.errorMessage == null
                          ? l10n.debugSaveFailed
                          : l10n.authFeedback(
                              widget.authController.errorMessage!,
                            ),
                    ),
                  ),
                );
              },
              child: Text(l10n.debugAddTestEntry),
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
                    final localVaultText = await VaultFileStore()
                        .loadTextIfExists();

                    if (!context.mounted) {
                      return;
                    }

                    if (localVaultText == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            l10n.debugNoLocalVaultAndNoOneDriveVault,
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
                          l10n.debugUploadedVaultToOneDrive(uploadedInfo.eTag),
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
                    SnackBar(content: Text(l10n.cloudMessageSignInCanceled)),
                  );
                } catch (error) {
                  if (!context.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.debugErrorDuringOneDriveSync(error.toString()),
                      ),
                    ),
                  );
                }
              },
              child: Text(l10n.debugTestOneDriveSync),
            ),
            FilledButton(
              onPressed: () async {
                await _microsoftAuth.signOut();
                if (!context.mounted) {
                  return;
                }
                await _microsoftAuth.connect();
              },
              child: Text(l10n.debugTestMicrosoftSignOutAndReSignIn),
            ),
          ],
        ),
      ),
    );
  }
}
