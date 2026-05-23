import 'clip_template.dart';

class AppliedTemplateConfig {
  const AppliedTemplateConfig({
    required this.templateId,
    required this.captionSize,
    required this.captionAnimation,
    required this.watermarkEnabled,
  });

  factory AppliedTemplateConfig.fromTemplate(ClipTemplate template) {
    return AppliedTemplateConfig(
      templateId: template.id,
      captionSize: template.captionStyle.size,
      captionAnimation: template.captionStyle.animation,
      watermarkEnabled: template.watermarkEnabledByDefault,
    );
  }

  final String templateId;
  final String captionSize;
  final String captionAnimation;
  final bool watermarkEnabled;
}
