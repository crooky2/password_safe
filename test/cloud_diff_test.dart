import "package:flutter_test/flutter_test.dart";

import "package:password_safe/cloud/cloud_diff.dart";
import "package:password_safe/vault/password_database.dart";

void main() {
  group("CloudDatabaseDiff.compare", () {
    test("returns an empty diff for equal databases", () {
      final database = PasswordDatabase(
        version: 1,
        entries: [
          entry("a", title: "Alpha"),
          entry("b", title: "Beta", username: "user"),
        ],
        folders: const [
          PasswordFolder(id: "folder", name: "Folder", entryIds: ["a", "b"]),
        ],
      );

      final diff = CloudDatabaseDiff.compare(
        localDatabase: database,
        cloudDatabase: database,
      );

      expect(diff.isEmpty, isTrue);
      expect(diff.isNotEmpty, isFalse);
      expect(diff.onlyLocal, isEmpty);
      expect(diff.onlyCloud, isEmpty);
      expect(diff.changed, isEmpty);
      expect(diff.all, isEmpty);
    });

    test(
      "detects only-local, only-cloud and changed entries in local order",
      () {
        final localOnly = entry("local-only", title: "Local only");
        final cloudOnly = entry("cloud-only", title: "Cloud only");
        final localChanged = entry("shared", title: "Local title");
        final cloudChanged = entry("shared", title: "Cloud title");

        final diff = CloudDatabaseDiff.compare(
          localDatabase: PasswordDatabase(
            version: 1,
            entries: [localOnly, localChanged],
          ),
          cloudDatabase: PasswordDatabase(
            version: 1,
            entries: [cloudChanged, cloudOnly],
          ),
        );

        expect(diff.isEmpty, isFalse);
        expect(diff.isNotEmpty, isTrue);
        expect(diff.onlyLocal.map((entryDiff) => entryDiff.id), ["local-only"]);
        expect(diff.onlyCloud.map((entryDiff) => entryDiff.id), ["cloud-only"]);
        expect(diff.changed.map((entryDiff) => entryDiff.id), ["shared"]);
        expect(diff.all.map((entryDiff) => entryDiff.id), [
          "local-only",
          "cloud-only",
          "shared",
        ]);
        expect(diff.onlyLocal.single.localEntry, localOnly);
        expect(diff.onlyLocal.single.cloudEntry, isNull);
        expect(diff.onlyCloud.single.localEntry, isNull);
        expect(diff.onlyCloud.single.cloudEntry, cloudOnly);
        expect(diff.changed.single.localEntry, localChanged);
        expect(diff.changed.single.cloudEntry, cloudChanged);
      },
    );

    final changedFieldCases = <String, PasswordEntry Function(PasswordEntry)>{
      "title": (base) => base.copyWith(title: "Cloud title"),
      "username": (base) => base.copyWith(username: "cloud-user"),
      "password": (base) => base.copyWith(password: "cloud-password"),
      "notes": (base) => base.copyWith(notes: "Cloud notes"),
      "url": (base) => base.copyWith(url: "https://cloud.example"),
      "favorite flag": (base) => base.copyWith(isFavorite: true),
      "icon": (base) => base.copyWith(iconKey: "cloud-icon"),
    };

    for (final testCase in changedFieldCases.entries) {
      test("marks an entry changed when ${testCase.key} differs", () {
        final localEntry = entry("shared");
        final cloudEntry = testCase.value(localEntry);

        final diff = CloudDatabaseDiff.compare(
          localDatabase: PasswordDatabase(version: 1, entries: [localEntry]),
          cloudDatabase: PasswordDatabase(version: 1, entries: [cloudEntry]),
        );

        expect(diff.onlyLocal, isEmpty);
        expect(diff.onlyCloud, isEmpty);
        expect(diff.changed.single.id, "shared");
        expect(diff.changed.single.title, localEntry.title);
      });
    }
  });

  group("CloudDatabaseDiff.mergeWithChoices", () {
    test("throws while any diff remains undecided", () {
      final diff = CloudDatabaseDiff.compare(
        localDatabase: PasswordDatabase(
          version: 1,
          entries: [entry("local-only")],
        ),
        cloudDatabase: const PasswordDatabase(version: 1, entries: []),
      );

      expect(() => diff.mergeWithChoices(const {}), throwsA(isA<StateError>()));
    });

    test("keeps local choices and removes cloud-only entries", () {
      final localOnly = entry("local-only", title: "Local only");
      final localChanged = entry("shared", title: "Local title");
      final cloudChanged = entry("shared", title: "Cloud title");

      final diff = CloudDatabaseDiff.compare(
        localDatabase: PasswordDatabase(
          version: 1,
          entries: [localOnly, localChanged],
        ),
        cloudDatabase: PasswordDatabase(
          version: 1,
          entries: [cloudChanged, entry("cloud-only")],
        ),
      );

      final merged = diff.mergeWithChoices({
        "local-only": CloudEntryChoice.keepLocal,
        "shared": CloudEntryChoice.keepLocal,
        "cloud-only": CloudEntryChoice.keepLocal,
      });

      expect(merged.entries.map((entry) => entry.id), ["local-only", "shared"]);
      expect(merged.entries[0], localOnly);
      expect(merged.entries[1], localChanged);
    });

    test("uses cloud choices and removes local-only entries", () {
      final cloudOnly = entry("cloud-only", title: "Cloud only");
      final localChanged = entry("shared", title: "Local title");
      final cloudChanged = entry("shared", title: "Cloud title");

      final diff = CloudDatabaseDiff.compare(
        localDatabase: PasswordDatabase(
          version: 1,
          entries: [entry("local-only"), localChanged],
        ),
        cloudDatabase: PasswordDatabase(
          version: 1,
          entries: [cloudChanged, cloudOnly],
        ),
      );

      final merged = diff.mergeWithChoices({
        "local-only": CloudEntryChoice.useCloud,
        "shared": CloudEntryChoice.useCloud,
        "cloud-only": CloudEntryChoice.useCloud,
      });

      expect(merged.entries.map((entry) => entry.id), ["shared", "cloud-only"]);
      expect(merged.entries[0], cloudChanged);
      expect(merged.entries[1], cloudOnly);
    });

    test("supports mixed choices and prunes deleted entries from folders", () {
      final localOnly = entry("local-only", title: "Local only");
      final cloudOnly = entry("cloud-only", title: "Cloud only");
      final localChanged = entry("shared", title: "Local title");
      final cloudChanged = entry("shared", title: "Cloud title");
      final unchanged = entry("unchanged", title: "Same");

      final diff = CloudDatabaseDiff.compare(
        localDatabase: PasswordDatabase(
          version: 1,
          entries: [localOnly, localChanged, unchanged],
          folders: const [
            PasswordFolder(
              id: "folder",
              name: "Folder",
              entryIds: ["local-only", "shared", "unchanged"],
            ),
          ],
        ),
        cloudDatabase: PasswordDatabase(
          version: 1,
          entries: [cloudChanged, unchanged, cloudOnly],
        ),
      );

      final merged = diff.mergeWithChoices({
        "local-only": CloudEntryChoice.useCloud,
        "shared": CloudEntryChoice.useCloud,
        "cloud-only": CloudEntryChoice.useCloud,
      });

      expect(merged.version, 1);
      expect(merged.entries.map((entry) => entry.id), [
        "shared",
        "unchanged",
        "cloud-only",
      ]);
      expect(merged.entries[0], cloudChanged);
      expect(merged.entries[1], unchanged);
      expect(merged.entries[2], cloudOnly);
      expect(merged.folders.single.entryIds, ["shared", "unchanged"]);
    });

    test("defaults missing choices to undecided", () {
      final diff = CloudDatabaseDiff.compare(
        localDatabase: PasswordDatabase(
          version: 1,
          entries: [
            entry("local-only"),
            entry("shared", title: "Local"),
          ],
        ),
        cloudDatabase: PasswordDatabase(
          version: 1,
          entries: [entry("shared", title: "Cloud")],
        ),
      );

      expect(
        () => diff.mergeWithChoices({"local-only": CloudEntryChoice.keepLocal}),
        throwsA(isA<StateError>()),
      );
    });
  });
}

PasswordEntry entry(
  String id, {
  String? title,
  String username = "user",
  String password = "password",
  String notes = "",
  String url = "",
  bool isFavorite = false,
  String iconKey = "",
}) {
  return PasswordEntry(
    id: id,
    title: title ?? "Title $id",
    username: username,
    password: password,
    notes: notes,
    url: url,
    isFavorite: isFavorite,
    iconKey: iconKey,
  );
}
