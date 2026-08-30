import "package:flutter/material.dart";
import "package:password_safe/widgets/home/popup_folder_form.dart";

import "../../auth/auth_controller.dart";

import "../../vault/folder_detector.dart";
import "../../vault/password_database.dart";

import "../../widgets/screen_frame.dart";
import "../../widgets/section_card.dart";
import "../../widgets/section_card_lightweight.dart";

import "all_entries_tab.dart";
import "../../l10n/app_localizations.dart";
import "../../l10n/localized_messages.dart";

class FoldersTab extends StatelessWidget {
  const FoldersTab({super.key, required this.authController});

  final AuthController authController;

  Future<void> _createFolder(
    BuildContext context, {
    String initialName = "",
    Set<String> initialEntryIds = const <String>{},
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final database = authController.database;

    if (database == null) {
      return;
    }

    final result = await showFolderFormPopup(
      context,
      entries: database.entries,
      folders: database.folders,
      initialName: initialName,
      initialEntryIds: initialEntryIds,
    );

    if (result == null || !context.mounted) {
      return;
    }

    final latestDatabase = authController.database;

    if (latestDatabase == null) {
      return;
    }

    final folder = PasswordFolder(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: result.name,
      entryIds: result.entryIds.toList(),
    );

    final success = await authController.saveDatabase(
      latestDatabase.addFolder(folder),
    );

    if (!context.mounted) {
      return;
    }

    // TODO: Localization
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? "Folder created." : "Folder creation failed."),
      ),
    );
  }

  Future<void> _editFolder(BuildContext context, PasswordFolder folder) async {
    final l10n = AppLocalizations.of(context)!;
    final database = authController.database;

    if (database == null) {
      return;
    }

    final result = await showFolderFormPopup(
      context,
      entries: database.entries,
      folders: database.folders,
      folder: folder,
    );

    if (result == null || !context.mounted) {
      return;
    }

    final latestDatabase = authController.database;
    final latestFolder = latestDatabase?.folderById(folder.id);

    if (latestDatabase == null || latestFolder == null) {
      return;
    }

    final updatedFolder = latestFolder.copyWith(
      name: result.name,
      entryIds: result.entryIds.toList(),
    );

    final success = await authController.saveDatabase(
      latestDatabase.updateFolder(updatedFolder),
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? "folderUpdated" : "failedToUpdateFolder",
        ), // TODO: Localization
      ),
    );
  }

  Future<void> _deleteFolder(
    BuildContext context,
    PasswordFolder folder,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        //TODO: Localization
        return AlertDialog(
          title: Text("deleteFolder"),
          content: Text("deleteFolderConfirmation${folder.name}"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(dialogContext).colorScheme.error,
              ),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final latestDatabase = authController.database;

    if (latestDatabase == null) {
      return;
    }

    final success = await authController.saveDatabase(
      latestDatabase.removeFolder(folder.id),
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? "folderDeleted"
              : "failedToDeleteFolder", // TODO: Localization
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: authController,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context)!;
        final database = authController.database;
        final entries = database?.entries ?? const <PasswordEntry>[];
        final customFolders = database?.folders ?? const <PasswordFolder>[];
        final detectedFolders = detectFolders(
          entries,
          untitledName: l10n.untitled,
        );

        return Scaffold(
          body: SafeArea(
            child: ScreenFrame(
              title: l10n.folders,
              enableReturnButton: true,
              headerActions: [
                IconButton(
                  tooltip: l10n.createNewFolder,
                  onPressed: () {
                    _createFolder(context);
                  },
                  icon: const Icon(Icons.create_new_folder_rounded),
                ),
              ],
              children: [
                SectionCard(
                  title: l10n.customFolders,
                  icon: Icons.folder_rounded,
                  children: [
                    if (customFolders.isEmpty)
                      Text(l10n.noCustomFoldersYet)
                    else
                      for (final folder in customFolders)
                        SectionCardLightweight(
                          title: folder.name,
                          subtitle: l10n.entryCount(folder.entryIds.length),
                          icon: Icons.folder_rounded,
                          contextMenuItems: [
                            SectionCardMenuItem(
                              label: "editFolder", //TODO: Localization
                              icon: Icons.edit_rounded,
                              onSelected: () {
                                _editFolder(context, folder);
                              },
                            ),
                            SectionCardMenuItem(
                              label: l10n.delete,
                              icon: Icons.delete_rounded,
                              isDestructive: true,
                              onSelected: () {
                                _deleteFolder(context, folder);
                              },
                            ),
                          ],
                          action: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AllEntriesTab(
                                  authController: authController,
                                  screenTitle: folder.name,
                                  folderId: folder.id,
                                  emptyMessage: l10n.thisFolderIsEmpty,
                                ),
                              ),
                            );
                          },
                        ),
                  ],
                ),
                SectionCard(
                  title: l10n.detectedFolders,
                  icon: Icons.auto_awesome_rounded,
                  children: [
                    if (detectedFolders.isEmpty)
                      Text(l10n.noDetectedFoldersYet)
                    else
                      for (final folder in detectedFolders)
                        SectionCardLightweight(
                          title: folder.name,
                          subtitle: l10n.folderSourceInfo(
                            folder.entries.length,
                            l10n.detectedFolderSourceLabel(folder.source),
                          ),
                          icon: Icons.auto_awesome_rounded,
                          contextMenuItems: [
                            SectionCardMenuItem(
                              label: "saveAsCustomFolder", //TODO: Localization,
                              icon: Icons.create_new_folder_rounded,
                              onSelected: () {
                                _createFolder(
                                  context,
                                  initialName: folder.name,
                                  initialEntryIds: folder.entries
                                      .map((entry) => entry.id)
                                      .toSet(),
                                );
                              },
                            ),
                          ],
                          action: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AllEntriesTab(
                                  authController: authController,
                                  screenTitle: folder.name,
                                  entryIds: folder.entries
                                      .map((entry) => entry.id)
                                      .toList(),
                                  emptyMessage: l10n.noEntriesInThisFolder,
                                ),
                              ),
                            );
                          },
                        ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
