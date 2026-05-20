import 'package:flutter/material.dart';

import 'router.dart';
import 'theme/app_theme.dart';

class LanggengClipApp extends StatelessWidget {
  const LanggengClipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Langgeng Clip',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
