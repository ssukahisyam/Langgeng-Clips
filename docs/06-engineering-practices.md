# 06 — Engineering Practices

Standard kerja yang berlaku sejak commit pertama.

## Code Quality

### Dart / Flutter

- **Linter**: `very_good_analysis` (lebih ketat dari `flutter_lints`).
- **Formatter**: `dart format` 80 char width.
- **Analyzer**: zero warning di main branch.
- **Naming**:
  - File: `snake_case.dart`.
  - Class: `PascalCase`.
  - Variable/function: `camelCase`.
  - Constants: `lowerCamelCase` (Dart convention, bukan UPPER_CASE).
- **Imports**: package import sebelum relative, sorted.
- **Null safety**: strict, hindari `!` kecuali sudah validated.

### Kotlin / Android

- **Linter**: `ktlint` + `detekt`.
- **Style**: Kotlin official style.
- **Naming**: standard JVM convention.
- **Threading**: gunakan `Coroutine` + `Dispatchers`, hindari raw `Thread`.

## Project Conventions

### Branching

```
main              # production, protected
develop           # integration branch (opsional kalau pakai gitflow)
feature/<topic>   # fitur baru, base dari main/develop
fix/<topic>       # bug fix
docs/<topic>      # dokumentasi
chore/<topic>     # tooling, deps update
release/<version> # release prep, opsional
```

Strategi disarankan: **trunk-based dengan short-lived feature branches**. Hindari long-lived branches.

### Commit Convention

Pakai **Conventional Commits** supaya bisa auto-changelog & semantic versioning.

```
feat(editor): add waveform timeline scrubber
fix(transcribe): handle empty audio chunk
docs(readme): update setup instructions
chore(deps): bump media3 to 1.4.1
refactor(render): extract crop logic to dedicated class
test(highlight): add sentence boundary tests
```

Type yang dipakai: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `perf`, `style`, `ci`.

### Pull Request

- Title singkat, deskriptif (Conventional Commits style).
- Description: **What** (singkat), **Why** (motivasi), **How** (highlight teknis), **Test** (cara verifikasi).
- Min 1 reviewer (atau self-review checklist kalau solo).
- Squash merge ke main untuk history bersih.
- Link issue/task di description.
- Screenshot untuk perubahan UI.

### Definition of Done

Sebuah task **selesai** kalau:
1. Kode di-review (atau self-review checklist done).
2. Linter & analyzer hijau.
3. Unit test added/updated dan lulus.
4. Manual QA happy path lulus di 1 device target.
5. Dokumentasi update kalau ada perubahan API/flow.
6. PR di-merge ke main.

## Testing Strategy

### Pyramid

```
       /\
      /  \   E2E (integration_test) — sedikit
     /────\
    /      \  Widget test — moderate
   /────────\
  /          \ Unit test — banyak
 /────────────\
```

### Unit Test

- Target coverage core domain logic: **70%+**.
- Wajib test untuk:
  - Highlight scoring & sentence-boundary refinement.
  - Transcript merge across chunks.
  - Storage repo (project, clip CRUD).
  - API client error handling & retry.
  - Theme resolver (system/light/dark).
- Tools: `flutter_test`, `mocktail`.

### Widget Test

- Komponen kritikal:
  - Timeline scrubber (drag, snap, zoom).
  - Caption editor (edit text, sync timing).
  - Mode selector (radio cards).
  - Watermark anchor picker.
- Pakai `flutter_test` + `golden_toolkit` untuk visual regression.

### Integration Test

- 1 happy path per major flow per phase:
  - Phase 1: import → trim → export.
  - Phase 2: import → transcribe → auto subtitle → export.
  - Phase 2: import → auto highlight → export 3 clip.
- Run di emulator API 30 dan device fisik kalau memungkinkan.

### Native Test

- **Espresso / JUnit** untuk Media3 pipeline.
- Golden frame compare untuk render output (1 frame per detik, hash compare).

### Manual QA Matrix

Minimal device sebelum release:
| Tier | Device | API | RAM |
|---|---|---|---|
| Low | Galaxy A14 / Redmi 9 | 28-30 | 4GB |
| Mid | Pixel 6a / Galaxy A54 | 33-34 | 6GB |
| High | Pixel 8 / S24 / OnePlus 12 | 34 | 8-12GB |

Vendor variation: Samsung (One UI), Xiaomi (MIUI/HyperOS), Google Pixel, dan minimal 1 Oppo/Vivo/Realme.

## CI/CD

### CI (GitHub Actions)

`.github/workflows/ci.yml`:
- Trigger: PR ke main, push ke main.
- Jobs:
  1. **lint**: `dart format --set-exit-if-changed` + `dart analyze`.
  2. **test**: `flutter test --coverage` + upload coverage report.
  3. **build-debug**: `flutter build apk --debug` (cache pub & gradle).
  4. **kotlin-lint** (kalau ada perubahan di android/): ktlint + detekt.

Target: setiap job <8 menit. Cache Gradle aggressive.

### CD

- **Internal track**: auto-upload AAB ke Play Console internal testing pada tag `v*-internal`.
- **Closed beta**: manual promote dari internal.
- **Production**: tag `v1.x.y` → manual upload setelah QA pass.
- **Versioning**: semver. `versionCode` auto dari commit count atau timestamp.

### Signing

- **Keystore** disimpan di password manager + offline backup.
- `key.properties` di-gitignore.
- CI signing key via GitHub Secrets, bukan committed.

## Observability

### Crash Reporting

- **Sentry** atau **Firebase Crashlytics**. Pilih satu di awal.
- Wajib dipasang **sebelum closed beta**.
- ProGuard mapping upload otomatis di CI.

### Analytics

- Event minimum:
  - `app_open`, `onboarding_complete`, `api_key_validated`.
  - `import_source` (local/drive/share).
  - `project_created`, `clip_exported` (with mode, duration, resolution).
  - `transcribe_completed` (with duration, language, latency).
  - `highlight_generated` (count, avg score).
  - `error_occurred` (type, recoverable).
- **Tidak track**: API key, file path, transcript content.
- Pilihan tool: Firebase Analytics (paling cepat) atau PostHog (lebih privacy-friendly).

### Performance Tracing

- Time to first frame.
- Editor frame drop %.
- Transcribe latency by audio length.
- Render speed (encoded seconds per real second).

### Logging

- Tier: `debug`, `info`, `warn`, `error`.
- Production: hanya `warn`+ ke remote.
- **Filter**: API key pattern, paths user, transcript content **tidak boleh masuk log**.
- Library: `logger` (Dart) + Timber-style (Kotlin).

## Security Practices

- API key hanya di `flutter_secure_storage`. Test: dump app data di emulator → key tidak boleh muncul plaintext.
- HTTPS only.
- Certificate pinning untuk Groq endpoint (Phase 2 polish).
- ProGuard/R8 enabled di release.
- `android:allowBackup=false` (kecuali ada alasan kuat).
- Scoped storage Android 11+.
- Permission minimum (no `READ_EXTERNAL_STORAGE` di API 33+, pakai Photo Picker).

## Dependency Management

- Pin exact version di `pubspec.yaml` (gunakan `^x.y.z` boleh, tapi commit `pubspec.lock`).
- Audit deps tiap 2 minggu (`flutter pub outdated`).
- Bump major version dengan PR terpisah + changelog.
- Hindari deps abandoned (cek last commit > 1 tahun = red flag).
- License audit: hanya MIT, BSD, Apache 2.0, OFL. LGPL boleh untuk dynamic link. **GPL hindari** kecuali wajib (FFmpeg full).

## Documentation

- **ADR** (Architecture Decision Record) di `docs/adr/NNNN-title.md` untuk keputusan besar.
- **API doc** internal: dartdoc untuk public API library.
- **Setup guide** di `CONTRIBUTING.md` (kalau ada kontributor).
- **Changelog** auto-generate dari Conventional Commits.

## Release Process

1. Buat branch `release/vX.Y.Z` dari main.
2. Bump version di `pubspec.yaml`, update CHANGELOG.
3. PR review → merge.
4. Tag `vX.Y.Z` → CD pipeline upload AAB.
5. QA di internal track 2-3 hari.
6. Promote ke closed beta → 1 minggu.
7. Promote ke production (rollout staged 10% → 50% → 100%).
8. Monitor crash rate 48 jam. Rollback kalau >0.5% crash regression.

## Tooling Recommendation

| Need | Tool |
|---|---|
| Editor | VS Code + Flutter ext, atau Android Studio |
| API testing | HTTPie / Insomnia |
| Pigeon | `dart run pigeon --input pigeons/...` |
| Codegen | `dart run build_runner watch -d` |
| Profiling | Flutter DevTools, Android Studio Profiler |
| Memory leak | LeakCanary (Android side) |
| Network inspect | Charles / mitmproxy (jangan production) |
