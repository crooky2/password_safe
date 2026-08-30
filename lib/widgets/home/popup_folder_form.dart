import "package:flutter/material.dart";

import "../../l10n/app_localizations.dart";
import "../../vault/password_database.dart";

import "../screen_popup.dart";

class FolderFormResult {
  const FolderFormResult({required this.name, required this.entryIds});

  final String name;
  final Set<String> entryIds;
}

Future<FolderFormResult?> showFolderFormPopup(
  BuildContext context, {
  required List<PasswordEntry> entries,
  required List<PasswordFolder> folders,
  PasswordFolder? folder,
  String initialName = "",
  Set<String> initialEntryIds = const <String>{},
}) {
  final l10n = AppLocalizations.of(context)!;

  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: l10n.closeFolderForm,
    barrierColor: Colors.transparent,
    pageBuilder: (context, animation, secondaryAnimation) {
      return FolderFormPopup(
        entries: entries,
        folders: folders,
        folder: folder,
        initialName: initialName,
        initialEntryIds: initialEntryIds,
      );
    },
  );
}

class FolderFormPopup extends StatefulWidget {
  const FolderFormPopup({
    super.key,
    required this.entries,
    required this.folders,
    this.folder,
    this.initialName = "",
    this.initialEntryIds = const <String>{},
  });

  final List<PasswordEntry> entries;
  final List<PasswordFolder> folders;

  final PasswordFolder? folder;

  final String initialName;
  final Set<String> initialEntryIds;

  @override
  State<FolderFormPopup> createState() => _FolderFormPopupState();
}

class _FolderFormPopupState extends State<FolderFormPopup> {
  late final TextEditingController _nameController;
  late Set<String> _selectedEntryIds;

  String? _errorMessage;
  bool get _isEditing => widget.folder != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.folder?.name ?? widget.initialName,
    );
    final validEntryIds = widget.entries.map((entry) => entry.id).toSet();
    final Iterable<String> startingEntryIds =
        widget.folder?.entryIds ?? widget.initialEntryIds;
    _selectedEntryIds = startingEntryIds.where(validEntryIds.contains).toSet();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _errorMessage = "Folder name is required."; // TODO: Localization
      });
      return;
    }

    final normName = name.toLowerCase();

    final nameExists = widget.folders.any((folder) {
      final isEditing = folder.id == widget.folder?.id;
      return !isEditing && folder.name.toLowerCase() == normName;
    });

    if (nameExists) {
      setState(() {
        _errorMessage = "Folder name already exists."; // TODO: Localization
      });
      return;
    }

    Navigator.of(context).pop(
      FolderFormResult(
        name: name,
        entryIds: Set.unmodifiable(_selectedEntryIds),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ScreenPopup(
      title: _isEditing ? "Edit Folder" : "Create Folder",
      onClose: () => Navigator.of(context).pop(),
      children: [
        TextField(
          controller: _nameController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.folderName,
            errorText: _errorMessage,
          ),
          onChanged: (_) {
            if (_errorMessage != null) {
              setState(() {
                _errorMessage = null;
              });
            }
          },
        ),
        const SizedBox(height: 16),

        Text(l10n.entries, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),

        if (widget.entries.isEmpty)
          if (widget.entries.isEmpty)
            Text(l10n.noEntriesAvailableToAddToFolder)
          else
            for (final entry in widget.entries)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _selectedEntryIds.contains(entry.id),
                title: Text(entry.title),
                subtitle: entry.username.trim().isEmpty
                    ? null
                    : Text(entry.username),
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _selectedEntryIds.add(entry.id);
                    } else {
                      _selectedEntryIds.remove(entry.id);
                    }
                  });
                },
              ),

        const SizedBox(height: 16),

        FilledButton.icon(
          onPressed: _submit,
          icon: Icon(
            _isEditing ? Icons.save_rounded : Icons.create_new_folder_rounded,
          ),
          label: Text(_isEditing ? l10n.saveChanges : l10n.create),
        ),
      ],
    );
  }
}
