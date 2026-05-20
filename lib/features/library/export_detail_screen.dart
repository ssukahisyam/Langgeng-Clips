import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../editor/editor_project.dart';
import 'export_history.dart';

class ExportDetailScreen extends ConsumerWidget {
  const ExportDetailScreen({required this.exportId, super.key});

  final String exportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(exportHistoryItemProvider(exportId));

    return Scaffold(
      appBar: AppBar(title: const Text('Export Detail')),
      body: SafeArea(
        child: item.when(
          data: (item) => item == null
              ? const Center(child: Text('Export tidak ditemukan.'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Durasi: ${formatMillis(item.durationMillis)}',
                            ),
                            Text(
                              'Dibuat: ${_formatDateTime(item.createdAtMillis)}',
                            ),
                            Text(
                              item.isSavedToGallery
                                  ? 'Status: tersimpan di Gallery'
                                  : 'Status: hanya cache',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _PathTile(title: 'Cache path', value: item.cachePath),
                    if (item.galleryUri != null) ...[
                      const SizedBox(height: 8),
                      _PathTile(title: 'Gallery URI', value: item.galleryUri!),
                    ],
                  ],
                ),
          error: (_, _) => const Center(child: Text('Gagal memuat export.')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  String _formatDateTime(int millis) {
    final value = DateTime.fromMillisecondsSinceEpoch(millis);
    return '${value.year}-${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')} '
        '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}';
  }
}

class _PathTile extends StatelessWidget {
  const _PathTile({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(title: Text(title), subtitle: Text(value)),
    );
  }
}
