import 'dart:convert';

import 'package:http/http.dart' as http;

import 'transcription_provider.dart';

class GroqWhisperProvider implements TranscriptionProvider {
  GroqWhisperProvider({
    required String apiKey,
    http.Client? client,
    Uri? endpoint,
  }) : _apiKey = apiKey,
       _client = client ?? http.Client(),
       _endpoint = endpoint ?? _defaultEndpoint;

  static final _defaultEndpoint = Uri.https(
    'api.groq.com',
    '/openai/v1/audio/transcriptions',
  );

  final String _apiKey;
  final http.Client _client;
  final Uri _endpoint;

  @override
  Future<Transcript> transcribeChunk(TranscriptionChunk chunk) async {
    if (_apiKey.trim().isEmpty) {
      throw const TranscriptionException('Groq API key belum tersedia.');
    }
    if (chunk.bytes.isEmpty) {
      throw const TranscriptionException('Audio chunk kosong.');
    }

    final request = http.MultipartRequest('POST', _endpoint)
      ..headers['Authorization'] = 'Bearer $_apiKey'
      ..fields['model'] = 'whisper-large-v3-turbo'
      ..fields['response_format'] = 'verbose_json'
      ..fields['timestamp_granularities[]'] = 'word'
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          chunk.bytes,
          filename: chunk.fileName,
        ),
      );

    final language = chunk.language;
    if (language != null && language.trim().isNotEmpty) {
      request.fields['language'] = language.trim();
    }

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      return Transcript.fromGroqJson(
        _decodeResponse(response.body),
        offsetMillis: chunk.startOffsetMillis,
      );
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const TranscriptionException('Groq API key tidak valid.');
    }
    if (response.statusCode == 429) {
      throw const TranscriptionException(
        'Groq sedang rate-limit. Coba beberapa saat lagi.',
      );
    }

    throw TranscriptionException(
      _extractMessage(response.body) ??
          'Transkripsi gagal. Groq mengembalikan ${response.statusCode}.',
    );
  }

  static Map<String, dynamic> _decodeResponse(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } on FormatException {
      throw const TranscriptionException('Response transkripsi tidak valid.');
    }
  }

  static String? _extractMessage(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final error = json['error'];
      if (error is Map<String, dynamic>) {
        return error['message'] as String?;
      }
    } on FormatException {
      return null;
    }

    return null;
  }
}
