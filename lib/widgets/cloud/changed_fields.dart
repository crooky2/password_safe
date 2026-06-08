import "package:flutter/material.dart";

import "../../cloud/cloud_diff.dart";
import "../../l10n/app_localizations.dart";

import "../home/entry_details.dart";

class CloudChangedFieldInfo {
  const CloudChangedFieldInfo({
    required this.label,
    required this.localValue,
    required this.cloudValue,
    this.isSecret = false,
  });

  final String label;
  final String localValue;
  final String cloudValue;
  final bool isSecret;
}

List<CloudChangedFieldInfo> cloudChangedFieldsForDiff(
  AppLocalizations l10n,
  CloudEntryDiff diff,
) {
  final local = diff.localEntry;
  final cloud = diff.cloudEntry;

  if (local == null || cloud == null) {
    return const [];
  }

  final fields = <CloudChangedFieldInfo>[];

  void add(
    String label,
    String localValue,
    String cloudValue, {
    bool isSecret = false,
  }) {
    if (localValue == cloudValue) return;

    fields.add(
      CloudChangedFieldInfo(
        label: label,
        localValue: localValue,
        cloudValue: cloudValue,
        isSecret: isSecret,
      ),
    );
  }

  add(l10n.titleLabel, local.title, cloud.title);
  add(l10n.username, local.username, cloud.username);
  add(l10n.password, local.password, cloud.password, isSecret: true);
  add(l10n.url, local.url, cloud.url);
  add(l10n.notes, local.notes, cloud.notes);
  add(
    l10n.favorite,
    local.isFavorite ? l10n.yes : l10n.no,
    cloud.isFavorite ? l10n.yes : l10n.no,
  );
  add(l10n.icon, local.iconKey, cloud.iconKey);

  return fields;
}

String cloudChangedFieldsSummary(AppLocalizations l10n, CloudEntryDiff diff) {
  final labels = cloudChangedFieldsForDiff(
    l10n,
    diff,
  ).map((field) => field.label).toList();

  if (labels.isEmpty) {
    return l10n.cloudChangedFieldsFallback;
  }

  final visibleLabels = labels.take(3).join(", ");

  if (labels.length <= 3) {
    return l10n.cloudChangedFieldsList(visibleLabels);
  }

  return l10n.cloudChangedFieldsListWithMore(visibleLabels, labels.length - 3);
}

class CloudChangedFields extends StatelessWidget {
  const CloudChangedFields({super.key, required this.diff});

  final CloudEntryDiff diff;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fields = cloudChangedFieldsForDiff(l10n, diff);

    if (fields.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final field in fields)
          _ChangedFieldComparison(field: field, l10n: l10n),
      ],
    );
  }
}

class _ChangedFieldComparison extends StatelessWidget {
  const _ChangedFieldComparison({required this.field, required this.l10n});

  final CloudChangedFieldInfo field;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(field.label, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),

          if (field.isSecret) ...[
            Text(l10n.cloudOnThisDevice, style: theme.textTheme.labelMedium),
            EntrySecretDetail(
              label: l10n.cloudFieldOnThisDevice(field.label),
              value: field.localValue,
            ),

            const SizedBox(height: 8),

            Text(l10n.cloudInCloud, style: theme.textTheme.labelMedium),
            EntrySecretDetail(
              label: l10n.cloudFieldInCloud(field.label),
              value: field.cloudValue,
            ),
          ] else ...[
            EntryDetail(label: l10n.cloudOnThisDevice, value: field.localValue),
            EntryDetail(label: l10n.cloudInCloud, value: field.cloudValue),
          ],
        ],
      ),
    );
  }
}
