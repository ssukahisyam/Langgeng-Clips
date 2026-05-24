import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/preferences/preferences_providers.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../onboarding/groq_api_key_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiKeyState = ref.watch(groqApiKeyControllerProvider);
    final apiKeySubtitle = apiKeyState.when(
      data: (state) => state.maskedKey ?? 'Belum terhubung',
      error: (_, _) => 'Gagal membaca key',
      loading: () => 'Memuat...',
    );
    final themeMode = ref.watch(themeModeControllerProvider).valueOrNull;
    final themeLabel = switch (themeMode ?? ThemeMode.system) {
      ThemeMode.system => 'System',
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
    };
    final locale = ref.watch(localeControllerProvider).valueOrNull;
    final languageLabel = switch (locale?.languageCode) {
      'id' => 'Indonesia',
      'en' => 'English',
      _ => 'System',
    };

    return AppScaffold(
      title: 'Settings',
      currentIndex: 2,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsGroup(
            title: 'Akun & API',
            children: [
              _SettingsRow(title: 'Groq API Key', subtitle: apiKeySubtitle),
              const _SettingsRow(
                title: 'Google Drive',
                subtitle: 'Tidak terhubung',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsGroup(
            title: 'Tampilan',
            children: [
              _SettingsRow(
                title: 'Tema',
                subtitle: themeLabel,
                onTap: () => _showThemeModeSheet(context, ref),
              ),
              _SettingsRow(
                title: 'Bahasa',
                subtitle: languageLabel,
                onTap: () => _showLanguageSheet(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsGroup(
            title: 'Langgeng Pro',
            children: [
              _SettingsRow(
                title: 'Pricing & subscription',
                subtitle: 'Free trial, restore, cancel info',
                onTap: () => context.go('/pricing'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsGroup(
            title: 'Bantuan',
            children: [
              _SettingsRow(
                title: 'Help Center',
                subtitle: 'FAQ dan panduan singkat',
                onTap: () => context.go('/help'),
              ),
              _SettingsRow(
                title: 'Send feedback',
                subtitle: 'Laporkan bug atau ide fitur',
                onTap: () => context.go('/feedback'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _SettingsGroup(
            title: 'Tentang',
            children: [
              _SettingsRow(title: 'Privacy Policy'),
              _SettingsRow(title: 'Terms'),
              _SettingsRow(title: 'Versi', subtitle: '0.1.0'),
            ],
          ),
        ],
      ),
    );
  }

  void _showThemeModeSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ThemeModeTile(title: 'System', value: ThemeMode.system),
              _ThemeModeTile(title: 'Light', value: ThemeMode.light),
              _ThemeModeTile(title: 'Dark', value: ThemeMode.dark),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return const SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LanguageTile(title: 'System', value: null),
              _LanguageTile(title: 'Indonesia', value: Locale('id')),
              _LanguageTile(title: 'English', value: Locale('en')),
              SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Card(child: Column(children: children)),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.title, this.subtitle, this.onTap});

  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}

class _ThemeModeTile extends ConsumerWidget {
  const _ThemeModeTile({required this.title, required this.value});

  final String title;
  final ThemeMode value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeModeControllerProvider).valueOrNull;
    final isSelected = (current ?? ThemeMode.system) == value;

    return ListTile(
      title: Text(title),
      trailing: isSelected ? const Icon(Icons.check_rounded) : null,
      onTap: () async {
        await ref
            .read(themeModeControllerProvider.notifier)
            .setThemeMode(value);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }
}

class _LanguageTile extends ConsumerWidget {
  const _LanguageTile({required this.title, required this.value});

  final String title;
  final Locale? value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeControllerProvider).valueOrNull;
    final isSelected = current?.languageCode == value?.languageCode;

    return ListTile(
      title: Text(title),
      trailing: isSelected ? const Icon(Icons.check_rounded) : null,
      onTap: () async {
        await ref.read(localeControllerProvider.notifier).setLocale(value);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }
}
