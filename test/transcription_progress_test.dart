import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/features/transcription/transcription_progress.dart';

void main() {
  test('progress state clamps percent and detects completion', () {
    const state = TranscriptionProgressState(
      completedChunks: 7,
      totalChunks: 5,
      currentLabel: 'chunk 5',
    );

    expect(state.progress, 1);
    expect(state.percentLabel, '100%');
    expect(state.isComplete, isTrue);
  });

  test('progress is zero before chunks are known', () {
    const state = TranscriptionProgressState(
      completedChunks: 0,
      totalChunks: 0,
    );

    expect(state.progress, 0);
    expect(state.isComplete, isFalse);
  });
}
