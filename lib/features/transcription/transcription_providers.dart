import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/preferences/preferences_providers.dart';
import '../../core/security/api_key_store.dart';
import 'groq_whisper_provider.dart';
import 'retrying_transcription_provider.dart';
import 'transcript_cache.dart';
import 'transcription_provider.dart';
import 'transcription_resume_store.dart';

final groqWhisperProvider = FutureProvider<GroqWhisperProvider>((ref) async {
  final apiKey = await ref.read(apiKeyStoreProvider).readGroqKey();
  return GroqWhisperProvider(apiKey: apiKey ?? '');
});

final transcriptionProvider = FutureProvider<TranscriptionProvider>((
  ref,
) async {
  final groq = await ref.watch(groqWhisperProvider.future);
  return RetryingTranscriptionProvider(delegate: groq);
});

final transcriptCacheProvider = FutureProvider<TranscriptCache>((ref) async {
  final preferences = await ref.watch(sharedPreferencesProvider.future);
  return TranscriptCache(preferences: preferences);
});

final transcriptionResumeStoreProvider =
    FutureProvider<TranscriptionResumeStore>((ref) async {
      final preferences = await ref.watch(sharedPreferencesProvider.future);
      return TranscriptionResumeStore(preferences: preferences);
    });
