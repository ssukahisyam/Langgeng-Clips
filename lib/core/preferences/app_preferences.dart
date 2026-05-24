import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences(this._preferences);

  static const _hasCompletedOnboardingKey = 'has_completed_onboarding';
  static const _themeModeKey = 'theme_mode';
  static const _languageCodeKey = 'language_code';

  final SharedPreferences _preferences;

  bool get hasCompletedOnboarding {
    return _preferences.getBool(_hasCompletedOnboardingKey) ?? false;
  }

  Future<void> setHasCompletedOnboarding(bool value) {
    return _preferences.setBool(_hasCompletedOnboardingKey, value);
  }

  ThemeMode get themeMode {
    final value = _preferences.getString(_themeModeKey);
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode value) {
    return _preferences.setString(_themeModeKey, value.name);
  }

  Locale? get locale {
    final languageCode = _preferences.getString(_languageCodeKey);
    return switch (languageCode) {
      'id' => const Locale('id'),
      'en' => const Locale('en'),
      _ => null,
    };
  }

  Future<void> setLocale(Locale? value) async {
    if (value == null) {
      await _preferences.remove(_languageCodeKey);
      return;
    }

    await _preferences.setString(_languageCodeKey, value.languageCode);
  }
}
