import "package:flutter/material.dart";

import "../../cloud/cloud_diff.dart";

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

List<CloudChangedFieldInfo> cloudChangedFieldsForDiff(CloudEntryDiff diff) {
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

  add("Title", local.title, cloud.title);
  add("Username", local.username, cloud.username);
  add("Password", local.password, cloud.password, isSecret: true);
  add("URL", local.url, cloud.url);
  add("Notes", local.notes, cloud.notes);
  add(
    "Favorite",
    local.isFavorite ? "Yes" : "No",
    cloud.isFavorite ? "Yes" : "No",
  );
  add("Icon", local.iconKey, cloud.iconKey);

  return fields;
}

String cloudChangedFieldsSummary(CloudEntryDiff diff) {
  final labels = cloudChangedFieldsForDiff(
    diff,
  ).map((field) => field.label).toList();

  if (labels.isEmpty) {
    return "This entry has different local and cloud versions.";
  }

  if (labels.length <= 3) {
    return "Changes: ${labels.join(", ")}";
  }

  return "Changes: ${labels.take(3).join(", ")} +${labels.length - 3} more";
}

class CloudChangedFields extends StatelessWidget {
  const CloudChangedFields({super.key, required this.diff});

  final CloudEntryDiff diff;

  @override
  Widget build(BuildContext context) {
    final fields = cloudChangedFieldsForDiff(diff);

    if (fields.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final field in fields) _ChangedFieldComparison(field: field),
      ],
    );
  }
}

class _ChangedFieldComparison extends StatelessWidget {
  const _ChangedFieldComparison({required this.field});

  final CloudChangedFieldInfo field;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secretLabel = field.label.toLowerCase();

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(field.label, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),

          if (field.isSecret) ...[
            Text("On this device", style: theme.textTheme.labelMedium),
            EntrySecretDetail(
              label: "$secretLabel on this device",
              value: field.localValue,
            ),

            const SizedBox(height: 8),

            Text("In cloud", style: theme.textTheme.labelMedium),
            EntrySecretDetail(
              label: "$secretLabel in cloud",
              value: field.cloudValue,
            ),
          ] else ...[
            EntryDetail(
              label: "On this device",
              value: field.localValue,
            ),
            EntryDetail(
              label: "In cloud",
              value: field.cloudValue,
            ),
          ],
        ],
      ),
    );
  }
}