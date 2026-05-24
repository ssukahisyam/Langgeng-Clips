import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../import/import_sheet.dart';
import '../monetization/ad_placeholder.dart';
import '../../shared/widgets/app_scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Halo, Creator',
      currentIndex: 0,
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Sudah siap bikin clip pertamamu?',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.workspace_premium_rounded),
              title: const Text('Promo: unlimited export minggu pertama'),
              subtitle: const Text(
                'Setelah promo, free tier tetap 3 export per hari.',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.go('/pricing'),
            ),
          ),
          const SizedBox(height: 12),
          const AdPlaceholder(label: 'Banner ad placeholder · Home'),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.add_circle_outline_rounded,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Buat Clip Baru',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Import video panjang dan mulai potong ke 9:16.'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => showImportSheet(context),
                    child: const Text('Pilih Video'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Template Cepat',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('Podcast')),
              Chip(label: Text('Gaming')),
              Chip(label: Text('Talking Head')),
              Chip(label: Text('Tutorial')),
            ],
          ),
        ],
      ),
    );
  }
}
