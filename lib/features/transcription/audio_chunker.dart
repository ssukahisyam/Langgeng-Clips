class AudioChunkPlan {
  const AudioChunkPlan({
    required this.index,
    required this.startMillis,
    required this.endMillis,
  });

  final int index;
  final int startMillis;
  final int endMillis;

  int get durationMillis => endMillis - startMillis;
}

class AudioChunker {
  const AudioChunker({
    this.chunkDurationMillis = 10 * 60 * 1000,
    this.overlapMillis = 5 * 1000,
  });

  final int chunkDurationMillis;
  final int overlapMillis;

  List<AudioChunkPlan> plan(int durationMillis) {
    if (durationMillis <= 0) {
      return const [];
    }
    if (chunkDurationMillis <= 0) {
      throw const AudioChunkerException('Durasi chunk harus lebih dari 0.');
    }
    if (overlapMillis < 0 || overlapMillis >= chunkDurationMillis) {
      throw const AudioChunkerException(
        'Overlap chunk harus lebih kecil dari durasi chunk.',
      );
    }

    final chunks = <AudioChunkPlan>[];
    var index = 0;
    var startMillis = 0;
    while (startMillis < durationMillis) {
      final endMillis = (startMillis + chunkDurationMillis).clamp(
        0,
        durationMillis,
      );
      chunks.add(
        AudioChunkPlan(
          index: index,
          startMillis: startMillis,
          endMillis: endMillis,
        ),
      );

      if (endMillis == durationMillis) {
        break;
      }
      index += 1;
      startMillis = endMillis - overlapMillis;
    }

    return chunks;
  }
}

class AudioChunkerException implements Exception {
  const AudioChunkerException(this.message);

  final String message;

  @override
  String toString() => message;
}
