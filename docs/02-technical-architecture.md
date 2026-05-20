# 02 — Technical Architecture

## High-Level Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter UI (Dart)                    │
│  • Screens: Home, Import, Editor, Templates, Library    │
│  • State: Riverpod                                      │
│  • Routing: go_router                                   │
└─────────────────────────────────────────────────────────┘
                          │ MethodChannel / Pigeon
                          ▼
┌─────────────────────────────────────────────────────────┐
│              Native Android Layer (Kotlin)              │
│  • Media3 Transformer (trim/crop/overlay/concat)        │
│  • MediaCodec (encode/decode hardware)                  │
│  • MediaMetadataRetriever (probe)                       │
│  • MLKit Face Detection (subject tracking)              │
└─────────────────────────────────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        ▼                 ▼                 ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────────┐
│  FFmpeg-Kit  │  │ Local Store  │  │  Cloud APIs      │
│  (fallback)  │  │ (sqflite +   │  │  • Groq Whisper  │
│              │  │  app dir)    │  │  • Groq LLM      │
│              │  │              │  │  • Drive OAuth   │
└──────────────┘  └──────────────┘  └──────────────────┘
```

## Layer & Tanggung Jawab

### Flutter (Dart)

- Semua UI, state, routing.
- Networking ke Groq API & Google Drive API.
- Orchestration pipeline (memanggil native via Pigeon).
- Local storage (sqflite, secure storage, file system).

### Native Android (Kotlin)

- Operasi berat video: decode/encode/transform via Media3.
- Face detection MLKit untuk subject tracking.
- Probe metadata (durasi, resolusi, codec, rotasi, FPS, audio tracks).
- Background render service (foreground notification).

### Pigeon Bridge

Type-safe MethodChannel codegen. Menghindari error string-based MethodChannel manual.

```
pigeons/
  video_pipeline.dart   # spec API native
android/.../pigeon/      # generated Kotlin
lib/core/pigeon/         # generated Dart
```

## Modul Utama

### 1. Import Module
- File picker lokal (`file_picker`).
- Google Drive integration (`googleapis_auth` + `googleapis/drive/v3`).
- Share intent receiver.
- Probe video → metadata model.

### 2. Transcription Module
- Abstraksi `TranscriptionProvider` interface.
- Implementasi awal: `GroqWhisperProvider`.
- Chunking audio (Whisper limit 25MB, kita split per 10 menit segment + overlap).
- Merge word-level timestamps lintas chunk.
- Cache hasil transkrip per file (hash SHA256 source).

### 3. Highlight Module
- Audio peak detection (FFmpeg `ebur128` filter).
- Scene change detection (`select='gt(scene,0.3)'`).
- Silence detection untuk podcast cleanup.
- LLM scoring via Groq (Llama 3.3 / DeepSeek).
- **Sentence-boundary refinement**: validasi semua boundary clip jatuh di awal/akhir kalimat dari word-timestamp.

### 4. Render Module (Native)
- Media3 Transformer pipeline composer.
- Steps: Trim → Crop 9:16 (face-tracked) → Subtitle overlay → Watermark → Encode.
- Progress callback ke Flutter via EventChannel.
- Foreground service untuk render lama (>30 detik).

### 5. Storage Module
- sqflite untuk metadata project & clip.
- File system app-private untuk source + intermediate.
- MediaStore API untuk save final ke gallery user.
- Cache layer: thumbnail (LRU), waveform, transcript.

### 6. Auth & Settings Module
- `flutter_secure_storage` untuk Groq API key (Android Keystore-backed).
- Validation ping ke Groq `/openai/v1/models`.
- OAuth token Drive di-refresh otomatis.

## Data Flow Auto-Clip

```
Video Input
  → Probe metadata (native)
  → Extract audio 16kHz mono WAV (FFmpeg)
  → Chunk audio → upload ke Groq Whisper
  → Word-level transcript JSON
  → Audio peak + scene + silence detection (lokal)
  → Send transcript + signal ke Groq LLM
  → LLM return candidate ranges (start, end, score, reason)
  → Sentence-boundary validation & adjustment
  → User preview & adjust di Editor
  → Native render pipeline:
      trim → crop 9:16 (face-track) → burn subtitle → watermark → encode H.264/HEVC
  → Save ke gallery + library
```

## Render Engine: Hybrid Strategy

### Primary: Media3 Transformer

**Kapan dipakai**: 90% kasus operasi standar.
- Trim (cut start/end).
- Scale + crop ke 9:16.
- Video composition (concat clip).
- Overlay (caption + watermark) via `OverlaySettings`.
- Encode H.264 / HEVC dengan MediaCodec hardware.

**Kelebihan**: hardware accelerated, hemat baterai, APK kecil, dirawat Google.

### Fallback: FFmpegKit

**Kapan dipakai**:
- Filter audio kompleks (ducking, normalize, EBU R128).
- Extract audio untuk Whisper.
- Format input eksotis yang Media3 belum support.
- Probe lanjutan kalau MediaMetadataRetriever kurang info.

**Catatan**: gunakan paket `min` untuk hemat APK size. Hindari paket `full-gpl` kecuali benar-benar perlu.

## Dependency Utama

### pubspec.yaml (target)
```yaml
flutter:
  sdk: flutter

# State & DI
flutter_riverpod: ^2.5.0
get_it: ^7.7.0

# Routing
go_router: ^14.2.0

# Models & codegen
freezed_annotation: ^2.4.0
json_annotation: ^4.9.0

# Networking
dio: ^5.5.0
retrofit: ^4.4.0

# Storage
sqflite: ^2.3.3
path_provider: ^2.1.4
flutter_secure_storage: ^9.2.2

# File / picker
file_picker: ^8.0.0

# Google Drive
googleapis: ^13.2.0
googleapis_auth: ^1.6.0
google_sign_in: ^6.2.1

# Video
video_player: ^2.9.1
chewie: ^1.8.0

# Background
workmanager: ^0.5.2

# Observability
sentry_flutter: ^8.6.0

# UI utilities
flutter_svg: ^2.0.10
cached_network_image: ^3.3.1
lottie: ^3.1.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  build_runner: ^2.4.12
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  retrofit_generator: ^9.0.0
  pigeon: ^22.4.0
  very_good_analysis: ^6.0.0
  mocktail: ^1.0.4
```

### Android (build.gradle)
```
androidx.media3:media3-transformer:1.4.x
androidx.media3:media3-effect:1.4.x
androidx.media3:media3-exoplayer:1.4.x
androidx.media3:media3-ui:1.4.x
com.google.mlkit:face-detection:16.x
com.arthenica:ffmpeg-kit-flutter-min:6.0-x  # via plugin
```

## Struktur Folder

```
langgeng_clip/
├── android/
│   └── app/src/main/kotlin/com/langgeng/clip/
│       ├── MainActivity.kt
│       ├── transformer/        # Media3 pipeline
│       ├── tracking/           # MLKit face tracking
│       ├── ffmpeg/             # FFmpeg fallback ops
│       ├── service/            # Foreground render service
│       └── pigeon/             # generated bridge
├── lib/
│   ├── main.dart
│   ├── app/                    # router, theme, DI
│   │   ├── app.dart
│   │   ├── router.dart
│   │   └── theme/
│   ├── core/
│   │   ├── api/                # groq client, drive client
│   │   ├── storage/            # sqflite repo, secure storage
│   │   ├── pigeon/             # generated
│   │   └── utils/
│   ├── features/
│   │   ├── onboarding/
│   │   ├── settings/
│   │   ├── home/
│   │   ├── import/
│   │   ├── editor/
│   │   ├── transcription/
│   │   ├── highlight/
│   │   ├── render/
│   │   ├── templates/
│   │   └── library/
│   └── shared/
│       ├── widgets/
│       └── models/
├── pigeons/
│   └── video_pipeline.dart
├── assets/
│   ├── fonts/
│   ├── templates/
│   └── lottie/
├── test/
└── integration_test/
```

## Threading Model

| Layer | Thread |
|---|---|
| UI | Dart main isolate |
| Heavy parsing (transcript merge) | Compute isolate |
| Network calls | Default async (Dart event loop) |
| Native render | Background thread Kotlin (`CoroutineScope(Dispatchers.Default)`) |
| MediaCodec encode | MediaCodec internal thread |
| Foreground service | Dedicated `ServiceScope` |

## Error Handling Strategy

- **Domain error tipe-aman**: sealed `Result<T, AppError>` — `NetworkError`, `ApiKeyInvalid`, `RateLimited`, `RenderFailed`, `StorageError`, dll.
- **UI error**: tampilkan via Snackbar (recoverable) atau Dialog (blocking).
- **Crash reporting**: Sentry capture exception + breadcrumb (jangan log API key/path file user).
- **Retry policy**:
  - Network: 3x exponential backoff untuk Groq API.
  - Render: tidak auto-retry, user diminta retry manual.

## Security

- API key hanya di `flutter_secure_storage` (Android Keystore).
- Tidak pernah log API key (filter di log layer).
- Tidak commit `key.properties`, keystore, `.env`.
- Network: HTTPS only, certificate pinning Groq endpoint (opsional Phase 2).
- Scoped storage Android 11+ (MediaStore + SAF).

## Versi Android Target

- `minSdkVersion`: **26** (Android 8.0)
  - Alasan: Media3 stabil, MLKit nyaman, scoped storage tidak terlalu repot.
- `targetSdkVersion`: **34** (Android 14, mengikuti Play Store policy 2024+).
- `compileSdkVersion`: 34.

## Performance Budget

| Metrik | Target |
|---|---|
| Cold start | < 2 detik |
| Time to import (file 1GB) | < 5 detik probe |
| Transcribe 1 jam audio | < 2 menit (Groq turbo) |
| LLM highlight 1 jam transcript | < 30 detik |
| Render 1 menit clip 1080p | < 1 menit di mid-range |
| Editor frame drop | < 5% pada timeline scrub |
| APK download size | < 80 MB (split-ABI per arch) |
| Memory peak | < 350 MB di low-mid device |

## Open Questions

- Apakah perlu cache hasil LLM scoring agar bisa rerun template tanpa hit API ulang? (Probably yes.)
- Kapan trigger `vacuum` sqflite? (Saat user delete project.)
- Apakah perlu support audio-only input (MP3) di V1? (Default tidak, V2.)
