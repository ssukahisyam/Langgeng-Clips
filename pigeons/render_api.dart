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
  });

  final String sourcePath;
  final int startMillis;
  final int endMillis;
  final String resolution;
  final String frameRate;
  final String codec;
}

class RenderResult {
  RenderResult({
    required this.cachePath,
    this.galleryUri,
    this.resolution,
    this.frameRate,
    this.codec,
  });

  final String cachePath;
  final String? galleryUri;
  final String? resolution;
  final String? frameRate;
  final String? codec;
}

@HostApi()
abstract class NativeRenderApi {
  @async
  RenderResult exportTrim(RenderRequest request);

  @async
  void cancelExport();
}
