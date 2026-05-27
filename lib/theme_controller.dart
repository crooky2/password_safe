import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

enum AppLanguage {
  system,
  english,
  german;

  Locale? get locale {
    return switch (this) {
      AppLanguage.system => null,
      AppLanguage.english => const Locale("en"),
      AppLanguage.german => const Locale("de"),
    };
  }
}

class ThemeController extends ChangeNotifier {
  static const _themeModeKey = "theme_mode";
  static const _languageKey = "language";

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  AppLanguage _language = AppLanguage.system;
  AppLanguage get language => _language;
  Locale? get locale => language.locale;

  Future<SharedPreferences?> _loadPreferences() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (error) {
      debugPrint(
        'ThemeController: shared_preferences is unavailable. '
        'Error: $error',
      );
      return null;
    }
  }

  Future<void> initialize() async {
    final preferences = await _loadPreferences();

    if (preferences == null) {
      return;
    }

    final savedThemeMode = preferences.getString(_themeModeKey);
    _themeMode = switch (savedThemeMode) {
      "light" => ThemeMode.light,
      "dark" => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    final savedLanguage = preferences.getString(_languageKey);
    _language = switch (savedLanguage) {
      "english" => AppLanguage.english,
      "german" => AppLanguage.german,
      _ => AppLanguage.system,
    };

    notifyListeners();
  }

  void setThemeMode(ThemeMode themeMode) {
    if (_themeMode == themeMode) {
      return;
    }

    _themeMode = themeMode;
    notifyListeners();

    _saveThemeMode(themeMode);
  }

  void setLanguage(AppLanguage language) {
    if (_language == language) {
      return;
    }

    _language = language;
    notifyListeners();

    _saveLanguage(language);
  }


  Future<void> _saveThemeMode(ThemeMode themeMode) async {
    final preferences = await _loadPreferences();

    if (preferences == null) {
      return;
    }

    await preferences.setString(_themeModeKey, themeMode.name);
  }

  Future<void> _saveLanguage(AppLanguage language) async {
    final preferences = await _loadPreferences();

    if (preferences == null) {
      return;
    }

    await preferences.setString(_languageKey, language.name);
  }
}