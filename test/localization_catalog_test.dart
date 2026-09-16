import "dart:convert";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:password_safe/l10n/app_localizations.dart";

Map<String, String> _messagesFor(Locale locale) {
  final path = "lib/l10n/app_${locale.languageCode}.arb";
  final catalog = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  return {
    for (final entry in catalog.entries)
      if (!entry.key.startsWith("@")) entry.key: entry.value as String,
  };
}

Set<String> _placeholders(String message) {
  return RegExp(r"\{([a-zA-Z_][a-zA-Z_0-9]*)\s*[,}]")
      .allMatches(message)
      .map((match) => match.group(1)!)
      .toSet();
}

void main() {
  test("English is the fallback for unsupported system languages", () {
    expect(AppLocalizations.supportedLocales.first, const Locale("en"));
  });

  for (final locale in AppLocalizations.supportedLocales) {
    test("${locale.languageCode} translates every message and placeholder", () {
      final english = _messagesFor(const Locale("en"));
      final translated = _messagesFor(locale);

      expect(translated.keys.toSet(), english.keys.toSet());
      for (final entry in english.entries) {
        final translation = translated[entry.key]!;
        expect(
          translation.trim(),
          isNotEmpty,
          reason: "${locale.languageCode}: ${entry.key} must not be blank",
        );
        expect(
          _placeholders(translation),
          _placeholders(entry.value),
          reason: "${locale.languageCode}: ${entry.key} placeholders differ",
        );
      }
    });
  }

  test("English and German generate plural and interpolated messages", () async {
    final english = await AppLocalizations.delegate.load(const Locale("en"));
    final german = await AppLocalizations.delegate.load(const Locale("de"));

    expect(english.entryCount(0), "0 entries");
    expect(english.entryCount(1), "1 entry");
    expect(english.entryCount(2), "2 entries");
    expect(german.entryCount(0), "0 Einträge");
    expect(german.entryCount(1), "1 Eintrag");
    expect(german.entryCount(2), "2 Einträge");
    expect(english.copyLabel("Username"), "Copy Username");
    expect(german.copyLabel("Benutzername"), "Benutzername kopieren");
    expect(
      english.cloudReviewDifferenceCount(2, 3),
      "Review 2 of 3 differences.",
    );
    expect(
      german.cloudReviewDifferenceCount(2, 3),
      "Prüfe 2 von 3 Unterschieden.",
    );
  });
}
