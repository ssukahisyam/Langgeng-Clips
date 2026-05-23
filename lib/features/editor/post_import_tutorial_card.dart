import 'package:flutter/material.dart';

class PostImportTutorialCard extends StatelessWidget {
  const PostImportTutorialCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick start',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text('1. Geser timeline untuk pilih momen terbaik.'),
            const Text('2. Pilih template di tab Style.'),
            const Text('3. Edit caption/watermark jika perlu.'),
            const Text('4. Export active clip.'),
          ],
        ),
      ),
    );
  }
}
