import '../watermark/watermark_config.dart';

class FreeTierWatermark {
  const FreeTierWatermark();

  static const text = 'Made with Langgeng Clip';

  WatermarkConfig apply({required bool isPremium, WatermarkConfig? existing}) {
    if (isPremium) {
      return existing ?? const WatermarkConfig();
    }

    return (existing ?? const WatermarkConfig()).copyWith(text: text);
  }
}
