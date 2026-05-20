import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/core/preferences/app_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('hasCompletedOnboarding defaults to false', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = AppPreferences(await SharedPreferences.getInstance());

    expect(preferences.hasCompletedOnboarding, isFalse);
  });

  test('persists onboarding completion', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = AppPreferences(await SharedPreferences.getInstance());

    await preferences.setHasCompletedOnboarding(true);

    expect(preferences.hasCompletedOnboarding, isTrue);
  });

  test('persists theme mode', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = AppPreferences(await SharedPreferences.getInstance());

    await preferences.setThemeMode(ThemeMode.dark);

    expect(preferences.themeMode, ThemeMode.dark);
  });
}
