# MVP QA & Release

Phase 1.6 tracks the manual validation needed before Play Console internal testing.

Use `docs/qa-run-template.md` for each release-candidate QA pass.

## Device Matrix

| Tier | Device target | API | RAM | Vendor coverage |
|---|---:|---:|---:|---|
| Low | Galaxy A14 or Redmi 9 | 28-30 | 4 GB | Samsung or Xiaomi |
| Mid | Pixel 6a | 33-34 | 6 GB | Google |
| Mid | Galaxy A54 or Redmi Note | 33-34 | 6-8 GB | Samsung or Xiaomi |
| High | Pixel 8 or Galaxy S24 | 34+ | 8-12 GB | Google or Samsung |
| High alt | OnePlus, Oppo, Vivo, or Realme | 34+ | 8-12 GB | BBK vendor family |

## Required Scenarios

| Scenario | Input | Expected result |
|---|---|---|
| Happy path trim | 1080p H.264 MP4, 30 fps | Export completes and appears in Library |
| Media3 re-encode | Landscape 16:9 MP4 | Output is 9:16, scaled to selected resolution, H.264 encoded |
| Rotated metadata | Portrait video stored as 1920x1080 with 90/270 rotation | UI treats display size as 1080x1920 |
| VFR input | Screen recording or OBS VFR file | Export completes without audio drift obvious to reviewer |
| Storage pressure | Device with low free space | Export fails with readable error, no crash |
| Large file | File larger than 2 GB | Import, trim, export either succeeds or fails with readable error |
| Cancel export | Cancel while Media3 export is running | Export stops, progress UI exits, no Library item is created |
| Share export | Completed Library item | Android share sheet opens with video URI |

## Release Gates

| Gate | Pass criteria |
|---|---|
| CI | `dart format --set-exit-if-changed .`, `flutter analyze`, `flutter test`, and debug APK build pass |
| Manual QA | All required scenarios pass on at least 5 devices |
| Crash monitoring | Internal track crash-free rate stays above 99% for 48 hours |
| Play pre-launch | No blocking crashes or policy warnings |
| Signed build | Release AAB is signed with non-debug keystore |

## Signed AAB Build

Release signing reads `android/key.properties` locally or environment variables in CI. Do not commit keystores or `key.properties`.

`android/key.properties` format:

```properties
storeFile=/absolute/path/to/upload-keystore.jks
storePassword=...
keyAlias=upload
keyPassword=...
```

Equivalent CI environment variables:

```text
LANGGENG_KEYSTORE_BASE64
LANGGENG_STOREFILE
LANGGENG_STOREPASSWORD
LANGGENG_KEYALIAS
LANGGENG_KEYPASSWORD
```

`LANGGENG_KEYSTORE_BASE64` is only used by GitHub Actions to reconstruct the keystore file in the runner temp directory. Generate it locally with:

```bash
base64 -w 0 upload-keystore.jks
```

Local AAB build command for Play upload later:

```bash
flutter build appbundle --release
```

GitHub Actions workflow:

- `.github/workflows/release-apk.yml` builds a signed release APK for tester installs.
- It runs manually via `workflow_dispatch` with a release tag input or on tags matching `v*-apk`.
- It attaches `app-release.apk` directly to a GitHub Release. It does not use workflow artifacts.
- Play Console AAB upload remains manual until the Play API service account is configured.

## Notes

- Do not mark Phase 1.6 complete until device QA and Play Console checks are actually performed.
- Keep raw test videos outside the repository; document filenames, source device, duration, codec, and frame-rate behavior in the QA run notes.
