import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/preferences/preferences_providers.dart';
import '../auto_highlight/highlight_candidate.dart';
import '../import/selected_video.dart';
import '../semi_auto/semi_auto_candidate.dart';
import '../subtitle/caption_document.dart';
import 'editor_project.dart';

final editorProjectStoreProvider = FutureProvider<EditorProjectStore>((
  ref,
) async {
  final preferences = await ref.watch(sharedPreferencesProvider.future);
  return EditorProjectStore(preferences);
});

final activeEditorSessionSummaryProvider = FutureProvider<EditorSession?>((
  ref,
) async {
  final store = await ref.watch(editorProjectStoreProvider.future);
  return store.readActiveSession();
});

class EditorProjectStore {
  EditorProjectStore(this._preferences);

  static const _activeSessionKey = 'editor_active_session';

  final SharedPreferences _preferences;

  EditorSession? readActiveSession() {
    final raw = _preferences.getString(_activeSessionKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return EditorSession.fromJson(decoded);
  }

  Future<void> saveActiveSession(EditorSession session) async {
    await _preferences.setString(
      _activeSessionKey,
      jsonEncode(session.toJson()),
    );
  }

  Future<void> clearActiveSession() async {
    await _preferences.remove(_activeSessionKey);
  }
}

class EditorSession {
  const EditorSession({
    required this.video,
    required this.project,
    this.captionDocument,
    this.semiAutoCandidates = const [],
    this.autoHighlightCandidates = const [],
  });

  factory EditorSession.fromJson(Map<String, dynamic> json) {
    return EditorSession(
      video: SelectedVideo.fromJson(json['video'] as Map<String, dynamic>),
      project: EditorProject.fromJson(json['project'] as Map<String, dynamic>),
      captionDocument: json['captionDocument'] is Map<String, dynamic>
          ? CaptionDocument.fromJson(
              json['captionDocument'] as Map<String, dynamic>,
            )
          : null,
      semiAutoCandidates: json['semiAutoCandidates'] is List
          ? (json['semiAutoCandidates'] as List)
                .whereType<Map<String, dynamic>>()
                .map(SemiAutoCandidate.fromJson)
                .toList(growable: false)
          : const [],
      autoHighlightCandidates: json['autoHighlightCandidates'] is List
          ? (json['autoHighlightCandidates'] as List)
                .whereType<Map<String, dynamic>>()
                .map(HighlightCandidate.fromJson)
                .toList(growable: false)
          : const [],
    );
  }

  final SelectedVideo video;
  final EditorProject project;
  final CaptionDocument? captionDocument;
  final List<SemiAutoCandidate> semiAutoCandidates;
  final List<HighlightCandidate> autoHighlightCandidates;

  Map<String, dynamic> toJson() {
    return {
      'video': video.toJson(),
      'project': project.toJson(),
      if (captionDocument != null) 'captionDocument': captionDocument!.toJson(),
      if (semiAutoCandidates.isNotEmpty)
        'semiAutoCandidates': semiAutoCandidates
            .map((candidate) => candidate.toJson())
            .toList(),
      if (autoHighlightCandidates.isNotEmpty)
        'autoHighlightCandidates': autoHighlightCandidates
            .map((candidate) => candidate.toJson())
            .toList(),
    };
  }
}
