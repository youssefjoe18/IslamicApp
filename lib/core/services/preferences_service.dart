import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyIsDark = 'is_dark_theme';
  static const String _keyTasbihCount = 'tasbih_count';
  static const String _keyTasbihPreset = 'tasbih_preset';
  static const String _keyNotifEnabled = 'notifications_enabled';

  final SharedPreferences prefs;

  PreferencesService({required this.prefs});

  bool getThemeIsDark() => prefs.getBool(_keyIsDark) ?? false;
  Future<bool> setThemeIsDark(bool value) => prefs.setBool(_keyIsDark, value);

  int getTasbihCount() => prefs.getInt(_keyTasbihCount) ?? 0;
  Future<bool> setTasbihCount(int value) => prefs.setInt(_keyTasbihCount, value);

  int getTasbihPreset() => prefs.getInt(_keyTasbihPreset) ?? 33;
  Future<bool> setTasbihPreset(int value) => prefs.setInt(_keyTasbihPreset, value);

  bool getNotificationsEnabled() => prefs.getBool(_keyNotifEnabled) ?? false;
  Future<bool> setNotificationsEnabled(bool value) => prefs.setBool(_keyNotifEnabled, value);
}


