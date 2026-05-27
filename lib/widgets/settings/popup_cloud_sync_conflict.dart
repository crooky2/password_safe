import "package:flutter/material.dart";

import "../screen_popup.dart";

enum CloudConflictChoice {
  useLocal,
  useCloud,
  keepBoth,
}

class CloudSyncConflictPopup extends StatelessWidget {
  const CloudSyncConflictPopup({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return ScreenPopup(
      title: "Cloud sync conflict",
      subtitle: "The vault file on this Device differs from the one in the cloud.",
      onClose: () {
        Navigator.of(context).pop();
      },
      children: [
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).pop(CloudConflictChoice.useLocal);
          },
          icon: const Icon(Icons.phone_rounded),
          label: const Text("Use this device's version"),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).pop(CloudConflictChoice.useCloud);
          },
          icon: const Icon(Icons.cloud_rounded),
          label: const Text("Use cloud version"),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).pop(CloudConflictChoice.keepBoth);
          },
          icon: const Icon(Icons.content_copy_rounded),
          label: const Text("Keep both versions"),
        ),
      ]
    );
  }
}