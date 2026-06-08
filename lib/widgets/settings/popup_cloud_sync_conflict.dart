import "package:flutter/material.dart";

import "../../l10n/app_localizations.dart";
import "../screen_popup.dart";

class CloudSyncConflictPopup extends StatelessWidget {
  const CloudSyncConflictPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ScreenPopup(
      title: l10n.cloudSyncConflict,
      subtitle: l10n.cloudConflictSubtitle,
      onClose: () {
        Navigator.of(context).pop();
      },
      children: [
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: Text("Resolve"),
        ),
      ],
    );
  }
}
