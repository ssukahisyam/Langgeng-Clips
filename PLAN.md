# Langgeng Clip Functionality Plan

Dokumen ini merangkum kondisi aplikasi saat ini dan rencana kerja untuk
mengubah Langgeng Clip dari kumpulan modul/skeleton menjadi aplikasi yang
berfungsi end-to-end di Android.

## Current State

- `flutter analyze` lulus tanpa issue.
- Test suite berjalan sampai puluhan test tanpa failure, tetapi perlu rerun
  dengan timeout lebih panjang karena eksekusi sebelumnya berhenti oleh timeout.
- Aplikasi sudah memiliki banyak modul Flutter: onboarding, settings, import,
  project setup, editor, render/export, caption, transcription, library,
  monetization, watermark, semi-auto, dan auto-highlight.
- Native Android sudah memiliki beberapa channel penting: metadata probe,
  render/export, export action, audio extraction, dan scene detection.
- Banyak fitur sudah ada di level model, UI, atau unit test, tetapi belum semua
  tersambung menjadi flow runtime yang lengkap.
- Dokumentasi masih tidak sinkron: `README.md` menyebut status pre-development,
  sementara kode aplikasi sudah jauh melewati tahap tersebut.

## Main Gaps

1. Project dan selected video masih disimpan di memory melalui Riverpod
   `StateProvider`, sehingga state mudah hilang saat app restart atau process
   Android dibunuh.
2. Belum ada persistence project/source/clip yang solid sesuai checklist
   `sqflite`.
3. Editor preview belum menggunakan video player native yang benar-benar
   memutar source video dan sinkron dengan timeline.
4. Mode Semi-Auto dan Auto AI bisa dipilih, tetapi flow generate kandidat belum
   sepenuhnya tersambung dari setup sampai editor.
5. Caption/transcription sudah punya provider, cache, progress, dan editor,
   tetapi perlu satu user journey yang jelas untuk generate, edit, preview, dan
   export subtitle.
6. Watermark editor belum sepenuhnya memengaruhi native export; native composer
   masih memakai watermark statis.
7. Settings, legal links, OSS licenses, release signing, QA matrix, dan Play
   readiness belum lengkap.
8. Native render perlu validasi device nyata untuk codec, rotation, large file,
   MediaStore, cancel flow, dan caption overlay.

## Execution Principles

- Prioritaskan flow end-to-end sebelum menambah fitur baru.
- Jaga perubahan tetap kecil dan dapat diuji per PR.
- Hindari mengaktifkan fitur di UI jika belum ada flow runtime yang aman.
- Simpan data penting secara persistent sebelum membangun fitur lanjutan.
- Setiap fase harus punya acceptance criteria yang dapat dicoba di device.

## Phase 1: Manual MVP End-To-End

Implementation status: completed for the current PR scope. Manual MVP now has
persistent active sessions, Home/Library draft resume, local file preview,
playhead/timeline sync, export history refresh, and Library shortcut after
export. Android build/device QA remains blocked in this environment until the
Android SDK and real devices are available.

Goal: user bisa import video lokal, setup project manual, preview video, pilih
range, export clip 9:16, melihat hasil di library, dan membuka ulang project.

Tasks:

- Update `README.md` dan `CHECKLIST.md` agar status project sesuai kode saat ini.
- Tambahkan persistence untuk project, source video, clip ranges, export history,
  caption document, dan watermark config.
- Tentukan strategi source video: reference path untuk MVP atau copy ke app
  storage untuk reliability.
- Implement real video preview di editor memakai native Media3/ExoPlayer atau
  plugin Flutter yang stabil.
- Sinkronkan preview dengan play/pause, seek, scrubber, dan range handles.
- Pastikan Manual Mode membuat, memilih, mengubah, dan export multi-clip.
- Auto-save project setiap perubahan penting.
- Validasi export native di Android real device.

Acceptance criteria:

- User bisa import MP4 lokal dan metadata tampil benar.
- User bisa membuat project manual dan app tidak kehilangan project setelah
  restart.
- User bisa play/pause/seek video di editor.
- User bisa mengatur start/end clip dan export hasil 9:16.
- Export tersimpan ke Gallery dan muncul di Library.
- User bisa share export dari Library.

## Phase 2: Caption And Transcription Flow

Goal: user bisa generate subtitle dari video, edit caption, preview hasil, dan
export clip dengan caption.

Tasks:

- Tambahkan CTA `Generate Subtitle` di editor atau caption tab.
- Gate transcription dengan Groq API key yang valid.
- Jalankan flow audio extraction, chunking, Groq Whisper upload, retry/resume,
  transcript cache, dan progress UI.
- Isi `captionDocumentProvider` dari hasil transcript.
- Persist caption document per project.
- Integrasikan caption editor dengan project aktif.
- Kirim caption segments ke native export dan validasi timing offset.
- Tambahkan handling error yang jelas untuk API key kosong, invalid key,
  rate limit, network timeout, dan extraction failure.

Acceptance criteria:

- User bisa generate subtitle untuk video pendek.
- Subtitle muncul di editor dan bisa diedit.
- Edit text tidak merusak timing.
- Export clip menyertakan subtitle yang sinkron.
- Transcription result bisa dipakai ulang dari cache.

## Phase 3: Semi-Auto Mode

Goal: user bisa memilih Semi-Auto, aplikasi membuat kandidat clip dari audio dan
scene analysis, lalu user memilih kandidat untuk diedit/export.

Tasks:

- Setelah setup Semi-Auto, jalankan audio level analysis, silence detection, dan
  scene change detection.
- Gabungkan hasil analisis menjadi `SemiAutoCandidate` yang punya range, score,
  dan reason.
- Buat UI review kandidat di timeline atau layar intermediate.
- Izinkan user memilih kandidat untuk menjadi clips.
- Tambahkan sensitivity/threshold sederhana.
- Persist kandidat di project.

Acceptance criteria:

- Semi-Auto tidak hanya masuk editor kosong.
- Kandidat clip tampil dengan range dan reason.
- User bisa apply kandidat menjadi clip dan mengubah range sebelum export.

## Phase 4: Auto AI Highlight

Goal: user bisa memilih Auto AI, aplikasi transcribe video, score highlight
dengan LLM, lalu menampilkan kandidat yang bisa dipilih.

Tasks:

- Gate Auto AI dengan Groq API key.
- Reuse transcription flow dari Phase 2.
- Kirim transcript ke Groq highlight client.
- Parse JSON response, validate ranges, dan refine ke sentence boundary.
- Cache hasil scoring per source dan config.
- Buat UI kandidat dengan score dan reason.
- Tambahkan warning estimasi durasi/cost untuk video panjang.
- Implement filler word removal sebagai toggle yang aman.

Acceptance criteria:

- Auto AI menghasilkan kandidat dari video pendek dengan transcript valid.
- Kandidat punya score/reason dan bisa dipreview.
- User bisa apply kandidat menjadi clips.
- Failure API tidak membuat project corrupt.

## Phase 5: Templates And Watermark Integration

Goal: template dan watermark yang dipilih user benar-benar memengaruhi preview
dan export.

Tasks:

- Extend Pigeon `RenderRequest` untuk membawa watermark config.
- Kirim text/image, position, opacity, scale, dan enabled state ke native render.
- Ganti watermark native statis dengan config dari project/editor.
- Terapkan template ke caption style, watermark default, export preset, dan crop
  guide.
- Tampilkan preview watermark/template di editor secara konsisten.

Acceptance criteria:

- User bisa mengubah watermark dan hasil export mengikuti konfigurasi itu.
- Template mengubah setelan project yang terlihat dan dapat diexport.

## Phase 6: Settings, Library, And Release Readiness

Goal: aplikasi siap dipakai beta internal dengan state persistent, settings
lengkap, observability aman, dan build release yang bisa diuji.

Tasks:

- Buat Library membaca project/export dari persistence yang sama.
- Lengkapi Settings: API key management, theme, language, privacy policy, terms,
  OSS licenses, app version, dan delete local data.
- Pastikan Sentry/analytics tidak mengirim API key, PII, atau local file path.
- Audit Android permissions dan storage behavior.
- Finalisasi minSdk/targetSdk, ProGuard/R8, release signing, dan AAB build.
- Jalankan QA matrix pada device low/mid/high dan beberapa versi Android.

Acceptance criteria:

- Internal tester bisa install build release.
- App bisa dipakai untuk skenario MVP tanpa crash blocking.
- Settings legal dan data controls tersedia.
- QA matrix memiliki catatan hasil dan bug prioritas.

## Definition Of Done For MVP

MVP dianggap berfungsi jika skenario berikut berhasil di Android device nyata:

1. User install app.
2. User menyelesaikan onboarding.
3. User import video lokal.
4. App membaca metadata video.
5. User membuat project manual.
6. User preview video dan memilih range.
7. User export clip 9:16.
8. Export tersimpan di Gallery.
9. Export muncul di Library.
10. User restart app dan project/export masih ada.
11. User bisa share hasil export.
12. Tidak ada crash pada video umum 720p/1080p.

## Technical Risks

- Native video preview dan timeline sync berpotensi menjadi pekerjaan terbesar.
- Android storage permission, file path, dan content URI bisa berbeda antar device.
- Media3 Transformer bisa gagal pada codec atau hardware tertentu.
- Video panjang akan menekan memory, storage, network, dan battery.
- Groq transcription/highlight butuh retry, resume, dan cost warning yang jelas.
- Persistence migration perlu dirancang sebelum data user beta mulai penting.

## Recommended PR Order

1. Documentation sync and MVP acceptance criteria.
2. Project/source/clip persistence.
3. Real editor video preview.
4. Manual export validation and Library persistence.
5. Caption/transcription end-to-end.
6. Semi-Auto candidate flow.
7. Auto AI highlight flow.
8. Watermark/template native export integration.
9. Settings/legal/release hardening.
