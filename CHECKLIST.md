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
- [x] Issue templates (bug, feature, question)
- [x] PR template
- [x] CONTRIBUTING.md (kalau buka kontribusi)
- [x] CODE_OF_CONDUCT.md
- [x] SECURITY.md (cara report vulnerability)

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
- [x] Cache pub & gradle di CI
- [ ] Keystore generated + backed up (3 lokasi)
- [ ] Keystore password di password manager
- [ ] Migrate ke Play App Signing saat upload pertama
- [ ] CD: tag-based AAB upload internal track

### 0.6 Observability Foundation
- [x] Pilih: Sentry vs Firebase Crashlytics
- [x] Crash reporting integrate Flutter + native
- [x] Analytics tool pilih (Firebase Analytics / PostHog)
- [x] Event schema documented
- [x] Filter regex untuk API key di logger
- [x] Sentry PII scrubbing config

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
- [x] Pigeon API spec untuk render
- [x] Native Media3 Transformer composer skeleton
- [x] Step: trim
- [x] Step: center crop 9:16
- [x] Step: scale ke target resolution
- [x] Step: encode H.264
- [x] Progress event channel
- [x] Foreground service untuk render lama
- [x] Notification channel + ongoing notification
- [x] Export Sheet UI (resolusi, FPS, codec)
- [x] Estimasi size + duration
- [x] Save ke MediaStore + register library
- [x] Cancel render flow
- [x] Error handling render fail
- [x] ProGuard rules untuk Media3 + Pigeon + Sentry

### 1.5 Library
- [x] Library screen list project
- [x] Filter chips (All / Drafts / Done)
- [x] Search field
- [x] Project Detail screen
- [x] Clip viewer fullscreen
- [x] Share clip (Android share intent)
- [x] Delete project (dengan konfirmasi)
- [x] Rename project
- [x] Duplicate project

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
- [x] `TranscriptionProvider` interface
- [x] `GroqWhisperProvider` impl
- [x] Android audio extract 16kHz mono WAV
- [x] Audio chunking 10 menit + overlap 5 detik
- [x] Upload chunk ke Groq Whisper API
- [x] Merge word-level timestamps lintas chunk
- [x] Cache transcript by source SHA256
- [x] Retry exponential backoff
- [x] Resume from last successful chunk
- [x] Multi-language detection
- [x] Bahasa override manual
- [x] Progress UI saat transcribe

### 2.2 Auto Subtitle
- [x] Caption Editor screen
- [x] Word list editable inline
- [x] Edit text only (timestamp tetap)
- [x] Edit timing via drag handle
- [x] Style: font picker
- [x] Style: size slider
- [x] Style: color highlight swatches
- [x] Style: position 9-grid
- [x] Animation: none / karaoke / typewriter
- [x] Subtitle render via Media3 OverlaySettings
- [x] Safe area aware (top 10%, bottom 15%)
- [x] Word-aware line break
- [x] Test emoji + ID + EN mix
- [x] Live preview real-time

### 2.3 Semi-Auto Mode
- [x] Audio peak detection (PCM WAV window RMS/peak)
- [x] Scene change detection
- [x] Silence detection (untuk podcast)
- [x] UI: highlight kandidat di timeline
- [x] User pilih kandidat untuk jadi clip
- [x] Tuning threshold parameter

### 2.4 Auto Highlight (AI)
- [x] Groq LLM client (Llama 3.3 / DeepSeek)
- [x] Prompt engineering iterasi 1
- [x] Output schema: ranges with score & reason
- [x] Sentence-boundary refinement validator
- [x] Eval dataset: 10-20 video sampel + ground truth
- [x] Benchmark akurasi prompt
- [x] A/B test prompt antar model
- [x] Cache hasil scoring per source+config
- [x] User preview & adjust hasil
- [x] Score badge di timeline
- [x] Filler word removal (toggle, default off)

### 2.5 Templates
- [x] Template definition format (JSON)
- [x] Preset Podcast (talking head, subtitle large, watermark optional)
- [x] Preset Gaming (pip kamera + game, dynamic caption)
- [x] Preset Talking Head (face-tracked crop, karaoke caption)
- [x] Preset Tutorial (clean caption, watermark logo)
- [x] Apply template flow di Editor
- [x] Preview template visual

### 2.6 Watermark
- [x] Watermark module: text input
- [x] Watermark module: image picker
- [x] Position 9-anchor
- [x] Position drag custom
- [x] Opacity slider
- [x] Scale slider
- [x] Native overlay implementation
- [x] Preview di editor

### 2.7 Subject Tracking
- [ ] MLKit Face Detection integrate native
- [x] Face tracking timeline (per detik atau per frame sample)
- [x] Smooth crop transition (kalman atau ease)
- [x] Fallback ke center crop saat no face
- [x] Multi-face: pilih primary
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
- [x] Banner ad Library + Home
- [x] Rewarded ad untuk extra export
- [x] Interstitial low frequency (max 1x per 3 menit)
- [x] Disclosure di Privacy Policy
- [x] Test ad units di debug

### 3.2 Subscription
- [ ] Play Billing setup
- [ ] Subscription product configured
- [x] Pricing page UI
- [x] Paywall flow
- [x] Free trial 7 hari
- [x] Restore purchase
- [x] Receipt validation client-side
- [ ] Receipt validation server-side (opsional)
- [x] Cancel subscription flow

### 3.3 Free Tier Limits
- [x] Daily export counter (3/hari, reset 00:00 WIB)
- [x] Watermark "Made with Langgeng Clip" auto di free tier
- [x] Premium template lock di free tier
- [x] Limit communication jelas sebelum user kena dinding
- [x] Promo first-week unlimited untuk user baru (opsional)

### 3.4 Polish
- [x] Performance audit (memory, frame drop, render speed)
- [x] A11y audit (TalkBack, dynamic type 200%)
- [x] Empty states copy review (UX writer kalau ada)
- [x] Error messages catalog finalisasi
- [x] In-app onboarding tutorial post-import
- [x] Help center / FAQ minimal 10 artikel
- [x] Send feedback form di Settings

### 3.5 Production Launch
- [x] Listing Play Store: short + full description
- [ ] Screenshots phone (min 2, ideal 6-8)
- [ ] Screenshots tablet 7" + 10"
- [ ] Feature graphic 1024×500
- [ ] Promo video YouTube
- [ ] IARC content rating
- [x] Categorization Video Players & Editors
- [x] Target audience age 13+ atau 17+
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
- [x] Setup guide di CONTRIBUTING.md
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
