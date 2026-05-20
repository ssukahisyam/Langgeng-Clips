import 'dart:convert';

import 'package:http/http.dart' as http;

class GroqApiKeyValidator {
  GroqApiKeyValidator({http.Client? client})
    : _client = client ?? http.Client();

  static final _modelsUri = Uri.https('api.groq.com', '/openai/v1/models');

  final http.Client _client;

  Future<void> validate(String apiKey) async {
    final response = await _client.get(
      _modelsUri,
      headers: {'Authorization': 'Bearer $apiKey'},
    );

    if (response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const GroqApiKeyValidationException('API key tidak valid.');
    }

    if (response.statusCode == 429) {
      throw const GroqApiKeyValidationException(
        'Groq sedang rate-limit. Coba beberapa saat lagi.',
      );
    }

    final message = _extractMessage(response.body);
    throw GroqApiKeyValidationException(
      message ?? 'Groq mengembalikan error ${response.statusCode}.',
    );
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

class GroqApiKeyValidationException implements Exception {
  const GroqApiKeyValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
