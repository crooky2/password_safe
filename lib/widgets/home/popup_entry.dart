import 'package:flutter/material.dart';

import "../screen_popup.dart";

import "../../vault/password_database.dart";

import "../../l10n/app_localizations.dart";

import "entry_details.dart";

enum EntryDetailsPopupAction { edit, delete, clone }

class EntryDetailsPopup extends StatelessWidget {
  const EntryDetailsPopup({
    super.key,
    required this.entry,
    this.showActions = true,
    this.titlePrefix,
  });

  final PasswordEntry entry;
  final bool showActions;
  final String? titlePrefix;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ScreenPopup(
      title: titlePrefix == null ? entry.title : "$titlePrefix: ${entry.title}",
      onClose: () => Navigator.of(context).pop(),

      children: [
        if (showActions) ...[
          Row(
            children: [
              Expanded(
                child: IconButton.filled(
                  onPressed: () {
                    Navigator.of(context).pop(EntryDetailsPopupAction.edit);
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  tooltip: l10n.edit,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: IconButton.filled(
                  onPressed: () {
                    Navigator.of(context).pop(EntryDetailsPopupAction.clone);
                  },
                  icon: const Icon(Icons.copy_sharp, size: 18),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: IconButton.filled(
                  onPressed: () {
                    Navigator.of(context).pop(EntryDetailsPopupAction.delete);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  icon: const Icon(Icons.delete, size: 18),

                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        EntryDetail(label: l10n.username, value: entry.username),
        EntrySecretDetail(label: l10n.password, value: entry.password),
        EntryDetail(label: l10n.url, value: entry.url),
        EntryDetail(label: l10n.notes, value: entry.notes),
      ],
    );
  }
}