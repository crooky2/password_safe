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

enum ThemeColorMode {
  defaultColor,
  custom,
}

class ThemeController extends ChangeNotifier {
  static const _themeModeKey = "theme_mode";
  static const _themeColorModeKey = "theme_color_mode";
  static const _customThemeColorKey = "custom_theme_color";
  static const _languageKey = "language";

  static const defaultSeedColor = Color(0xFF1F6F78);

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  ThemeColorMode _themeColorMode = ThemeColorMode.defaultColor;
  ThemeColorMode get themeColorMode => _themeColorMode;

  Color _customThemeColor = defaultSeedColor;
  Color get customThemeColor => _customThemeColor;

  Color get seedColor => switch (_themeColorMode) {
    ThemeColorMode.defaultColor => defaultSeedColor,
    ThemeColorMode.custom => _customThemeColor,
  };

  AppLanguage _language = AppLanguage.system;
  AppLanguage get language => _language;
  Locale? get locale => language.locale;

  Future<void> _themeColorWrites = Future<void>.value();

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

    final savedColor = preferences.getInt(_customThemeColorKey);
    _customThemeColor =
        savedColor != null && savedColor >= 0 && savedColor <= 0xFFFFFFFF
        ? Color(savedColor).withValues(alpha: 1.0)
        : defaultSeedColor;
    _themeColorMode = preferences.getString(_themeColorModeKey) == "custom"
        ? ThemeColorMode.custom
        : ThemeColorMode.defaultColor;

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

  void setThemeColorMode(ThemeColorMode mode) {
    if (_themeColorMode == mode) return;

    _themeColorMode = mode;
    notifyListeners();
    _saveThemeColor();
  }

  void setCustomThemeColor(Color color) {
    final opaqueColor = Color(color.toARGB32()).withValues(alpha: 1.0);
    if (_themeColorMode == ThemeColorMode.custom &&
        _customThemeColor == opaqueColor) {
      return;
    }

    _customThemeColor = opaqueColor;
    _themeColorMode = ThemeColorMode.custom;

    notifyListeners();
    _saveThemeColor();
  }

  void _saveThemeColor() {
    final savedMode = _themeColorMode.name;
    final savedColor = _customThemeColor.toARGB32();

    _themeColorWrites = _themeColorWrites
        .then<void>((_) async {
          final preferences = await _loadPreferences();
          if (preferences == null) return;

          await preferences.setInt(_customThemeColorKey, savedColor);
          await preferences.setString(_themeColorModeKey, savedMode);
        })
        .catchError((Object error) {
          debugPrint("ThemeController: could not save theme color. $error");
        });
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
