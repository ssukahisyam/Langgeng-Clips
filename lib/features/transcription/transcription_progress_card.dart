import 'package:flutter/material.dart';

import 'transcription_progress.dart';

class TranscriptionProgressCard extends StatelessWidget {
  const TranscriptionProgressCard({super.key, required this.state});

  final TranscriptionProgressState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.isComplete ? 'Transcription complete' : 'Transcribing',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: state.progress),
            const SizedBox(height: 8),
            Text(
              '${state.percentLabel} · ${state.completedChunks}/${state.totalChunks} chunks',
            ),
            Text(state.currentLabel),
          ],
        ),
      ),
    );
  }
}
