# Security Local Checks

Use these checks before internal, beta, or production release candidates. They do not replace a full security review, but they catch common local regressions.

## API Key Storage

Goal: Groq API keys must not appear in logs, exported files, screenshots, or plaintext app preferences.

Checklist:

- Save a test Groq API key through the app UI.
- Confirm the app still reads the key after restart.
- Inspect app logs for the raw key or common prefixes.
- Confirm `flutter_secure_storage` remains the only persistence path for the key.
- Delete the key in-app and confirm it no longer unlocks Groq-backed flows.

Useful local commands:

```sh
flutter test test/groq_api_key_validator_test.dart test/sentry_observability_test.dart
flutter analyze
```

Device-only checks when a debug device is available:

```sh
adb logcat | grep -i groq
adb shell run-as com.langgeng.langgeng_clip ls -R /data/data/com.langgeng.langgeng_clip
```

Do not paste real API keys into issues, docs, screenshots, or QA notes. Use fake keys for evidence.

## Release Hardening

Before release builds:

- Verify `android/app/proguard-rules.pro` still keeps required Media3, Pigeon, and Sentry classes.
- Confirm `android/key.properties`, keystores, `.env`, and secret files are ignored by git.
- Run `git status --short` before every commit and release build.
- Run `git diff --check` before committing generated or documentation files.

## Reporting

Security issues should follow `SECURITY.md`. Do not file public issues for exposed credentials, keystore problems, or user-data leaks.
