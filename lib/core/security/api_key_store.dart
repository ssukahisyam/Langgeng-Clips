import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiKeyStore {
  ApiKeyStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _groqKey = 'groq_api_key';

  final FlutterSecureStorage _storage;

  Future<String?> readGroqKey() => _storage.read(key: _groqKey);

  Future<void> saveGroqKey(String value) {
    return _storage.write(key: _groqKey, value: value.trim());
  }

  Future<void> deleteGroqKey() => _storage.delete(key: _groqKey);
}
