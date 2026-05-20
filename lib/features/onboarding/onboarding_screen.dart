import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = [
      _OnboardingPage(
        icon: Icons.folder_open_rounded,
        title: 'Bawa video panjangmu',
        body:
            'Import file lokal, Google Drive, atau share intent dari app lain.',
      ),
      _OnboardingPage(
        icon: Icons.auto_awesome_rounded,
        title: 'AI temukan momen terbaik',
        body:
            'Pilih manual, semi-auto, atau auto highlight sesuai workflow kamu.',
      ),
      _OnboardingPage(
        icon: Icons.smart_display_rounded,
        title: 'Siap untuk Shorts',
        body: 'Export 9:16 dengan subtitle, template, dan watermark yang rapi.',
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go('/setup/api-key'),
                  child: const Text('Skip'),
                ),
              ),
              Expanded(child: PageView(children: pages)),
              FilledButton(
                onPressed: () => context.go('/setup/api-key'),
                child: const Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 96, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 32),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Text(
          body,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}
