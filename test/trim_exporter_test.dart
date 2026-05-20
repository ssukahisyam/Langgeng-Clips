import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/features/render/trim_exporter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.langgeng.clip/trim_export');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('export returns output path from native channel', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'exportTrim');
          expect(call.arguments, {
            'sourcePath': '/video/input.mp4',
            'startMillis': 1000,
            'endMillis': 5000,
          });

          return {
            'cachePath': '/cache/output.mp4',
            'galleryUri': 'content://media/video/1',
          };
        });

    final result = await const TrimExporter().export(
      sourcePath: '/video/input.mp4',
      startMillis: 1000,
      endMillis: 5000,
    );

    expect(result.cachePath, '/cache/output.mp4');
    expect(result.galleryUri, 'content://media/video/1');
    expect(result.isSavedToGallery, isTrue);
  });

  test('export throws when native channel returns empty path', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => {'cachePath': ''});

    await expectLater(
      const TrimExporter().export(
        sourcePath: '/video/input.mp4',
        startMillis: 1000,
        endMillis: 5000,
      ),
      throwsA(isA<TrimExportException>()),
    );
  });
}
