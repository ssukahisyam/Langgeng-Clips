import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'selected_video.dart';
import 'selected_video_controller.dart';
import '../editor/editor_project_store.dart';

Future<void> showImportSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => const ImportSheet(),
  );
}

class ImportSheet extends ConsumerWidget {
  const ImportSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih Sumber Video',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  _ImportSourceRow(
                    icon: Icons.folder_open_rounded,
                    title: 'File Lokal',
                    subtitle: 'MP4, MOV, atau MKV dari device kamu',
                    onTap: () => _pickLocalVideo(context, ref),
                  ),
                  const Divider(height: 1),
                  _ImportSourceRow(
                    icon: Icons.smart_display_outlined,
                    title: 'YouTube URL',
                    subtitle: 'Belum aktif: menunggu share-intent dan policy',
                  ),
                  const Divider(height: 1),
                  _ImportSourceRow(
                    icon: Icons.cloud_outlined,
                    title: 'Google Drive',
                    subtitle: 'Belum aktif: OAuth Drive belum diaktifkan',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Format awal: MP4, MOV, MKV. Import lokal diprioritaskan untuk MVP.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickLocalVideo(BuildContext context, WidgetRef ref) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'mov', 'mkv'],
      allowMultiple: false,
      withData: false,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.single;
    final selectedVideo = SelectedVideo.fromPlatformFile(file);
    ref.read(selectedVideoProvider.notifier).state = selectedVideo;
    final store = await ref.read(editorProjectStoreProvider.future);
    await store.clearActiveSession();
    ref.invalidate(activeEditorSessionSummaryProvider);

    navigator.pop();
    if (!context.mounted) {
      return;
    }

    context.go('/project/setup');
    scaffoldMessenger.showSnackBar(
      SnackBar(content: Text('Dipilih: ${file.name}')),
    );
  }
}

class _ImportSourceRow extends StatelessWidget {
  const _ImportSourceRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: onTap != null,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
