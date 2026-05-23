import 'clip_template.dart';

abstract final class TemplatePresets {
  static const podcast = ClipTemplate(
    id: 'podcast',
    name: 'Podcast',
    description: 'Talking head layout with large readable subtitles.',
    captionStyle: CaptionStyle(
      size: 'large',
      highlightColor: '#4F46E5',
      animation: 'none',
    ),
    layout: TemplateLayout(
      cropMode: 'center_crop_9_16',
      captionPosition: 'bottom_center',
    ),
    watermarkEnabledByDefault: false,
  );

  static const gaming = ClipTemplate(
    id: 'gaming',
    name: 'Gaming',
    description: 'Gameplay-first layout with dynamic captions.',
    captionStyle: CaptionStyle(
      size: 'medium',
      highlightColor: '#22C55E',
      animation: 'karaoke',
    ),
    layout: TemplateLayout(
      cropMode: 'center_crop_9_16',
      captionPosition: 'top_center',
    ),
    watermarkEnabledByDefault: false,
  );

  static const talkingHead = ClipTemplate(
    id: 'talking_head',
    name: 'Talking Head',
    description: 'Face-focused crop with karaoke captions.',
    captionStyle: CaptionStyle(
      size: 'large',
      highlightColor: '#F97316',
      animation: 'karaoke',
    ),
    layout: TemplateLayout(
      cropMode: 'face_focus_9_16',
      captionPosition: 'bottom_center',
    ),
    watermarkEnabledByDefault: false,
  );

  static const tutorial = ClipTemplate(
    id: 'tutorial',
    name: 'Tutorial',
    description: 'Clean captions with optional logo watermark.',
    captionStyle: CaptionStyle(
      size: 'medium',
      highlightColor: '#0EA5E9',
      animation: 'none',
    ),
    layout: TemplateLayout(
      cropMode: 'center_crop_9_16',
      captionPosition: 'bottom_center',
    ),
    watermarkEnabledByDefault: true,
  );

  static const all = <ClipTemplate>{podcast, gaming, talkingHead, tutorial};
}
