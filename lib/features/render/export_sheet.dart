import 'package:flutter/material.dart';

import '../editor/editor_project.dart';
import 'export_options.dart';

Future<void> showExportSheet({
  required BuildContext context,
  required EditorClip clip,
  required ValueChanged<ExportOptions> onExport,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => ExportSheet(clip: clip, onExport: onExport),
  );
}

class ExportSheet extends StatefulWidget {
  const ExportSheet({required this.clip, required this.onExport, super.key});

  final EditorClip clip;
  final ValueChanged<ExportOptions> onExport;

  @override
  State<ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<ExportSheet> {
  String _resolution = '1080p';
  String _frameRate = '30';
  String _codec = 'H.264';

  @override
  Widget build(BuildContext context) {
    final options = ExportOptions(
      resolution: _resolution,
      frameRate: _frameRate,
      codec: _codec,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            const _FieldLabel('Resolusi'),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: '720p', label: Text('720p')),
                ButtonSegment(value: '1080p', label: Text('1080p')),
                ButtonSegment(value: '4K', label: Text('4K')),
              ],
              selected: {_resolution},
              onSelectionChanged: (value) =>
                  setState(() => _resolution = value.single),
            ),
            const SizedBox(height: 16),
            const _FieldLabel('Frame rate'),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: '30', label: Text('30')),
                ButtonSegment(value: '60', label: Text('60')),
              ],
              selected: {_frameRate},
              onSelectionChanged: (value) =>
                  setState(() => _frameRate = value.single),
            ),
            const SizedBox(height: 16),
            const _FieldLabel('Codec'),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'H.264', label: Text('H.264')),
                ButtonSegment(value: 'HEVC', label: Text('HEVC')),
              ],
              selected: {_codec},
              onSelectionChanged: (value) =>
                  setState(() => _codec = value.single),
            ),
            const SizedBox(height: 16),
            Text(
              'Estimasi: ${options.estimateSizeLabel(widget.clip)} · '
              '${formatMillis(widget.clip.durationMillis)}',
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onExport(options);
              },
              child: const Text('Mulai Export'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
