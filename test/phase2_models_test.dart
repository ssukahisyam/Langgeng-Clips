import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/features/auto_highlight/filler_word_filter.dart';
import 'package:langgeng_clip/features/semi_auto/semi_auto_candidate.dart';
import 'package:langgeng_clip/features/templates/template_application.dart';
import 'package:langgeng_clip/features/templates/template_presets.dart';
import 'package:langgeng_clip/features/transcription/transcription_provider.dart';

void main() {
  test('filler word filter is disabled by default', () {
    const transcript = Transcript(
      text: 'um hello',
      words: [
        TranscriptWord(text: 'um', startMillis: 0, endMillis: 100),
        TranscriptWord(text: 'hello', startMillis: 120, endMillis: 300),
      ],
    );

    expect(const FillerWordFilter().apply(transcript).text, 'um hello');
    expect(
      const FillerWordFilter(enabled: true).apply(transcript).text,
      'hello',
    );
  });

  test('semi-auto candidate validates ranges and thresholds', () {
    const candidate = SemiAutoCandidate(
      startMillis: 1000,
      endMillis: 5000,
      reason: 'audio peak',
      confidence: 0.7,
    );
    const tuning = SemiAutoTuning(audioPeakThreshold: -16);

    expect(candidate.isValid, isTrue);
    expect(tuning.audioPeakThreshold, -16);
  });

  test('template application maps preset fields into editor config', () {
    final config = AppliedTemplateConfig.fromTemplate(TemplatePresets.tutorial);

    expect(config.templateId, 'tutorial');
    expect(config.captionSize, 'medium');
    expect(config.captionAnimation, 'none');
    expect(config.watermarkEnabled, isTrue);
  });
}
