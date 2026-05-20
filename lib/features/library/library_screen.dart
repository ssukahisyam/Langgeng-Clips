import 'package:flutter/material.dart';

import '../../shared/widgets/app_scaffold.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Library',
      currentIndex: 1,
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
      ],
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.video_library_outlined, size: 56),
              SizedBox(height: 16),
              Text('Belum ada project'),
              SizedBox(height: 8),
              Text(
                'Project dan hasil export akan muncul di sini.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
