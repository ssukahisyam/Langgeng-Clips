import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/preferences/preferences_providers.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class LanggengClipApp extends ConsumerWidget {
  const LanggengClipApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeControllerProvider).valueOrNull;
    final locale = ref.watch(localeControllerProvider).valueOrNull;

    return MaterialApp.router(
      title: 'Langgeng Clip',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode ?? ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
