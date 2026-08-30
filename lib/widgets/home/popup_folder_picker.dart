import "package:flutter/material.dart";

import "../../l10n/app_localizations.dart";
import "../../vault/password_database.dart";

import "../screen_popup.dart";

Future<Set<String>?> showFolderPickerPopup(
  BuildContext context, {
  required List<PasswordFolder> folders,
  required Set<String> initiallySelectedFolderIds,
}) {
  final l10n = AppLocalizations.of(context)!;

  return showGeneralDialog<Set<String>>(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Folders", // TODO: Localization
    barrierColor: Colors.transparent,
    pageBuilder: (context, animation, secondaryAnimation) {
      return FolderPickerPopup(
        folders: folders,
        initiallySelectedFolderIds: initiallySelectedFolderIds,
      );
    },
  );
}

class FolderPickerPopup extends StatefulWidget {
  const FolderPickerPopup({
    super.key,
    required this.folders,
    required this.initiallySelectedFolderIds,
  });

  final List<PasswordFolder> folders;
  final Set<String> initiallySelectedFolderIds;

  @override
  State<FolderPickerPopup> createState() => _FolderPickerPopupState();
}

class _FolderPickerPopupState extends State<FolderPickerPopup> {
  late Set<String> _selectedFolderIds;
  String _query = "";

  @override
  void initState() {
    super.initState();

    final validFolderIds = widget.folders.map((folder) => folder.id).toSet();

    _selectedFolderIds = widget.initiallySelectedFolderIds.intersection(
      validFolderIds,
    );
  }

  void _finish() {
    Navigator.of(context).pop(_selectedFolderIds);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final query = _query.trim().toLowerCase();

    final visibleFolders = widget.folders.where((folder) {
      return query.isEmpty || folder.name.toLowerCase().contains(query);
    }).toList();

    return ScreenPopup(
      title: "Select Folders", // TODO: Localization
      onClose: () => Navigator.of(context).pop(),
      children: [
        if (widget.folders.isNotEmpty) ...[
          TextField(
            decoration: InputDecoration(
              labelText: "searchFolders", // TODO: Localization
              prefixIcon: const Icon(Icons.search_rounded),
            ),
            onChanged: (value) {
              setState(() {
                _query = value;
              });
            },
          ),
          const SizedBox(height: 12),
        ],

        if (widget.folders.isEmpty)
          Text("noCustomFoldersYet") // TODO: Localization
        else if (visibleFolders.isEmpty)
          Text("noFoldersMatchSearch") // TODO: Localization
        else
          for (final folder in visibleFolders)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.folder_rounded),
              value: _selectedFolderIds.contains(folder.id),
              title: Text(folder.name),
              subtitle: Text(l10n.entryCount(folder.entryIds.length)),
              onChanged: (selected) {
                setState(() {
                  if (selected == true) {
                    _selectedFolderIds.add(folder.id);
                  } else {
                    _selectedFolderIds.remove(folder.id);
                  }
                });
              },
            ),

        const SizedBox(height: 16),

        Row(
          children: [
            TextButton(
              onPressed: _selectedFolderIds.isEmpty
                  ? null
                  : () {
                      setState(() {
                        _selectedFolderIds.clear();
                      });
                    },
              child: Text("clearSelection"), // TODO: Localization
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: _finish,
              icon: const Icon(Icons.done_rounded),
              label: Text("done"), // TODO: Localization
            ),
          ],
        ),
      ],
    );
  }
}
