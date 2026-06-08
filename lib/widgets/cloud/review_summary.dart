import "package:flutter/material.dart";

import "../../cloud/cloud_diff.dart";

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
    final undecidedCount = _totalCount - selectionCount;

    return SectionCard(
      title: "Review changes",
      subtitle: undecidedCount == 0
          ? "All changes have been reviewed."
          : "$undecidedCount of $_totalCount differences.",
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
            label: Text(isApplying ? "Applying changes..." : "Apply changes"),
          ),
        ),

        const SizedBox(height: 16),
        Text("Select for all:"),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<CloudEntryChoice>(
            emptySelectionAllowed: true,
            segments: [
              ButtonSegment(
                value: CloudEntryChoice.keepLocal,
                icon: Icon(Icons.phone_android_rounded),
                label: Text("Keep local"),
              ),
              ButtonSegment(
                value: CloudEntryChoice.useCloud,
                icon: Icon(Icons.cloud_rounded),
                label: Text("Keep cloud"),
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
