import "package:flutter/material.dart";

import "../../l10n/app_localizations.dart";

class HomeActionBar extends StatelessWidget {
  const HomeActionBar({super.key, this.onAddEntry, this.onSearch});

  final VoidCallback? onAddEntry;
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: l10n.addEntry,
          onPressed: onAddEntry,
          icon: const Icon(Icons.add_rounded),
        ),
        IconButton(
          tooltip: l10n.searchForEntry,
          onPressed: onSearch,
          icon: const Icon(Icons.search),
        ),
      ],
    );
  }
}
