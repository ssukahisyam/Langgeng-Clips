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

final exportHistoryItemProvider =
    FutureProvider.family<ExportHistoryItem?, String>((ref, id) async {
      final items = await ref.watch(exportHistoryItemsProvider.future);
      for (final item in items) {
        if (item.id == id) {
          return item;
        }
      }

      return null;
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
    await _writeAll(items);
  }

  Future<void> delete(String id) async {
    final items = readAll().where((item) => item.id != id).toList();
    await _writeAll(items);
  }

  Future<void> rename({required String id, required String title}) async {
    final items = [
      for (final item in readAll())
        if (item.id == id) item.copyWith(title: title) else item,
    ];
    await _writeAll(items);
  }

  Future<void> duplicate(String id) async {
    final source = readAll().where((item) => item.id == id).firstOrNull;
    if (source == null) {
      return;
    }

    await add(
      source.copyWith(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: '${source.title} (copy)',
        createdAtMillis: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Future<void> _writeAll(List<ExportHistoryItem> items) async {
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
    this.resolution,
    this.frameRate,
    this.codec,
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
      resolution: json['resolution'] as String?,
      frameRate: json['frameRate'] as String?,
      codec: json['codec'] as String?,
    );
  }

  final String id;
  final String title;
  final String cachePath;
  final String? galleryUri;
  final int createdAtMillis;
  final int durationMillis;
  final String? resolution;
  final String? frameRate;
  final String? codec;

  bool get isSavedToGallery => galleryUri != null && galleryUri!.isNotEmpty;

  ExportHistoryItem copyWith({
    String? id,
    String? title,
    String? cachePath,
    String? galleryUri,
    int? createdAtMillis,
    int? durationMillis,
    String? resolution,
    String? frameRate,
    String? codec,
  }) {
    return ExportHistoryItem(
      id: id ?? this.id,
      title: title ?? this.title,
      cachePath: cachePath ?? this.cachePath,
      galleryUri: galleryUri ?? this.galleryUri,
      createdAtMillis: createdAtMillis ?? this.createdAtMillis,
      durationMillis: durationMillis ?? this.durationMillis,
      resolution: resolution ?? this.resolution,
      frameRate: frameRate ?? this.frameRate,
      codec: codec ?? this.codec,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'cachePath': cachePath,
      'galleryUri': galleryUri,
      'createdAtMillis': createdAtMillis,
      'durationMillis': durationMillis,
      'resolution': resolution,
      'frameRate': frameRate,
      'codec': codec,
    };
  }
}
