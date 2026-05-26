import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../import/selected_video_controller.dart';
import '../library/export_history.dart';
import '../onboarding/groq_api_key_controller.dart';
import '../render/export_options.dart';
import '../render/export_sheet.dart';
import '../render/trim_exporter.dart';
import '../subject_tracking/subject_tracking.dart';
import '../subject_tracking/subject_tracking_panel.dart';
import '../subtitle/caption_document.dart';
import '../templates/template_presets.dart';
import '../transcription/transcription_progress.dart';
import '../transcription/transcription_progress_card.dart';
import '../transcription/caption_generation_controller.dart';
import '../transcription/transcription_language.dart';
import '../watermark/watermark_config.dart';
import '../watermark/watermark_preview.dart';
import 'editor_project.dart';
import 'editor_project_controller.dart';
import 'post_import_tutorial_card.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  String _activePanel = 'Clips';
  bool _isPlaying = false;
  bool _isExporting = false;
  bool _removeFillerWords = false;
  int _playheadMillis = 0;
  TranscriptionLanguage _captionLanguage = TranscriptionLanguage.auto;
  double _exportProgress = 0;
  WatermarkConfig _watermarkConfig = const WatermarkConfig(
    text: '@LanggengClip',
  );
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
    final sessionLoader = ref.watch(activeEditorSessionLoaderProvider);
    final video = ref.watch(selectedVideoProvider);
    final project = ref.watch(editorProjectProvider);

    if (sessionLoader.isLoading && (video == null || project == null)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editor')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
            onPressed: () => _showEditorMenu(context),
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
                  _PreviewPanel(
                    fileName: video.name,
                    filePath: video.path,
                    fileAvailable: video.existsOnDevice,
                    isPlaying: _isPlaying,
                    playheadMillis: project.clampPlayheadMillis(
                      _playheadMillis,
                    ),
                    playheadLabel: formatMillis(
                      project.clampPlayheadMillis(_playheadMillis),
                    ),
                    activeClipLabel:
                        '${formatMillis(project.activeClip.startMillis)} - '
                        '${formatMillis(project.activeClip.endMillis)}',
                    clipStartMillis: project.activeClip.startMillis,
                    clipEndMillis: project.activeClip.endMillis,
                    onPlayheadChanged: (value) {
                      if (mounted) {
                        setState(() => _playheadMillis = value);
                      }
                    },
                    onPlaybackEnded: () {
                      if (mounted) {
                        setState(() => _isPlaying = false);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  const PostImportTutorialCard(),
                  const SizedBox(height: 12),
                  _TransportBar(
                    isPlaying: _isPlaying,
                    onPlayPause: () => setState(() => _isPlaying = !_isPlaying),
                    onSkipPrevious: _skipToActiveClipStart,
                    onSkipNext: _skipToActiveClipEnd,
                    onCut: _addClipFromActiveRange,
                  ),
                  const SizedBox(height: 16),
                  _TimelineEditor(
                    project: project,
                    onRangeChanged: _updateActiveClipRange,
                    playheadMillis: project.clampPlayheadMillis(
                      _playheadMillis,
                    ),
                    onPlayheadChanged: _updatePlayhead,
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
                    mode: project.mode,
                    template: project.template,
                    clipCount: project.clipCount,
                    targetDuration: project.targetDuration,
                    removeFillerWords: _removeFillerWords,
                    captionLanguage: _captionLanguage,
                    watermarkConfig: _watermarkConfig,
                    onTemplateSelected: _applyTemplate,
                    onCaptionLanguageChanged: (value) {
                      setState(() => _captionLanguage = value);
                    },
                    onRemoveFillerWordsChanged: (value) {
                      setState(() => _removeFillerWords = value);
                    },
                    onWatermarkChanged: (value) {
                      setState(() => _watermarkConfig = value);
                    },
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
                    onPressed: _isExporting || !video.existsOnDevice
                        ? null
                        : () => showExportSheet(
                            context: context,
                            clip: project.activeClip,
                            onExport: (options) => _exportActiveClipWithOptions(
                              video.path,
                              project.activeClip,
                              options,
                              ref.read(captionDocumentProvider).items,
                            ),
                          ),
                    child: _isExporting
                        ? const Text('Exporting...')
                        : Text(
                            video.existsOnDevice
                                ? 'Export active clip'
                                : 'Source file missing',
                          ),
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

    final updatedProject = project.updateActiveClipRange(
      startMillis: values.start.round(),
      endMillis: values.end.round(),
    );
    ref.read(editorProjectProvider.notifier).state = updatedProject;
    setState(() {
      _playheadMillis = updatedProject.clampPlayheadMillis(_playheadMillis);
    });
    unawaited(saveActiveEditorSession(ref));
  }

  void _updatePlayhead(double value) {
    final project = ref.read(editorProjectProvider);
    if (project == null) {
      return;
    }

    setState(
      () => _playheadMillis = project.clampPlayheadMillis(value.round()),
    );
  }

  void _skipToActiveClipStart() {
    final project = ref.read(editorProjectProvider);
    if (project == null) {
      return;
    }

    setState(() {
      _isPlaying = false;
      _playheadMillis = project.skipToActiveClipStart();
    });
  }

  void _skipToActiveClipEnd() {
    final project = ref.read(editorProjectProvider);
    if (project == null) {
      return;
    }

    setState(() {
      _isPlaying = false;
      _playheadMillis = project.skipToActiveClipEnd();
    });
  }

  void _addClipFromActiveRange() {
    final project = ref.read(editorProjectProvider);
    if (project == null) {
      return;
    }

    ref.read(editorProjectProvider.notifier).state = project
        .addClipFromActiveRange();
    unawaited(saveActiveEditorSession(ref));
  }

  void _selectClip(String id) {
    final project = ref.read(editorProjectProvider);
    if (project == null) {
      return;
    }

    final updatedProject = project.setActiveClip(id);
    ref.read(editorProjectProvider.notifier).state = updatedProject;
    setState(() {
      _isPlaying = false;
      _playheadMillis = updatedProject.activeClip.startMillis;
    });
    unawaited(saveActiveEditorSession(ref));
  }

  void _applyTemplate(String templateName) {
    final project = ref.read(editorProjectProvider);
    if (project == null) {
      return;
    }

    ref.read(editorProjectProvider.notifier).state = project.applyTemplate(
      templateName,
    );
    unawaited(saveActiveEditorSession(ref));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$templateName template applied.')));
  }

  Future<void> _exportActiveClipWithOptions(
    String sourcePath,
    EditorClip clip,
    ExportOptions options,
    List<CaptionItem> captionItems,
  ) async {
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
            options: options,
            captionItems: captionItems,
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
            resolution: exportResult.resolution,
            frameRate: exportResult.frameRate,
            codec: exportResult.codec,
            targetWidth: exportResult.targetWidth,
            targetHeight: exportResult.targetHeight,
            cropToPortrait: exportResult.cropToPortrait,
            requiresReencode: exportResult.requiresReencode,
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
          action: SnackBarAction(
            label: 'Library',
            onPressed: () => context.go('/library'),
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

  Future<void> _showEditorMenu(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Rename project'),
                onTap: () => Navigator.of(context).pop('rename'),
              ),
              ListTile(
                leading: const Icon(Icons.refresh_rounded),
                title: const Text('Reset to first clip'),
                onTap: () => Navigator.of(context).pop('reset'),
              ),
              ListTile(
                leading: const Icon(Icons.help_outline_rounded),
                title: const Text('Open help center'),
                onTap: () => Navigator.of(context).pop('help'),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || action == null) {
      return;
    }

    switch (action) {
      case 'rename':
        final project = ref.read(editorProjectProvider);
        if (project != null && context.mounted) {
          await _renameProject(context, project.title);
        }
      case 'reset':
        final project = ref.read(editorProjectProvider);
        if (project != null && project.clips.isNotEmpty) {
          ref.read(editorProjectProvider.notifier).state = project
              .setActiveClip(project.clips.first.id);
          unawaited(saveActiveEditorSession(ref));
          messenger.showSnackBar(
            const SnackBar(content: Text('Kembali ke clip pertama.')),
          );
        }
      case 'help':
        router.go('/help');
    }
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
    unawaited(saveActiveEditorSession(ref));
  }
}

class _PreviewPanel extends StatefulWidget {
  const _PreviewPanel({
    required this.fileName,
    required this.filePath,
    required this.fileAvailable,
    required this.isPlaying,
    required this.playheadMillis,
    required this.playheadLabel,
    required this.activeClipLabel,
    required this.clipStartMillis,
    required this.clipEndMillis,
    required this.onPlayheadChanged,
    required this.onPlaybackEnded,
  });

  final String fileName;
  final String filePath;
  final bool fileAvailable;
  final bool isPlaying;
  final int playheadMillis;
  final String playheadLabel;
  final String activeClipLabel;
  final int clipStartMillis;
  final int clipEndMillis;
  final ValueChanged<int> onPlayheadChanged;
  final VoidCallback onPlaybackEnded;

  @override
  State<_PreviewPanel> createState() => _PreviewPanelState();
}

class _PreviewPanelState extends State<_PreviewPanel> {
  VideoPlayerController? _controller;
  bool _isInitializing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeControllerIfNeeded();
  }

  @override
  void didUpdateWidget(_PreviewPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filePath != widget.filePath ||
        oldWidget.fileAvailable != widget.fileAvailable) {
      _disposeController();
      _initializeControllerIfNeeded();
      return;
    }

    _syncPlaybackState();
    _syncPlayhead(oldWidget.playheadMillis);
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  Future<void> _initializeControllerIfNeeded() async {
    if (!widget.fileAvailable || widget.filePath.isEmpty) {
      return;
    }

    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    final controller = VideoPlayerController.file(File(widget.filePath));
    _controller = controller;
    controller.addListener(_handleControllerTick);

    try {
      await controller.initialize();
      await controller.setLooping(false);
      await controller.seekTo(Duration(milliseconds: widget.playheadMillis));
      if (!mounted || _controller != controller) {
        return;
      }

      setState(() => _isInitializing = false);
      _syncPlaybackState();
    } catch (_) {
      if (!mounted || _controller != controller) {
        return;
      }

      setState(() {
        _isInitializing = false;
        _errorMessage = 'Preview video gagal dimuat.';
      });
    }
  }

  void _handleControllerTick() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    final positionMillis = controller.value.position.inMilliseconds;
    if (positionMillis >= widget.clipEndMillis && controller.value.isPlaying) {
      controller.pause();
      controller.seekTo(Duration(milliseconds: widget.clipEndMillis));
      widget.onPlaybackEnded();
      widget.onPlayheadChanged(widget.clipEndMillis);
      return;
    }

    if ((positionMillis - widget.playheadMillis).abs() >= 250) {
      widget.onPlayheadChanged(
        positionMillis.clamp(widget.clipStartMillis, widget.clipEndMillis),
      );
    }
  }

  void _syncPlaybackState() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (widget.isPlaying && !controller.value.isPlaying) {
      if (controller.value.position.inMilliseconds >= widget.clipEndMillis) {
        controller.seekTo(Duration(milliseconds: widget.clipStartMillis));
      }
      unawaited(controller.play());
      return;
    }

    if (!widget.isPlaying && controller.value.isPlaying) {
      unawaited(controller.pause());
    }
  }

  void _syncPlayhead(int oldPlayheadMillis) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (widget.playheadMillis == oldPlayheadMillis) {
      return;
    }

    final controllerMillis = controller.value.position.inMilliseconds;
    if ((controllerMillis - widget.playheadMillis).abs() >= 250) {
      unawaited(
        controller.seekTo(Duration(milliseconds: widget.playheadMillis)),
      );
    }
  }

  void _disposeController() {
    final controller = _controller;
    _controller = null;
    controller?.removeListener(_handleControllerTick);
    unawaited(controller?.dispose() ?? Future<void>.value());
  }

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
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildVideoSurface(context),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: _PreviewStatusOverlay(
                  fileName: widget.fileName,
                  fileAvailable: widget.fileAvailable,
                  isPlaying: widget.isPlaying,
                  playheadLabel: widget.playheadLabel,
                  activeClipLabel: widget.activeClipLabel,
                  errorMessage: _errorMessage,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoSurface(BuildContext context) {
    final controller = _controller;
    if (!widget.fileAvailable) {
      return const _PreviewPlaceholder(
        icon: Icons.video_file_outlined,
        label: 'Source file tidak tersedia',
      );
    }

    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null || controller == null) {
      return const _PreviewPlaceholder(
        icon: Icons.error_outline_rounded,
        label: 'Preview video gagal dimuat',
      );
    }

    if (!controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
      ),
    );
  }
}

class _PreviewPlaceholder extends StatelessWidget {
  const _PreviewPlaceholder({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 64),
        const SizedBox(height: 12),
        Text(label, textAlign: TextAlign.center),
      ],
    );
  }
}

class _PreviewStatusOverlay extends StatelessWidget {
  const _PreviewStatusOverlay({
    required this.fileName,
    required this.fileAvailable,
    required this.isPlaying,
    required this.playheadLabel,
    required this.activeClipLabel,
    this.errorMessage,
  });

  final String fileName;
  final bool fileAvailable;
  final bool isPlaying;
  final String playheadLabel;
  final String activeClipLabel;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              errorMessage ??
                  (fileAvailable
                      ? 'Preview $playheadLabel · Clip $activeClipLabel'
                      : 'Source file tidak tersedia'),
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransportBar extends StatelessWidget {
  const _TransportBar({
    required this.isPlaying,
    required this.onPlayPause,
    required this.onSkipPrevious,
    required this.onSkipNext,
    required this.onCut,
  });

  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onSkipPrevious;
  final VoidCallback onSkipNext;
  final VoidCallback onCut;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: onSkipPrevious,
              icon: const Icon(Icons.skip_previous),
            ),
            IconButton(
              onPressed: onPlayPause,
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            ),
            IconButton(
              onPressed: onSkipNext,
              icon: const Icon(Icons.skip_next),
            ),
            TextButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fit-to-screen preview aktif.')),
              ),
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
    required this.playheadMillis,
    required this.onRangeChanged,
    required this.onPlayheadChanged,
    required this.onSelectClip,
  });

  final EditorProject project;
  final int playheadMillis;
  final ValueChanged<RangeValues> onRangeChanged;
  final ValueChanged<double> onPlayheadChanged;
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
            Row(
              children: [
                const Icon(Icons.my_location_rounded, size: 18),
                const SizedBox(width: 8),
                Text('Playhead: ${formatMillis(playheadMillis)}'),
              ],
            ),
            Slider(
              min: activeClip.startMillis.toDouble(),
              max: activeClip.endMillis.toDouble(),
              value: playheadMillis
                  .clamp(activeClip.startMillis, activeClip.endMillis)
                  .toDouble(),
              label: formatMillis(playheadMillis),
              onChanged: onPlayheadChanged,
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
    required this.mode,
    required this.template,
    required this.clipCount,
    required this.targetDuration,
    required this.removeFillerWords,
    required this.captionLanguage,
    required this.watermarkConfig,
    required this.onTemplateSelected,
    required this.onCaptionLanguageChanged,
    required this.onRemoveFillerWordsChanged,
    required this.onWatermarkChanged,
  });

  final String activePanel;
  final String mode;
  final String template;
  final String clipCount;
  final String targetDuration;
  final bool removeFillerWords;
  final TranscriptionLanguage captionLanguage;
  final WatermarkConfig watermarkConfig;
  final ValueChanged<String> onTemplateSelected;
  final ValueChanged<TranscriptionLanguage> onCaptionLanguageChanged;
  final ValueChanged<bool> onRemoveFillerWordsChanged;
  final ValueChanged<WatermarkConfig> onWatermarkChanged;

  @override
  Widget build(BuildContext context) {
    return switch (activePanel) {
      'Caption' => _CaptionToolPanel(
        language: captionLanguage,
        onLanguageChanged: onCaptionLanguageChanged,
      ),
      'Style' => _TemplateToolPanel(
        template: template,
        mode: mode,
        clipCount: clipCount,
        targetDuration: targetDuration,
        onTemplateSelected: onTemplateSelected,
      ),
      'Watermark' => _WatermarkToolPanel(
        config: watermarkConfig,
        onChanged: onWatermarkChanged,
      ),
      'Audio' => _AudioToolPanel(
        removeFillerWords: removeFillerWords,
        onRemoveFillerWordsChanged: onRemoveFillerWordsChanged,
      ),
      _ => _ClipsToolPanel(
        template: template,
        mode: mode,
        clipCount: clipCount,
        targetDuration: targetDuration,
      ),
    };
  }
}

class _ClipsToolPanel extends StatelessWidget {
  const _ClipsToolPanel({
    required this.template,
    required this.mode,
    required this.clipCount,
    required this.targetDuration,
  });

  final String template;
  final String mode;
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
              'Clips',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('Mode: $mode'),
            Text('Template: $template'),
            Text('Jumlah clip: $clipCount'),
            Text('Durasi target: $targetDuration'),
            const SizedBox(height: 12),
            const Text(
              'Gunakan timeline untuk atur range, lalu Add untuk membuat clip.',
            ),
          ],
        ),
      ),
    );
  }
}

class _CaptionToolPanel extends ConsumerWidget {
  const _CaptionToolPanel({
    required this.language,
    required this.onLanguageChanged,
  });

  final TranscriptionLanguage language;
  final ValueChanged<TranscriptionLanguage> onLanguageChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final video = ref.watch(selectedVideoProvider);
    final project = ref.watch(editorProjectProvider);
    final generationState = ref.watch(captionGenerationControllerProvider);
    final apiKeyState = ref.watch(groqApiKeyControllerProvider).valueOrNull;
    final hasApiKey = apiKeyState?.hasKey ?? false;
    final progress =
        generationState.valueOrNull ??
        const TranscriptionProgressState(
          completedChunks: 0,
          totalChunks: 0,
          currentLabel: 'Transcription belum dijalankan',
        );
    final error = generationState.error;
    final isGenerating = generationState.isLoading;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Captions',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TranscriptionProgressCard(state: progress),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            if (!hasApiKey) ...[
              const SizedBox(height: 8),
              Text(
                'Groq API key diperlukan untuk generate subtitle baru.',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ],
            const SizedBox(height: 12),
            DropdownButtonFormField<TranscriptionLanguage>(
              initialValue: language,
              decoration: const InputDecoration(labelText: 'Language'),
              items: [
                for (final option in TranscriptionLanguage.supported)
                  DropdownMenuItem(value: option, child: Text(option.label)),
              ],
              onChanged: isGenerating
                  ? null
                  : (value) {
                      if (value != null) {
                        onLanguageChanged(value);
                      }
                    },
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: isGenerating || video == null || project == null
                  ? null
                  : hasApiKey
                  ? () => ref
                        .read(captionGenerationControllerProvider.notifier)
                        .generate(
                          video: video,
                          project: project,
                          settings: TranscriptionSettings(language: language),
                        )
                  : () => context.go('/setup/api-key'),
              icon: isGenerating
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      hasApiKey
                          ? Icons.auto_awesome_rounded
                          : Icons.key_rounded,
                    ),
              label: Text(
                isGenerating
                    ? 'Generating...'
                    : hasApiKey
                    ? 'Generate subtitle'
                    : 'Setup API key',
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => context.go('/editor/captions'),
              icon: const Icon(Icons.closed_caption_rounded),
              label: const Text('Open caption editor'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Subtitle akan memakai cache transcript jika video pernah diproses.',
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateToolPanel extends StatelessWidget {
  const _TemplateToolPanel({
    required this.template,
    required this.mode,
    required this.clipCount,
    required this.targetDuration,
    required this.onTemplateSelected,
  });

  final String template;
  final String mode;
  final String clipCount;
  final String targetDuration;
  final ValueChanged<String> onTemplateSelected;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Templates',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Current setup: $mode · $template · $clipCount clips · $targetDuration',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final preset in TemplatePresets.all)
                  ActionChip(
                    label: Text(preset.name),
                    avatar: const Icon(Icons.auto_awesome_rounded, size: 18),
                    onPressed: () => onTemplateSelected(preset.name),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioToolPanel extends StatelessWidget {
  const _AudioToolPanel({
    required this.removeFillerWords,
    required this.onRemoveFillerWordsChanged,
  });

  final bool removeFillerWords;
  final ValueChanged<bool> onRemoveFillerWordsChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Highlights',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Auto highlight scoring, filler-word toggle, dan semi-auto candidate model sudah siap. Deteksi audio/scene native masih pending.',
            ),
            const SizedBox(height: 12),
            const SubjectTrackingPanel(config: SubjectTrackingConfig()),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Remove filler words'),
              subtitle: const Text(
                'Default off; applies when transcript is ready.',
              ),
              value: removeFillerWords,
              onChanged: onRemoveFillerWordsChanged,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('AI highlight engine ready.')),
                );
              },
              icon: const Icon(Icons.auto_graph_rounded),
              label: const Text('Preview AI candidates'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WatermarkToolPanel extends StatelessWidget {
  const _WatermarkToolPanel({required this.config, required this.onChanged});

  final WatermarkConfig config;
  final ValueChanged<WatermarkConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Watermark',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            WatermarkPreview(config: config),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: config.text,
              decoration: const InputDecoration(labelText: 'Text watermark'),
              onChanged: (value) => onChanged(config.copyWith(text: value)),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<WatermarkAnchor>(
              initialValue: config.anchor,
              decoration: const InputDecoration(labelText: 'Position'),
              items: const [
                DropdownMenuItem(
                  value: WatermarkAnchor.topLeft,
                  child: Text('Top left'),
                ),
                DropdownMenuItem(
                  value: WatermarkAnchor.topCenter,
                  child: Text('Top center'),
                ),
                DropdownMenuItem(
                  value: WatermarkAnchor.topRight,
                  child: Text('Top right'),
                ),
                DropdownMenuItem(
                  value: WatermarkAnchor.center,
                  child: Text('Center'),
                ),
                DropdownMenuItem(
                  value: WatermarkAnchor.bottomLeft,
                  child: Text('Bottom left'),
                ),
                DropdownMenuItem(
                  value: WatermarkAnchor.bottomCenter,
                  child: Text('Bottom center'),
                ),
                DropdownMenuItem(
                  value: WatermarkAnchor.bottomRight,
                  child: Text('Bottom right'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  onChanged(config.copyWith(anchor: value));
                }
              },
            ),
            Slider(
              value: config.opacity,
              min: 0,
              max: 1,
              divisions: 10,
              label: 'Opacity ${(config.opacity * 100).round()}%',
              onChanged: (value) => onChanged(config.copyWith(opacity: value)),
            ),
            Slider(
              value: config.scale,
              min: 0.25,
              max: 4,
              divisions: 15,
              label: 'Scale ${config.scale.toStringAsFixed(2)}x',
              onChanged: (value) => onChanged(config.copyWith(scale: value)),
            ),
            const Text(
              'Text/image config, anchors, drag coordinates, opacity, scale, dan preview sudah siap. Native overlay render masih pending.',
            ),
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
