import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../import/selected_video_controller.dart';
import 'editor_project_controller.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  String _activePanel = 'Clips';
  bool _isPlaying = false;

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
                  ),
                  const SizedBox(height: 16),
                  const _TimelinePlaceholder(),
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
              child: FilledButton(
                onPressed: null,
                child: const Text('Export (segera hadir)'),
              ),
            ),
          ],
        ),
      ),
    );
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
  const _TransportBar({required this.isPlaying, required this.onPlayPause});

  final bool isPlaying;
  final VoidCallback onPlayPause;

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
              onPressed: () {},
              icon: const Icon(Icons.content_cut_rounded),
              label: const Text('Cut'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelinePlaceholder extends StatelessWidget {
  const _TimelinePlaceholder();

  @override
  Widget build(BuildContext context) {
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
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: 0.35,
                backgroundColor: Theme.of(context).colorScheme.surface,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 36,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Text('Clip 1 · drag handles coming next'),
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
