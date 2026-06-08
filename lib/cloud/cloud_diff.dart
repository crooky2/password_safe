import "../vault/password_database.dart";

enum CloudEntryDiffType { onlyLocal, onlyCloud, changed }

enum CloudEntryChoice { undecided, keepLocal, useCloud }

class CloudEntryDiff {
  const CloudEntryDiff({required this.type, this.localEntry, this.cloudEntry});

  final CloudEntryDiffType type;
  final PasswordEntry? localEntry;
  final PasswordEntry? cloudEntry;

  String get id {
    return localEntry?.id ?? cloudEntry!.id;
  }

  String get title {
    return localEntry?.title ?? cloudEntry?.title ?? "";
  }
}

class CloudDatabaseDiff {
  const CloudDatabaseDiff({
    required this.localDatabase,
    required this.cloudDatabase,
    required this.onlyLocal,
    required this.onlyCloud,
    required this.changed,
  });

  final PasswordDatabase localDatabase;
  final PasswordDatabase cloudDatabase;

  final List<CloudEntryDiff> onlyLocal;
  final List<CloudEntryDiff> onlyCloud;
  final List<CloudEntryDiff> changed;

  bool get isEmpty {
    return onlyLocal.isEmpty && onlyCloud.isEmpty && changed.isEmpty;
  }

  bool get isNotEmpty {
    return !isEmpty;
  }

  List<CloudEntryDiff> get all {
    return [...onlyLocal, ...onlyCloud, ...changed];
  }

  factory CloudDatabaseDiff.compare({
    required PasswordDatabase localDatabase,
    required PasswordDatabase cloudDatabase,
  }) {
    final localEntriesById = {
      for (final entry in localDatabase.entries) entry.id: entry,
    };

    final cloudEntriesById = {
      for (final entry in cloudDatabase.entries) entry.id: entry,
    };

    final onlyLocal = <CloudEntryDiff>[];
    final onlyCloud = <CloudEntryDiff>[];
    final changed = <CloudEntryDiff>[];

    for (final localEntry in localDatabase.entries) {
      final cloudEntry = cloudEntriesById[localEntry.id];

      if (cloudEntry == null) {
        onlyLocal.add(
          CloudEntryDiff(
            type: CloudEntryDiffType.onlyLocal,
            localEntry: localEntry,
          ),
        );
        continue;
      }

      if (!_sameEntry(localEntry, cloudEntry)) {
        changed.add(
          CloudEntryDiff(
            type: CloudEntryDiffType.changed,
            localEntry: localEntry,
            cloudEntry: cloudEntry,
          ),
        );
      }
    }

    for (final cloudEntry in cloudDatabase.entries) {
      if (!localEntriesById.containsKey(cloudEntry.id)) {
        onlyCloud.add(
          CloudEntryDiff(
            type: CloudEntryDiffType.onlyCloud,
            cloudEntry: cloudEntry,
          ),
        );
      }
    }

    return CloudDatabaseDiff(
      localDatabase: localDatabase,
      cloudDatabase: cloudDatabase,
      onlyLocal: onlyLocal,
      onlyCloud: onlyCloud,
      changed: changed,
    );
  }

  static bool _sameEntry(PasswordEntry local, PasswordEntry cloud) {
    return local.id == cloud.id &&
        local.title == cloud.title &&
        local.username == cloud.username &&
        local.password == cloud.password &&
        local.notes == cloud.notes &&
        local.url == cloud.url &&
        local.isFavorite == cloud.isFavorite &&
        local.iconKey == cloud.iconKey;
  }

  PasswordDatabase mergeWithChoices(Map<String, CloudEntryChoice> choices) {
    final mergedEntriesById = {
      for (final entry in localDatabase.entries) entry.id: entry,
    };

    for (final diff in all) {
      final choice = choices[diff.id] ?? CloudEntryChoice.undecided;

      switch (choice) {
        case CloudEntryChoice.undecided:
          throw StateError("Cannot merge while entries are undecided.");

        case CloudEntryChoice.keepLocal:
          if (diff.type == CloudEntryDiffType.onlyCloud) {
            mergedEntriesById.remove(diff.id);
          } else {
            mergedEntriesById[diff.id] = diff.localEntry!;
          }

        case CloudEntryChoice.useCloud:
          if (diff.type == CloudEntryDiffType.onlyLocal) {
            mergedEntriesById.remove(diff.id);
          } else {
            mergedEntriesById[diff.id] = diff.cloudEntry!;
          }
      }
    }

    final remainingEntryIds = mergedEntriesById.keys.toSet();

    return localDatabase.copyWith(
      entries: mergedEntriesById.values.toList(),
      folders: localDatabase.folders.map((folder) {
        return folder.copyWith(
          entryIds: folder.entryIds.where(remainingEntryIds.contains).toList(),
        );
      }).toList(),
    );
  }
}
