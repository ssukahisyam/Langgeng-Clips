import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/features/media_intelligence/scene_change_detector.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('test_media_intelligence');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('detect calls native scene change detector', () async {
    late MethodCall capturedCall;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          capturedCall = call;
          return [
            {'timeMillis': 2000, 'score': 0.42},
          ];
        });

    final changes = await const SceneChangeDetector(channel: channel).detect(
      sourcePath: '/video/input.mp4',
      intervalMillis: 500,
      threshold: 0.3,
    );

    expect(capturedCall.method, 'detectSceneChanges');
    expect(capturedCall.arguments, {
      'sourcePath': '/video/input.mp4',
      'intervalMillis': 500,
      'threshold': 0.3,
    });
    expect(changes.single.timeMillis, 2000);
    expect(changes.single.score, 0.42);
  });

  test('detect validates interval before native call', () async {
    await expectLater(
      const SceneChangeDetector(
        channel: channel,
      ).detect(sourcePath: '/video/input.mp4', intervalMillis: 0),
      throwsA(
        isA<SceneDetectionException>().having(
          (error) => error.message,
          'message',
          'Interval scene detection tidak valid.',
        ),
      ),
    );
  });
}
