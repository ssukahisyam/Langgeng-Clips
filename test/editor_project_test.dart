import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/features/editor/editor_project.dart';

void main() {
  test('copyWith updates title without changing setup options', () {
    final project = EditorProject.initial(
      title: 'episode.mp4',
      mode: 'Semi-Auto',
      template: 'Podcast',
      clipCount: 'Auto',
      targetDuration: '30s',
      durationMillis: 60000,
    );

    final renamed = project.copyWith(title: 'Episode 12');

    expect(renamed.title, 'Episode 12');
    expect(renamed.mode, 'Semi-Auto');
    expect(renamed.template, 'Podcast');
    expect(renamed.clipCount, 'Auto');
    expect(renamed.targetDuration, '30s');
  });

  test('updates active clip range safely', () {
    final project = EditorProject.initial(
      title: 'episode.mp4',
      template: 'Podcast',
      clipCount: 'Auto',
      targetDuration: '30s',
      durationMillis: 60000,
    ).updateActiveClipRange(startMillis: 10000, endMillis: 30000);

    expect(project.activeClip.startMillis, 10000);
    expect(project.activeClip.endMillis, 30000);
    expect(project.activeClip.durationMillis, 20000);
  });

  test('adds clip from active range and selects it', () {
    final project =
        EditorProject.initial(
              title: 'episode.mp4',
              template: 'Podcast',
              clipCount: 'Auto',
              targetDuration: '30s',
              durationMillis: 60000,
            )
            .updateActiveClipRange(startMillis: 5000, endMillis: 15000)
            .addClipFromActiveRange();

    expect(project.clips, hasLength(2));
    expect(project.activeClip.id, 'clip-2');
    expect(project.activeClip.startMillis, 5000);
    expect(project.activeClip.endMillis, 15000);
  });

  test('formats milliseconds for editor labels', () {
    expect(formatMillis(61000), '01:01');
    expect(formatMillis(3661000), '01:01:01');
  });

  test('applies template name to project setup', () {
    final project = EditorProject.initial(
      title: 'episode.mp4',
      template: 'Podcast',
      clipCount: 'Auto',
      targetDuration: '30s',
      durationMillis: 60000,
    );

    expect(project.applyTemplate('Gaming').template, 'Gaming');
  });

  test('serializes project with clips and active clip', () {
    final project =
        EditorProject.initial(
              title: 'episode.mp4',
              template: 'Podcast',
              clipCount: 'Auto',
              targetDuration: '30s',
              durationMillis: 60000,
            )
            .updateActiveClipRange(startMillis: 5000, endMillis: 15000)
            .addClipFromActiveRange();

    final restored = EditorProject.fromJson(project.toJson());

    expect(restored.title, project.title);
    expect(restored.template, project.template);
    expect(restored.clips, hasLength(2));
    expect(restored.activeClipId, 'clip-2');
    expect(restored.activeClip.startMillis, 5000);
    expect(restored.activeClip.endMillis, 15000);
  });

  test('clamps playhead to active clip range', () {
    final project = EditorProject.initial(
      title: 'episode.mp4',
      template: 'Podcast',
      clipCount: 'Auto',
      targetDuration: '30s',
      durationMillis: 60000,
    ).updateActiveClipRange(startMillis: 10000, endMillis: 20000);

    expect(project.clampPlayheadMillis(5000), 10000);
    expect(project.clampPlayheadMillis(15000), 15000);
    expect(project.clampPlayheadMillis(25000), 20000);
  });

  test('skips to active clip boundaries', () {
    final project = EditorProject.initial(
      title: 'episode.mp4',
      template: 'Podcast',
      clipCount: 'Auto',
      targetDuration: '30s',
      durationMillis: 60000,
    ).updateActiveClipRange(startMillis: 10000, endMillis: 20000);

    expect(project.skipToActiveClipStart(), 10000);
    expect(project.skipToActiveClipEnd(), 20000);
  });
}
