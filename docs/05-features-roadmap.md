# 05 — Features Roadmap

Pengelompokan per milestone. Setiap fitur punya scope jelas dan acceptance criteria ringkas.

## Phase 0 — Foundation (1-2 minggu)

Tujuan: project siap di-develop, dasar branding & legal jalan.

- [ ] Repo struktur, `.gitignore`, lint config (Dart + Kotlin).
- [ ] Flutter project init dengan struktur folder dari `02-technical-architecture.md`.
- [ ] Theme system (light/dark) dasar + token implementation.
- [ ] go_router setup dengan stub semua route.
- [ ] Riverpod + DI (get_it) skeleton.
- [ ] Pigeon spec awal untuk video pipeline.
- [ ] Splash + Onboarding 3 slide (UI saja, no logic).
- [ ] CI: GitHub Actions build APK debug pada PR.
- [ ] Crashlytics / Sentry pasang dari awal.
- [ ] Privacy Policy + ToS draft host.
- [ ] App icon adaptive (foreground + background).
- [ ] Brand check nama "Langgeng Clip" (Play Store, domain).

**Definition of Done**: APK debug bisa install di device, splash → onboarding → home stub jalan, CI hijau.

---

## Phase 1 — MVP Slice (4-6 minggu)

Tujuan: end-to-end flow manual clipping bekerja, bisa export 1 clip 9:16.

### M1.1 — API Key & Settings (3-4 hari)
- [ ] API Key Setup screen + validate ke Groq.
- [ ] flutter_secure_storage integrate.
- [ ] Settings screen full (Akun, Tampilan, Render, Tentang).
- [ ] Toggle theme system/light/dark dengan persistence.
- [ ] Bahasa app (ID/EN) dengan `flutter_localizations`.

### M1.2 — Import & Probe (4-5 hari)
- [ ] Home screen final (greeting, hero CTA, quick template chips).
- [ ] Import sheet: file_picker lokal.
- [ ] Native: probe metadata (durasi, resolusi, codec, rotation, FPS, audio tracks).
- [ ] Storage: save source file ke app dir, register di sqflite.
- [ ] Empty state semua layar.

### M1.3 — Project Setup & Editor Manual (7-10 hari)
- [ ] Project Setup screen.
- [ ] Editor scaffold: top bar, preview (ExoPlayer wrap), transport, timeline, tab bar.
- [ ] Timeline: waveform render basic + scrubber + clip range handle.
- [ ] Manual mode: split clip, set in/out, multi clip.
- [ ] Auto-save state project setiap 30s.

### M1.4 — Render Pipeline (5-7 hari)
- [ ] Native Media3 Transformer pipeline: trim → center crop 9:16 → encode H.264.
- [ ] Progress event channel ke Flutter.
- [ ] Foreground service untuk render lama.
- [ ] Export sheet UI dengan kualitas/codec/FPS.
- [ ] Save ke MediaStore + register di library.

### M1.5 — Library (2-3 hari)
- [ ] Library screen list project.
- [ ] Filter chips, search.
- [ ] Project Detail screen.
- [ ] Delete / rename project.

**Definition of Done MVP**: user bisa import file lokal → trim manual → export 1 clip 9:16 → muncul di gallery.

---

## Phase 2 — V1.0 (6-8 minggu)

Tujuan: AI features lengkap (transcribe, auto-subtitle, auto-highlight), template, watermark.

### M2.1 — Transcription (5-7 hari)
- [ ] `TranscriptionProvider` interface + `GroqWhisperProvider` impl.
- [ ] Native: extract audio 16kHz mono WAV via FFmpeg.
- [ ] Chunking audio per 10 menit + overlap.
- [ ] Merge word-level timestamps lintas chunk.
- [ ] Cache transcript per file (hash SHA256).
- [ ] Multi-language detection + override.

### M2.2 — Auto Subtitle (5-7 hari)
- [ ] Caption Editor screen dengan word list editable.
- [ ] Subtitle render via Media3 OverlaySettings.
- [ ] Style: font, size, color highlight, position 9-grid.
- [ ] Animation: none / karaoke / typewriter.
- [ ] Safe area aware (jangan di area UI Reels/TikTok).

### M2.3 — Semi-Auto Mode (4-5 hari)
- [ ] Audio peak detection via FFmpeg ebur128.
- [ ] Scene change detection.
- [ ] Silence detection untuk podcast.
- [ ] UI: highlight kandidat di timeline, user pilih.

### M2.4 — Auto Highlight (AI) Mode (7-10 hari)
- [ ] Groq LLM client (Llama 3.3 atau DeepSeek).
- [ ] Prompt engineering untuk highlight scoring.
- [ ] Sentence-boundary refinement: validasi dari word-timestamp.
- [ ] Eval dataset 10-20 video sampel + benchmark.
- [ ] User preview & adjust hasil AI.
- [ ] Cache hasil scoring.

### M2.5 — Templates (4-5 hari)
- [ ] Template definition format (JSON).
- [ ] 4 preset: Podcast, Gaming, Talking Head, Tutorial.
- [ ] Template includes: caption style, watermark default, crop strategy.
- [ ] Apply template flow di Editor.

### M2.6 — Watermark (3-4 hari)
- [ ] Watermark module: text & image.
- [ ] Position 9-anchor + drag custom.
- [ ] Opacity slider, scale slider.
- [ ] Native overlay implementation.

### M2.7 — Subject Tracking (5-7 hari)
- [ ] MLKit Face Detection integrate native.
- [ ] Face tracking timeline (per detik).
- [ ] Smooth crop transition (kalman filter atau ease).
- [ ] Fallback ke center crop kalau no face.

**Definition of Done V1.0**: 3 mode jalan, auto-mode menghasilkan clip yang 70%+ "usable" oleh tester, 4 template pilihan.

---

## Phase 3 — V1.5 Polish & Monetisasi (3-4 minggu)

### M3.1 — AdMob Integration
- [ ] Banner ad di Library + Home.
- [ ] Rewarded ad untuk export ekstra (free tier).
- [ ] Interstitial setelah export (low frequency, max 1x per 3 menit).

### M3.2 — Subscription
- [ ] Play Billing setup.
- [ ] Pricing page + paywall.
- [ ] Free trial 7 hari.
- [ ] Receipt validation client-side (server-side optional).
- [ ] Restore purchase.

### M3.3 — Free Tier Limits
- [ ] Daily export counter (3/hari free).
- [ ] Watermark "Made with Langgeng Clip" di free tier (toggle off di Pro).
- [ ] Premium template lock di free tier.

### M3.4 — Polish
- [ ] Performance audit + optimisasi (memory, frame drop, render speed).
- [ ] A11y audit (TalkBack test, dynamic type).
- [ ] Empty states & error messages copy review.
- [ ] Onboarding tutorial in-app (post-import).
- [ ] Help center / FAQ minimal 10 artikel.

**Definition of Done V1.5**: monetisasi aktif, conversion tracking jalan, rating Play Store >4.0.

---

## Phase 4 — V2.0 Post-Launch (3+ bulan)

### M4.1 — iOS Port
- [ ] AVFoundation pipeline rewrite Kotlin → Swift.
- [ ] Pigeon iOS bridge.
- [ ] App Store assets & submission.

### M4.2 — Cloud / Managed Mode
- [ ] Backend API (Cloudflare Workers / Supabase).
- [ ] User authentication (Google/Apple sign-in).
- [ ] Server-side rendering option.
- [ ] Subscription tier "Managed" tanpa BYOK.

### M4.3 — Advanced Features
- [ ] B-roll library (stock footage, opsional).
- [ ] BGM picker dengan ducking otomatis.
- [ ] Auto-translate subtitle.
- [ ] Custom template editor.
- [ ] Cloud project sync.
- [ ] Tim/collaboration (Phase 4+).

---

## Cross-Cutting Concerns (semua phase)

- [ ] Unit test coverage core logic 70%+.
- [ ] Widget test komponen kritikal.
- [ ] Integration test happy path setiap phase.
- [ ] Manual QA matrix 5 device (low/mid/high, vendor berbeda).
- [ ] Crash-free rate >99%.
- [ ] APK download size <80MB.

## Out of Scope Permanent (kecuali ada permintaan kuat)

- Live streaming clip.
- Direct upload ke TikTok/YouTube/Instagram.
- Dektop/web port.
- Custom AI model training.
- Real-time collaboration.
