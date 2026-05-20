import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../editor/editor_project.dart';
import 'export_history.dart';

class ExportViewerScreen extends ConsumerWidget {
  const ExportViewerScreen({required this.exportId, super.key});

  final String exportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(exportHistoryItemProvider(exportId));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Clip Viewer'),
      ),
      body: item.when(
        data: (item) => item == null
            ? const Center(
                child: Text(
                  'Export tidak ditemukan.',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : SafeArea(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141414),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF262626)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.play_circle_outline_rounded,
                              color: Colors.white,
                              size: 80,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              item.title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formatMillis(item.durationMillis),
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Video playback akan ditambahkan setelah native preview player.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white54),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
        error: (_, _) => const Center(
          child: Text(
            'Gagal memuat export.',
            style: TextStyle(color: Colors.white),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
