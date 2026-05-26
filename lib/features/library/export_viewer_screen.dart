import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import 'export_history.dart';

class ExportViewerScreen extends ConsumerWidget {
  const ExportViewerScreen({required this.exportId, super.key});

  final String exportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(exportHistoryItemProvider(exportId));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Clip Viewer'),
      ),
      body: item.when(
        data: (item) => item == null
            ? const Center(
                child: Text(
                  'Export tidak ditemukan.',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : ExportVideoViewer(item: item),
        error: (_, _) => const Center(
          child: Text(
            'Gagal memuat export.',
            style: TextStyle(color: Colors.white),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class ExportVideoViewer extends StatefulWidget {
  const ExportVideoViewer({required this.item, super.key});

  final ExportHistoryItem item;

  @override
  State<ExportVideoViewer> createState() => _ExportVideoViewerState();
}

class _ExportVideoViewerState extends State<ExportVideoViewer> {
  VideoPlayerController? _controller;
  bool _isInitializing = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    final file = File(widget.item.cachePath);
    if (!file.existsSync()) {
      setState(() {
        _isInitializing = false;
        _error = 'File export tidak ditemukan di cache.';
      });
      return;
    }

    final controller = VideoPlayerController.file(file);
    _controller = controller;
    try {
      await controller.initialize();
      if (!mounted) {
        return;
      }
      setState(() => _isInitializing = false);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isInitializing = false;
        _error = 'Video export gagal dimuat.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }

    final error = _error;
    final controller = _controller;
    if (error != null ||
        controller == null ||
        !controller.value.isInitialized) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            error ?? 'Video export belum siap.',
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SafeArea(
      child: Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(controller),
              Positioned(
                bottom: 24,
                child: FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      controller.value.isPlaying
                          ? controller.pause()
                          : controller.play();
                    });
                  },
                  icon: Icon(
                    controller.value.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                  ),
                  label: Text(controller.value.isPlaying ? 'Pause' : 'Play'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
