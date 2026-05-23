enum WatermarkAnchor {
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

class WatermarkConfig {
  const WatermarkConfig({
    this.text,
    this.imagePath,
    this.anchor = WatermarkAnchor.bottomRight,
    this.customX,
    this.customY,
    this.opacity = 0.75,
    this.scale = 1,
  });

  factory WatermarkConfig.fromJson(Map<String, dynamic> json) {
    return WatermarkConfig(
      text: json['text'] as String?,
      imagePath: json['imagePath'] as String?,
      anchor: WatermarkAnchor.values.firstWhere(
        (anchor) => anchor.name == json['anchor'],
        orElse: () => WatermarkAnchor.bottomRight,
      ),
      customX: (json['customX'] as num?)?.toDouble(),
      customY: (json['customY'] as num?)?.toDouble(),
      opacity: ((json['opacity'] as num?)?.toDouble() ?? 0.75).clamp(0, 1),
      scale: ((json['scale'] as num?)?.toDouble() ?? 1).clamp(0.25, 4),
    );
  }

  final String? text;
  final String? imagePath;
  final WatermarkAnchor anchor;
  final double? customX;
  final double? customY;
  final double opacity;
  final double scale;

  bool get hasContent {
    return (text != null && text!.trim().isNotEmpty) ||
        (imagePath != null && imagePath!.trim().isNotEmpty);
  }

  Map<String, dynamic> toJson() {
    return {
      if (text != null) 'text': text,
      if (imagePath != null) 'imagePath': imagePath,
      'anchor': anchor.name,
      if (customX != null) 'customX': customX,
      if (customY != null) 'customY': customY,
      'opacity': opacity,
      'scale': scale,
    };
  }

  WatermarkConfig copyWith({
    String? text,
    String? imagePath,
    WatermarkAnchor? anchor,
    double? customX,
    double? customY,
    double? opacity,
    double? scale,
  }) {
    return WatermarkConfig(
      text: text ?? this.text,
      imagePath: imagePath ?? this.imagePath,
      anchor: anchor ?? this.anchor,
      customX: customX ?? this.customX,
      customY: customY ?? this.customY,
      opacity: opacity ?? this.opacity,
      scale: scale ?? this.scale,
    );
  }
}
