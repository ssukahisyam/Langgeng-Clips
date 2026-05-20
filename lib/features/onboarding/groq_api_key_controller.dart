import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/security/api_key_store.dart';
import 'groq_api_key_validator.dart';

final apiKeyStoreProvider = Provider<ApiKeyStore>((ref) => ApiKeyStore());

final groqApiKeyValidatorProvider = Provider<GroqApiKeyValidator>(
  (ref) => GroqApiKeyValidator(),
);

final groqApiKeyControllerProvider =
    AsyncNotifierProvider<GroqApiKeyController, GroqApiKeyState>(
      GroqApiKeyController.new,
    );

class GroqApiKeyController extends AsyncNotifier<GroqApiKeyState> {
  @override
  Future<GroqApiKeyState> build() async {
    final key = await ref.read(apiKeyStoreProvider).readGroqKey();

    return GroqApiKeyState(
      hasKey: key != null && key.isNotEmpty,
      maskedKey: _maskKey(key),
    );
  }

  Future<void> validateAndSave(String rawKey) async {
    final key = rawKey.trim();
    if (key.isEmpty) {
      state = AsyncValue.data(
        state.valueOrNull?.copyWith(errorMessage: 'API key wajib diisi') ??
            const GroqApiKeyState(errorMessage: 'API key wajib diisi'),
      );
      return;
    }

    if (!key.startsWith('gsk_')) {
      state = AsyncValue.data(
        state.valueOrNull?.copyWith(
              errorMessage: 'Format Groq API key biasanya diawali gsk_',
            ) ??
            const GroqApiKeyState(
              errorMessage: 'Format Groq API key biasanya diawali gsk_',
            ),
      );
      return;
    }

    state = const AsyncValue.loading();

    try {
      await ref.read(groqApiKeyValidatorProvider).validate(key);
      await ref.read(apiKeyStoreProvider).saveGroqKey(key);
      state = AsyncValue.data(
        GroqApiKeyState(hasKey: true, maskedKey: _maskKey(key)),
      );
    } catch (error) {
      state = AsyncValue.data(
        GroqApiKeyState(hasKey: false, errorMessage: _toMessage(error)),
      );
    }
  }

  Future<void> deleteKey() async {
    await ref.read(apiKeyStoreProvider).deleteGroqKey();
    state = const AsyncValue.data(GroqApiKeyState());
  }

  static String? _maskKey(String? key) {
    if (key == null || key.isEmpty) {
      return null;
    }

    final suffix = key.length <= 4 ? key : key.substring(key.length - 4);
    return '********$suffix';
  }

  static String _toMessage(Object error) {
    if (error is GroqApiKeyValidationException) {
      return error.message;
    }

    return 'Gagal validasi key. Cek koneksi internet lalu coba lagi.';
  }
}

class GroqApiKeyState {
  const GroqApiKeyState({
    this.hasKey = false,
    this.maskedKey,
    this.errorMessage,
  });

  final bool hasKey;
  final String? maskedKey;
  final String? errorMessage;

  GroqApiKeyState copyWith({
    bool? hasKey,
    String? maskedKey,
    String? errorMessage,
  }) {
    return GroqApiKeyState(
      hasKey: hasKey ?? this.hasKey,
      maskedKey: maskedKey ?? this.maskedKey,
      errorMessage: errorMessage,
    );
  }
}
