import "package:flutter/material.dart";

import "../../auth/auth_controller.dart";

import "../../vault/folder_detector.dart";
import "../../vault/password_database.dart";

import "../../widgets/screen_frame.dart";
import "../../widgets/section_card.dart";
import "../../widgets/section_card_lightweight.dart";
import "../../widgets/screen_popup.dart";

import "all_entries_tab.dart";

class FoldersTab extends StatelessWidget {
  const FoldersTab({super.key, required this.authController});

  final AuthController authController;

  Future<void> _createFolder(BuildContext context) async {
    final nameController = TextEditingController();
    final selectedEntryIds = <String>{};
    final entries = authController.database?.entries ?? const <PasswordEntry>[];

    final result = await showGeneralDialog<_FolderFormResult>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close folder form",
      barrierColor: Colors.transparent,
      pageBuilder: (context, animation, secondaryAnimation) {
        return StatefulBuilder(
          builder: (context, setPopupState) {
            return ScreenPopup(
              title: "New folder",
              onClose: () {
                Navigator.of(context).pop();
              },
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: "Folder name"),
                ),
                const SizedBox(height: 16),

                Text("Entries", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (entries.isEmpty)
                  const Text("No entries available to add to folder.")
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
                  label: const Text("Create"),
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
              ? "Folder created."
              : authController.errorMessage ?? "Failed to create folder.",
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
        final database = authController.database;
        final entries = database?.entries ?? const <PasswordEntry>[];
        final customFolders = database?.folders ?? const <PasswordFolder>[];
        final detectedFolders = detectFolders(entries);

        return Scaffold(
          body: SafeArea(
            child: ScreenFrame(
              title: "Folders",
              enableReturnButton: true,
              headerActions: [
                IconButton(
                  tooltip: "Create new folder",
                  onPressed: () {
                    _createFolder(context);
                  },
                  icon: const Icon(Icons.create_new_folder_rounded),
                ),
              ],
              children: [
                SectionCard(
                  title: "Custom",
                  icon: Icons.folder_rounded,
                  children: [
                    if (customFolders.isEmpty)
                      const Text("No custom folders yet.")
                    else
                      for (final folder in customFolders)
                        SectionCardLightweight(
                          title: folder.name,
                          subtitle: "${folder.entryIds.length} entries",
                          icon: Icons.folder_rounded,
                          action: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AllEntriesTab(
                                  authController: authController,
                                  screenTitle: folder.name,
                                  entryIds: folder.entryIds,
                                  emptyMessage: "This folder is empty.",
                                ),
                              ),
                            );
                          },
                        ),
                  ],
                ),
                SectionCard(
                  title: "Detected",
                  icon: Icons.auto_awesome_rounded,
                  children: [
                    if (detectedFolders.isEmpty)
                      const Text("No detected folders yet.")
                    else
                      for (final folder in detectedFolders)
                        SectionCardLightweight(
                          title: folder.name,
                          subtitle:
                              "${folder.entries.length} entries - ${folder.source}",
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
                                  emptyMessage: "No entries in this folder.",
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
