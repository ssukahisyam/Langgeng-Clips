import 'highlight_candidate.dart';

class HighlightEvalSample {
  const HighlightEvalSample({
    required this.id,
    required this.sourceLabel,
    required this.groundTruth,
  });

  final String id;
  final String sourceLabel;
  final List<HighlightCandidate> groundTruth;
}

class HighlightBenchmarkResult {
  const HighlightBenchmarkResult({
    required this.sampleCount,
    required this.usableCount,
    required this.averageScore,
  });

  final int sampleCount;
  final int usableCount;
  final double averageScore;

  double get usableRate {
    if (sampleCount <= 0) {
      return 0;
    }

    return usableCount / sampleCount;
  }
}

class HighlightBenchmark {
  const HighlightBenchmark({this.usableThreshold = 0.7});

  final double usableThreshold;

  HighlightBenchmarkResult evaluate(List<HighlightResult> results) {
    if (results.isEmpty) {
      return const HighlightBenchmarkResult(
        sampleCount: 0,
        usableCount: 0,
        averageScore: 0,
      );
    }

    final bestScores = results.map(_bestScore).toList();
    final usableCount = bestScores
        .where((score) => score >= usableThreshold)
        .length;
    final average = bestScores.reduce((a, b) => a + b) / bestScores.length;
    return HighlightBenchmarkResult(
      sampleCount: results.length,
      usableCount: usableCount,
      averageScore: average,
    );
  }

  double _bestScore(HighlightResult result) {
    if (result.candidates.isEmpty) {
      return 0;
    }

    return result.candidates
        .map((candidate) => candidate.score)
        .reduce((a, b) => a > b ? a : b);
  }
}

class PromptVariant {
  const PromptVariant({
    required this.id,
    required this.model,
    required this.prompt,
  });

  final String id;
  final String model;
  final String prompt;
}

abstract final class HighlightPromptVariants {
  static const llama33 = PromptVariant(
    id: 'llama_3_3_v1',
    model: 'llama-3.3-70b-versatile',
    prompt:
        'Score complete short-form highlight ranges with hook, conflict, and payoff.',
  );

  static const deepSeek = PromptVariant(
    id: 'deepseek_v1',
    model: 'deepseek-r1-distill-llama-70b',
    prompt:
        'Find concise viral-ready segments and explain why each range works.',
  );

  static const all = <PromptVariant>{llama33, deepSeek};
}
