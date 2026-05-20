# Master Checklist — Langgeng Clip

Master task list end-to-end. Centang sambil jalan. Update minimal mingguan.

> Notation: `[ ]` pending, `[x]` done, `[~]` in progress, `[!]` blocked.

---

## Phase 0 — Foundation (Pre-Development)

### 0.1 Branding & Identity
- [ ] Cek availability nama "Langgeng Clip" di Play Store search
- [ ] Cek domain `langgengclip.com` / `.id` / `.app`
- [ ] Cek username `@langgengclip` di Twitter/X, Instagram, TikTok, YouTube
- [ ] Cek trademark Indonesia (DJKI) untuk nama
- [ ] Backup names siap kalau konflik (LanggengClip, ClipLanggeng, Klipper, Klipsmart)
- [ ] Logo: mark + wordmark final
- [ ] Logo variations: full color, mono dark, mono light, mark only
- [ ] App icon adaptive (foreground + background layer) 512×512
- [ ] Notification icon monochrome
- [ ] Splash logo asset
- [ ] Color palette finalisasi (light + dark theme)
- [ ] Tagline final dipilih

### 0.2 Legal & Compliance Foundations
- [ ] Privacy Policy draft (Bahasa Indonesia + English)
- [ ] Terms of Service draft
- [ ] Host Privacy Policy + ToS (GitHub Pages atau domain)
- [ ] Data Safety Form mapping ditulis (referensi `07-legal-compliance.md`)
- [ ] License audit semua dependency (cek tabel di `07-legal-compliance.md`)
- [ ] Keputusan final fitur YouTube: drop, share-intent only (default), atau OAuth
- [ ] Konfirmasi yurisdiksi hukum (Indonesia/International)
- [ ] Konfirmasi distribusi awal (Play Store global atau ID-only)

### 0.3 Repo Setup
- [x] Repo init di GitHub (ssukahisyam/Langgeng-Clips)
- [x] Initial planning docs di branch `docs/initial-planning`
- [ ] `.gitignore` Flutter + Android + IDE
- [ ] Branch protection main: require PR review, no force push
- [ ] Repo description + topics di GitHub
- [ ] Issue templates (bug, feature, question)
- [ ] PR template
- [ ] CONTRIBUTING.md (kalau buka kontribusi)
- [ ] CODE_OF_CONDUCT.md
- [ ] SECURITY.md (cara report vulnerability)

### 0.4 Project Init
- [x] `flutter create` dengan org `com.langgeng.clip`
- [ ] Struktur folder sesuai `02-technical-architecture.md`
- [ ] `pubspec.yaml` dengan dependency utama
- [x] `analysis_options.yaml` dengan Flutter lint rules
- [ ] `dart format` config (80 char)
- [ ] Android: `build.gradle` config (minSdk 26, targetSdk 34)
- [ ] Android: ktlint + detekt setup
- [ ] Pre-commit hook: dart format + lint
- [x] Theme system (light/dark) + token implementation
- [x] Riverpod + go_router skeleton
- [ ] DI (get_it) skeleton
- [ ] Pigeon spec awal (`pigeons/video_pipeline.dart`)
- [ ] Localization setup (`flutter_localizations` + ARB files)

### 0.5 CI/CD Foundation
- [x] GitHub Actions: lint job
- [x] GitHub Actions: test job
- [x] GitHub Actions: build APK debug on PR
- [ ] Cache pub & gradle di CI
- [ ] Keystore generated + backed up (3 lokasi)
- [ ] Keystore password di password manager
- [ ] Migrate ke Play App Signing saat upload pertama
- [ ] CD: tag-based AAB upload internal track

### 0.6 Observability Foundation
- [ ] Pilih: Sentry vs Firebase Crashlytics
- [ ] Crash reporting integrate Flutter + native
- [ ] Analytics tool pilih (Firebase Analytics / PostHog)
- [ ] Event schema documented
- [ ] Filter regex untuk API key di logger
- [ ] Sentry PII scrubbing config

### 0.7 Splash & Onboarding (UI Stub)
- [x] Splash screen UI
- [x] Onboarding 3 slide UI
- [x] PageView + dot indicator
- [x] Skip + Next/Get Started button
- [x] First-run detection logic
- [ ] Localization ID + EN

---

## Phase 1 — MVP (4-6 minggu)

### 1.1 API Key & Settings
- [x] API Key Setup screen UI
- [x] Validate Groq key endpoint integration
- [x] `flutter_secure_storage` integrate
- [ ] Settings screen full layout
- [x] Theme toggle (System/Light/Dark) persist
- [ ] Language toggle (ID/EN) persist
- [ ] About section (Privacy, Terms, OSS License, Version)
- [ ] OSS License auto-generate (`flutter_oss_licenses`)
- [x] In-app guide "Cara dapat Groq API key"

### 1.2 Import & Probe
- [x] Home screen layout (greeting, hero CTA, quick template chips)
- [x] Import Sheet bottom sheet
- [x] file_picker integrate (lokal)
- [x] Native: probe metadata via MediaMetadataRetriever
- [ ] Probe coverage: durasi, resolusi, codec, rotation, FPS, audio tracks
- [ ] Probe coverage: VFR detection
- [ ] Storage: copy/reference source ke app dir
- [ ] Sqflite schema: project, source, clip
- [ ] Sqflite repo + DAO
- [ ] Empty state semua layar
- [ ] Loading state probe video

### 1.3 Project Setup & Editor (Manual Mode)
- [x] Project Setup screen
- [x] Mode selector (Manual aktif, Semi-Auto/Auto disabled placeholder)
- [x] Template dropdown (4 preset placeholder)
- [x] Stepper jumlah clip
- [x] Segmented durasi target
- [x] Editor scaffold: top bar, preview, transport, timeline, tab bar
- [ ] ExoPlayer integrate via Pigeon (preview)
- [ ] Timeline: waveform render
- [x] Timeline: scrubber + playhead
- [x] Timeline: clip range handles (drag start/end)
- [ ] Timeline: pinch zoom
- [x] Manual: split clip
- [x] Manual: multi-clip support
- [ ] Auto-save state project tiap 30s
- [x] Project rename via top bar tap

### 1.4 Render Pipeline
- [ ] Pigeon API spec untuk render
- [ ] Native Media3 Transformer composer skeleton
- [ ] Step: trim
- [ ] Step: center crop 9:16
- [ ] Step: scale ke target resolution
- [ ] Step: encode H.264
- [ ] Progress event channel
- [ ] Foreground service untuk render lama
- [ ] Notification channel + ongoing notification
- [ ] Export Sheet UI (resolusi, FPS, codec)
- [ ] Estimasi size + duration
- [ ] Save ke MediaStore + register library
- [ ] Cancel render flow
- [ ] Error handling render fail
- [ ] ProGuard rules untuk Media3 + Pigeon + Sentry

### 1.5 Library
- [ ] Library screen list project
- [ ] Filter chips (All / Drafts / Done)
- [ ] Search field
- [ ] Project Detail screen
- [ ] Clip viewer fullscreen
- [ ] Share clip (Android share intent)
- [ ] Delete project (dengan konfirmasi)
- [ ] Rename project
- [ ] Duplicate project

### 1.6 MVP QA & Release
- [ ] Manual QA matrix 5 device (low/mid/high)
- [ ] Crash-free rate >99% di internal track
- [ ] Test storage edge cases (penuh, file >2GB)
- [ ] Test VFR input
- [ ] Test rotated video metadata
- [ ] Pre-launch report Play Console clean
- [ ] Build AAB release signed
- [ ] Upload internal track Play Console
- [ ] Recruit 12+ closed beta tester aktif

---

## Phase 2 — V1.0 (6-8 minggu)

### 2.1 Transcription
- [ ] `TranscriptionProvider` interface
- [ ] `GroqWhisperProvider` impl
- [ ] FFmpeg extract audio 16kHz mono WAV
- [ ] Audio chunking 10 menit + overlap 5 detik
- [ ] Upload chunk ke Groq Whisper API
- [ ] Merge word-level timestamps lintas chunk
- [ ] Cache transcript by source SHA256
- [ ] Retry exponential backoff
- [ ] Resume from last successful chunk
- [ ] Multi-language detection
- [ ] Bahasa override manual
- [ ] Progress UI saat transcribe

### 2.2 Auto Subtitle
- [ ] Caption Editor screen
- [ ] Word list editable inline
- [ ] Edit text only (timestamp tetap)
- [ ] Edit timing via drag handle
- [ ] Style: font picker
- [ ] Style: size slider
- [ ] Style: color highlight swatches
- [ ] Style: position 9-grid
- [ ] Animation: none / karaoke / typewriter
- [ ] Subtitle render via Media3 OverlaySettings
- [ ] Safe area aware (top 10%, bottom 15%)
- [ ] Word-aware line break
- [ ] Test emoji + ID + EN mix
- [ ] Live preview real-time

### 2.3 Semi-Auto Mode
- [ ] FFmpeg ebur128 audio peak detection
- [ ] Scene change detection
- [ ] Silence detection (untuk podcast)
- [ ] UI: highlight kandidat di timeline
- [ ] User pilih kandidat untuk jadi clip
- [ ] Tuning threshold parameter

### 2.4 Auto Highlight (AI)
- [ ] Groq LLM client (Llama 3.3 / DeepSeek)
- [ ] Prompt engineering iterasi 1
- [ ] Output schema: ranges with score & reason
- [ ] Sentence-boundary refinement validator
- [ ] Eval dataset: 10-20 video sampel + ground truth
- [ ] Benchmark akurasi prompt
- [ ] A/B test prompt antar model
- [ ] Cache hasil scoring per source+config
- [ ] User preview & adjust hasil
- [ ] Score badge di timeline
- [ ] Filler word removal (toggle, default off)

### 2.5 Templates
- [ ] Template definition format (JSON)
- [ ] Preset Podcast (talking head, subtitle large, watermark optional)
- [ ] Preset Gaming (pip kamera + game, dynamic caption)
- [ ] Preset Talking Head (face-tracked crop, karaoke caption)
- [ ] Preset Tutorial (clean caption, watermark logo)
- [ ] Apply template flow di Editor
- [ ] Preview template visual

### 2.6 Watermark
- [ ] Watermark module: text input
- [ ] Watermark module: image picker
- [ ] Position 9-anchor
- [ ] Position drag custom
- [ ] Opacity slider
- [ ] Scale slider
- [ ] Native overlay implementation
- [ ] Preview di editor

### 2.7 Subject Tracking
- [ ] MLKit Face Detection integrate native
- [ ] Face tracking timeline (per detik atau per frame sample)
- [ ] Smooth crop transition (kalman atau ease)
- [ ] Fallback ke center crop saat no face
- [ ] Multi-face: pilih primary
- [ ] Test dengan video podcast 2 orang

### 2.8 V1.0 QA & Release
- [ ] Auto-mode 70%+ "usable" rate dari tester survey
- [ ] Manual QA matrix 5 device
- [ ] Crash-free rate >99%
- [ ] Open beta track Play Console
- [ ] 500+ install open beta
- [ ] Rating Play Store >4.0

---

## Phase 3 — V1.5 Polish & Monetisasi (3-4 minggu)

### 3.1 AdMob Integration
- [ ] AdMob account + app ID
- [ ] Banner ad Library + Home
- [ ] Rewarded ad untuk extra export
- [ ] Interstitial low frequency (max 1x per 3 menit)
- [ ] Disclosure di Privacy Policy
- [ ] Test ad units di debug

### 3.2 Subscription
- [ ] Play Billing setup
- [ ] Subscription product configured
- [ ] Pricing page UI
- [ ] Paywall flow
- [ ] Free trial 7 hari
- [ ] Restore purchase
- [ ] Receipt validation client-side
- [ ] Receipt validation server-side (opsional)
- [ ] Cancel subscription flow

### 3.3 Free Tier Limits
- [ ] Daily export counter (3/hari, reset 00:00 WIB)
- [ ] Watermark "Made with Langgeng Clip" auto di free tier
- [ ] Premium template lock di free tier
- [ ] Limit communication jelas sebelum user kena dinding
- [ ] Promo first-week unlimited untuk user baru (opsional)

### 3.4 Polish
- [ ] Performance audit (memory, frame drop, render speed)
- [ ] A11y audit (TalkBack, dynamic type 200%)
- [ ] Empty states copy review (UX writer kalau ada)
- [ ] Error messages catalog finalisasi
- [ ] In-app onboarding tutorial post-import
- [ ] Help center / FAQ minimal 10 artikel
- [ ] Send feedback form di Settings

### 3.5 Production Launch
- [ ] Listing Play Store: short + full description
- [ ] Screenshots phone (min 2, ideal 6-8)
- [ ] Screenshots tablet 7" + 10"
- [ ] Feature graphic 1024×500
- [ ] Promo video YouTube
- [ ] IARC content rating
- [ ] Categorization Video Players & Editors
- [ ] Target audience age 13+ atau 17+
- [ ] Staged rollout 10%
- [ ] Monitor crash 48 jam
- [ ] Promote 50%
- [ ] Promote 100%

---

## Phase 4 — V2.0 Post-Launch

### 4.1 iOS Port
- [ ] AVFoundation pipeline rewrite Swift
- [ ] Pigeon iOS bridge
- [ ] Apple Developer account
- [ ] App Store assets + listing
- [ ] TestFlight beta
- [ ] App Store submission

### 4.2 Cloud / Managed Mode
- [ ] Backend pilih (Cloudflare Workers / Supabase)
- [ ] Auth Google/Apple sign-in
- [ ] Server-side render option
- [ ] Subscription tier "Managed"

### 4.3 Advanced Features
- [ ] B-roll library (kalau ada partner stock)
- [ ] BGM picker dengan ducking
- [ ] Auto-translate subtitle
- [ ] Custom template editor
- [ ] Cloud project sync
- [ ] Tim/collaboration

---

## Cross-Cutting (Selalu Berjalan)

### Testing
- [ ] Unit test coverage core 70%+
- [ ] Widget test komponen kritikal
- [ ] Integration test happy path setiap phase
- [ ] Native Espresso test render pipeline
- [ ] Golden frame compare untuk render output

### Documentation
- [ ] ADR untuk keputusan besar (`docs/adr/NNNN-*.md`)
- [ ] Setup guide di CONTRIBUTING.md
- [ ] Changelog auto-generate
- [ ] In-code dartdoc untuk public API

### Security
- [ ] Cert pinning Groq endpoint (Phase 2)
- [ ] Penetration test sederhana sebelum production
- [ ] Cek dump app data → API key tidak plaintext
- [ ] R8/ProGuard release build verified

### Marketing & Community
- [ ] Landing page live
- [ ] Waitlist 200+ signup sebelum closed beta
- [ ] Discord/Telegram komunitas
- [ ] Build-in-public Twitter/X mingguan
- [ ] YouTube tutorial 3 video
- [ ] TikTok demo 5 video

### Operational
- [ ] Eval dataset highlight maintain
- [ ] Customer support email aktif
- [ ] Response time <24 jam beta, <48 jam production
- [ ] Roadmap public update bulanan

---

## Definition of Done — Per Phase

| Phase | DoD |
|---|---|
| Phase 0 | APK debug install, splash → onboarding → home stub jalan, CI hijau, Privacy Policy live |
| Phase 1 | Import → trim manual → export 1 clip 9:16 sukses di 5 device |
| Phase 2 | 3 mode jalan, auto-mode 70%+ usable, 4 template, watermark, face tracking |
| Phase 3 | Monetisasi aktif, conversion tracked, rating >4.0, 1000+ install |
| Phase 4 | iOS live, managed mode active, 5%+ Pro conversion |

## Update Log

Tanggal | Phase | Update | Notes
---|---|---|---
2026-05-19 | 0 | Initial planning docs created | Branch `docs/initial-planning` opened
