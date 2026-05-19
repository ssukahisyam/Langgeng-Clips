# 07 — Legal & Compliance

Aspek hukum, privacy, dan kepatuhan policy yang harus disiapkan sebelum publish.

## Privacy Policy

### Wajib Mencakup

1. **Data yang dikumpulkan**:
   - Tidak ada data personal yang dikirim ke server kita (tidak ada server).
   - Crash report ke Sentry/Crashlytics (anonymous device ID, OS, stack trace, breadcrumb).
   - Analytics event (anonymous).

2. **Data yang dikirim ke pihak ketiga (dengan persetujuan user)**:
   - **Groq**: audio file (untuk Whisper transcription) + transcript (untuk LLM scoring). Dikirim menggunakan API key milik user.
   - **Google Drive**: hanya jika user pilih sumber Drive. OAuth scope `drive.readonly`.
   - User bertanggung jawab atas penggunaan kuota & ToS Groq/Google.

3. **Data yang TIDAK kami kumpulkan/upload**:
   - Video file user (semua diproses lokal di device).
   - File path / nama file user di log/analytics.
   - API key user (disimpan di Android Keystore, tidak pernah keluar device kecuali ke Groq).
   - Hasil clip (tetap di device user, save ke gallery user sendiri).

4. **Storage di device**: cache transkrip, thumbnail, source file user (kontrol penuh user via "Hapus cache" di Settings).

5. **Hak user**: delete semua data lokal via uninstall atau "Hapus data" di Settings.

6. **Anak-anak**: app tidak ditujukan untuk anak <13 tahun (Designed for Families dihindari karena BYOK ke layanan AI eksternal tidak diizinkan untuk kategori ini).

7. **Kontak**: email developer + URL repo.

### Hosting

- Host di GitHub Pages atau domain custom.
- Update Privacy Policy = bump tanggal "Last updated" + notify user via in-app banner kalau perubahan material.

## Terms of Service / EULA

### Poin Utama

1. **License**: hak pakai non-eksklusif, non-transferable.
2. **Disclaimer kualitas AI**:
   - Hasil auto-highlight tidak 100% akurat.
   - User wajib review sebelum publish.
   - Kami tidak bertanggung jawab atas misinterpretasi konten yang di-clip.
3. **BYOK**:
   - User bertanggung jawab atas API key Groq miliknya.
   - Kuota dan biaya = tanggung jawab user.
   - Kami tidak proxy atau cache key di server.
4. **Konten user**:
   - User pemilik penuh konten input dan output.
   - User wajib punya hak atas video sumber (copyright).
5. **Larangan**:
   - Mengunggah konten ilegal, deepfake malicious, ujaran kebencian.
   - Reverse engineer aplikasi.
   - Menggunakan untuk membuat misinformation/disinformation.
6. **Limitation of liability**: max liability = harga subscription bulan terakhir (atau $0 untuk free user).
7. **Termination**: hak kami suspend akun yang melanggar.
8. **Governing law**: hukum Indonesia (sesuaikan).

## Play Store Compliance

### Data Safety Form

Mapping yang harus diisi di Play Console:

| Data Type | Collected | Shared | Optional | Purpose |
|---|---|---|---|---|
| Audio recording (extracted from video) | Yes | Yes (to Groq) | Yes (only auto-mode) | App functionality |
| App activity (events) | Yes | No | Yes | Analytics |
| Crash logs | Yes | No | No | App functionality |
| Device or other IDs | Yes | No | No | Crash reporting |
| Files & docs (videos) | No | No | — | Processed locally only |
| Personal info | No | No | — | — |
| Contacts | No | No | — | — |
| Location | No | No | — | — |

**Encryption in transit**: Yes (HTTPS).
**User can request deletion**: Yes (uninstall + clear cache).

### Policy Checks

| Policy | Status | Catatan |
|---|---|---|
| Permissions Declaration | Required | Justify semua permission di listing |
| Subscription Policy | Required | Jelas free trial period & cancellation |
| Ads Policy | Required | Disclose AdMob di Privacy Policy |
| User Data Policy | Required | Privacy Policy URL valid |
| Spam Policy | OK | Original app, bukan clone |
| Misleading Claims | Watch | Hindari klaim "100% accurate AI" |
| Restricted Content | OK | Bukan dewasa, judi, drug |
| YouTube Download Policy | **Risk** | Default tidak support download YouTube |
| Designed for Families | Skip | Min age 13+ atau 17+ |

### YouTube Download — Keputusan Final

**Tidak support download YouTube langsung di MVP/V1**. Alasan:
- Melanggar YouTube ToS.
- Risiko takedown Play Store tinggi.
- Banyak app sebelumnya kena hapus (PowerTube, NewPipe di Play Store, dll).

**Alternatif yang aman**:
1. **Share Intent**: user share URL dari YouTube app → Langgeng Clip terima → tampilkan instruksi "rekam screen / unduh manual via PC lalu import file".
2. **YouTube Data API + OAuth**: hanya untuk video yang user upload sendiri (Phase 2+, butuh review Google).

### Permission yang Diminta

| Permission | Justifikasi |
|---|---|
| `INTERNET` | Groq API, Drive API |
| `ACCESS_NETWORK_STATE` | Cek konektivitas sebelum upload audio |
| `READ_MEDIA_VIDEO` (API 33+) | Pilih video dari galeri |
| `READ_MEDIA_IMAGES` (opsional) | Watermark dari galeri |
| `POST_NOTIFICATIONS` (API 33+) | Foreground service render progress |
| `FOREGROUND_SERVICE` + `FOREGROUND_SERVICE_MEDIA_PROCESSING` | Render lama di background |
| `WAKE_LOCK` | Render tidak terinterupsi sleep |
| `BILLING` | Play Billing subscription |
| `INTERNET` (com.android.vending) | Iklan AdMob |

**Tidak diminta**:
- `READ_EXTERNAL_STORAGE` / `WRITE_EXTERNAL_STORAGE` (pakai scoped storage + MediaStore).
- `RECORD_AUDIO`, `CAMERA` (tidak rekam langsung di app).
- `ACCESS_FINE_LOCATION`, `READ_CONTACTS`, dll.

## Open Source License Audit

### Dependency Utama

| Lib | License | Compatible | Catatan |
|---|---|---|---|
| Flutter / Dart SDK | BSD-3 | ✓ | |
| Media3 | Apache 2.0 | ✓ | |
| MLKit Face Detection | Google ToS | ✓ | Terms terikat Firebase ToS |
| FFmpegKit (community) | LGPL/GPL tergantung paket | ⚠ | Pakai paket `min` (LGPL), hindari `full-gpl` |
| Riverpod | MIT | ✓ | |
| Dio | MIT | ✓ | |
| Sentry | MIT/BSD | ✓ | |
| Inter font | OFL 1.1 | ✓ | Wajib include OFL.txt di assets |
| JetBrains Mono | OFL 1.1 | ✓ | Wajib include OFL.txt |
| Lucide icons | ISC | ✓ | |
| Lottie | Apache 2.0 | ✓ | |

### Attribution Screen

Wajib di Settings > Tentang > "OSS License":
- Generate otomatis dari `flutter_oss_licenses` package.
- Include semua deps dengan license text-nya.
- Include font OFL notice.

## App Distribution

### Internal Testing
- Email tester: max 100 (Play Console internal).
- Tidak perlu review Play Store.
- Build pakai signing config production.

### Closed Testing
- Min 12 tester aktif selama 14 hari (Play Store policy untuk new app dari 2024).
- Boleh banyak track (alpha, beta).

### Production
- Review 7 hari (typical) untuk new app.
- Staged rollout: 10% → 50% → 100% selama 1 minggu.

### Listing Requirements
- App icon 512×512.
- Feature graphic 1024×500.
- Screenshots: min 2, max 8 per ukuran (phone, 7" tablet, 10" tablet).
- Promo video URL (YouTube, opsional tapi bagus untuk konversi).
- Description short (80 char) + full (4000 char).
- Categorization: **Video Players & Editors**.
- Content rating: IARC questionnaire.
- Target audience age: **13+** (atau 17+ kalau ingin aman).

## GDPR / Indonesian PDP Law

### Indonesia (UU PDP 27/2022)

- **Persetujuan eksplisit** untuk pemrosesan data personal — minta lewat onboarding.
- **Hak akses**: user bisa request data yang kami simpan (gampang: tidak ada).
- **Hak hapus**: uninstall = hapus semua local data.
- **DPO**: tidak wajib untuk skala kecil, tapi sediakan kontak.
- **Bahasa**: Privacy Policy wajib tersedia dalam Bahasa Indonesia.

### GDPR (kalau distribusi ke EU)

- Cookie consent tidak relevan (mobile app native).
- DSAR tetap harus didukung (mostly N/A karena kita tidak collect).
- Data Processing Agreement dengan Groq/Google (mereka sudah punya standard DPA).
- Disclosure di privacy policy: data di-process di mana (Groq US/EU?).

## Trademark & Branding

### Cek Sebelum Final

- [ ] Nama "Langgeng Clip" available di Play Store search?
- [ ] Domain `langgengclip.com` / `.id` available?
- [ ] Username `@langgengclip` available di Twitter/X, Instagram, TikTok, YouTube?
- [ ] Trademark Indonesia (DJKI) konflik?
- [ ] Logo unik (bukan dari template gratis tanpa modifikasi)?

### Backup Names (kalau "Langgeng Clip" tidak available)

- LanggengClip
- ClipLanggeng
- Klipper
- Klipsmart
- Klipify

## Deliverables

| Dokumen | Format | Tempat | Owner |
|---|---|---|---|
| Privacy Policy | Markdown → HTML | GitHub Pages | Dev |
| Terms of Service | Markdown → HTML | GitHub Pages | Dev |
| Play Store Listing | Form di Play Console | Play Console | Dev |
| Data Safety Form | Form Play Console | Play Console | Dev |
| OSS Attribution | In-app screen | App | Dev |
| EULA (kalau perlu strict) | PDF/in-app | App + Web | Dev |

## Tools Pembantu

- **Privacy Policy**: TermsFeed (gratis basic), Iubenda (paid, comprehensive).
- **Terms generator**: Termly.
- **Data Safety helper**: Play Console punya wizard.
- **License generator**: `flutter_oss_licenses` package.

## Open Issues

- Konfirmasi yurisdiksi hukum (Indonesia? International?).
- Konfirmasi distribusi awal (Play Store global atau ID-only)?
- Apakah perlu daftar PSE Kominfo (kalau target Indonesia eksklusif dengan user >100rb)?
