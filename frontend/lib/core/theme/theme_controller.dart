import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controls application ThemeMode with observable notifications.
/// Keeps the approved light theme as the default.
class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode;

  ThemeController({ThemeMode initialMode = ThemeMode.light})
      : _themeMode = initialMode;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
      _saveThemeMode(mode);
    }
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_theme_mode', mode.name);
    } catch (_) {}
  }

  Future<void> loadSavedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('app_theme_mode');
      if (saved == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (saved == 'system') {
        _themeMode = ThemeMode.system;
      } else if (saved == 'light') {
        _themeMode = ThemeMode.light;
      }
      notifyListeners();
    } catch (_) {}
  }
}

/// Global shared controller instance for app-wide theme switching.
final ThemeController globalThemeController = ThemeController();
