class SemiAutoCandidate {
  const SemiAutoCandidate({
    required this.startMillis,
    required this.endMillis,
    required this.reason,
    required this.confidence,
  });

  final int startMillis;
  final int endMillis;
  final String reason;
  final double confidence;

  bool get isValid =>
      endMillis > startMillis && confidence >= 0 && confidence <= 1;
}

class SemiAutoTuning {
  const SemiAutoTuning({
    this.audioPeakThreshold = -18,
    this.silenceThreshold = -42,
    this.sceneChangeThreshold = 0.35,
  });

  final double audioPeakThreshold;
  final double silenceThreshold;
  final double sceneChangeThreshold;
}
