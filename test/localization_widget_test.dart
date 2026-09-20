import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:password_safe/l10n/app_localizations.dart";
import "package:password_safe/screens/settings/appearance_tab.dart";
import "package:password_safe/theme_controller.dart";

Widget _localizedApp(ThemeController controller) {
  return AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      return MaterialApp(
        locale: controller.locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Scaffold(
              body: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => AppearanceTab(themeController: controller),
                    ),
                  );
                },
                child: Text(l10n.appearance),
              ),
            );
          },
        ),
      );
    },
  );
}

Future<void> _selectLanguage(WidgetTester tester, String label) async {
  await tester.tap(find.byType(DropdownButton<AppLanguage>));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  final systemLocaleCases = <({List<Locale> preferred, String expected})>[
    (preferred: [const Locale("en", "GB")], expected: "en"),
    (preferred: [const Locale("de", "AT")], expected: "de"),
    (preferred: [const Locale("de", "CH")], expected: "de"),
    (preferred: [const Locale("fr", "FR")], expected: "en"),
    (
      preferred: [const Locale("fr", "FR"), const Locale("de", "DE")],
      expected: "de",
    ),
    (
      preferred: [const Locale("en", "US"), const Locale("de", "DE")],
      expected: "en",
    ),
  ];

  for (final localeCase in systemLocaleCases) {
    testWidgets("resolves system locales ${localeCase.preferred}", (
      tester,
    ) async {
      tester.binding.platformDispatcher.localesTestValue = localeCase.preferred;
      addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);
      final controller = ThemeController();
      addTearDown(controller.dispose);
      await controller.initialize();

      await tester.pumpWidget(_localizedApp(controller));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(TextButton));
      expect(Localizations.localeOf(context), Locale(localeCase.expected));
      expect(
        find.text(localeCase.expected == "de" ? "Darstellung" : "Appearance"),
        findsOneWidget,
      );
    });
  }

  testWidgets("language selection updates an already pushed appearance route", (
    tester,
  ) async {
    tester.binding.platformDispatcher.localesTestValue = [
      const Locale("de", "DE"),
    ];
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);
    SharedPreferences.setMockInitialValues({"language": "english"});
    final controller = ThemeController();
    addTearDown(controller.dispose);
    await controller.initialize();

    await tester.pumpWidget(_localizedApp(controller));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Appearance"));
    await tester.pumpAndSettle();
    final appearanceState = tester.state(find.byType(AppearanceTab));

    expect(find.text("Language"), findsOneWidget);
    await _selectLanguage(tester, "German");

    expect(controller.language, AppLanguage.german);
    expect(find.text("Darstellung"), findsOneWidget);
    expect(find.text("Sprache"), findsOneWidget);
    expect(tester.state(find.byType(AppearanceTab)), same(appearanceState));
    expect(
      tester.widget<DropdownButton<AppLanguage>>(
        find.byType(DropdownButton<AppLanguage>),
      ).value,
      AppLanguage.german,
    );

    await _selectLanguage(tester, "Englisch");

    expect(controller.language, AppLanguage.english);
    expect(find.text("Appearance"), findsOneWidget);
    expect(find.text("Language"), findsOneWidget);

    await _selectLanguage(tester, "System");

    expect(controller.language, AppLanguage.system);
    expect(controller.locale, isNull);
    expect(find.text("Darstellung"), findsOneWidget);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString("language"), "system");

    tester.binding.platformDispatcher.localesTestValue = [
      const Locale("en", "GB"),
    ];
    await tester.pumpAndSettle();

    expect(find.text("Appearance"), findsOneWidget);
    expect(find.text("Language"), findsOneWidget);
    expect(tester.state(find.byType(AppearanceTab)), same(appearanceState));
    expect(tester.takeException(), isNull);
  });
}
