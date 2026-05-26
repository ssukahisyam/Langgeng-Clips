import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/features/editor/editor_project.dart';
import 'package:langgeng_clip/features/editor/editor_project_store.dart';
import 'package:langgeng_clip/features/import/selected_video.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('stores and restores active editor session', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = EditorProjectStore(preferences);
    final session = EditorSession(
      video: const SelectedVideo(
        name: 'episode.mp4',
        path: '/storage/episode.mp4',
        sizeBytes: 1024,
      ),
      project: EditorProject.initial(
        title: 'episode.mp4',
        template: 'Podcast',
        clipCount: 'Auto',
        targetDuration: '30s',
        durationMillis: 60000,
      ),
    );

    await store.saveActiveSession(session);

    final restored = store.readActiveSession();
    expect(restored, isNotNull);
    expect(restored!.video.name, 'episode.mp4');
    expect(restored.video.path, '/storage/episode.mp4');
    expect(restored.project.title, 'episode.mp4');
    expect(restored.project.activeClip.endMillis, 60000);
  });

  test('clears active editor session', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = EditorProjectStore(preferences);

    await store.saveActiveSession(
      EditorSession(
        video: const SelectedVideo(
          name: 'episode.mp4',
          path: '/storage/episode.mp4',
          sizeBytes: 1024,
        ),
        project: EditorProject.initial(
          title: 'episode.mp4',
          template: 'Podcast',
          clipCount: 'Auto',
          targetDuration: '30s',
          durationMillis: 60000,
        ),
      ),
    );

    await store.clearActiveSession();

    expect(store.readActiveSession(), isNull);
  });
}
