import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/app_scaffold.dart';
import '../editor/editor_project.dart';
import 'export_history.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(exportHistoryItemsProvider);

    return AppScaffold(
      title: 'Library',
      currentIndex: 1,
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
      ],
      child: history.when(
        data: (items) => items.isEmpty
            ? const _EmptyLibraryState()
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return _ExportHistoryTile(item: items[index]);
                },
              ),
        error: (_, _) => const Center(child: Text('Gagal memuat Library.')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _ExportHistoryTile extends StatelessWidget {
  const _ExportHistoryTile({required this.item});

  final ExportHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.fromMillisecondsSinceEpoch(item.createdAtMillis);
    return Card(
      child: ListTile(
        leading: const Icon(Icons.movie_outlined),
        title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${formatMillis(item.durationMillis)} · ${_formatDate(createdAt)}',
        ),
        trailing: Icon(
          item.galleryUri == null
              ? Icons.folder_outlined
              : Icons.photo_library_outlined,
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    return '${value.year}-${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }
}

class _EmptyLibraryState extends StatelessWidget {
  const _EmptyLibraryState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.video_library_outlined, size: 56),
            SizedBox(height: 16),
            Text('Belum ada export'),
            SizedBox(height: 8),
            Text(
              'Hasil export dari editor akan muncul di sini.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
