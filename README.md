# Langgeng Clip

Aplikasi Android untuk mengubah video panjang menjadi short-form clip (9:16) secara otomatis dengan bantuan AI. Dibangun dengan Flutter untuk UI dan Media3 native untuk pipeline rendering.

> Status: **MVP development**. Kode Flutter dan native Android sudah tersedia,
> tetapi beberapa flow masih berupa skeleton atau belum tersambung end-to-end.

## Tujuan

- Otomasi proses clipping dari long-form (podcast, gaming, talking head, tutorial) ke short-form viral.
- Hemat waktu editing: auto-subtitle, auto-highlight, auto-crop 9:16.
- Jalan di Android, output langsung siap upload ke TikTok, Reels, dan YouTube Shorts.

## Highlight Fitur

- Manual editor flow dengan import file lokal, project setup, timeline range,
  multi-clip, dan export native.
- Transkrip dan highlight via **Groq** (`whisper-large-v3-turbo` + LLM scoring)
  dengan **BYOK** (Bring Your Own Key).
- Auto-subtitle, caption editor, template, watermark, semi-auto, dan auto AI
  sudah memiliki modul awal, tetapi masih perlu integrasi runtime penuh.
- Tema dark/light, localization ID/EN, onboarding, settings dasar, library,
  observability, dan monetization placeholder.

## Tech Stack

- **Flutter 3.x** + Dart 3.x (UI)
- **Media3 Transformer** (rendering native, hardware accelerated)
- **FFmpegKit** (fallback untuk filter kompleks)
- **MLKit Face Detection** (subject tracking saat crop 9:16)
- **Groq API** (Whisper + LLM, BYOK)
- **Riverpod**, **go_router**, **freezed**, **dio**, **sqflite**, **flutter_secure_storage**

## Dokumentasi

Semua dokumen perencanaan ada di folder [`docs/`](./docs):

- [`docs/01-product-vision.md`](./docs/01-product-vision.md) — Visi, target user, problem statement.
- [`docs/02-technical-architecture.md`](./docs/02-technical-architecture.md) — Arsitektur sistem, tech stack, data flow.
- [`docs/03-design-system.md`](./docs/03-design-system.md) — Color tokens, tipografi, spacing, komponen.
- [`docs/04-ui-pages.md`](./docs/04-ui-pages.md) — Rancangan per-page (12 layar utama).
- [`docs/05-features-roadmap.md`](./docs/05-features-roadmap.md) — Fitur per milestone (MVP, V1, V1.5, V2).
- [`docs/06-engineering-practices.md`](./docs/06-engineering-practices.md) — Linting, testing, CI/CD, observability.
- [`docs/07-legal-compliance.md`](./docs/07-legal-compliance.md) — Privacy, ToS, Play Store policy, license.
- [`docs/08-go-to-market.md`](./docs/08-go-to-market.md) — Branding, beta, monetisasi, komunikasi.
- [`docs/09-risks-mitigation.md`](./docs/09-risks-mitigation.md) — Risiko teknis & operasional + mitigasi.
- [`CHECKLIST.md`](./CHECKLIST.md) — Master task list end-to-end.

## Status Pengerjaan

Lihat [`CHECKLIST.md`](./CHECKLIST.md) untuk progress per fase dan
[`PLAN.md`](./PLAN.md) untuk rencana membuat aplikasi berfungsi end-to-end.

## License

Akan ditentukan sebelum public release. Saat ini repo private/development.
