import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class ThemeController extends ChangeNotifier {
  static const _themeModeKey = "theme_mode";

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

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


  Future<void> _saveThemeMode(ThemeMode themeMode) async {
    final preferences = await _loadPreferences();

    if (preferences == null) {
      return;
    }

    await preferences.setString(_themeModeKey, themeMode.name);
  }
}