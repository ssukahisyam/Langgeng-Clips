import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/preferences/preferences_providers.dart';

final exportHistoryRepositoryProvider = FutureProvider<ExportHistoryRepository>(
  (ref) async {
    final preferences = await ref.watch(sharedPreferencesProvider.future);
    return ExportHistoryRepository(preferences);
  },
);

final exportHistoryItemsProvider = FutureProvider<List<ExportHistoryItem>>((
  ref,
) async {
  final repository = await ref.watch(exportHistoryRepositoryProvider.future);
  return repository.readAll();
});

class ExportHistoryRepository {
  ExportHistoryRepository(this._preferences);

  static const _itemsKey = 'export_history_items';

  final SharedPreferences _preferences;

  List<ExportHistoryItem> readAll() {
    final raw = _preferences.getString(_itemsKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .cast<Map<String, dynamic>>()
        .map(ExportHistoryItem.fromJson)
        .toList(growable: false);
  }

  Future<void> add(ExportHistoryItem item) async {
    final items = [item, ...readAll()];
    final encoded = jsonEncode(items.map((item) => item.toJson()).toList());
    await _preferences.setString(_itemsKey, encoded);
  }
}

class ExportHistoryItem {
  const ExportHistoryItem({
    required this.id,
    required this.title,
    required this.cachePath,
    required this.createdAtMillis,
    required this.durationMillis,
    this.galleryUri,
  });

  factory ExportHistoryItem.fromJson(Map<String, dynamic> json) {
    return ExportHistoryItem(
      id: json['id'] as String,
      title: json['title'] as String,
      cachePath: json['cachePath'] as String,
      galleryUri: json['galleryUri'] as String?,
      createdAtMillis: json['createdAtMillis'] as int,
      durationMillis: json['durationMillis'] as int,
    );
  }

  final String id;
  final String title;
  final String cachePath;
  final String? galleryUri;
  final int createdAtMillis;
  final int durationMillis;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'cachePath': cachePath,
      'galleryUri': galleryUri,
      'createdAtMillis': createdAtMillis,
      'durationMillis': durationMillis,
    };
  }
}
