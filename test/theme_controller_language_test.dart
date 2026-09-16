import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:password_safe/theme_controller.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test("a new installation follows the system language", () async {
    final controller = ThemeController();
    addTearDown(controller.dispose);

    await controller.initialize();

    expect(controller.language, AppLanguage.system);
    expect(controller.locale, isNull);
  });

  for (final language in AppLanguage.values) {
    test("restores the saved ${language.name} language", () async {
      SharedPreferences.setMockInitialValues({"language": language.name});
      final controller = ThemeController();
      addTearDown(controller.dispose);

      await controller.initialize();

      expect(controller.language, language);
      expect(controller.locale, language.locale);
    });
  }

  test("an unsupported saved language falls back to the system", () async {
    SharedPreferences.setMockInitialValues({"language": "unsupported"});
    final controller = ThemeController();
    addTearDown(controller.dispose);

    await controller.initialize();

    expect(controller.language, AppLanguage.system);
    expect(controller.locale, isNull);
  });

  test("language changes notify immediately and survive a restart", () async {
    final controller = ThemeController();
    addTearDown(controller.dispose);
    await controller.initialize();
    var notifications = 0;
    controller.addListener(() => notifications++);

    for (final language in [
      AppLanguage.german,
      AppLanguage.english,
      AppLanguage.system,
    ]) {
      final previousNotifications = notifications;
      controller.setLanguage(language);

      expect(notifications, previousNotifications + 1);
      expect(controller.language, language);
      expect(controller.locale, language.locale);

      // Persistence is deliberately asynchronous; let its queued write finish.
      await Future<void>.delayed(Duration.zero);
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString("language"), language.name);

      final restartedController = ThemeController();
      addTearDown(restartedController.dispose);
      await restartedController.initialize();
      expect(restartedController.language, language);
      expect(restartedController.locale, language.locale);
    }
  });

  test("selecting the current language does not notify again", () async {
    SharedPreferences.setMockInitialValues({"language": "english"});
    final controller = ThemeController();
    addTearDown(controller.dispose);
    await controller.initialize();
    var notifications = 0;
    controller.addListener(() => notifications++);

    controller.setLanguage(AppLanguage.english);

    expect(notifications, 0);
    expect(controller.locale, const Locale("en"));
  });
}
