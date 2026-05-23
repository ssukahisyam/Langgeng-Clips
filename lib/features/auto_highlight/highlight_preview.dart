import 'package:flutter/material.dart';

import 'highlight_candidate.dart';

class HighlightPreview extends StatelessWidget {
  const HighlightPreview({
    super.key,
    required this.candidates,
    required this.onSelected,
  });

  final List<HighlightCandidate> candidates;
  final ValueChanged<HighlightCandidate> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI highlight candidates',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (final candidate in candidates)
          Card(
            child: ListTile(
              title: Text(candidate.reason),
              subtitle: Text(
                '${candidate.startMillis}ms - ${candidate.endMillis}ms',
              ),
              trailing: _ScoreBadge(score: candidate.score),
              onTap: () => onSelected(candidate),
            ),
          ),
      ],
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('${(score * 100).round()}'));
  }
}
