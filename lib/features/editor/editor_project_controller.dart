import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../import/selected_video_controller.dart';
import '../auto_highlight/highlight_candidate.dart';
import '../semi_auto/semi_auto_candidate.dart';
import '../subtitle/caption_document.dart';
import '../watermark/watermark_config.dart';
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
  final captionDocument = session.captionDocument;
  if (captionDocument != null) {
    ref.read(captionDocumentProvider.notifier).state = captionDocument;
  }
  ref.read(semiAutoCandidatesProvider.notifier).state =
      session.semiAutoCandidates;
  ref.read(autoHighlightCandidatesProvider.notifier).state =
      session.autoHighlightCandidates;
  final watermarkConfig = session.watermarkConfig;
  if (watermarkConfig != null) {
    ref.read(watermarkConfigProvider.notifier).state = watermarkConfig;
  }
});

Future<void> saveActiveEditorSession(WidgetRef ref) async {
  final video = ref.read(selectedVideoProvider);
  final project = ref.read(editorProjectProvider);
  if (video == null || project == null) {
    return;
  }

  final store = await ref.read(editorProjectStoreProvider.future);
  await store.saveActiveSession(
    EditorSession(
      video: video,
      project: project,
      captionDocument: ref.read(captionDocumentProvider),
      semiAutoCandidates: ref.read(semiAutoCandidatesProvider),
      autoHighlightCandidates: ref.read(autoHighlightCandidatesProvider),
      watermarkConfig: ref.read(watermarkConfigProvider),
    ),
  );
  ref.invalidate(activeEditorSessionSummaryProvider);
}
