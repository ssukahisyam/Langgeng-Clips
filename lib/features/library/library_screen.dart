import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/app_scaffold.dart';
import '../editor/editor_project.dart';
import 'export_history.dart';

enum LibraryFilter { all, done, drafts }

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  LibraryFilter _filter = LibraryFilter.all;

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(exportHistoryItemsProvider);

    return AppScaffold(
      title: 'Library',
      currentIndex: 1,
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
      ],
      child: history.when(
        data: (items) {
          final filtered = _applyFilter(items);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: _filter == LibraryFilter.all,
                        onSelected: () =>
                            setState(() => _filter = LibraryFilter.all),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Done',
                        selected: _filter == LibraryFilter.done,
                        onSelected: () =>
                            setState(() => _filter = LibraryFilter.done),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Drafts',
                        selected: _filter == LibraryFilter.drafts,
                        onSelected: () =>
                            setState(() => _filter = LibraryFilter.drafts),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const _EmptyLibraryState()
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          return _ExportHistoryTile(item: filtered[index]);
                        },
                      ),
              ),
            ],
          );
        },
        error: (_, _) => const Center(child: Text('Gagal memuat Library.')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  List<ExportHistoryItem> _applyFilter(List<ExportHistoryItem> items) {
    return switch (_filter) {
      LibraryFilter.all => items,
      LibraryFilter.done => items,
      LibraryFilter.drafts => const [],
    };
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
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
        onTap: () => context.go('/library/export/${item.id}'),
        leading: const Icon(Icons.movie_outlined),
        title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${formatMillis(item.durationMillis)} · ${_formatDate(createdAt)}',
        ),
        trailing: Icon(
          item.isSavedToGallery
              ? Icons.photo_library_outlined
              : Icons.folder_outlined,
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
