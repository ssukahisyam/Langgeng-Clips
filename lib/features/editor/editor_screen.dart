import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../import/selected_video_controller.dart';
import '../library/export_history.dart';
import '../render/export_sheet.dart';
import '../render/trim_exporter.dart';
import 'editor_project.dart';
import 'editor_project_controller.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  String _activePanel = 'Clips';
  bool _isPlaying = false;
  bool _isExporting = false;
  double _exportProgress = 0;
  StreamSubscription<double>? _exportProgressSubscription;

  @override
  void initState() {
    super.initState();
    _exportProgressSubscription = const TrimExporter().progressStream.listen((
      progress,
    ) {
      if (mounted) {
        setState(() => _exportProgress = progress);
      }
    });
  }

  @override
  void dispose() {
    _exportProgressSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final video = ref.watch(selectedVideoProvider);
    final project = ref.watch(editorProjectProvider);

    if (video == null || project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editor')),
        body: _MissingEditorState(onBackHome: () => context.go('/home')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/project/setup'),
          icon: const Icon(Icons.close_rounded),
        ),
        title: GestureDetector(
          onTap: () => _renameProject(context, project.title),
          child: Text(project.title, overflow: TextOverflow.ellipsis),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _PreviewPanel(fileName: video.name),
                  const SizedBox(height: 12),
                  _TransportBar(
                    isPlaying: _isPlaying,
                    onPlayPause: () => setState(() => _isPlaying = !_isPlaying),
                    onCut: _addClipFromActiveRange,
                  ),
                  const SizedBox(height: 16),
                  _TimelineEditor(
                    project: project,
                    onRangeChanged: _updateActiveClipRange,
                    onSelectClip: _selectClip,
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'Clips', label: Text('Clips')),
                        ButtonSegment(value: 'Style', label: Text('Style')),
                        ButtonSegment(value: 'Audio', label: Text('Audio')),
                        ButtonSegment(value: 'Caption', label: Text('Caption')),
                        ButtonSegment(
                          value: 'Watermark',
                          label: Text('Watermark'),
                        ),
                      ],
                      selected: {_activePanel},
                      onSelectionChanged: (value) {
                        setState(() => _activePanel = value.single);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _EditorPanel(
                    activePanel: _activePanel,
                    template: project.template,
                    clipCount: project.clipCount,
                    targetDuration: project.targetDuration,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isExporting) ...[
                    LinearProgressIndicator(value: _exportProgress),
                    const SizedBox(height: 8),
                    Text('${(_exportProgress * 100).round()}%'),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _cancelExport,
                      child: const Text('Cancel export'),
                    ),
                    const SizedBox(height: 8),
                  ],
                  FilledButton(
                    onPressed: _isExporting
                        ? null
                        : () => showExportSheet(
                            context: context,
                            clip: project.activeClip,
                            onExport: (_) => _exportActiveClip(
                              video.path,
                              project.activeClip,
                            ),
                          ),
                    child: _isExporting
                        ? const Text('Exporting...')
                        : const Text('Export active clip'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateActiveClipRange(RangeValues values) {
    final project = ref.read(editorProjectProvider);
    if (project == null) {
      return;
    }

    ref.read(editorProjectProvider.notifier).state = project
        .updateActiveClipRange(
          startMillis: values.start.round(),
          endMillis: values.end.round(),
        );
  }

  void _addClipFromActiveRange() {
    final project = ref.read(editorProjectProvider);
    if (project == null) {
      return;
    }

    ref.read(editorProjectProvider.notifier).state = project
        .addClipFromActiveRange();
  }

  void _selectClip(String id) {
    final project = ref.read(editorProjectProvider);
    if (project == null) {
      return;
    }

    ref.read(editorProjectProvider.notifier).state = project.setActiveClip(id);
  }

  Future<void> _exportActiveClip(String sourcePath, EditorClip clip) async {
    setState(() {
      _isExporting = true;
      _exportProgress = 0;
    });
    final messenger = ScaffoldMessenger.of(context);

    try {
      final exportResult = await ref
          .read(trimExporterProvider)
          .export(
            sourcePath: sourcePath,
            startMillis: clip.startMillis,
            endMillis: clip.endMillis,
          );
      final project = ref.read(editorProjectProvider);
      if (project != null) {
        final repository = await ref.read(
          exportHistoryRepositoryProvider.future,
        );
        await repository.add(
          ExportHistoryItem(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            title: '${project.title} · ${clip.name}',
            cachePath: exportResult.cachePath,
            galleryUri: exportResult.galleryUri,
            createdAtMillis: DateTime.now().millisecondsSinceEpoch,
            durationMillis: clip.durationMillis,
          ),
        );
        ref.invalidate(exportHistoryItemsProvider);
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            exportResult.isSavedToGallery
                ? 'Export selesai dan tersimpan di Gallery.'
                : 'Export selesai: ${exportResult.cachePath}',
          ),
        ),
      );
      setState(() => _exportProgress = 1);
    } on TrimExportException catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Export gagal. Coba ulangi.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _cancelExport() async {
    await ref.read(trimExporterProvider).cancel();
    if (!mounted) {
      return;
    }

    setState(() => _isExporting = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Export dibatalkan.')));
  }

  Future<void> _renameProject(BuildContext context, String currentTitle) async {
    final controller = TextEditingController(text: currentTitle);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename project'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Nama project'),
            textInputAction: TextInputAction.done,
            onSubmitted: (value) => Navigator.of(context).pop(value),
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
        );
      },
    );
    controller.dispose();

    final trimmed = newTitle?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return;
    }

    final currentProject = ref.read(editorProjectProvider);
    if (currentProject == null) {
      return;
    }

    ref.read(editorProjectProvider.notifier).state = currentProject.copyWith(
      title: trimmed,
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({required this.fileName});

  final String fileName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 9 / 16,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_circle_outline_rounded, size: 64),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  fileName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 6),
              const Text('Preview 9:16 placeholder'),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransportBar extends StatelessWidget {
  const _TransportBar({
    required this.isPlaying,
    required this.onPlayPause,
    required this.onCut,
  });

  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onCut;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.skip_previous)),
            IconButton(
              onPressed: onPlayPause,
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.skip_next)),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.fit_screen_rounded),
              label: const Text('Fit'),
            ),
            TextButton.icon(
              onPressed: onCut,
              icon: const Icon(Icons.content_cut_rounded),
              label: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineEditor extends StatelessWidget {
  const _TimelineEditor({
    required this.project,
    required this.onRangeChanged,
    required this.onSelectClip,
  });

  final EditorProject project;
  final ValueChanged<RangeValues> onRangeChanged;
  final ValueChanged<String> onSelectClip;

  @override
  Widget build(BuildContext context) {
    final activeClip = project.activeClip;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Timeline',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Text(
              '${formatMillis(activeClip.startMillis)} - '
              '${formatMillis(activeClip.endMillis)} '
              '(${formatMillis(activeClip.durationMillis)})',
            ),
            RangeSlider(
              min: 0,
              max: project.durationMillis.toDouble(),
              values: RangeValues(
                activeClip.startMillis.toDouble(),
                activeClip.endMillis.toDouble(),
              ),
              labels: RangeLabels(
                formatMillis(activeClip.startMillis),
                formatMillis(activeClip.endMillis),
              ),
              onChanged: onRangeChanged,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final clip in project.clips)
                  ChoiceChip(
                    label: Text(
                      '${clip.name} · ${formatMillis(clip.durationMillis)}',
                    ),
                    selected: clip.id == project.activeClipId,
                    onSelected: (_) => onSelectClip(clip.id),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EditorPanel extends StatelessWidget {
  const _EditorPanel({
    required this.activePanel,
    required this.template,
    required this.clipCount,
    required this.targetDuration,
  });

  final String activePanel;
  final String template;
  final String clipCount;
  final String targetDuration;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activePanel,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('Template: $template'),
            Text('Jumlah clip: $clipCount'),
            Text('Durasi target: $targetDuration'),
            const SizedBox(height: 12),
            const Text('Panel detail akan diisi setelah timeline manual siap.'),
          ],
        ),
      ),
    );
  }
}

class _MissingEditorState extends StatelessWidget {
  const _MissingEditorState({required this.onBackHome});

  final VoidCallback onBackHome;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.edit_outlined, size: 56),
            const SizedBox(height: 16),
            Text(
              'Project belum siap',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Pilih video dan atur project terlebih dahulu.',
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
