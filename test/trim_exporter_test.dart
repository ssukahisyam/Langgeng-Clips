import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/core/pigeon/render_api.g.dart' as pigeon;
import 'package:langgeng_clip/features/render/export_options.dart';
import 'package:langgeng_clip/features/render/trim_exporter.dart';
import 'package:langgeng_clip/features/subtitle/caption_document.dart';

const _defaultOptions = ExportOptions(
  resolution: '1080p',
  frameRate: '30',
  codec: 'H.264',
);

void main() {
  test('export returns result from Pigeon render gateway', () async {
    final gateway = _FakeRenderGateway(
      result: pigeon.RenderResult(
        cachePath: '/cache/output.mp4',
        galleryUri: 'content://media/video/1',
        resolution: '1080p',
        frameRate: '30',
        codec: 'H.264',
        targetWidth: 1080,
        targetHeight: 1920,
        cropToPortrait: true,
        requiresReencode: true,
      ),
    );

    final result = await TrimExporter(nativeRenderGateway: gateway).export(
      sourcePath: '/video/input.mp4',
      startMillis: 1000,
      endMillis: 5000,
      options: _defaultOptions,
    );

    expect(gateway.lastRequest?.sourcePath, '/video/input.mp4');
    expect(gateway.lastRequest?.startMillis, 1000);
    expect(gateway.lastRequest?.endMillis, 5000);
    expect(gateway.lastRequest?.resolution, '1080p');
    expect(gateway.lastRequest?.frameRate, '30');
    expect(gateway.lastRequest?.codec, 'H.264');
    expect(gateway.lastRequest?.targetWidth, 1080);
    expect(gateway.lastRequest?.targetHeight, 1920);
    expect(gateway.lastRequest?.cropToPortrait, isTrue);
    expect(gateway.lastRequest?.requiresReencode, isTrue);
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

  test('export passes caption segments to native render gateway', () async {
    final gateway = _FakeRenderGateway(
      result: pigeon.RenderResult(cachePath: '/cache/output.mp4'),
    );

    await TrimExporter(nativeRenderGateway: gateway).export(
      sourcePath: '/video/input.mp4',
      startMillis: 1000,
      endMillis: 5000,
      options: _defaultOptions,
      captionItems: const [
        CaptionItem(
          id: '1',
          text: 'Hello clip',
          startMillis: 1000,
          endMillis: 2500,
        ),
      ],
    );

    expect(gateway.lastRequest?.captionSegments, hasLength(1));
    expect(gateway.lastRequest?.captionSegments?.single?.text, 'Hello clip');
    expect(gateway.lastRequest?.captionSegments?.single?.startMillis, 1000);
    expect(gateway.lastRequest?.captionSegments?.single?.endMillis, 2500);
  });

  test('export throws when Pigeon gateway returns empty path', () async {
    final gateway = _FakeRenderGateway(
      result: pigeon.RenderResult(cachePath: ''),
    );

    await expectLater(
      TrimExporter(nativeRenderGateway: gateway).export(
        sourcePath: '/video/input.mp4',
        startMillis: 1000,
        endMillis: 5000,
        options: _defaultOptions,
      ),
      throwsA(isA<TrimExportException>()),
    );
  });

  test('export validates empty source before native call', () async {
    final gateway = _FakeRenderGateway();

    await expectLater(
      TrimExporter(nativeRenderGateway: gateway).export(
        sourcePath: '',
        startMillis: 1000,
        endMillis: 5000,
        options: _defaultOptions,
      ),
      throwsA(
        isA<TrimExportException>()
            .having(
              (error) => error.message,
              'message',
              'File sumber tidak tersedia. Pilih ulang video.',
            )
            .having(
              (error) => error.analyticsCode,
              'analyticsCode',
              'invalid_source',
            ),
      ),
    );
    expect(gateway.lastRequest, isNull);
  });

  test('export validates invalid range before native call', () async {
    final gateway = _FakeRenderGateway();

    await expectLater(
      TrimExporter(nativeRenderGateway: gateway).export(
        sourcePath: '/video/input.mp4',
        startMillis: 5000,
        endMillis: 1000,
        options: _defaultOptions,
      ),
      throwsA(
        isA<TrimExportException>()
            .having(
              (error) => error.message,
              'message',
              'Range clip tidak valid. Geser start/end clip.',
            )
            .having(
              (error) => error.analyticsCode,
              'analyticsCode',
              'invalid_range',
            ),
      ),
    );
    expect(gateway.lastRequest, isNull);
  });

  test('export maps platform exceptions to readable errors', () async {
    final gateway = _FakeRenderGateway(
      error: PlatformException(code: 'invalid_range'),
    );

    await expectLater(
      TrimExporter(nativeRenderGateway: gateway).export(
        sourcePath: '/video/input.mp4',
        startMillis: 1000,
        endMillis: 5000,
        options: _defaultOptions,
      ),
      throwsA(
        isA<TrimExportException>()
            .having(
              (error) => error.message,
              'message',
              'Range clip tidak valid. Geser start/end clip.',
            )
            .having(
              (error) => error.analyticsCode,
              'analyticsCode',
              'invalid_range',
            ),
      ),
    );
  });

  test(
    'export ignores raw native message for unknown platform errors',
    () async {
      final gateway = _FakeRenderGateway(
        error: PlatformException(
          code: 'native_failure',
          message: '/storage/emulated/0/private/input.mp4 failed',
        ),
      );

      await expectLater(
        TrimExporter(nativeRenderGateway: gateway).export(
          sourcePath: '/video/input.mp4',
          startMillis: 1000,
          endMillis: 5000,
          options: _defaultOptions,
        ),
        throwsA(
          isA<TrimExportException>()
              .having(
                (error) => error.message,
                'message',
                'Export gagal. Coba ulangi.',
              )
              .having(
                (error) => error.analyticsCode,
                'analyticsCode',
                'unknown',
              )
              .having((error) => error.recoverable, 'recoverable', isTrue),
        ),
      );
    },
  );

  test('cancel calls Pigeon render gateway', () async {
    final gateway = _FakeRenderGateway();

    await TrimExporter(nativeRenderGateway: gateway).cancel();

    expect(gateway.cancelCalled, isTrue);
  });
}

class _FakeRenderGateway implements NativeRenderGateway {
  _FakeRenderGateway({this.result, this.error});

  final pigeon.RenderResult? result;
  final PlatformException? error;
  pigeon.RenderRequest? lastRequest;
  bool cancelCalled = false;

  @override
  Future<pigeon.RenderResult> exportTrim(pigeon.RenderRequest request) async {
    lastRequest = request;
    final error = this.error;
    if (error != null) {
      throw error;
    }

    return result ?? pigeon.RenderResult(cachePath: '/cache/output.mp4');
  }

  @override
  Future<void> cancelExport() async {
    cancelCalled = true;
  }
}
