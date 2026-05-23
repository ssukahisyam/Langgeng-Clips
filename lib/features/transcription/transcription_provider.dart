import 'dart:typed_data';

abstract interface class TranscriptionProvider {
  Future<Transcript> transcribeChunk(TranscriptionChunk chunk);
}

class TranscriptionChunk {
  const TranscriptionChunk({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
    required this.startOffsetMillis,
    this.language,
  });

  final Uint8List bytes;
  final String fileName;
  final String mimeType;
  final int startOffsetMillis;
  final String? language;

  TranscriptionChunk copyWith({String? language}) {
    return TranscriptionChunk(
      bytes: bytes,
      fileName: fileName,
      mimeType: mimeType,
      startOffsetMillis: startOffsetMillis,
      language: language ?? this.language,
    );
  }
}

class Transcript {
  const Transcript({
    required this.text,
    required this.words,
    this.language,
    this.durationSeconds,
  });

  factory Transcript.fromGroqJson(
    Map<String, dynamic> json, {
    int offsetMillis = 0,
  }) {
    final wordsJson = json['words'];
    final words = wordsJson is List
        ? wordsJson
              .whereType<Map<String, dynamic>>()
              .map((word) => TranscriptWord.fromGroqJson(word, offsetMillis))
              .toList()
        : const <TranscriptWord>[];

    return Transcript(
      text: json['text'] as String? ?? '',
      language: json['language'] as String?,
      durationSeconds: (json['duration'] as num?)?.toDouble(),
      words: words,
    );
  }

  factory Transcript.fromJson(Map<String, dynamic> json) {
    final wordsJson = json['words'];
    return Transcript(
      text: json['text'] as String? ?? '',
      language: json['language'] as String?,
      durationSeconds: (json['durationSeconds'] as num?)?.toDouble(),
      words: wordsJson is List
          ? wordsJson
                .whereType<Map<String, dynamic>>()
                .map(TranscriptWord.fromJson)
                .toList()
          : const <TranscriptWord>[],
    );
  }

  factory Transcript.mergeChunks(List<Transcript> chunks) {
    if (chunks.isEmpty) {
      return const Transcript(text: '', words: []);
    }

    final words = chunks.expand((chunk) => chunk.words).toList()
      ..sort((a, b) {
        final startCompare = a.startMillis.compareTo(b.startMillis);
        if (startCompare != 0) {
          return startCompare;
        }

        return a.endMillis.compareTo(b.endMillis);
      });
    final mergedWords = <TranscriptWord>[];
    for (final word in words) {
      if (mergedWords.isNotEmpty &&
          word.text == mergedWords.last.text &&
          word.startMillis < mergedWords.last.endMillis) {
        continue;
      }
      mergedWords.add(word);
    }

    return Transcript(
      text: mergedWords.map((word) => word.text).join(' ').trim(),
      language: chunks.first.language,
      durationSeconds: chunks.last.durationSeconds,
      words: mergedWords,
    );
  }

  final String text;
  final String? language;
  final double? durationSeconds;
  final List<TranscriptWord> words;

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      if (language != null) 'language': language,
      if (durationSeconds != null) 'durationSeconds': durationSeconds,
      'words': words.map((word) => word.toJson()).toList(),
    };
  }
}

class TranscriptWord {
  const TranscriptWord({
    required this.text,
    required this.startMillis,
    required this.endMillis,
  });

  factory TranscriptWord.fromGroqJson(
    Map<String, dynamic> json,
    int offsetMillis,
  ) {
    return TranscriptWord(
      text: json['word'] as String? ?? '',
      startMillis: offsetMillis + _secondsToMillis(json['start']),
      endMillis: offsetMillis + _secondsToMillis(json['end']),
    );
  }

  factory TranscriptWord.fromJson(Map<String, dynamic> json) {
    return TranscriptWord(
      text: json['text'] as String? ?? '',
      startMillis: (json['startMillis'] as num?)?.toInt() ?? 0,
      endMillis: (json['endMillis'] as num?)?.toInt() ?? 0,
    );
  }

  final String text;
  final int startMillis;
  final int endMillis;

  Map<String, dynamic> toJson() {
    return {'text': text, 'startMillis': startMillis, 'endMillis': endMillis};
  }

  static int _secondsToMillis(Object? value) {
    if (value is num) {
      return (value * 1000).round();
    }

    return 0;
  }
}

class TranscriptionException implements Exception {
  const TranscriptionException(this.message);

  final String message;

  @override
  String toString() => message;
}
