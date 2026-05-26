import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../import/selected_video_controller.dart';
import 'editor_project.dart';
import 'editor_project_store.dart';

final editorProjectProvider = StateProvider<EditorProject?>((ref) => null);

final activeEditorSessionLoaderProvider = FutureProvider<void>((ref) async {
  final store = await ref.watch(editorProjectStoreProvider.future);
  final session = store.readActiveSession();
  if (session == null) {
    return;
  }

  ref.read(selectedVideoProvider.notifier).state = session.video;
  ref.read(editorProjectProvider.notifier).state = session.project;
});

Future<void> saveActiveEditorSession(WidgetRef ref) async {
  final video = ref.read(selectedVideoProvider);
  final project = ref.read(editorProjectProvider);
  if (video == null || project == null) {
    return;
  }

  final store = await ref.read(editorProjectStoreProvider.future);
  await store.saveActiveSession(EditorSession(video: video, project: project));
  ref.invalidate(activeEditorSessionSummaryProvider);
}
