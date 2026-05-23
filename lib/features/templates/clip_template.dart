class ClipTemplate {
  const ClipTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.captionStyle,
    required this.layout,
    required this.watermarkEnabledByDefault,
  });

  factory ClipTemplate.fromJson(Map<String, dynamic> json) {
    return ClipTemplate(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      captionStyle: CaptionStyle.fromJson(
        json['captionStyle'] as Map<String, dynamic>? ?? const {},
      ),
      layout: TemplateLayout.fromJson(
        json['layout'] as Map<String, dynamic>? ?? const {},
      ),
      watermarkEnabledByDefault:
          json['watermarkEnabledByDefault'] as bool? ?? false,
    );
  }

  final String id;
  final String name;
  final String description;
  final CaptionStyle captionStyle;
  final TemplateLayout layout;
  final bool watermarkEnabledByDefault;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'captionStyle': captionStyle.toJson(),
      'layout': layout.toJson(),
      'watermarkEnabledByDefault': watermarkEnabledByDefault,
    };
  }
}

class CaptionStyle {
  const CaptionStyle({
    required this.size,
    required this.highlightColor,
    required this.animation,
  });

  factory CaptionStyle.fromJson(Map<String, dynamic> json) {
    return CaptionStyle(
      size: json['size'] as String? ?? 'medium',
      highlightColor: json['highlightColor'] as String? ?? '#4F46E5',
      animation: json['animation'] as String? ?? 'none',
    );
  }

  final String size;
  final String highlightColor;
  final String animation;

  Map<String, dynamic> toJson() {
    return {
      'size': size,
      'highlightColor': highlightColor,
      'animation': animation,
    };
  }
}

class TemplateLayout {
  const TemplateLayout({required this.cropMode, required this.captionPosition});

  factory TemplateLayout.fromJson(Map<String, dynamic> json) {
    return TemplateLayout(
      cropMode: json['cropMode'] as String? ?? 'center_crop_9_16',
      captionPosition: json['captionPosition'] as String? ?? 'bottom_center',
    );
  }

  final String cropMode;
  final String captionPosition;

  Map<String, dynamic> toJson() {
    return {'cropMode': cropMode, 'captionPosition': captionPosition};
  }
}
