import 'package:flutter/material.dart';
import 'package:ip_radio_app/themes/dark_theme.dart';
import 'package:ip_radio_app/themes/light_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = lightTheme;
  static const String _themeKey = 'is_dark_mode';

  ThemeProvider() {
    _loadTheme();
  }

  ThemeData get themeData => _themeData;

  bool get isDarkMode => _themeData == darkTheme;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    _saveTheme(isDarkMode);
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == lightTheme) {
      themeData = darkTheme;
    } else {
      themeData = lightTheme;
    }
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool(_themeKey) ?? false;
    _themeData = isDarkMode ? darkTheme : lightTheme;
    notifyListeners();
  }

  Future<void> _saveTheme(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
  }
}
