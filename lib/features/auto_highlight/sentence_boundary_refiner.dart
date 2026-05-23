import '../transcription/transcription_provider.dart';
import 'highlight_candidate.dart';

class SentenceBoundaryRefiner {
  const SentenceBoundaryRefiner();

  HighlightCandidate refine(
    HighlightCandidate candidate,
    Transcript transcript,
  ) {
    final words = transcript.words;
    if (words.isEmpty) {
      return candidate;
    }

    final startWord = words.lastWhere(
      (word) => word.startMillis <= candidate.startMillis,
      orElse: () => words.first,
    );
    final endWord = words.firstWhere(
      (word) =>
          _isSentenceEnd(word.text) && word.endMillis >= candidate.endMillis,
      orElse: () => words.last,
    );

    return candidate.copyWith(
      startMillis: startWord.startMillis,
      endMillis: endWord.endMillis,
    );
  }

  bool _isSentenceEnd(String text) {
    final trimmed = text.trim();
    return trimmed.endsWith('.') ||
        trimmed.endsWith('!') ||
        trimmed.endsWith('?');
  }
}
