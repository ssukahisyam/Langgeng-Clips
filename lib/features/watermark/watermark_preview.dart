import 'package:flutter/material.dart';

import 'watermark_config.dart';

class WatermarkPreview extends StatelessWidget {
  const WatermarkPreview({super.key, required this.config});

  final WatermarkConfig config;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Align(
          alignment: _alignmentFor(config.anchor),
          child: Opacity(
            opacity: config.opacity,
            child: Transform.scale(
              scale: config.scale,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.48),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: Text(
                      config.text?.trim().isNotEmpty == true
                          ? config.text!
                          : 'Watermark',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Alignment _alignmentFor(WatermarkAnchor anchor) {
    return switch (anchor) {
      WatermarkAnchor.topLeft => Alignment.topLeft,
      WatermarkAnchor.topCenter => Alignment.topCenter,
      WatermarkAnchor.topRight => Alignment.topRight,
      WatermarkAnchor.centerLeft => Alignment.centerLeft,
      WatermarkAnchor.center => Alignment.center,
      WatermarkAnchor.centerRight => Alignment.centerRight,
      WatermarkAnchor.bottomLeft => Alignment.bottomLeft,
      WatermarkAnchor.bottomCenter => Alignment.bottomCenter,
      WatermarkAnchor.bottomRight => Alignment.bottomRight,
    };
  }
}
