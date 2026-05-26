import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/core/pigeon/render_api.g.dart',
    kotlinOut:
        'android/app/src/main/kotlin/com/langgeng/langgeng_clip/pigeon/RenderApi.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.langgeng.langgeng_clip.pigeon'),
  ),
)
class RenderRequest {
  RenderRequest({
    required this.sourcePath,
    required this.startMillis,
    required this.endMillis,
    required this.resolution,
    required this.frameRate,
    required this.codec,
    required this.targetWidth,
    required this.targetHeight,
    required this.cropToPortrait,
    required this.requiresReencode,
    this.captionSegments,
    this.watermark,
  });

  final String sourcePath;
  final int startMillis;
  final int endMillis;
  final String resolution;
  final String frameRate;
  final String codec;
  final int targetWidth;
  final int targetHeight;
  final bool cropToPortrait;
  final bool requiresReencode;
  final List<RenderCaptionSegment?>? captionSegments;
  final RenderWatermarkConfig? watermark;
}

class RenderWatermarkConfig {
  RenderWatermarkConfig({
    this.text,
    this.imagePath,
    required this.anchor,
    this.customX,
    this.customY,
    required this.opacity,
    required this.scale,
  });

  final String? text;
  final String? imagePath;
  final String anchor;
  final double? customX;
  final double? customY;
  final double opacity;
  final double scale;
}

class RenderCaptionSegment {
  RenderCaptionSegment({
    required this.text,
    required this.startMillis,
    required this.endMillis,
  });

  final String text;
  final int startMillis;
  final int endMillis;
}

class RenderResult {
  RenderResult({
    required this.cachePath,
    this.galleryUri,
    this.resolution,
    this.frameRate,
    this.codec,
    this.targetWidth,
    this.targetHeight,
    this.cropToPortrait,
    this.requiresReencode,
  });

  final String cachePath;
  final String? galleryUri;
  final String? resolution;
  final String? frameRate;
  final String? codec;
  final int? targetWidth;
  final int? targetHeight;
  final bool? cropToPortrait;
  final bool? requiresReencode;
}

@HostApi()
abstract class NativeRenderApi {
  @async
  RenderResult exportTrim(RenderRequest request);

  @async
  void cancelExport();
}
