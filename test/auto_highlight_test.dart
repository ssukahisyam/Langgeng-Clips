import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:langgeng_clip/features/auto_highlight/groq_highlight_client.dart';
import 'package:langgeng_clip/features/auto_highlight/highlight_cache.dart';
import 'package:langgeng_clip/features/auto_highlight/highlight_candidate.dart';
import 'package:langgeng_clip/features/auto_highlight/sentence_boundary_refiner.dart';
import 'package:langgeng_clip/features/transcription/transcription_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('highlight result parses valid ranges only', () {
    final result = HighlightResult.fromJson({
      'ranges': [
        {
          'startMillis': 1000,
          'endMillis': 9000,
          'score': 0.82,
          'reason': 'Hook',
        },
        {'startMillis': 9000, 'endMillis': 1000, 'score': 0.5, 'reason': 'Bad'},
      ],
    });

    expect(result.candidates, hasLength(1));
    expect(result.candidates.single.score, 0.82);
    expect(result.candidates.single.reason, 'Hook');
  });

  test('Groq highlight client requests JSON response schema', () async {
    late Map<String, dynamic> body;
    final client = GroqHighlightClient(
      apiKey: 'gsk_test',
      client: _FakePostClient((request) async {
        body = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {
                  'content': jsonEncode({
                    'ranges': [
                      {
                        'startMillis': 0,
                        'endMillis': 10000,
                        'score': 0.9,
                        'reason': 'Strong opening',
                      },
                    ],
                  }),
                },
              },
            ],
          }),
          200,
        );
      }),
    );

    final result = await client.scoreTranscript(
      const Transcript(
        text: 'This is a great hook.',
        words: [
          TranscriptWord(text: 'This', startMillis: 0, endMillis: 200),
          TranscriptWord(text: 'hook.', startMillis: 800, endMillis: 1000),
        ],
      ),
    );

    expect(body['model'], 'llama-3.3-70b-versatile');
    expect(body['response_format'], {'type': 'json_object'});
    expect(result.candidates.single.reason, 'Strong opening');
  });

  test('sentence boundary refiner expands to nearby sentence end', () {
    final refined = const SentenceBoundaryRefiner().refine(
      const HighlightCandidate(
        startMillis: 250,
        endMillis: 900,
        score: 0.8,
        reason: 'Payoff',
      ),
      const Transcript(
        text: 'hello there. final word.',
        words: [
          TranscriptWord(text: 'hello', startMillis: 0, endMillis: 200),
          TranscriptWord(text: 'there.', startMillis: 250, endMillis: 500),
          TranscriptWord(text: 'final', startMillis: 700, endMillis: 900),
          TranscriptWord(text: 'word.', startMillis: 950, endMillis: 1200),
        ],
      ),
    );

    expect(refined.startMillis, 250);
    expect(refined.endMillis, 1200);
  });

  test('highlight cache stores result by source and config hash', () async {
    SharedPreferences.setMockInitialValues({});
    final cache = HighlightCache(
      preferences: await SharedPreferences.getInstance(),
    );
    const result = HighlightResult(
      candidates: [
        HighlightCandidate(
          startMillis: 0,
          endMillis: 5000,
          score: 0.75,
          reason: 'Useful tip',
        ),
      ],
    );

    await cache.write(
      sourceSha256: 'source',
      configHash: 'config',
      result: result,
    );

    final cached = cache.read(sourceSha256: 'source', configHash: 'config');
    expect(cached?.candidates.single.reason, 'Useful tip');
    expect(cache.read(sourceSha256: 'source', configHash: 'other'), isNull);
  });
}

class _FakePostClient extends http.BaseClient {
  _FakePostClient(this._handler);

  final Future<http.Response> Function(http.Request request) _handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request is! http.Request) {
      throw StateError('Expected Request');
    }
    final response = await _handler(request);
    return http.StreamedResponse(
      Stream<List<int>>.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
    );
  }
}
