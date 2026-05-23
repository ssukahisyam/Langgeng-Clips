import '../transcription/transcription_provider.dart';

class FillerWordFilter {
  const FillerWordFilter({this.enabled = false});

  static const defaultFillers = {'um', 'uh', 'emm', 'anu', 'kayak', 'like'};

  final bool enabled;

  Transcript apply(Transcript transcript) {
    if (!enabled) {
      return transcript;
    }

    final words = transcript.words
        .where((word) => !defaultFillers.contains(word.text.toLowerCase()))
        .toList();

    return Transcript(
      text: words.map((word) => word.text).join(' '),
      language: transcript.language,
      durationSeconds: transcript.durationSeconds,
      words: words,
    );
  }
}
