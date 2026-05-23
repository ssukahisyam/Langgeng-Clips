import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/features/subject_tracking/subject_tracking.dart';

void main() {
  test('timeline returns nearest sample', () {
    const timeline = FaceTrackTimeline(
      samples: [
        FaceTrackSample(
          timeMillis: 0,
          centerX: 0.4,
          centerY: 0.5,
          confidence: 0.7,
        ),
        FaceTrackSample(
          timeMillis: 1000,
          centerX: 0.6,
          centerY: 0.5,
          confidence: 0.8,
        ),
      ],
    );

    expect(timeline.sampleAt(900).centerX, 0.6);
    expect(timeline.hasFace, isTrue);
  });

  test('tracking config selects primary face by confidence', () {
    final primary = const SubjectTrackingConfig().primaryFace([
      const FaceTrackSample(
        timeMillis: 0,
        centerX: 0.2,
        centerY: 0.5,
        confidence: 0.6,
      ),
      const FaceTrackSample(
        timeMillis: 0,
        centerX: 0.8,
        centerY: 0.5,
        confidence: 0.9,
      ),
    ]);

    expect(primary.centerX, 0.8);
  });

  test('tracking falls back to center crop when no face exists', () {
    final fallback = const SubjectTrackingConfig().fallbackCenterCrop(500);

    expect(fallback.timeMillis, 500);
    expect(fallback.centerX, 0.5);
    expect(fallback.centerY, 0.5);
    expect(fallback.confidence, 0);
  });
}
