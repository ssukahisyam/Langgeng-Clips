import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../editor/editor_project.dart';
import '../editor/editor_project_controller.dart';
import '../import/selected_video_controller.dart';
import 'video_metadata.dart';
import 'video_metadata_probe.dart';

class ProjectSetupScreen extends ConsumerStatefulWidget {
  const ProjectSetupScreen({super.key});

  @override
  ConsumerState<ProjectSetupScreen> createState() => _ProjectSetupScreenState();
}

class _ProjectSetupScreenState extends ConsumerState<ProjectSetupScreen> {
  String _mode = 'Manual';
  String _template = 'Podcast';
  String _clipCount = 'Auto';
  String _duration = 'Auto';

  @override
  Widget build(BuildContext context) {
    final video = ref.watch(selectedVideoProvider);
    final metadata = video == null || video.path.isEmpty
        ? null
        : ref.watch(videoMetadataProvider(video.path));

    return Scaffold(
      appBar: AppBar(title: const Text('Atur Project')),
      body: SafeArea(
        child: video == null
            ? _MissingVideoState(onBackHome: () => context.go('/home'))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _SourceVideoCard(
                    videoName: video.name,
                    fileMeta: _sourceMeta(),
                    metadata: metadata,
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(title: 'Mode Clipping'),
                  const SizedBox(height: 8),
                  _ModeCard(
                    title: 'Manual',
                    subtitle: 'Pilih timeline start dan end sendiri.',
                    selected: _mode == 'Manual',
                    enabled: true,
                    onTap: () => setState(() => _mode = 'Manual'),
                  ),
                  _ModeCard(
                    title: 'Semi-Auto',
                    subtitle:
                        'Gunakan kandidat silence, scene, dan audio peak.',
                    selected: _mode == 'Semi-Auto',
                    enabled: true,
                    onTap: () => setState(() => _mode = 'Semi-Auto'),
                  ),
                  _ModeCard(
                    title: 'Auto (AI)',
                    subtitle:
                        'Generate kandidat highlight dari transcript dan AI.',
                    selected: _mode == 'Auto (AI)',
                    enabled: true,
                    onTap: () => setState(() => _mode = 'Auto (AI)'),
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(title: 'Template'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _template,
                    decoration: const InputDecoration(labelText: 'Template'),
                    items: const [
                      DropdownMenuItem(
                        value: 'Podcast',
                        child: Text('Podcast'),
                      ),
                      DropdownMenuItem(value: 'Gaming', child: Text('Gaming')),
                      DropdownMenuItem(
                        value: 'Talking Head',
                        child: Text('Talking Head'),
                      ),
                      DropdownMenuItem(
                        value: 'Tutorial',
                        child: Text('Tutorial'),
                      ),
                    ],
                    onChanged: (value) => setState(() => _template = value!),
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(title: 'Jumlah Clip'),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'Auto', label: Text('Auto')),
                      ButtonSegment(value: '1', label: Text('1')),
                      ButtonSegment(value: '3', label: Text('3')),
                      ButtonSegment(value: '5', label: Text('5')),
                    ],
                    selected: {_clipCount},
                    onSelectionChanged: (value) {
                      setState(() => _clipCount = value.single);
                    },
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(title: 'Durasi Target'),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: '15s', label: Text('15s')),
                      ButtonSegment(value: '30s', label: Text('30s')),
                      ButtonSegment(value: '60s', label: Text('60s')),
                      ButtonSegment(value: 'Auto', label: Text('Auto')),
                    ],
                    selected: {_duration},
                    onSelectionChanged: (value) {
                      setState(() => _duration = value.single);
                    },
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: () {
                      ref
                          .read(editorProjectProvider.notifier)
                          .state = EditorProject.initial(
                        title: video.name,
                        mode: _mode,
                        template: _template,
                        clipCount: _clipCount,
                        targetDuration: _duration,
                        durationMillis:
                            metadata?.valueOrNull?.durationMillis ?? 60000,
                      );
                      context.go('/editor');
                    },
                    child: Text(
                      _mode == 'Manual' ? 'Mulai Edit' : 'Generate Clip',
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String _sourceMeta() {
    final video = ref.read(selectedVideoProvider)!;
    final exists = video.existsOnDevice ? 'file siap' : 'path belum tersedia';
    return '${video.extension} · ${video.formattedSize} · $exists';
  }
}

class _SourceVideoCard extends StatelessWidget {
  const _SourceVideoCard({
    required this.videoName,
    required this.fileMeta,
    required this.metadata,
  });

  final String videoName;
  final String fileMeta;
  final AsyncValue<VideoMetadata>? metadata;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.movie_outlined, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    videoName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(fileMeta),
                  const SizedBox(height: 6),
                  _MetadataText(metadata: metadata),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetadataText extends StatelessWidget {
  const _MetadataText({required this.metadata});

  final AsyncValue<VideoMetadata>? metadata;

  @override
  Widget build(BuildContext context) {
    final value = metadata;
    if (value == null) {
      return const Text('Metadata: path file belum tersedia');
    }

    return value.when(
      data: (metadata) => Text(
        '${metadata.formattedDuration} · ${metadata.resolution} · '
        'rotasi ${metadata.rotationDegrees}° · ${metadata.mimeType}',
      ),
      error: (_, _) => const Text('Metadata: gagal dibaca'),
      loading: () => const Row(
        children: [
          SizedBox.square(
            dimension: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text('Membaca metadata...'),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        color: selected ? Theme.of(context).colorScheme.primaryContainer : null,
        child: ListTile(
          enabled: enabled,
          onTap: enabled ? onTap : null,
          leading: Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
          ),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: selected ? const Icon(Icons.check_rounded) : null,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _MissingVideoState extends StatelessWidget {
  const _MissingVideoState({required this.onBackHome});

  final VoidCallback onBackHome;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.video_file_outlined, size: 56),
            const SizedBox(height: 16),
            Text(
              'Belum ada video dipilih',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Pilih video dari Home untuk mulai membuat project.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onBackHome,
              child: const Text('Kembali Home'),
            ),
          ],
        ),
      ),
    );
  }
}
