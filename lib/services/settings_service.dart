import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static const _themeKey = 'app_theme_color';
  static const _darkModeKey = 'dark_mode';
  static const _notifKey = 'notifications_enabled';
  static const _langKey = 'language';

  // আগে
  Color _themeColor = const Color(0xFF1D9E75);
  // পরে
  // Color _themeColor = const Color(0xFF0F766E);
  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = true;
  String _language = 'bn';

  Color get themeColor => _themeColor;
  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  String get language => _language;
  
  static const List<Map<String, dynamic>> themeOptions = [
    // {'name': 'ফরেস্ট গ্রিন', 'color': Color(0xFF1D9E75), 'dark': Color(0xFF0F6E56)},
    {'name': 'ওশান টিল', 'color': Color(0xFF1A5276), 'dark': Color(0xFF1F618D)},
    {'name': 'প্রপার্টি গ্রিন','color': Color(0xFF2D7A4F), 'dark': Color(0xFF1E5235)},
    {'name': 'ডার্ক ফরেস্ট', 'color': Color(0xFF0F5132), 'dark': Color(0xFF0A3622)},
  ];


  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final colorHex = prefs.getString(_themeKey);
    if (colorHex != null) {
      _themeColor = Color(int.parse(colorHex));
    }
    final dm = prefs.getString(_darkModeKey) ?? 'system';
    _themeMode = dm == 'light'
        ? ThemeMode.light
        : dm == 'dark'
            ? ThemeMode.dark
            : ThemeMode.system;
    _notificationsEnabled = prefs.getBool(_notifKey) ?? true;
    _language = prefs.getString(_langKey) ?? 'bn';
    notifyListeners();
  }

  Future<void> setThemeColor(Color color) async {
    _themeColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, color.value.toString());
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    final val = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
            ? 'dark'
            : 'system';
    await prefs.setString(_darkModeKey, val);
    notifyListeners();
  }

  Future<void> setNotifications(bool val) async {
    _notificationsEnabled = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notifKey, val);
    notifyListeners();
  }
}
