import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/features/transcription/transcription_language.dart';

void main() {
  test('auto language omits Groq language parameter', () {
    expect(TranscriptionLanguage.auto.isAuto, isTrue);
    expect(TranscriptionLanguage.auto.groqParameter, isNull);
  });

  test('manual language override maps to Groq language parameter', () {
    expect(TranscriptionLanguage.indonesian.groqParameter, 'id');
    expect(TranscriptionLanguage.english.groqParameter, 'en');
  });

  test('supported languages include auto and common target languages', () {
    expect(
      TranscriptionLanguage.supported.map((language) => language.code),
      containsAll(['auto', 'id', 'en', 'ja', 'ko']),
    );
  });
}
