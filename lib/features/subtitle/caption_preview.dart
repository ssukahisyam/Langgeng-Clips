import 'package:flutter/material.dart';

import 'caption_document.dart';

class CaptionPreview extends StatelessWidget {
  const CaptionPreview({super.key, required this.document});

  final CaptionDocument document;

  @override
  Widget build(BuildContext context) {
    final text = document.items.isEmpty
        ? 'Caption preview'
        : document.items.first.text;
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 72),
          child: Align(
            alignment: _alignmentFor(document.style.position),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.54),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(document.style.highlightColor),
                    fontSize: document.style.size,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Alignment _alignmentFor(CaptionPosition position) {
    return switch (position) {
      CaptionPosition.topLeft => Alignment.topLeft,
      CaptionPosition.topCenter => Alignment.topCenter,
      CaptionPosition.topRight => Alignment.topRight,
      CaptionPosition.centerLeft => Alignment.centerLeft,
      CaptionPosition.center => Alignment.center,
      CaptionPosition.centerRight => Alignment.centerRight,
      CaptionPosition.bottomLeft => Alignment.bottomLeft,
      CaptionPosition.bottomCenter => Alignment.bottomCenter,
      CaptionPosition.bottomRight => Alignment.bottomRight,
    };
  }
}
