import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_preferences.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (ref) => SharedPreferences.getInstance(),
);

final appPreferencesProvider = FutureProvider<AppPreferences>((ref) async {
  final preferences = await ref.watch(sharedPreferencesProvider.future);
  return AppPreferences(preferences);
});

final themeModeControllerProvider =
    AsyncNotifierProvider<ThemeModeController, ThemeMode>(
      ThemeModeController.new,
    );

final localeControllerProvider =
    AsyncNotifierProvider<LocaleController, Locale?>(LocaleController.new);

class ThemeModeController extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    final preferences = await ref.watch(appPreferencesProvider.future);
    return preferences.themeMode;
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    final preferences = await ref.read(appPreferencesProvider.future);
    await preferences.setThemeMode(themeMode);
    state = AsyncValue.data(themeMode);
  }
}

class LocaleController extends AsyncNotifier<Locale?> {
  @override
  Future<Locale?> build() async {
    final preferences = await ref.watch(appPreferencesProvider.future);
    return preferences.locale;
  }

  Future<void> setLocale(Locale? locale) async {
    final preferences = await ref.read(appPreferencesProvider.future);
    await preferences.setLocale(locale);
    state = AsyncValue.data(locale);
  }
}
