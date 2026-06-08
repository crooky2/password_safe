import "package:flutter/material.dart";

import "../../cloud/cloud_diff.dart";

import "../section_card.dart";


class CloudReviewSummary extends StatelessWidget {
  const CloudReviewSummary({
    super.key,
    required this.diff,
    required this.selectionCount,
    required this.isApplying,
    required this.onApply
  });

  final CloudDatabaseDiff diff;
  final int selectionCount;
  final bool isApplying;
  final VoidCallback onApply;

  int get _totalCount {
    return diff.onlyLocal.length + diff.onlyCloud.length + diff.changed.length;
  }

  @override
  Widget build (BuildContext context) {
    final undecidedCount = _totalCount - selectionCount;

    return SectionCard(
      title: "Review changes",
      subtitle: undecidedCount == 0
          ? "All changes have been reviewed."
          : "$undecidedCount of $_totalCount differences.",
      icon: Icons.rule_rounded,
      children: [
        FilledButton.icon(
          onPressed: isApplying || undecidedCount > 0 ? null : onApply,
          icon: isApplying
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.done_all_rounded),
          label: Text(isApplying ? "Applying changes..." : "Apply changes"),
        )
      ]
    );
  }
}