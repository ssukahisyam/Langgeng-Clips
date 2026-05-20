import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'selected_video.dart';
import 'selected_video_controller.dart';

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
                  const _ImportSourceRow(
                    icon: Icons.smart_display_outlined,
                    title: 'YouTube URL',
                    subtitle:
                        'Belum aktif di MVP untuk menjaga policy Play Store',
                  ),
                  const Divider(height: 1),
                  const _ImportSourceRow(
                    icon: Icons.cloud_outlined,
                    title: 'Google Drive',
                    subtitle: 'Akan ditambahkan setelah file lokal stabil',
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
    ref.read(selectedVideoProvider.notifier).state =
        SelectedVideo.fromPlatformFile(file);

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
      trailing: Icon(
        onTap == null
            ? Icons.lock_outline_rounded
            : Icons.chevron_right_rounded,
      ),
      onTap: onTap,
    );
  }
}
