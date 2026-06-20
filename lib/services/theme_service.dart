import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:harmfilter_flutter/widgets/hf_theme.dart';

class ThemeService extends ChangeNotifier {
  static const _keyDarkMode = 'isDarkMode';
  static const _keyAvatar = 'selectedAvatar';
  static const _keyLanguage = 'language';
  static const _keyNotifications = 'notifications';
  static const _keyAccentColor = 'accentColor';

  ThemeMode _themeMode = ThemeMode.dark;
  String _selectedAvatar =
      "https://api.dicebear.com/7.x/avataaars/svg?seed=You";
  String _language = 'en';
  bool _notifications = true;
  Color? _accentColor = const Color(0xFFE8001D);

  ThemeMode get themeMode => _themeMode;
  String get selectedAvatar => _selectedAvatar;
  Color get accentColor => _accentColor ?? const Color(0xFFE8001D);
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  String _encodeColor(Color color) => color.value.toRadixString(16).padLeft(8, '0').toUpperCase();

  Color _decodeColor(String? value) {
    final raw = value;
    if (raw == null || raw.isEmpty) return const Color(0xFFE8001D);
    final normalized = raw.replaceFirst('#', '').toUpperCase();
    final parsed = int.tryParse(normalized, radix: 16);
    if (parsed == null) return const Color(0xFFE8001D);
    return Color(parsed);
  }

  /// Load all saved preferences from disk. Call once before runApp.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    final isDark = prefs.getBool(_keyDarkMode) ?? true;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    _selectedAvatar =
        prefs.getString(_keyAvatar) ??
        "https://api.dicebear.com/7.x/avataaars/svg?seed=You";

    _language = prefs.getString(_keyLanguage) ?? 'en';

    _notifications = prefs.getBool(_keyNotifications) ?? true;

    _accentColor = _decodeColor(prefs.getString(_keyAccentColor));
    HFTheme.setAccent(_accentColor ?? const Color(0xFFE8001D));

    notifyListeners();
  }

  void toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, isDark);
  }

  void setAvatar(String avatarUrl) async {
    _selectedAvatar = avatarUrl;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAvatar, avatarUrl);
  }

  // Language
  String get language => _language;
  void setLanguage(String lang) async {
    _language = lang;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, lang);
  }

  // Notifications
  bool get notifications => _notifications;
  void setNotifications(bool value) async {
    _notifications = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, value);
  }

  void setAccentColor(Color value) async {
    _accentColor = value;
    HFTheme.setAccent(value);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccentColor, _encodeColor(value));
  }
}
