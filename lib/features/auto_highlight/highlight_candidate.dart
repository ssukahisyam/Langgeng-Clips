class HighlightCandidate {
  const HighlightCandidate({
    required this.startMillis,
    required this.endMillis,
    required this.score,
    required this.reason,
  });

  factory HighlightCandidate.fromJson(Map<String, dynamic> json) {
    return HighlightCandidate(
      startMillis: (json['startMillis'] as num?)?.toInt() ?? 0,
      endMillis: (json['endMillis'] as num?)?.toInt() ?? 0,
      score: (json['score'] as num?)?.toDouble() ?? 0,
      reason: json['reason'] as String? ?? '',
    );
  }

  final int startMillis;
  final int endMillis;
  final double score;
  final String reason;

  bool get isValid => endMillis > startMillis && score >= 0 && score <= 1;

  HighlightCandidate copyWith({int? startMillis, int? endMillis}) {
    return HighlightCandidate(
      startMillis: startMillis ?? this.startMillis,
      endMillis: endMillis ?? this.endMillis,
      score: score,
      reason: reason,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startMillis': startMillis,
      'endMillis': endMillis,
      'score': score,
      'reason': reason,
    };
  }
}

class HighlightResult {
  const HighlightResult({required this.candidates});

  factory HighlightResult.fromJson(Map<String, dynamic> json) {
    final ranges = json['ranges'];
    return HighlightResult(
      candidates: ranges is List
          ? ranges
                .whereType<Map<String, dynamic>>()
                .map(HighlightCandidate.fromJson)
                .where((candidate) => candidate.isValid)
                .toList()
          : const <HighlightCandidate>[],
    );
  }

  final List<HighlightCandidate> candidates;

  Map<String, dynamic> toJson() {
    return {
      'ranges': candidates.map((candidate) => candidate.toJson()).toList(),
    };
  }
}
