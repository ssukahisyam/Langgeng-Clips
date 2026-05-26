import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../editor/editor_project.dart';
import '../editor/editor_project_store.dart';
import '../import/selected_video.dart';
import '../media_intelligence/audio_level_analyzer.dart';
import '../media_intelligence/scene_change_detector.dart';
import '../transcription/audio_extractor.dart';
import '../transcription/caption_generation_controller.dart';
import 'semi_auto_candidate.dart';

final sceneChangeDetectorProvider = Provider<SceneChangeDetector>((ref) {
  return const SceneChangeDetector();
});

final audioLevelAnalyzerProvider = Provider<AudioLevelAnalyzer>((ref) {
  return const AudioLevelAnalyzer(windowMillis: 250);
});

final semiAutoGenerationControllerProvider =
    AsyncNotifierProvider<
      SemiAutoGenerationController,
      List<SemiAutoCandidate>
    >(SemiAutoGenerationController.new);

class SemiAutoGenerationController
    extends AsyncNotifier<List<SemiAutoCandidate>> {
  @override
  Future<List<SemiAutoCandidate>> build() async {
    return ref.watch(semiAutoCandidatesProvider);
  }

  Future<void> generate({
    required SelectedVideo video,
    required EditorProject project,
    SemiAutoTuning tuning = const SemiAutoTuning(),
  }) async {
    state = const AsyncValue.loading();
    try {
      final candidates = await _generateCandidates(
        video: video,
        project: project,
        tuning: tuning,
      );
      ref.read(semiAutoCandidatesProvider.notifier).state = candidates;
      await _saveCandidates(
        video: video,
        project: project,
        candidates: candidates,
      );
      state = AsyncValue.data(candidates);
    } on AudioExtractionException catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    } on AudioLevelException catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    } on SceneDetectionException catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    } catch (error, stackTrace) {
      state = AsyncValue.error(
        const SemiAutoGenerationException('Gagal membuat kandidat Semi-Auto.'),
        stackTrace,
      );
    }
  }

  Future<List<SemiAutoCandidate>> _generateCandidates({
    required SelectedVideo video,
    required EditorProject project,
    required SemiAutoTuning tuning,
  }) async {
    final targetDuration = _targetDurationMillis(project);
    final extractor = ref.read(audioExtractorProvider);
    final audioPath = await extractor.extractWav16kMono(
      sourcePath: video.path,
      startMillis: 0,
      endMillis: project.durationMillis,
    );
    final analysis = ref
        .read(audioLevelAnalyzerProvider)
        .analyzeWav(await File(audioPath).readAsBytes());
    final scenes = await ref
        .read(sceneChangeDetectorProvider)
        .detect(sourcePath: video.path, threshold: tuning.sceneChangeThreshold);

    final candidates = <SemiAutoCandidate>[
      for (final peak in analysis.peaks(
        thresholdDbfs: tuning.audioPeakThreshold,
      ))
        _candidateAround(
          centerMillis: peak.timeMillis,
          durationMillis: targetDuration,
          projectDurationMillis: project.durationMillis,
          reason: 'Audio peak ${peak.peakDbfs.toStringAsFixed(1)} dBFS',
          confidence: _normalizeDbfs(peak.peakDbfs),
        ),
      for (final silence in analysis.silences(
        thresholdDbfs: tuning.silenceThreshold,
      ))
        _candidateAround(
          centerMillis: silence.endMillis,
          durationMillis: targetDuration,
          projectDurationMillis: project.durationMillis,
          reason: 'After silence break',
          confidence: 0.62,
        ),
      for (final scene in scenes)
        _candidateAround(
          centerMillis: scene.timeMillis,
          durationMillis: targetDuration,
          projectDurationMillis: project.durationMillis,
          reason: 'Scene change ${(scene.score * 100).round()}%',
          confidence: scene.score.clamp(0, 1),
        ),
    ].where((candidate) => candidate.isValid).toList();

    candidates.sort((a, b) => b.confidence.compareTo(a.confidence));
    return _dedupe(candidates).take(_targetClipCount(project)).toList();
  }

  Future<void> _saveCandidates({
    required SelectedVideo video,
    required EditorProject project,
    required List<SemiAutoCandidate> candidates,
  }) async {
    final store = await ref.read(editorProjectStoreProvider.future);
    await store.saveActiveSession(
      EditorSession(
        video: video,
        project: project,
        semiAutoCandidates: candidates,
      ),
    );
    ref.invalidate(activeEditorSessionSummaryProvider);
  }

  SemiAutoCandidate _candidateAround({
    required int centerMillis,
    required int durationMillis,
    required int projectDurationMillis,
    required String reason,
    required double confidence,
  }) {
    final halfDuration = durationMillis ~/ 2;
    final startMillis = (centerMillis - halfDuration).clamp(
      0,
      projectDurationMillis,
    );
    final endMillis = (startMillis + durationMillis).clamp(
      0,
      projectDurationMillis,
    );
    return SemiAutoCandidate(
      startMillis: startMillis,
      endMillis: endMillis,
      reason: reason,
      confidence: confidence,
    );
  }

  List<SemiAutoCandidate> _dedupe(List<SemiAutoCandidate> candidates) {
    final deduped = <SemiAutoCandidate>[];
    for (final candidate in candidates) {
      final overlapsExisting = deduped.any(
        (existing) =>
            candidate.startMillis < existing.endMillis &&
            candidate.endMillis > existing.startMillis,
      );
      if (!overlapsExisting) {
        deduped.add(candidate);
      }
    }
    return deduped;
  }

  int _targetDurationMillis(EditorProject project) {
    return switch (project.targetDuration) {
      '15s' => 15000,
      '30s' => 30000,
      '60s' => 60000,
      _ => 30000,
    };
  }

  int _targetClipCount(EditorProject project) {
    return switch (project.clipCount) {
      '1' => 1,
      '3' => 3,
      '5' => 5,
      _ => 5,
    };
  }

  double _normalizeDbfs(double dbfs) {
    return ((dbfs + 42) / 24).clamp(0, 1);
  }
}

class SemiAutoGenerationException implements Exception {
  const SemiAutoGenerationException(this.message);

  final String message;

  @override
  String toString() => message;
}
