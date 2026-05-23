import 'package:flutter/material.dart';

import '../editor/editor_project.dart';
import 'caption_document.dart';

class CaptionEditorScreen extends StatefulWidget {
  const CaptionEditorScreen({super.key});

  @override
  State<CaptionEditorScreen> createState() => _CaptionEditorScreenState();
}

class _CaptionEditorScreenState extends State<CaptionEditorScreen> {
  CaptionDocument _document = const CaptionDocument(
    items: [
      CaptionItem(
        id: '1',
        text: 'Tap to edit caption text',
        startMillis: 0,
        endMillis: 1800,
      ),
      CaptionItem(
        id: '2',
        text: 'Drag timing handles later',
        startMillis: 1900,
        endMillis: 3600,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Caption Editor')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _CaptionStyleCard(
            style: _document.style,
            onChanged: (style) =>
                setState(() => _document = _document.updateStyle(style)),
          ),
          const SizedBox(height: 16),
          for (final item in _document.items) ...[
            _CaptionItemCard(
              item: item,
              onChanged: (text) => setState(() {
                _document = _document.updateText(id: item.id, text: text);
              }),
              onTimingChanged: (values) => setState(() {
                _document = _document.updateTiming(
                  id: item.id,
                  startMillis: values.start.round(),
                  endMillis: values.end.round(),
                );
              }),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _CaptionStyleCard extends StatelessWidget {
  const _CaptionStyleCard({required this.style, required this.onChanged});

  final CaptionStyleConfig style;
  final ValueChanged<CaptionStyleConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Style', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: style.fontFamily,
              decoration: const InputDecoration(labelText: 'Font'),
              items: const [
                DropdownMenuItem(value: 'System', child: Text('System')),
                DropdownMenuItem(value: 'Inter', child: Text('Inter')),
                DropdownMenuItem(value: 'Roboto', child: Text('Roboto')),
              ],
              onChanged: (value) {
                if (value != null) {
                  onChanged(style.copyWith(fontFamily: value));
                }
              },
            ),
            Slider(
              value: style.size,
              min: 20,
              max: 96,
              divisions: 19,
              label: style.size.round().toString(),
              onChanged: (value) => onChanged(style.copyWith(size: value)),
            ),
            Wrap(
              spacing: 8,
              children: [
                for (final color in const [
                  0xFF4F46E5,
                  0xFFF97316,
                  0xFF22C55E,
                  0xFF0EA5E9,
                ])
                  ChoiceChip(
                    label: const Text(''),
                    avatar: CircleAvatar(backgroundColor: Color(color)),
                    selected: style.highlightColor == color,
                    onSelected: (_) =>
                        onChanged(style.copyWith(highlightColor: color)),
                  ),
              ],
            ),
            DropdownButtonFormField<CaptionAnimation>(
              initialValue: style.animation,
              decoration: const InputDecoration(labelText: 'Animation'),
              items: const [
                DropdownMenuItem(
                  value: CaptionAnimation.none,
                  child: Text('None'),
                ),
                DropdownMenuItem(
                  value: CaptionAnimation.karaoke,
                  child: Text('Karaoke'),
                ),
                DropdownMenuItem(
                  value: CaptionAnimation.typewriter,
                  child: Text('Typewriter'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  onChanged(style.copyWith(animation: value));
                }
              },
            ),
            DropdownButtonFormField<CaptionPosition>(
              initialValue: style.position,
              decoration: const InputDecoration(labelText: 'Position'),
              items: const [
                DropdownMenuItem(
                  value: CaptionPosition.topLeft,
                  child: Text('Top left'),
                ),
                DropdownMenuItem(
                  value: CaptionPosition.topCenter,
                  child: Text('Top center'),
                ),
                DropdownMenuItem(
                  value: CaptionPosition.topRight,
                  child: Text('Top right'),
                ),
                DropdownMenuItem(
                  value: CaptionPosition.centerLeft,
                  child: Text('Center left'),
                ),
                DropdownMenuItem(
                  value: CaptionPosition.center,
                  child: Text('Center'),
                ),
                DropdownMenuItem(
                  value: CaptionPosition.centerRight,
                  child: Text('Center right'),
                ),
                DropdownMenuItem(
                  value: CaptionPosition.bottomLeft,
                  child: Text('Bottom left'),
                ),
                DropdownMenuItem(
                  value: CaptionPosition.bottomCenter,
                  child: Text('Bottom center'),
                ),
                DropdownMenuItem(
                  value: CaptionPosition.bottomRight,
                  child: Text('Bottom right'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  onChanged(style.copyWith(position: value));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CaptionItemCard extends StatelessWidget {
  const _CaptionItemCard({
    required this.item,
    required this.onChanged,
    required this.onTimingChanged,
  });

  final CaptionItem item;
  final ValueChanged<String> onChanged;
  final ValueChanged<RangeValues> onTimingChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${formatMillis(item.startMillis)} - ${formatMillis(item.endMillis)}',
            ),
            TextFormField(
              initialValue: item.text,
              decoration: const InputDecoration(labelText: 'Caption text'),
              onChanged: onChanged,
            ),
            RangeSlider(
              min: 0,
              max: 10000,
              values: RangeValues(
                item.startMillis.toDouble().clamp(0, 10000),
                item.endMillis.toDouble().clamp(0, 10000),
              ),
              labels: RangeLabels(
                formatMillis(item.startMillis),
                formatMillis(item.endMillis),
              ),
              onChanged: onTimingChanged,
            ),
          ],
        ),
      ),
    );
  }
}
