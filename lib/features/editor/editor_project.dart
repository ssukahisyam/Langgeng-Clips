class EditorClip {
  const EditorClip({
    required this.id,
    required this.name,
    required this.startMillis,
    required this.endMillis,
  });

  final String id;
  final String name;
  final int startMillis;
  final int endMillis;

  int get durationMillis => endMillis - startMillis;

  EditorClip copyWith({int? startMillis, int? endMillis}) {
    return EditorClip(
      id: id,
      name: name,
      startMillis: startMillis ?? this.startMillis,
      endMillis: endMillis ?? this.endMillis,
    );
  }
}

class EditorProject {
  const EditorProject({
    required this.title,
    required this.template,
    required this.clipCount,
    required this.targetDuration,
    required this.durationMillis,
    required this.clips,
    required this.activeClipId,
  });

  factory EditorProject.initial({
    required String title,
    required String template,
    required String clipCount,
    required String targetDuration,
    required int durationMillis,
  }) {
    final safeDuration = durationMillis <= 0 ? 60000 : durationMillis;
    return EditorProject(
      title: title,
      template: template,
      clipCount: clipCount,
      targetDuration: targetDuration,
      durationMillis: safeDuration,
      clips: [
        EditorClip(
          id: 'clip-1',
          name: 'Clip 1',
          startMillis: 0,
          endMillis: safeDuration,
        ),
      ],
      activeClipId: 'clip-1',
    );
  }

  final String title;
  final String template;
  final String clipCount;
  final String targetDuration;
  final int durationMillis;
  final List<EditorClip> clips;
  final String activeClipId;

  EditorClip get activeClip {
    return clips.firstWhere(
      (clip) => clip.id == activeClipId,
      orElse: () => clips.first,
    );
  }

  EditorProject copyWith({
    String? title,
    String? template,
    String? clipCount,
    String? targetDuration,
    int? durationMillis,
    List<EditorClip>? clips,
    String? activeClipId,
  }) {
    return EditorProject(
      title: title ?? this.title,
      template: template ?? this.template,
      clipCount: clipCount ?? this.clipCount,
      targetDuration: targetDuration ?? this.targetDuration,
      durationMillis: durationMillis ?? this.durationMillis,
      clips: clips ?? this.clips,
      activeClipId: activeClipId ?? this.activeClipId,
    );
  }

  EditorProject updateActiveClipRange({
    required int startMillis,
    required int endMillis,
  }) {
    final safeStart = startMillis.clamp(0, durationMillis - 1000);
    final safeEnd = endMillis.clamp(safeStart + 1000, durationMillis);

    return copyWith(
      clips: [
        for (final clip in clips)
          if (clip.id == activeClipId)
            clip.copyWith(startMillis: safeStart, endMillis: safeEnd)
          else
            clip,
      ],
    );
  }

  EditorProject addClipFromActiveRange() {
    final source = activeClip;
    final nextIndex = clips.length + 1;
    final clip = EditorClip(
      id: 'clip-$nextIndex',
      name: 'Clip $nextIndex',
      startMillis: source.startMillis,
      endMillis: source.endMillis,
    );

    return copyWith(clips: [...clips, clip], activeClipId: clip.id);
  }

  EditorProject setActiveClip(String id) {
    if (!clips.any((clip) => clip.id == id)) {
      return this;
    }

    return copyWith(activeClipId: id);
  }
}

String formatMillis(int millis) {
  final totalSeconds = (millis / 1000).round();
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;

  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  return '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}
