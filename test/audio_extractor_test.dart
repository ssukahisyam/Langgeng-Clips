import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/features/transcription/audio_extractor.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('test_audio_tools');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('extractWav16kMono calls native channel and returns path', () async {
    late MethodCall capturedCall;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          capturedCall = call;
          return '/cache/audio.wav';
        });

    final path = await const AudioExtractor(channel: channel).extractWav16kMono(
      sourcePath: '/video/input.mp4',
      startMillis: 1000,
      endMillis: 5000,
    );

    expect(path, '/cache/audio.wav');
    expect(capturedCall.method, 'extractWav16kMono');
    expect(capturedCall.arguments, {
      'sourcePath': '/video/input.mp4',
      'startMillis': 1000,
      'endMillis': 5000,
    });
  });

  test('validates invalid audio range before native call', () async {
    await expectLater(
      const AudioExtractor(channel: channel).extractWav16kMono(
        sourcePath: '/video/input.mp4',
        startMillis: 5000,
        endMillis: 1000,
      ),
      throwsA(
        isA<AudioExtractionException>().having(
          (error) => error.message,
          'message',
          'Range audio tidak valid.',
        ),
      ),
    );
  });

  test('maps native extraction failures to readable error', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          throw PlatformException(code: 'extract_failed');
        });

    await expectLater(
      const AudioExtractor(channel: channel).extractWav16kMono(
        sourcePath: '/video/input.mp4',
        startMillis: 1000,
        endMillis: 5000,
      ),
      throwsA(
        isA<AudioExtractionException>().having(
          (error) => error.message,
          'message',
          'Gagal mengekstrak audio WAV.',
        ),
      ),
    );
  });

  test('maps unavailable native extraction to readable error', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          throw PlatformException(code: 'extract_unavailable');
        });

    await expectLater(
      const AudioExtractor(channel: channel).extractWav16kMono(
        sourcePath: '/video/input.mp4',
        startMillis: 1000,
        endMillis: 5000,
      ),
      throwsA(
        isA<AudioExtractionException>().having(
          (error) => error.message,
          'message',
          'FFmpeg audio extraction belum tersedia di build ini.',
        ),
      ),
    );
  });
}
