import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/security/api_key_store.dart';
import 'groq_whisper_provider.dart';

final groqWhisperProvider = FutureProvider<GroqWhisperProvider>((ref) async {
  final apiKey = await ref.read(apiKeyStoreProvider).readGroqKey();
  return GroqWhisperProvider(apiKey: apiKey ?? '');
});
