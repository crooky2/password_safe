import "package:flutter/material.dart";

import "../../cloud/cloud_diff.dart";
import "../../l10n/app_localizations.dart";

import "../section_card.dart";
import "changed_fields.dart";

class CloudDiffGroup extends StatelessWidget {
  const CloudDiffGroup({
    super.key,
    required this.title,
    required this.entries,
    required this.choices,
    required this.onChoiceChanged,
    required this.onOpenDetails,
  });

  final String title;
  final List<CloudEntryDiff> entries;
  final Map<String, CloudEntryChoice> choices;
  final void Function(String entryId, CloudEntryChoice choice) onChoiceChanged;
  final void Function(CloudEntryDiff diff) onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        const SizedBox(height: 8),
        for (final diff in entries)
          _CloudDiffRow(
            diff: diff,
            l10n: l10n,
            selectedChoice: choices[diff.id] ?? CloudEntryChoice.undecided,
            onChoiceChanged: onChoiceChanged,
            onOpenDetails: onOpenDetails,
            changedFieldsBuilder: (context, diff) =>
                CloudChangedFields(diff: diff),
          ),

        const SizedBox(height: 16),
      ],
    );
  }
}

class _CloudDiffRow extends StatelessWidget {
  const _CloudDiffRow({
    required this.diff,
    required this.l10n,
    required this.selectedChoice,
    required this.onChoiceChanged,
    required this.onOpenDetails,
    required this.changedFieldsBuilder,
  });

  final CloudEntryDiff diff;
  final AppLocalizations l10n;
  final CloudEntryChoice selectedChoice;
  final void Function(String entryId, CloudEntryChoice choice) onChoiceChanged;
  final void Function(CloudEntryDiff diff) onOpenDetails;
  final Widget Function(BuildContext context, CloudEntryDiff diff)
  changedFieldsBuilder;

  String _localChoiceLabel() {
    return switch (diff.type) {
      CloudEntryDiffType.onlyLocal => l10n.cloudUploadToCloud,
      CloudEntryDiffType.onlyCloud => l10n.cloudDeleteCloud,
      CloudEntryDiffType.changed => l10n.cloudKeepLocal,
    };
  }

  String _cloudChoiceLabel() {
    return switch (diff.type) {
      CloudEntryDiffType.onlyLocal => l10n.cloudDeleteLocal,
      CloudEntryDiffType.onlyCloud => l10n.cloudImport,
      CloudEntryDiffType.changed => l10n.cloudUseCloud,
    };
  }

  IconData _localChoiceIcon() {
    return switch (diff.type) {
      CloudEntryDiffType.onlyLocal => Icons.cloud_upload_rounded,
      CloudEntryDiffType.onlyCloud => Icons.delete_outline_rounded,
      CloudEntryDiffType.changed => Icons.phone_android_rounded,
    };
  }

  IconData _cloudChoiceIcon() {
    return switch (diff.type) {
      CloudEntryDiffType.onlyLocal => Icons.delete_outline_rounded,
      CloudEntryDiffType.onlyCloud => Icons.cloud_download_rounded,
      CloudEntryDiffType.changed => Icons.cloud_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: diff.title,
      action: () {
        onOpenDetails(diff);
      },
      subtitle: switch (diff.type) {
        CloudEntryDiffType.onlyLocal => l10n.cloudOnlyLocalDescription,
        CloudEntryDiffType.onlyCloud => l10n.cloudOnlyCloudDescription,
        CloudEntryDiffType.changed => cloudChangedFieldsSummary(l10n, diff),
      },
      icon: switch (diff.type) {
        CloudEntryDiffType.onlyLocal => Icons.upload_rounded,
        CloudEntryDiffType.onlyCloud => Icons.download_rounded,
        CloudEntryDiffType.changed => Icons.compare_arrows_rounded,
      },
      borderColor: switch (diff.type) {
        CloudEntryDiffType.onlyLocal => Colors.green.shade700,
        CloudEntryDiffType.onlyCloud => Colors.blue.shade700,
        CloudEntryDiffType.changed => Theme.of(context).colorScheme.error,
      },
      children: [
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<CloudEntryChoice>(
            emptySelectionAllowed: true,
            segments: [
              ButtonSegment(
                value: CloudEntryChoice.keepLocal,
                icon: Icon(_localChoiceIcon()),
                label: Text(_localChoiceLabel()),
              ),
              ButtonSegment(
                value: CloudEntryChoice.useCloud,
                icon: Icon(_cloudChoiceIcon()),
                label: Text(_cloudChoiceLabel()),
              ),
            ],
            selected: selectedChoice == CloudEntryChoice.undecided
                ? const <CloudEntryChoice>{}
                : {selectedChoice},
            onSelectionChanged: (selected) {
              final choice = selected.isEmpty
                  ? CloudEntryChoice.undecided
                  : selected.first;

              onChoiceChanged(diff.id, choice);
            },
          ),
        ),
      ],
    );
  }
}
