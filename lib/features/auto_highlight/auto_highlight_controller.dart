import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/preferences/preferences_providers.dart';
import '../../core/security/api_key_store.dart';
import '../editor/editor_project.dart';
import '../editor/editor_project_store.dart';
import '../import/selected_video.dart';
import '../onboarding/groq_api_key_controller.dart';
import '../transcription/caption_generation_controller.dart';
import '../transcription/transcription_provider.dart';
import '../transcription/transcription_providers.dart';
import 'groq_highlight_client.dart';
import 'highlight_cache.dart';
import 'highlight_candidate.dart';
import 'sentence_boundary_refiner.dart';

final highlightCacheProvider = FutureProvider<HighlightCache>((ref) async {
  final preferences = await ref.watch(sharedPreferencesProvider.future);
  return HighlightCache(preferences: preferences);
});

final groqHighlightClientProvider = FutureProvider<GroqHighlightClient>((
  ref,
) async {
  final apiKey = await ref.read(apiKeyStoreProvider).readGroqKey();
  return GroqHighlightClient(apiKey: apiKey ?? '');
});

final sentenceBoundaryRefinerProvider = Provider<SentenceBoundaryRefiner>((
  ref,
) {
  return const SentenceBoundaryRefiner();
});

final autoHighlightControllerProvider =
    AsyncNotifierProvider<AutoHighlightController, List<HighlightCandidate>>(
      AutoHighlightController.new,
    );

class AutoHighlightController extends AsyncNotifier<List<HighlightCandidate>> {
  @override
  Future<List<HighlightCandidate>> build() async {
    return ref.watch(autoHighlightCandidatesProvider);
  }

  Future<void> generate({
    required SelectedVideo video,
    required EditorProject project,
  }) async {
    state = const AsyncValue.loading();
    try {
      final apiKeyState = await ref.read(groqApiKeyControllerProvider.future);
      if (!apiKeyState.hasKey) {
        throw const HighlightException(
          'Groq API key belum tersedia. Tambahkan API key untuk Auto AI.',
        );
      }

      final sourceSha256 = await ref
          .read(sourceFingerprintProvider)
          .sha256ForFile(video.path);
      final configHash = _configHash(project);
      final cache = await ref.read(highlightCacheProvider.future);
      final cached = cache.read(
        sourceSha256: sourceSha256,
        configHash: configHash,
      );
      if (cached != null) {
        await _applyResult(video: video, project: project, result: cached);
        return;
      }

      final transcript = await _ensureTranscript(
        video: video,
        project: project,
        sourceSha256: sourceSha256,
      );
      final rawResult = await ref
          .read(groqHighlightClientProvider.future)
          .then((client) => client.scoreTranscript(transcript));
      final refinedResult = HighlightResult(
        candidates: rawResult.candidates
            .map(
              (candidate) => ref
                  .read(sentenceBoundaryRefinerProvider)
                  .refine(candidate, transcript),
            )
            .where((candidate) => candidate.isValid)
            .toList(),
      );
      await cache.write(
        sourceSha256: sourceSha256,
        configHash: configHash,
        result: refinedResult,
      );
      await _applyResult(video: video, project: project, result: refinedResult);
    } on HighlightException catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    } on TranscriptionException catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    } catch (error, stackTrace) {
      state = AsyncValue.error(
        const HighlightException('Gagal membuat kandidat Auto AI.'),
        stackTrace,
      );
    }
  }

  Future<Transcript> _ensureTranscript({
    required SelectedVideo video,
    required EditorProject project,
    required String sourceSha256,
  }) async {
    final transcriptCache = await ref.read(transcriptCacheProvider.future);
    final cachedTranscript = transcriptCache.read(sourceSha256);
    if (cachedTranscript != null) {
      return cachedTranscript;
    }

    await ref
        .read(captionGenerationControllerProvider.notifier)
        .generate(video: video, project: project);
    final generatedTranscript = transcriptCache.read(sourceSha256);
    if (generatedTranscript == null) {
      throw const HighlightException(
        'Transcript belum tersedia. Generate subtitle terlebih dahulu.',
      );
    }
    return generatedTranscript;
  }

  Future<void> _applyResult({
    required SelectedVideo video,
    required EditorProject project,
    required HighlightResult result,
  }) async {
    final candidates = [...result.candidates]
      ..sort((a, b) => b.score.compareTo(a.score));
    ref.read(autoHighlightCandidatesProvider.notifier).state = candidates;
    state = AsyncValue.data(candidates);

    final store = await ref.read(editorProjectStoreProvider.future);
    await store.saveActiveSession(
      EditorSession(
        video: video,
        project: project,
        autoHighlightCandidates: candidates,
      ),
    );
    ref.invalidate(activeEditorSessionSummaryProvider);
  }

  String _configHash(EditorProject project) {
    return sha256
        .convert('${project.targetDuration}:${project.clipCount}:v1'.codeUnits)
        .toString();
  }
}
