import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/preferences/preferences_providers.dart';
import '../onboarding/groq_api_key_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 600), () async {
      if (mounted) {
        final preferences = await ref.read(appPreferencesProvider.future);
        if (!mounted) {
          return;
        }

        if (!preferences.hasCompletedOnboarding) {
          context.go('/onboarding');
          return;
        }

        final keyState = await ref.read(groqApiKeyControllerProvider.future);
        if (!mounted) {
          return;
        }

        context.go(keyState.hasKey ? '/home' : '/setup/api-key');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.content_cut_rounded, size: 56),
              SizedBox(height: 16),
              Text(
                'Langgeng Clip',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 6),
              Text('clip smarter'),
            ],
          ),
        ),
      ),
    );
  }
}
