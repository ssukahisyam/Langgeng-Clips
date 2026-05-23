import 'dart:convert';

import 'package:http/http.dart' as http;

import '../transcription/transcription_provider.dart';
import 'highlight_candidate.dart';

class GroqHighlightClient {
  GroqHighlightClient({
    required String apiKey,
    http.Client? client,
    Uri? endpoint,
  }) : _apiKey = apiKey,
       _client = client ?? http.Client(),
       _endpoint = endpoint ?? _defaultEndpoint;

  static final _defaultEndpoint = Uri.https(
    'api.groq.com',
    '/openai/v1/chat/completions',
  );

  final String _apiKey;
  final http.Client _client;
  final Uri _endpoint;

  Future<HighlightResult> scoreTranscript(Transcript transcript) async {
    if (_apiKey.trim().isEmpty) {
      throw const HighlightException('Groq API key belum tersedia.');
    }

    final response = await _client.post(
      _endpoint,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'llama-3.3-70b-versatile',
        'temperature': 0.2,
        'response_format': {'type': 'json_object'},
        'messages': [
          {'role': 'system', 'content': _systemPrompt},
          {'role': 'user', 'content': _transcriptPayload(transcript)},
        ],
      }),
    );

    if (response.statusCode == 200) {
      return HighlightResult.fromJson(_extractJsonObject(response.body));
    }
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const HighlightException('Groq API key tidak valid.');
    }
    if (response.statusCode == 429) {
      throw const HighlightException(
        'Groq sedang rate-limit. Coba beberapa saat lagi.',
      );
    }

    throw HighlightException(
      'AI highlight gagal. Groq mengembalikan ${response.statusCode}.',
    );
  }

  static const _systemPrompt = '''
You score long-form video transcript ranges for short-form clips.
Return JSON only with shape: {"ranges":[{"startMillis":0,"endMillis":10000,"score":0.0,"reason":"..."}]}.
Rules: choose complete thoughts, prefer hooks/conflict/payoff, keep score between 0 and 1, do not invent timestamps.
''';

  String _transcriptPayload(Transcript transcript) {
    final words = transcript.words.map((word) {
      return {
        'text': word.text,
        'startMillis': word.startMillis,
        'endMillis': word.endMillis,
      };
    }).toList();

    return jsonEncode({'text': transcript.text, 'words': words});
  }

  static Map<String, dynamic> _extractJsonObject(String body) {
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    final choices = decoded['choices'];
    if (choices is! List || choices.isEmpty) {
      throw const HighlightException('Response AI highlight tidak valid.');
    }
    final first = choices.first;
    if (first is! Map<String, dynamic>) {
      throw const HighlightException('Response AI highlight tidak valid.');
    }
    final message = first['message'];
    if (message is! Map<String, dynamic>) {
      throw const HighlightException('Response AI highlight tidak valid.');
    }
    final content = message['content'];
    if (content is! String) {
      throw const HighlightException('Response AI highlight tidak valid.');
    }

    return jsonDecode(content) as Map<String, dynamic>;
  }
}

class HighlightException implements Exception {
  const HighlightException(this.message);

  final String message;

  @override
  String toString() => message;
}
