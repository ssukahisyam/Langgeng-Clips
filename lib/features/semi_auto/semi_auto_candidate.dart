import 'package:flutter_riverpod/flutter_riverpod.dart';

final semiAutoCandidatesProvider = StateProvider<List<SemiAutoCandidate>>((
  ref,
) {
  return const [];
});

class SemiAutoCandidate {
  const SemiAutoCandidate({
    required this.startMillis,
    required this.endMillis,
    required this.reason,
    required this.confidence,
  });

  factory SemiAutoCandidate.fromJson(Map<String, dynamic> json) {
    return SemiAutoCandidate(
      startMillis: (json['startMillis'] as num?)?.toInt() ?? 0,
      endMillis: (json['endMillis'] as num?)?.toInt() ?? 0,
      reason: json['reason'] as String? ?? 'Semi-auto candidate',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
    );
  }

  final int startMillis;
  final int endMillis;
  final String reason;
  final double confidence;

  bool get isValid =>
      endMillis > startMillis && confidence >= 0 && confidence <= 1;

  Map<String, dynamic> toJson() {
    return {
      'startMillis': startMillis,
      'endMillis': endMillis,
      'reason': reason,
      'confidence': confidence,
    };
  }
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
