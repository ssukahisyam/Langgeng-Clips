import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../editor/editor_project.dart';
import 'export_actions.dart';
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
                            if (item.resolution != null)
                              Text('Resolusi: ${item.resolution}'),
                            if (item.targetWidth != null &&
                                item.targetHeight != null)
                              Text(
                                'Target: ${item.targetWidth}x${item.targetHeight}',
                              ),
                            if (item.frameRate != null)
                              Text('FPS: ${item.frameRate}'),
                            if (item.codec != null)
                              Text('Codec: ${item.codec}'),
                            if (item.cropToPortrait == true)
                              const Text('Crop: 9:16 portrait target'),
                            if (item.requiresReencode == true)
                              const Text('Render mode: re-encode required'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () =>
                          context.go('/library/export/${item.id}/viewer'),
                      icon: const Icon(Icons.fullscreen_rounded),
                      label: const Text('Open viewer'),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.tonalIcon(
                      onPressed: () => _share(context, item),
                      icon: const Icon(Icons.share_rounded),
                      label: const Text('Share clip'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => _rename(context, ref, item),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Rename'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => _duplicate(context, ref, item),
                      icon: const Icon(Icons.copy_rounded),
                      label: const Text('Duplicate'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => _delete(context, ref, item),
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Delete'),
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

  Future<void> _share(BuildContext context, ExportHistoryItem item) async {
    try {
      final uri = item.galleryUri;
      if (uri == null || uri.isEmpty) {
        throw const ExportActionException('Export belum tersimpan di Gallery.');
      }

      await const ExportActions().share(uri: uri, title: item.title);
    } on ExportActionException catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export belum tersimpan di Gallery.')),
        );
      }
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuka share sheet.')),
        );
      }
    }
  }

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    ExportHistoryItem item,
  ) async {
    final controller = TextEditingController(text: item.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename export'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();

    final title = newTitle?.trim();
    if (title == null || title.isEmpty) {
      return;
    }

    final repository = await ref.read(exportHistoryRepositoryProvider.future);
    await repository.rename(id: item.id, title: title);
    ref
      ..invalidate(exportHistoryItemsProvider)
      ..invalidate(exportHistoryItemProvider(item.id));
  }

  Future<void> _duplicate(
    BuildContext context,
    WidgetRef ref,
    ExportHistoryItem item,
  ) async {
    final repository = await ref.read(exportHistoryRepositoryProvider.future);
    await repository.duplicate(item.id);
    ref.invalidate(exportHistoryItemsProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Export duplicated.')));
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    ExportHistoryItem item,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete export?'),
        content: const Text('History export akan dihapus dari Library.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) {
      return;
    }

    final repository = await ref.read(exportHistoryRepositoryProvider.future);
    await repository.delete(item.id);
    ref.invalidate(exportHistoryItemsProvider);
    if (context.mounted) {
      context.go('/library');
    }
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
