class FaceTrackSample {
  const FaceTrackSample({
    required this.timeMillis,
    required this.centerX,
    required this.centerY,
    required this.confidence,
  });

  final int timeMillis;
  final double centerX;
  final double centerY;
  final double confidence;
}

class FaceTrackTimeline {
  const FaceTrackTimeline({required this.samples});

  final List<FaceTrackSample> samples;

  bool get hasFace => samples.any((sample) => sample.confidence > 0.5);

  FaceTrackSample sampleAt(int timeMillis) {
    if (samples.isEmpty) {
      return const FaceTrackSample(
        timeMillis: 0,
        centerX: 0.5,
        centerY: 0.5,
        confidence: 0,
      );
    }

    return samples.reduce((a, b) {
      final aDistance = (a.timeMillis - timeMillis).abs();
      final bDistance = (b.timeMillis - timeMillis).abs();
      return aDistance <= bDistance ? a : b;
    });
  }
}

class SubjectTrackingConfig {
  const SubjectTrackingConfig({
    this.enabled = false,
    this.smoothing = 0.65,
    this.multiFaceStrategy = MultiFaceStrategy.primaryByConfidence,
  });

  final bool enabled;
  final double smoothing;
  final MultiFaceStrategy multiFaceStrategy;

  FaceTrackSample fallbackCenterCrop(int timeMillis) {
    return FaceTrackSample(
      timeMillis: timeMillis,
      centerX: 0.5,
      centerY: 0.5,
      confidence: 0,
    );
  }

  FaceTrackSample primaryFace(List<FaceTrackSample> faces) {
    if (faces.isEmpty) {
      return fallbackCenterCrop(0);
    }

    return faces.reduce((a, b) => a.confidence >= b.confidence ? a : b);
  }
}

enum MultiFaceStrategy { primaryByConfidence }
