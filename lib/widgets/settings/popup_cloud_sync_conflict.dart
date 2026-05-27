import "package:flutter/material.dart";

import "../../l10n/app_localizations.dart";
import "../screen_popup.dart";

enum CloudConflictChoice { useLocal, useCloud, keepBoth }

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
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).pop(CloudConflictChoice.useLocal);
          },
          icon: const Icon(Icons.phone_rounded),
          label: Text(l10n.useThisDevicesVersion),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).pop(CloudConflictChoice.useCloud);
          },
          icon: const Icon(Icons.cloud_rounded),
          label: Text(l10n.useCloudVersion),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).pop(CloudConflictChoice.keepBoth);
          },
          icon: const Icon(Icons.content_copy_rounded),
          label: Text(l10n.keepBothVersions),
        ),
      ],
    );
  }
}
