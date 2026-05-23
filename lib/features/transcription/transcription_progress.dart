class TranscriptionProgressState {
  const TranscriptionProgressState({
    required this.completedChunks,
    required this.totalChunks,
    this.currentLabel = 'Preparing transcription',
  });

  final int completedChunks;
  final int totalChunks;
  final String currentLabel;

  double get progress {
    if (totalChunks <= 0) {
      return 0;
    }

    return (completedChunks / totalChunks).clamp(0, 1);
  }

  String get percentLabel => '${(progress * 100).round()}%';

  bool get isComplete => totalChunks > 0 && completedChunks >= totalChunks;
}
