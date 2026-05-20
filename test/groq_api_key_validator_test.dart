import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:langgeng_clip/features/onboarding/groq_api_key_validator.dart';

void main() {
  test('validate completes for valid Groq key response', () async {
    final validator = GroqApiKeyValidator(
      client: MockClient((request) async {
        expect(request.url.host, 'api.groq.com');
        expect(request.headers['Authorization'], 'Bearer gsk_valid');

        return http.Response('{"data": []}', 200);
      }),
    );

    await expectLater(validator.validate('gsk_valid'), completes);
  });

  test('validate throws readable error for invalid key', () async {
    final validator = GroqApiKeyValidator(
      client: MockClient(
        (_) async => http.Response('{"error":{"message":"bad key"}}', 401),
      ),
    );

    await expectLater(
      validator.validate('gsk_invalid'),
      throwsA(isA<GroqApiKeyValidationException>()),
    );
  });
}
