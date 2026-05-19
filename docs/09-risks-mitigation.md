# 09 — Risks & Mitigation

Risiko teknis, produk, dan operasional. Setiap risiko punya dampak, probabilitas, dan rencana mitigasi.

## Klasifikasi

- **Probabilitas**: Low / Medium / High.
- **Dampak**: Low (annoyance), Medium (delay/feature loss), High (project blocker / takedown / data loss).

---

## A. Technical Risks

### A.1 Render performance lambat di mid-low device

| | |
|---|---|
| Probabilitas | High |
| Dampak | Medium |
| Akar masalah | MediaCodec quirks, software fallback, thermal throttle |

**Mitigasi**:
- Default proxy 1080p untuk preview, render 4K hanya saat export.
- Tampilkan progress + ETA jelas, allow background.
- Toggle "Hemat baterai mode" → cap 720p + 30fps.
- Test di Galaxy A14 / Redmi 9 sebagai baseline minimum.
- Telemetry render duration vs device — auto-warn user kalau device tidak optimal.

### A.2 Variasi vendor Android (Samsung/Xiaomi/Oppo) MediaCodec quirks

| | |
|---|---|
| Probabilitas | Medium |
| Dampak | High |

**Mitigasi**:
- Device matrix testing wajib (lihat `06-engineering-practices.md`).
- Fallback ke FFmpeg software encoder kalau Media3 fail.
- Whitelist codec yang aman per vendor (mis. avoid HEVC di beberapa Xiaomi lama).
- Monitor crash by device model di Crashlytics, prioritize fix top 5 device.

### A.3 Memory peak >350MB di low-end device → OOM kill

| | |
|---|---|
| Probabilitas | Medium |
| Dampak | High |

**Mitigasi**:
- Bitmap pooling untuk timeline thumbnail.
- LRU cache dengan limit dinamis berdasarkan `ActivityManager.memoryClass`.
- Stream waveform render (bukan render full sekaligus).
- Release resource segera setelah leave screen.
- LeakCanary di debug build.

### A.4 ProGuard/R8 strip Media3/MLKit class → crash production

| | |
|---|---|
| Probabilitas | Medium |
| Dampak | High |

**Mitigasi**:
- Setup `proguard-rules.pro` lengkap dari awal (Media3, MLKit, Pigeon, Sentry).
- Test build release lokal sebelum tag.
- Pre-launch report Play Console enable.

### A.5 Storage device penuh saat import/render → crash

| | |
|---|---|
| Probabilitas | Medium |
| Dampak | Medium |

**Mitigasi**:
- Cek `StatFs` sebelum import: butuh free space >2x durasi source.
- Auto-cleanup intermediate file setelah render.
- Tampilkan estimate size sebelum export.
- Setting "Hapus cache" yang clear.

### A.6 ffmpeg-kit-flutter (community fork) abandoned

| | |
|---|---|
| Probabilitas | Medium |
| Dampak | High |

**Mitigasi**:
- Pakai sebagai **fallback only**, bukan engine utama.
- Abstraksi `VideoFilterEngine` interface — bisa swap.
- Fork repo kalau perlu maintain sendiri.
- Eksplorasi alternatif: native FFmpeg via JNI, atau hand-roll filter di Media3.

### A.7 Groq rate limit / quota habis di tengah render

| | |
|---|---|
| Probabilitas | Medium |
| Dampak | Medium |

**Mitigasi**:
- Pre-flight check kuota sebelum mulai transcribe (kalau API expose).
- Retry dengan exponential backoff.
- Resume transcribe dari chunk terakhir kalau gagal.
- Cache transcript by source hash → tidak perlu re-transcribe kalau retry.
- Pesan error jelas: "Kuota Groq habis, coba besok atau upgrade tier."

### A.8 Subtitle render visual bug (font shaping, emoji, line break)

| | |
|---|---|
| Probabilitas | Medium |
| Dampak | Medium |

**Mitigasi**:
- Pakai font subset dengan glyph yang dipakai saja.
- Test dengan emoji + Bahasa Indonesia + English mix.
- Word-aware line break (tidak potong di tengah kata).
- Preview real-time di editor sebelum export.
- Safe area padding wajib (jangan di area UI Reels).

### A.9 Variable Frame Rate (VFR) input → audio drift

| | |
|---|---|
| Probabilitas | Medium |
| Dampak | High |

**Mitigasi**:
- Detect VFR di probe step.
- Re-encode ke CFR (constant frame rate) sebelum proses.
- Test dengan rekaman screen Android (sering VFR), Premiere export VFR, OBS recording.

### A.10 Word-timestamp Whisper meleset di video panjang

| | |
|---|---|
| Probabilitas | Medium |
| Dampak | High (clip cut salah) |

**Mitigasi**:
- Chunk audio dengan overlap 5 detik untuk kalibrasi.
- Validate timestamp monotonically increasing.
- Sentence-boundary refinement: lock ke awal kalimat berikutnya kalau drift terdeteksi.
- User bisa adjust manual di Caption Editor.

---

## B. AI / Highlight Quality Risks

### B.1 LLM mendeteksi highlight yang misleading / out-of-context

| | |
|---|---|
| Probabilitas | High |
| Dampak | High (reputasi, viral negative) |

**Mitigasi**:
- **Sentence-boundary lock**: clip selalu mulai/akhir di kalimat utuh.
- Prompt engineering: minta LLM expand boundary ke awal pertanyaan/setup terdekat.
- User wajib preview & approve sebelum render (tidak auto-export).
- Disclaimer di onboarding: "AI tidak sempurna, selalu review."
- Eval dataset 10-20 video untuk benchmark akurasi.
- A/B test prompt antar model (Llama vs DeepSeek vs Mixtral).

### B.2 LLM hallucinate (tambah/hilangkan kata)

| | |
|---|---|
| Probabilitas | Low |
| Dampak | High |

**Mitigasi**:
- LLM hanya **score & segment**, tidak generate text.
- Subtitle text murni dari Whisper, bukan LLM.
- Validate output LLM: pastikan timestamp ada di transcript asli.

### B.3 Bahasa non-Inggris / dialek hasil Whisper kurang akurat

| | |
|---|---|
| Probabilitas | Medium |
| Dampak | Medium |

**Mitigasi**:
- Caption Editor wajib ada — user bisa koreksi.
- Bahasa yang akurasi rendah ditandai (mis. dialek Jawa, Sunda) dengan warning.
- Future: support custom vocabulary / hot words.

### B.4 Filler word ("umm", "eh", "anu") tidak dihapus → clip tidak bersih

| | |
|---|---|
| Probabilitas | Medium |
| Dampak | Low |

**Mitigasi**:
- Toggle "Remove filler" di Editor (disable by default V1).
- Library kata filler per bahasa (ID/EN).
- User bisa edit manual.

---

## C. Product / UX Risks

### C.1 User tidak paham BYOK & cara dapat Groq API key

| | |
|---|---|
| Probabilitas | High |
| Dampak | High (drop-off di onboarding) |

**Mitigasi**:
- In-app step-by-step guide cara dapat API key (screenshot Groq dashboard).
- Video 60 detik di YouTube + link dari onboarding.
- "Lewati untuk sekarang" tetap bisa pakai mode manual.
- FAQ artikel "Cara dapat Groq API key gratis".

### C.2 User expect kualitas seperti Opus Clip tapi disappointed

| | |
|---|---|
| Probabilitas | High |
| Dampak | Medium |

**Mitigasi**:
- Expectation setting di onboarding: "AI assistive, bukan auto-magic."
- Tampilkan score AI di hasil clip — user paham mana yang strong / weak.
- Iterate prompt + benchmark untuk catch up kualitas.
- Komunikasi "early access, masih improve" di beta phase.

### C.3 Editor terlalu kompleks untuk pemula

| | |
|---|---|
| Probabilitas | Medium |
| Dampak | Medium |

**Mitigasi**:
- Onboarding tutorial in-app (highlight tour) saat first open editor.
- Default value sensible (template auto-applied).
- Mode "Quick Mode" yang skip semua advanced setting.
- A/B test simplified editor di Phase 3.

### C.4 Free tier limit (3/hari) terlalu ketat → user uninstall

| | |
|---|---|
| Probabilitas | Medium |
| Dampak | Medium |

**Mitigasi**:
- A/B test limit (3 vs 5 vs 10).
- Rewarded ad untuk extra export (positif: user engage iklan).
- Communicate limit jelas sebelum user kena dinding.
- Promo "first week unlimited" untuk user baru.

---

## D. Legal / Policy Risks

### D.1 Play Store reject / takedown karena YouTube download

| | |
|---|---|
| Probabilitas | High (kalau implementasi naive) |
| Dampak | High (project killed) |

**Mitigasi**:
- **Default tidak support download YouTube.**
- Hanya share intent + file lokal di MVP.
- YouTube Data API + OAuth (untuk video user sendiri) di Phase 2 dengan review.

### D.2 Privacy violation report karena audio/transcript dikirim ke Groq

| | |
|---|---|
| Probabilitas | Low |
| Dampak | High |

**Mitigasi**:
- Disclosure jelas di onboarding + Privacy Policy.
- Data Safety Form Play Console diisi akurat.
- Encryption in transit (HTTPS).
- Tidak track / store data Groq di server kita.
- Tombol "Use offline manual mode" kalau user tidak nyaman.

### D.3 API key user bocor (bug di logging atau crash report)

| | |
|---|---|
| Probabilitas | Low |
| Dampak | High |

**Mitigasi**:
- Filter regex API key di log layer (`gsk_*`, `sk-*`, dll).
- Sentry: scrub PII otomatis.
- Tidak pernah include header Authorization di error report.
- Penetration test sederhana sebelum public launch (cek dump app data).

### D.4 Copyright claim dari konten user yang melanggar

| | |
|---|---|
| Probabilitas | Low |
| Dampak | Medium |

**Mitigasi**:
- ToS jelas: user bertanggung jawab atas konten.
- Tidak host atau distribute output (semua di device user).
- Disclaimer di onboarding.

### D.5 Indonesian PSE Kominfo registration

| | |
|---|---|
| Probabilitas | Medium (kalau user >100k) |
| Dampak | Medium (denda atau blokir) |

**Mitigasi**:
- Pantau jumlah user.
- Daftar PSE saat threshold tercapai (proses ~1 bulan).
- Konsultasi legal saat user >50k untuk persiapan.

---

## E. Operational Risks

### E.1 Solo developer burnout

| | |
|---|---|
| Probabilitas | High |
| Dampak | High |

**Mitigasi**:
- Realistic milestone, bukan "MVP 2 minggu" yang tidak realistis.
- Scope freeze sebelum launch — say no to non-critical feature.
- Break minimum 1 hari per minggu, no laptop.
- Budget freelancer untuk area lemah (mis. native Android).
- Komunitas / mentor sebagai sounding board.

### E.2 Kehilangan keystore signing → tidak bisa update app

| | |
|---|---|
| Probabilitas | Low |
| Dampak | **Critical** (tidak ada recovery) |

**Mitigasi**:
- Generate keystore + simpan **3 lokasi**: password manager, encrypted backup di cloud (Google Drive private), USB offline.
- Catat password di tempat terpisah dari keystore.
- Test recovery flow sekali sebelum production.
- Migrate ke Play App Signing (Play Store kelola key untuk kita) — sangat direkomendasikan.

### E.3 Repo loss (laptop hilang, drive gagal)

| | |
|---|---|
| Probabilitas | Low |
| Dampak | High |

**Mitigasi**:
- Push ke GitHub setiap akhir hari kerja.
- Mirror ke GitLab/Codeberg sebagai fallback.
- Backup local repo ke external drive mingguan.

### E.4 Groq menutup free tier / pricing naik

| | |
|---|---|
| Probabilitas | Medium |
| Dampak | High (kalau no fallback) |

**Mitigasi**:
- Abstraksi `TranscriptionProvider` & `LLMProvider` interface.
- Siap implementasi alternatif: Deepgram, AssemblyAI, OpenAI Whisper, Replicate.
- Komunikasi proaktif ke user kalau ada perubahan.
- Mode manual tetap jalan tanpa cloud.

### E.5 Tester drop saat closed beta (kurang dari 12 aktif)

| | |
|---|---|
| Probabilitas | Medium |
| Dampak | Medium (delay launch) |

**Mitigasi**:
- Recruit 30+ tester awal (asumsi 30% drop).
- Insentif: lifetime Pro tier untuk tester aktif.
- Engagement: weekly call/feedback session.
- Backup pool: friends & family yang creator.

### E.6 Crash rate >0.5% di production

| | |
|---|---|
| Probabilitas | Medium |
| Dampak | High |

**Mitigasi**:
- Staged rollout 10% → 50% → 100%.
- Monitor crash rate 48 jam setiap stage.
- Auto-rollback hook (manual saat ini, otomasi di Phase 4).
- Hotfix process documented (release branch + cherry-pick).

---

## F. Cost / Resource Risks

### F.1 Cost development testing API Groq (own key) overrun

| | |
|---|---|
| Probabilitas | Low |
| Dampak | Low |

**Mitigasi**:
- Set hard limit di Groq dashboard.
- Pakai cache aggressive saat development (transcript cached by hash).
- Test dengan video pendek dulu.

### F.2 Play Console fee ($25) + domain + hosting

| | |
|---|---|
| Probabilitas | Certain (planned) |
| Dampak | Low |

**Mitigasi**:
- Budget $50-100 untuk launch (Play Console + domain 1 tahun + Vercel free tier).
- ROI dari Pro subscription Phase 3.

---

## Risk Register Summary

| ID | Risk | Prob | Impact | Owner | Status |
|---|---|---|---|---|---|
| A.1 | Render lambat mid-low | High | Med | Dev | Mitigated by design |
| A.4 | ProGuard strip | Med | High | Dev | Pending setup |
| B.1 | LLM misleading clip | High | High | Dev | Mitigated by sentence-lock |
| C.1 | BYOK confusion | High | High | Dev/UX | In-app guide planned |
| D.1 | YouTube takedown | High | High | Product | Avoided in MVP |
| E.2 | Keystore loss | Low | Critical | Dev | Backup plan documented |
| E.4 | Groq pricing change | Med | High | Dev | Abstraction layer planned |

Update register ini sebelum/sesudah setiap milestone.

## Lessons Learned (akan ditulis pasca-milestone)

Tinggalkan section ini kosong, isi setelah closed beta dan setelah V1 launch dengan apa yang sebenarnya terjadi vs apa yang diprediksi.
