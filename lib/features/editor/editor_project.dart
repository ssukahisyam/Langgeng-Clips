class EditorProject {
  const EditorProject({
    required this.title,
    required this.template,
    required this.clipCount,
    required this.targetDuration,
  });

  final String title;
  final String template;
  final String clipCount;
  final String targetDuration;

  EditorProject copyWith({
    String? title,
    String? template,
    String? clipCount,
    String? targetDuration,
  }) {
    return EditorProject(
      title: title ?? this.title,
      template: template ?? this.template,
      clipCount: clipCount ?? this.clipCount,
      targetDuration: targetDuration ?? this.targetDuration,
    );
  }
}
