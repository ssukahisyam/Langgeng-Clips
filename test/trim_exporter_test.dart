import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/features/render/export_options.dart';
import 'package:langgeng_clip/features/render/trim_exporter.dart';

const _defaultOptions = ExportOptions(
  resolution: '1080p',
  frameRate: '30',
  codec: 'H.264',
);

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
            'resolution': '1080p',
            'frameRate': '30',
            'codec': 'H.264',
            'targetWidth': 1080,
            'targetHeight': 1920,
            'cropToPortrait': true,
            'requiresReencode': true,
          });

          return {
            'cachePath': '/cache/output.mp4',
            'galleryUri': 'content://media/video/1',
            'resolution': '1080p',
            'frameRate': '30',
            'codec': 'H.264',
            'targetWidth': 1080,
            'targetHeight': 1920,
            'cropToPortrait': true,
            'requiresReencode': true,
          };
        });

    final result = await const TrimExporter().export(
      sourcePath: '/video/input.mp4',
      startMillis: 1000,
      endMillis: 5000,
      options: _defaultOptions,
    );

    expect(result.cachePath, '/cache/output.mp4');
    expect(result.galleryUri, 'content://media/video/1');
    expect(result.resolution, '1080p');
    expect(result.frameRate, '30');
    expect(result.codec, 'H.264');
    expect(result.targetWidth, 1080);
    expect(result.targetHeight, 1920);
    expect(result.cropToPortrait, isTrue);
    expect(result.requiresReencode, isTrue);
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
        options: _defaultOptions,
      ),
      throwsA(isA<TrimExportException>()),
    );
  });

  test('export validates empty source before native call', () async {
    await expectLater(
      const TrimExporter().export(
        sourcePath: '',
        startMillis: 1000,
        endMillis: 5000,
        options: _defaultOptions,
      ),
      throwsA(
        isA<TrimExportException>().having(
          (error) => error.message,
          'message',
          'File sumber tidak tersedia. Pilih ulang video.',
        ),
      ),
    );
  });

  test('export validates invalid range before native call', () async {
    await expectLater(
      const TrimExporter().export(
        sourcePath: '/video/input.mp4',
        startMillis: 5000,
        endMillis: 1000,
        options: _defaultOptions,
      ),
      throwsA(
        isA<TrimExportException>().having(
          (error) => error.message,
          'message',
          'Range clip tidak valid. Geser start/end clip.',
        ),
      ),
    );
  });

  test('export maps platform exceptions to readable errors', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          throw PlatformException(code: 'invalid_range');
        });

    await expectLater(
      const TrimExporter().export(
        sourcePath: '/video/input.mp4',
        startMillis: 1000,
        endMillis: 5000,
        options: _defaultOptions,
      ),
      throwsA(
        isA<TrimExportException>().having(
          (error) => error.message,
          'message',
          'Range clip tidak valid. Geser start/end clip.',
        ),
      ),
    );
  });

  test('cancel calls native cancel method', () async {
    var called = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'cancelExport');
          called = true;
          return null;
        });

    await const TrimExporter().cancel();

    expect(called, isTrue);
  });
}
