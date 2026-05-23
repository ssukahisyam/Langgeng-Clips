import '../transcription/transcription_provider.dart';

class CaptionSegment {
  const CaptionSegment({
    required this.text,
    required this.startMillis,
    required this.endMillis,
  });

  final String text;
  final int startMillis;
  final int endMillis;
}

class CaptionSegmenter {
  const CaptionSegmenter({
    this.maxCharactersPerLine = 28,
    this.maxWordsPerSegment = 7,
  });

  final int maxCharactersPerLine;
  final int maxWordsPerSegment;

  List<CaptionSegment> segment(Transcript transcript) {
    if (transcript.words.isEmpty) {
      return const [];
    }

    final segments = <CaptionSegment>[];
    var buffer = <TranscriptWord>[];
    for (final word in transcript.words) {
      final candidate = [...buffer, word];
      if (buffer.isNotEmpty && _shouldBreak(candidate)) {
        segments.add(_buildSegment(buffer));
        buffer = [word];
      } else {
        buffer = candidate;
      }
    }

    if (buffer.isNotEmpty) {
      segments.add(_buildSegment(buffer));
    }

    return segments;
  }

  bool _shouldBreak(List<TranscriptWord> words) {
    return words.length > maxWordsPerSegment ||
        _joinWords(words).length > maxCharactersPerLine;
  }

  CaptionSegment _buildSegment(List<TranscriptWord> words) {
    return CaptionSegment(
      text: _joinWords(words),
      startMillis: words.first.startMillis,
      endMillis: words.last.endMillis,
    );
  }

  String _joinWords(List<TranscriptWord> words) {
    return words
        .map((word) => word.text.trim())
        .where((word) => word.isNotEmpty)
        .join(' ');
  }
}
