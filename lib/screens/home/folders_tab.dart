import "package:flutter/material.dart";

import "../../auth/auth_controller.dart";

import "../../vault/folder_detector.dart";
import "../../vault/password_database.dart";

import "../../widgets/screen_frame.dart";
import "../../widgets/section_card.dart";
import "../../widgets/section_card_lightweight.dart";
import "../../widgets/screen_popup.dart";

import "all_entries_tab.dart";
import "../../l10n/app_localizations.dart";
import "../../l10n/localized_messages.dart";

class FoldersTab extends StatelessWidget {
  const FoldersTab({super.key, required this.authController});

  final AuthController authController;

  Future<void> _createFolder(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final selectedEntryIds = <String>{};
    final entries = authController.database?.entries ?? const <PasswordEntry>[];

    final result = await showGeneralDialog<_FolderFormResult>(
      context: context,
      barrierDismissible: true,
      barrierLabel: l10n.closeFolderForm,
      barrierColor: Colors.transparent,
      pageBuilder: (context, animation, secondaryAnimation) {
        return StatefulBuilder(
          builder: (context, setPopupState) {
            return ScreenPopup(
              title: l10n.newFolder,
              onClose: () {
                Navigator.of(context).pop();
              },
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(labelText: l10n.folderName),
                ),
                const SizedBox(height: 16),

                Text(
                  l10n.entries,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (entries.isEmpty)
                  Text(l10n.noEntriesAvailableToAddToFolder)
                else
                  for (final entry in entries)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: selectedEntryIds.contains(entry.id),
                      title: Text(entry.title),
                      subtitle: entry.username.trim().isEmpty
                          ? null
                          : Text(entry.username),
                      onChanged: (isSelected) {
                        setPopupState(() {
                          if (isSelected == true) {
                            selectedEntryIds.add(entry.id);
                          } else {
                            selectedEntryIds.remove(entry.id);
                          }
                        });
                      },
                    ),

                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop(
                      _FolderFormResult(
                        name: nameController.text.trim(),
                        entryIds: selectedEntryIds.toList(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.create_new_folder_rounded),
                  label: Text(l10n.create),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null || result.name.isEmpty) {
      nameController.dispose();
      return;
    }

    final database = authController.database;
    if (database == null) {
      nameController.dispose();
      return;
    }

    final folder = PasswordFolder(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: result.name,
      entryIds: result.entryIds,
    );

    final success = await authController.saveDatabase(
      database.addFolder(folder),
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? l10n.folderCreated
              : authController.errorMessage == null
              ? l10n.failedToCreateFolder
              : l10n.authFeedback(authController.errorMessage!),
        ),
      ),
    );
    nameController.dispose();
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
        final detectedFolders = detectFolders(entries);

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
                          action: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AllEntriesTab(
                                  authController: authController,
                                  screenTitle: folder.name,
                                  entryIds: folder.entryIds,
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

class _FolderFormResult {
  const _FolderFormResult({required this.name, required this.entryIds});

  final String name;
  final List<String> entryIds;
}
