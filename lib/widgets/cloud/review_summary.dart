import "package:flutter/material.dart";

import "../../cloud/cloud_diff.dart";
import "../../l10n/app_localizations.dart";

import "../section_card.dart";

class CloudReviewSummary extends StatelessWidget {
  const CloudReviewSummary({
    super.key,
    required this.diff,
    required this.selectionCount,
    required this.isApplying,
    required this.onApply,
    required this.onSelectAll,
  });

  final CloudDatabaseDiff diff;
  final int selectionCount;
  final bool isApplying;
  final VoidCallback onApply;
  final ValueChanged<CloudEntryChoice> onSelectAll;

  int get _totalCount {
    return diff.onlyLocal.length + diff.onlyCloud.length + diff.changed.length;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final undecidedCount = _totalCount - selectionCount;

    return SectionCard(
      title: l10n.cloudReviewChanges,
      subtitle: undecidedCount == 0
          ? l10n.cloudAllChangesReviewed
          : l10n.cloudReviewDifferenceCount(undecidedCount, _totalCount),
      icon: Icons.rule_rounded,
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: isApplying || undecidedCount > 0 ? null : onApply,
            icon: isApplying
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.done_all_rounded),
            label: Text(
              isApplying ? l10n.cloudApplyingChanges : l10n.cloudApplyChanges,
            ),
          ),
        ),

        const SizedBox(height: 16),
        Text(l10n.cloudSelectForAll),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<CloudEntryChoice>(
            emptySelectionAllowed: true,
            segments: [
              ButtonSegment(
                value: CloudEntryChoice.keepLocal,
                icon: Icon(Icons.phone_android_rounded),
                label: Text(l10n.cloudKeepLocal),
              ),
              ButtonSegment(
                value: CloudEntryChoice.useCloud,
                icon: Icon(Icons.cloud_rounded),
                label: Text(l10n.cloudKeepCloud),
              ),
            ],
            selected: const <CloudEntryChoice>{},
            onSelectionChanged: isApplying || _totalCount == 0
                ? null
                : (selected) {
                    if (selected.isEmpty) {
                      return;
                    }

                    onSelectAll(selected.first);
                  },
          ),
        ),
      ],
    );
  }
}
