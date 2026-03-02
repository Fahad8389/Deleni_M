import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const _keyLanguage = 'language';
  static const _keyDarkMode = 'darkMode';
  static const _keyAccessibility = 'accessibilityMode';
  static const _keyNotifications = 'notifications';
  static const _keyDefaultHospital = 'defaultHospitalId';

  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  String get language => _prefs.getString(_keyLanguage) ?? 'en';
  Future<void> setLanguage(String value) => _prefs.setString(_keyLanguage, value);

  bool get darkMode => _prefs.getBool(_keyDarkMode) ?? false;
  Future<void> setDarkMode(bool value) => _prefs.setBool(_keyDarkMode, value);

  bool get accessibilityMode => _prefs.getBool(_keyAccessibility) ?? false;
  Future<void> setAccessibilityMode(bool value) => _prefs.setBool(_keyAccessibility, value);

  bool get notifications => _prefs.getBool(_keyNotifications) ?? true;
  Future<void> setNotifications(bool value) => _prefs.setBool(_keyNotifications, value);

  String get defaultHospitalId => _prefs.getString(_keyDefaultHospital) ?? 'king-faisal';
  Future<void> setDefaultHospitalId(String value) => _prefs.setString(_keyDefaultHospital, value);
}
