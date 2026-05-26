import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'caption_segmenter.dart';
import '../transcription/transcription_provider.dart';

final captionDocumentProvider = StateProvider<CaptionDocument>((ref) {
  return const CaptionDocument(
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
});

class CaptionDocument {
  const CaptionDocument({
    required this.items,
    this.style = const CaptionStyleConfig(),
  });

  factory CaptionDocument.fromTranscript(
    Transcript transcript, {
    CaptionStyleConfig style = const CaptionStyleConfig(),
    CaptionSegmenter segmenter = const CaptionSegmenter(),
  }) {
    final segments = segmenter.segment(transcript);
    return CaptionDocument(
      style: style,
      items: [
        for (final (index, segment) in segments.indexed)
          CaptionItem(
            id: 'caption-${index + 1}',
            text: segment.text,
            startMillis: segment.startMillis,
            endMillis: segment.endMillis,
          ),
      ],
    );
  }

  factory CaptionDocument.fromJson(Map<String, dynamic> json) {
    final items = json['items'];
    return CaptionDocument(
      items: items is List
          ? items
                .whereType<Map<String, dynamic>>()
                .map(CaptionItem.fromJson)
                .toList(growable: false)
          : const [],
      style: CaptionStyleConfig.fromJson(
        json['style'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  final List<CaptionItem> items;
  final CaptionStyleConfig style;

  CaptionDocument updateText({required String id, required String text}) {
    return CaptionDocument(
      style: style,
      items: [
        for (final item in items)
          if (item.id == id) item.copyWith(text: text) else item,
      ],
    );
  }

  CaptionDocument updateTiming({
    required String id,
    required int startMillis,
    required int endMillis,
  }) {
    if (endMillis <= startMillis) {
      return this;
    }

    return CaptionDocument(
      style: style,
      items: [
        for (final item in items)
          if (item.id == id)
            item.copyWith(startMillis: startMillis, endMillis: endMillis)
          else
            item,
      ],
    );
  }

  CaptionDocument updateStyle(CaptionStyleConfig value) {
    return CaptionDocument(items: items, style: value);
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'style': style.toJson(),
    };
  }
}

class CaptionItem {
  const CaptionItem({
    required this.id,
    required this.text,
    required this.startMillis,
    required this.endMillis,
  });

  factory CaptionItem.fromJson(Map<String, dynamic> json) {
    return CaptionItem(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      startMillis: (json['startMillis'] as num?)?.toInt() ?? 0,
      endMillis: (json['endMillis'] as num?)?.toInt() ?? 0,
    );
  }

  final String id;
  final String text;
  final int startMillis;
  final int endMillis;

  CaptionItem copyWith({String? text, int? startMillis, int? endMillis}) {
    return CaptionItem(
      id: id,
      text: text ?? this.text,
      startMillis: startMillis ?? this.startMillis,
      endMillis: endMillis ?? this.endMillis,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'startMillis': startMillis,
      'endMillis': endMillis,
    };
  }
}

class CaptionStyleConfig {
  const CaptionStyleConfig({
    this.fontFamily = 'System',
    this.size = 42,
    this.highlightColor = 0xFF4F46E5,
    this.position = CaptionPosition.bottomCenter,
    this.animation = CaptionAnimation.none,
  });

  factory CaptionStyleConfig.fromJson(Map<String, dynamic> json) {
    return CaptionStyleConfig(
      fontFamily: json['fontFamily'] as String? ?? 'System',
      size: (json['size'] as num?)?.toDouble() ?? 42,
      highlightColor: (json['highlightColor'] as num?)?.toInt() ?? 0xFF4F46E5,
      position: CaptionPosition.values.firstWhere(
        (value) => value.name == json['position'],
        orElse: () => CaptionPosition.bottomCenter,
      ),
      animation: CaptionAnimation.values.firstWhere(
        (value) => value.name == json['animation'],
        orElse: () => CaptionAnimation.none,
      ),
    );
  }

  final String fontFamily;
  final double size;
  final int highlightColor;
  final CaptionPosition position;
  final CaptionAnimation animation;

  CaptionStyleConfig copyWith({
    String? fontFamily,
    double? size,
    int? highlightColor,
    CaptionPosition? position,
    CaptionAnimation? animation,
  }) {
    return CaptionStyleConfig(
      fontFamily: fontFamily ?? this.fontFamily,
      size: (size ?? this.size).clamp(20, 96),
      highlightColor: highlightColor ?? this.highlightColor,
      position: position ?? this.position,
      animation: animation ?? this.animation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fontFamily': fontFamily,
      'size': size,
      'highlightColor': highlightColor,
      'position': position.name,
      'animation': animation.name,
    };
  }
}

enum CaptionPosition {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  center,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

enum CaptionAnimation { none, karaoke, typewriter }
