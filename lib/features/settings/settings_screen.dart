import 'package:flutter/material.dart';

import '../../shared/widgets/app_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Settings',
      currentIndex: 2,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SettingsGroup(
            title: 'Akun & API',
            children: [
              _SettingsRow(title: 'Groq API Key', subtitle: 'Belum terhubung'),
              _SettingsRow(title: 'Google Drive', subtitle: 'Tidak terhubung'),
            ],
          ),
          SizedBox(height: 16),
          _SettingsGroup(
            title: 'Tampilan',
            children: [
              _SettingsRow(title: 'Tema', subtitle: 'System'),
              _SettingsRow(title: 'Bahasa', subtitle: 'Indonesia'),
            ],
          ),
          SizedBox(height: 16),
          _SettingsGroup(
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
  const _SettingsRow({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}
