class AnalyticsEventDefinition {
  const AnalyticsEventDefinition({
    required this.name,
    required this.requiredProperties,
  });

  final String name;
  final Set<String> requiredProperties;
}

abstract final class AnalyticsEvents {
  static const appOpen = AnalyticsEventDefinition(
    name: 'app_open',
    requiredProperties: {'app_version', 'build_number'},
  );

  static const onboardingComplete = AnalyticsEventDefinition(
    name: 'onboarding_complete',
    requiredProperties: {'step_count'},
  );

  static const apiKeyValidated = AnalyticsEventDefinition(
    name: 'api_key_validated',
    requiredProperties: {'provider', 'success'},
  );

  static const importSourceSelected = AnalyticsEventDefinition(
    name: 'import_source_selected',
    requiredProperties: {'source'},
  );

  static const projectCreated = AnalyticsEventDefinition(
    name: 'project_created',
    requiredProperties: {'mode', 'clip_count', 'target_duration_seconds'},
  );

  static const clipExportStarted = AnalyticsEventDefinition(
    name: 'clip_export_started',
    requiredProperties: {'resolution', 'fps', 'codec', 'requires_reencode'},
  );

  static const clipExportCompleted = AnalyticsEventDefinition(
    name: 'clip_export_completed',
    requiredProperties: {
      'resolution',
      'fps',
      'codec',
      'duration_ms',
      'saved_to_gallery',
    },
  );

  static const clipExportFailed = AnalyticsEventDefinition(
    name: 'clip_export_failed',
    requiredProperties: {'error_code', 'recoverable'},
  );

  static const clipExportCancelled = AnalyticsEventDefinition(
    name: 'clip_export_cancelled',
    requiredProperties: {'progress_bucket'},
  );

  static const all = <AnalyticsEventDefinition>{
    appOpen,
    onboardingComplete,
    apiKeyValidated,
    importSourceSelected,
    projectCreated,
    clipExportStarted,
    clipExportCompleted,
    clipExportFailed,
    clipExportCancelled,
  };
}
