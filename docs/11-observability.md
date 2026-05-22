# Observability

This document records the MVP observability decisions before SDK integration.

## Tooling Decisions

| Need | Choice | Reason |
|---|---|---|
| Crash reporting | Sentry | Works across Flutter and native Android, supports PII scrubbing, and does not require Firebase project setup. |
| Product analytics | PostHog | Privacy-friendly event tracking and easier self-hosting path if needed later. |

## Minimum Event Schema

| Event | Required properties | Notes |
|---|---|---|
| `app_open` | `app_version`, `build_number` | No user path or API key. |
| `onboarding_complete` | `step_count` | Fire once per install. |
| `api_key_validated` | `provider`, `success` | Never include the key or key prefix. |
| `import_source_selected` | `source` | Allowed values: `local`, `youtube_placeholder`, `drive_placeholder`. |
| `project_created` | `mode`, `clip_count`, `target_duration_seconds` | No source file path. |
| `clip_export_started` | `resolution`, `fps`, `codec`, `requires_reencode` | No source file path. |
| `clip_export_completed` | `resolution`, `fps`, `codec`, `duration_ms`, `saved_to_gallery` | No output URI or path. |
| `clip_export_failed` | `error_code`, `recoverable` | Use normalized error codes only. |
| `clip_export_cancelled` | `progress_bucket` | Bucket progress, do not send exact timeline data. |

The code contract for these events lives in `lib/core/observability/analytics_events.dart` and is covered by `test/analytics_events_test.dart`.

## PII And Secret Filtering

Remote logs and crash breadcrumbs must redact:

| Pattern | Replacement |
|---|---|
| `gsk_[A-Za-z0-9_-]+` | `[REDACTED_GROQ_KEY]` |
| `(?i)(api[_-]?key|authorization|bearer)[:= ]+[^\s,]+` | `$1=[REDACTED_SECRET]` |
| `content://[^\s]+` | `[REDACTED_CONTENT_URI]` |
| `file://[^\s]+` | `[REDACTED_FILE_URI]` |
| Android absolute paths under `/storage/`, `/sdcard/`, or `/data/` | `[REDACTED_PATH]` |

## Sentry Configuration Requirements

- Enable `sendDefaultPii = false`.
- Add `beforeSend` scrubbing for the patterns above.
- Disable attachment upload unless explicitly needed for a debug build.
- Do not capture transcript text, selected file paths, gallery URIs, or Groq API keys.
- Upload ProGuard/R8 mapping only from release CI.

Flutter integration is enabled by setting `SENTRY_DSN` at build time:

```bash
flutter build apk --dart-define=SENTRY_DSN=https://examplePublicKey@o0.ingest.sentry.io/0
```

If `SENTRY_DSN` is empty, the app runs without remote crash reporting.

## Native Logging Requirements

- Kotlin logs should only use normalized error codes for export failures.
- Do not log `sourcePath`, `cachePath`, `galleryUri`, or raw `RenderRequest` objects.
- Progress logs should be disabled in release builds.
