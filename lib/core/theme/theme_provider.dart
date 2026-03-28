import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages theme state and persistence
class ThemeProvider extends ChangeNotifier {
  static final ThemeProvider _instance = ThemeProvider._internal();

  bool _isDarkMode = false;
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  ThemeProvider._internal();

  factory ThemeProvider() {
    return _instance;
  }

  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _isInitialized;

  /// Initialize theme from SharedPreferences
  Future<void> init() async {
    if (_isInitialized) return;
    
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs.getBool('isDarkMode') ?? false;
    _isInitialized = true;
    notifyListeners();
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    await setDarkMode(!_isDarkMode);
  }

  /// Set theme directly
  Future<void> setDarkMode(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      await _prefs.setBool('isDarkMode', isDark);
      notifyListeners();
    }
  }
}
