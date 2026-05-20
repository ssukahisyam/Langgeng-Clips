import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/preferences/preferences_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _pageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
                  onPressed: () => _completeOnboarding(context, ref),
                  child: const Text('Skip'),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _pageIndex = index),
                  children: pages,
                ),
              ),
              const SizedBox(height: 16),
              _DotIndicator(length: pages.length, selectedIndex: _pageIndex),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  if (_pageIndex < pages.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                    );
                    return;
                  }

                  _completeOnboarding(context, ref);
                },
                child: Text(
                  _pageIndex == pages.length - 1 ? 'Get Started' : 'Next',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _completeOnboarding(BuildContext context, WidgetRef ref) async {
    final preferences = await ref.read(appPreferencesProvider.future);
    await preferences.setHasCompletedOnboarding(true);

    if (context.mounted) {
      context.go('/setup/api-key');
    }
  }
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.length, required this.selectedIndex});

  final int length;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final isSelected = index == selectedIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: isSelected ? 20 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
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
