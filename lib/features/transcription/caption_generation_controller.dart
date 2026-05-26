import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../editor/editor_project.dart';
import '../editor/editor_project_controller.dart';
import '../editor/editor_project_store.dart';
import '../import/selected_video.dart';
import '../import/selected_video_controller.dart';
import '../onboarding/groq_api_key_controller.dart';
import '../subtitle/caption_document.dart';
import 'audio_chunker.dart';
import 'audio_extractor.dart';
import 'source_fingerprint.dart';
import 'transcription_language.dart';
import 'transcription_progress.dart';
import 'transcription_provider.dart';
import 'transcription_providers.dart';

final audioExtractorProvider = Provider<AudioExtractor>((ref) {
  return const AudioExtractor();
});

final sourceFingerprintProvider = Provider<SourceFingerprint>((ref) {
  return const SourceFingerprint();
});

final audioChunkerProvider = Provider<AudioChunker>((ref) {
  return const AudioChunker();
});

final captionGenerationControllerProvider =
    AsyncNotifierProvider<
      CaptionGenerationController,
      TranscriptionProgressState?
    >(CaptionGenerationController.new);

class CaptionGenerationController
    extends AsyncNotifier<TranscriptionProgressState?> {
  @override
  Future<TranscriptionProgressState?> build() async => null;

  Future<void> generate({
    required SelectedVideo video,
    required EditorProject project,
    TranscriptionSettings settings = const TranscriptionSettings(),
  }) async {
    state = const AsyncValue.data(
      TranscriptionProgressState(
        completedChunks: 0,
        totalChunks: 0,
        currentLabel: 'Preparing transcription',
      ),
    );

    try {
      final fingerprint = ref.read(sourceFingerprintProvider);
      final sourceSha256 = await fingerprint.sha256ForFile(video.path);
      final cache = await ref.read(transcriptCacheProvider.future);
      final cachedTranscript = cache.read(sourceSha256);
      if (cachedTranscript != null) {
        _applyTranscript(cachedTranscript);
        state = const AsyncValue.data(
          TranscriptionProgressState(
            completedChunks: 1,
            totalChunks: 1,
            currentLabel: 'Loaded transcript from cache',
          ),
        );
        return;
      }

      final chunker = ref.read(audioChunkerProvider);
      final chunks = chunker.plan(project.durationMillis);
      if (chunks.isEmpty) {
        throw const TranscriptionException('Durasi video tidak valid.');
      }

      final apiKeyState = await ref.read(groqApiKeyControllerProvider.future);
      if (!apiKeyState.hasKey) {
        throw const TranscriptionException(
          'Groq API key belum tersedia. Tambahkan API key untuk generate subtitle.',
        );
      }

      state = AsyncValue.data(
        TranscriptionProgressState(
          completedChunks: 0,
          totalChunks: chunks.length,
          currentLabel: 'Extracting audio',
        ),
      );

      final extractor = ref.read(audioExtractorProvider);
      final provider = await ref.read(transcriptionProvider.future);
      final resumeStore = await ref.read(
        transcriptionResumeStoreProvider.future,
      );
      final checkpoint = resumeStore.read(sourceSha256);
      final transcripts = <Transcript>[];
      for (final chunk in chunks) {
        final resumedTranscript = checkpoint?.chunkTranscripts[chunk.index];
        if (resumedTranscript != null) {
          transcripts.add(resumedTranscript);
          continue;
        }

        state = AsyncValue.data(
          TranscriptionProgressState(
            completedChunks: transcripts.length,
            totalChunks: chunks.length,
            currentLabel:
                'Transcribing chunk ${chunk.index + 1}/${chunks.length}',
          ),
        );
        final audioPath = await extractor.extractWav16kMono(
          sourcePath: video.path,
          startMillis: chunk.startMillis,
          endMillis: chunk.endMillis,
        );
        final audioBytes = await File(audioPath).readAsBytes();
        final transcript = await provider.transcribeChunk(
          TranscriptionChunk(
            bytes: audioBytes,
            fileName: 'langgeng_chunk_${chunk.index}.wav',
            mimeType: 'audio/wav',
            startOffsetMillis: chunk.startMillis,
            language: settings.language.groqParameter,
          ),
        );
        transcripts.add(transcript);
        await resumeStore.markCompleted(
          sourceSha256,
          chunk.index,
          transcript: transcript,
        );
      }

      final transcript = Transcript.mergeChunks(transcripts);
      await cache.write(sourceSha256, transcript);
      await resumeStore.clear(sourceSha256);
      _applyTranscript(transcript);
      state = AsyncValue.data(
        TranscriptionProgressState(
          completedChunks: chunks.length,
          totalChunks: chunks.length,
          currentLabel: 'Subtitle generated',
        ),
      );
    } on AudioExtractionException catch (error, stackTrace) {
      state = AsyncValue.error(
        TranscriptionException(error.message),
        stackTrace,
      );
    } on SourceFingerprintException catch (error, stackTrace) {
      state = AsyncValue.error(
        TranscriptionException(error.message),
        stackTrace,
      );
    } on TranscriptionException catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    } catch (error, stackTrace) {
      state = AsyncValue.error(
        const TranscriptionException('Gagal membuat subtitle.'),
        stackTrace,
      );
    }
  }

  void _applyTranscript(Transcript transcript) {
    final current = ref.read(captionDocumentProvider);
    final document = CaptionDocument.fromTranscript(
      transcript,
      style: current.style,
    );
    ref.read(captionDocumentProvider.notifier).state = document;
    unawaited(_saveCaptionDocument(document));
  }

  Future<void> _saveCaptionDocument(CaptionDocument document) async {
    final video = ref.read(selectedVideoProvider);
    final project = ref.read(editorProjectProvider);
    if (video == null || project == null) {
      return;
    }

    final store = await ref.read(editorProjectStoreProvider.future);
    await store.saveActiveSession(
      EditorSession(video: video, project: project, captionDocument: document),
    );
    ref.invalidate(activeEditorSessionSummaryProvider);
  }
}
