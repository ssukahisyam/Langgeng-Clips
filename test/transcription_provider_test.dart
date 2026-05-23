import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:langgeng_clip/features/transcription/groq_whisper_provider.dart';
import 'package:langgeng_clip/features/transcription/transcription_provider.dart';

void main() {
  test('parses Groq verbose json with word offsets', () {
    final transcript = Transcript.fromGroqJson({
      'text': 'hello world',
      'language': 'en',
      'duration': 1.2,
      'words': [
        {'word': 'hello', 'start': 0.1, 'end': 0.5},
        {'word': 'world', 'start': 0.6, 'end': 1.2},
      ],
    }, offsetMillis: 10 * 60 * 1000);

    expect(transcript.text, 'hello world');
    expect(transcript.language, 'en');
    expect(transcript.durationSeconds, 1.2);
    expect(transcript.words.first.text, 'hello');
    expect(transcript.words.first.startMillis, 600100);
    expect(transcript.words.first.endMillis, 600500);
  });

  test('uploads audio chunk to Groq Whisper endpoint', () async {
    late http.MultipartRequest capturedRequest;
    final provider = GroqWhisperProvider(
      apiKey: 'gsk_test',
      client: _FakeMultipartClient((request) {
        capturedRequest = request;
        return http.Response(
          jsonEncode({
            'text': 'halo',
            'words': [
              {'word': 'halo', 'start': 0, 'end': 0.25},
            ],
          }),
          200,
        );
      }),
    );

    final transcript = await provider.transcribeChunk(
      TranscriptionChunk(
        bytes: Uint8List.fromList([1, 2, 3]),
        fileName: 'chunk-000.wav',
        mimeType: 'audio/wav',
        startOffsetMillis: 5000,
        language: 'id',
      ),
    );

    expect(capturedRequest.method, 'POST');
    expect(capturedRequest.url.host, 'api.groq.com');
    expect(capturedRequest.headers['Authorization'], 'Bearer gsk_test');
    expect(capturedRequest.fields['model'], 'whisper-large-v3-turbo');
    expect(capturedRequest.fields['response_format'], 'verbose_json');
    expect(capturedRequest.fields['timestamp_granularities[]'], 'word');
    expect(capturedRequest.fields['language'], 'id');
    expect(capturedRequest.files.single.field, 'file');
    expect(capturedRequest.files.single.filename, 'chunk-000.wav');
    expect(transcript.text, 'halo');
    expect(transcript.words.single.startMillis, 5000);
    expect(transcript.words.single.endMillis, 5250);
  });

  test('maps Groq rate limit to readable error', () async {
    final provider = GroqWhisperProvider(
      apiKey: 'gsk_test',
      client: _FakeMultipartClient((request) => http.Response('', 429)),
    );

    await expectLater(
      provider.transcribeChunk(
        TranscriptionChunk(
          bytes: Uint8List.fromList([1]),
          fileName: 'chunk.wav',
          mimeType: 'audio/wav',
          startOffsetMillis: 0,
        ),
      ),
      throwsA(
        isA<TranscriptionException>().having(
          (error) => error.message,
          'message',
          'Groq sedang rate-limit. Coba beberapa saat lagi.',
        ),
      ),
    );
  });
}

class _FakeMultipartClient extends http.BaseClient {
  _FakeMultipartClient(this._handler);

  final FutureOr<http.Response> Function(http.MultipartRequest request)
  _handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request is! http.MultipartRequest) {
      throw StateError('Expected MultipartRequest');
    }

    final response = await _handler(request);
    return http.StreamedResponse(
      Stream<List<int>>.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
      reasonPhrase: response.reasonPhrase,
    );
  }
}
