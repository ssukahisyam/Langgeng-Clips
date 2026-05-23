import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/features/auto_highlight/highlight_candidate.dart';
import 'package:langgeng_clip/features/auto_highlight/highlight_eval.dart';

void main() {
  test('benchmark computes usable rate and average best score', () {
    final result = const HighlightBenchmark(usableThreshold: 0.7).evaluate([
      const HighlightResult(
        candidates: [
          HighlightCandidate(
            startMillis: 0,
            endMillis: 1000,
            score: 0.8,
            reason: 'hook',
          ),
        ],
      ),
      const HighlightResult(
        candidates: [
          HighlightCandidate(
            startMillis: 0,
            endMillis: 1000,
            score: 0.5,
            reason: 'weak',
          ),
        ],
      ),
    ]);

    expect(result.sampleCount, 2);
    expect(result.usableCount, 1);
    expect(result.usableRate, 0.5);
    expect(result.averageScore, 0.65);
  });

  test('prompt variants support A/B model evaluation', () {
    expect(
      HighlightPromptVariants.all.map((variant) => variant.model),
      containsAll(['llama-3.3-70b-versatile', 'deepseek-r1-distill-llama-70b']),
    );
  });
}
