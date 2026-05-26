import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../editor/editor_project.dart';
import '../editor/editor_project_controller.dart';
import '../editor/editor_project_store.dart';
import '../import/import_sheet.dart';
import '../import/selected_video_controller.dart';
import '../monetization/ad_placeholder.dart';
import '../project_setup/project_setup_screen.dart';
import '../../shared/widgets/app_scaffold.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession = ref.watch(activeEditorSessionSummaryProvider);

    return AppScaffold(
      title: 'Halo, Creator',
      currentIndex: 0,
      actions: [
        IconButton(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Belum ada notifikasi.')),
          ),
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
          activeSession.when(
            data: (session) => session == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ActiveDraftCard(session: session),
                  ),
            error: (_, _) => const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
          ),
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
              _TemplateChip(label: 'Podcast'),
              _TemplateChip(label: 'Gaming'),
              _TemplateChip(label: 'Talking Head'),
              _TemplateChip(label: 'Tutorial'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActiveDraftCard extends ConsumerWidget {
  const _ActiveDraftCard({required this.session});

  final EditorSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = session.project;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.edit_note_rounded),
        title: Text(
          project.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${project.clips.length} clip · ${formatMillis(project.activeClip.durationMillis)} aktif',
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {
          ref.read(selectedVideoProvider.notifier).state = session.video;
          ref.read(editorProjectProvider.notifier).state = project;
          context.go('/editor');
        },
      ),
    );
  }
}

class _TemplateChip extends ConsumerWidget {
  const _TemplateChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        ref.read(quickTemplateProvider.notifier).state = label;
        showImportSheet(context);
      },
    );
  }
}
