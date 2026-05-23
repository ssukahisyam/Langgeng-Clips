import 'package:flutter/material.dart';

import 'subject_tracking.dart';

class SubjectTrackingPanel extends StatelessWidget {
  const SubjectTrackingPanel({super.key, required this.config});

  final SubjectTrackingConfig config;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subject tracking',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              config.enabled
                  ? 'Face-aware crop enabled'
                  : 'Center crop fallback',
            ),
            const SizedBox(height: 8),
            Text('Smoothing: ${(config.smoothing * 100).round()}%'),
            const Text('Multi-face strategy: primary by confidence'),
          ],
        ),
      ),
    );
  }
}
