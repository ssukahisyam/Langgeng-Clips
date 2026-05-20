import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/features/editor/editor_project.dart';

void main() {
  test('copyWith updates title without changing setup options', () {
    const project = EditorProject(
      title: 'episode.mp4',
      template: 'Podcast',
      clipCount: 'Auto',
      targetDuration: '30s',
    );

    final renamed = project.copyWith(title: 'Episode 12');

    expect(renamed.title, 'Episode 12');
    expect(renamed.template, 'Podcast');
    expect(renamed.clipCount, 'Auto');
    expect(renamed.targetDuration, '30s');
  });
}
