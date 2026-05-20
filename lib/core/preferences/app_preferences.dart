import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences(this._preferences);

  static const _hasCompletedOnboardingKey = 'has_completed_onboarding';
  static const _themeModeKey = 'theme_mode';

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
}
