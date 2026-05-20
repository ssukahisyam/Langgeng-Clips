# 04 — UI Pages

12 layar utama. Setiap halaman: tujuan, layout, state, dan catatan implementasi.

## Information Architecture

```
Splash
  └─ Onboarding (3 slide, first-run only)
       └─ API Key Setup (BYOK)
            └─ Home  ─┬─ Import Sheet ─ Project Setup ─ Editor ─ Export Sheet
                      ├─ Library ─ Project Detail
                      └─ Settings
```

Bottom Nav: **Home / Library / Settings**.
Editor adalah **modal full-screen** (bukan tab), keluar via tombol back.

---

## Page 1 — Splash

**Tujuan**: brand recognition, hide async bootstrap (cek auth, load theme, init DB).

**Layout**:
- Logo center (mark + wordmark "Langgeng Clip"), tagline kecil di bawah.
- Background: solid background-token.
- Tidak ada loading bar.

**Logic**: max display 800ms. Setelah ready:
- First-run → Onboarding.
- Sudah pernah onboard tapi belum API key → API Key Setup (atau Home kalau user lewati).
- Sudah lengkap → Home.

**Transisi keluar**: fade 250ms.

```
┌────────────────────────┐
│                        │
│        ◆ logo          │
│   Langgeng Clip        │
│   clip smarter         │
│                        │
└────────────────────────┘
```

---

## Page 2 — Onboarding

**Tujuan**: 3 slide singkat menjelaskan value proposition.

**Layout per slide**:
- Ilustrasi/Lottie 60% atas.
- Teks 40% bawah: judul (Display) + body (Body M, max 2 baris).
- Dot indicator 3 titik.
- Skip top-right (text button).
- Next/Get Started bottom-anchored (filled button).

**Konten**:
1. **Import** — "Bawa video panjangmu" (file lokal, Drive, share).
2. **Auto Clip** — "AI temukan momen terbaik" (waveform highlight visual).
3. **Export** — "Siap upload ke Shorts/Reels/TikTok" (frame 9:16).

Slide ke-3 tombol → API Key Setup.

**State**: tidak ada loading. Pagination via `PageView`.

---

## Page 3 — API Key Setup (BYOK)

**Tujuan**: user paste Groq API key, validasi, lanjut.

**Layout**:
- Top bar dengan back arrow.
- Title: "Hubungkan Groq".
- Helper paragraf 2 baris.
- TextField password-style + toggle visibility.
- Helper inline "Disimpan aman di device kamu" + ikon shield kecil.
- Link "Cara dapat API key" (text button accent) → buka in-app webview/sheet step-by-step.
- CTA filled "Validasi & Lanjut".
- CTA text "Lewati untuk sekarang".

**State**:
- Loading: tombol disabled + spinner inline saat ping `/openai/v1/models`.
- Success: animasi checkmark 500ms → navigate Home.
- Error: inline error merah di bawah field ("Key tidak valid" / "Network error").

**Storage**: simpan ke `flutter_secure_storage` dengan key `groq_api_key`.

```
┌────────────────────────┐
│ ←                      │
│ Hubungkan Groq         │
│ Untuk transkrip & auto │
│ highlight (gratis di   │
│ groq.com)              │
│                        │
│ ┌──────────────────┐   │
│ │ gsk_••••••••     │👁│
│ └──────────────────┘   │
│ Disimpan aman di       │
│ device kamu.           │
│                        │
│ → Cara dapat API key   │
│                        │
│ [ Validasi & Lanjut  ] │
│ [ Lewati ]             │
└────────────────────────┘
```

---

## Page 4 — Home

**Tujuan**: starting point, 1 hero CTA.

**Layout** (top → bottom):
1. **Greeting** + counter aktivitas bulan ini (e.g., "Sudah 12 clip bulan ini").
2. **Hero CTA "Buat Clip Baru"** — card besar accent → buka Import sheet.
3. **Continue working on** — horizontal list project draft (hide kalau kosong).
4. **Quick Templates** — chip horizontal scroll, tap = mulai project pre-set template.
5. **Tip card** — single tip rotation, dismissible.

**Empty state** (user baru): hanya hero CTA + ilustrasi outline + helper "Mulai dengan upload video pertamamu".

**State**: pull-to-refresh untuk reload draft list.

```
┌────────────────────────┐
│ Halo, Creator      ⚙   │
│ Sudah 12 clip bulan ini│
│                        │
│ ┌──────────────────┐   │
│ │  +  Buat Clip    │   │
│ │     Baru         │   │
│ └──────────────────┘   │
│                        │
│ Lanjutkan              │
│ ┌──┐ ┌──┐ ┌──┐         │
│ │  │ │  │ │  │         │
│ └──┘ └──┘ └──┘         │
│                        │
│ Template Cepat         │
│ [Podcast] [Gaming]     │
│ [Talking] [Tutorial]   │
│                        │
│ [Home] [Library] [⚙]   │
└────────────────────────┘
```

---

## Page 5 — Import Sheet

**Tujuan**: pilih sumber video. Bottom sheet, bukan full page.

**Layout**:
- Drag handle.
- Title "Pilih Sumber Video".
- 3 row list dengan ikon kiri & chevron kanan:
  - File Lokal
  - YouTube URL (atau Share Intent — keputusan policy)
  - Google Drive
- Format hint di bawah ("Format: MP4, MOV, MKV").

**Behavior**:
- File Lokal → `file_picker` SAF.
- YouTube URL → expand jadi input field + tombol "Ambil" (atau redirect ke share-intent flow).
- Google Drive → OAuth flow → file picker grid.

**Setelah pilih file** → loader probe metadata → Project Setup.

> Catatan: keputusan final fitur YouTube ada di `09-risks-mitigation.md`. Default MVP: hanya share intent / file lokal.

---

## Page 6 — Project Setup (Mode Selector)

**Tujuan**: pilih mode clipping, template, jumlah clip, target durasi.

**Layout**:
- Top bar back.
- Card preview video (thumbnail, nama, durasi, resolusi).
- Section "Mode Clipping" — 3 radio cards: Manual / Semi-Auto / Auto (AI).
- Section "Template" — dropdown.
- Section "Jumlah Clip" — stepper (Auto / angka 1-20).
- Section "Durasi target" — segmented (15s / 30s / 60s / Auto).
- CTA filled bottom-anchored "Mulai Edit".

**State**: hanya satu mode aktif. "Auto" durasi menampilkan badge info "AI tentukan, hindari potong di tengah kalimat".

```
┌────────────────────────┐
│ ←  Atur Project        │
│                        │
│ ┌──────────────────┐   │
│ │ [thumbnail]      │   │
│ │ podcast.mp4      │   │
│ │ 01:23:45 · 1080p │   │
│ └──────────────────┘   │
│                        │
│ Mode Clipping          │
│ ○ Manual               │
│ ● Semi-Auto            │
│ ○ Auto (AI)            │
│                        │
│ Template [Podcast ▼]   │
│ Jumlah Clip ( – ) Auto │
│ Durasi 15  [30]  60 A  │
│                        │
│ [    Mulai Edit    ]   │
└────────────────────────┘
```

---

## Page 7 — Editor (Layar Utama, Full-screen)

**Tujuan**: layar paling kompleks, edit timeline + style + caption + watermark.

**Zona vertikal**:
1. **Top bar** — close (✕), project name (tap rename), more (⋮).
2. **Preview** (40% tinggi) — aspect 9:16 letterboxed. Tap play/pause.
3. **Transport bar** — prev frame, play/pause, next frame, fit/fill, speed, cut/split.
4. **Timeline** — waveform + scrubber + clip ranges. Pinch zoom.
5. **Tab bar** — Clips / Style / Audio / Caption / Watermark.
6. **Panel content** — sesuai tab aktif.
7. **Bottom CTA "Export"**.

**Tab Clips**: list semua clip (thumbnail + durasi + score). Swipe delete. Reorder drag.

**Tab Style**: pilih template (preview visual).

**Tab Audio**: volume original, fade, BGM (Phase 2).

**Tab Caption**: toggle, bahasa, font, ukuran, warna highlight, posisi, animasi.

**Tab Watermark**: toggle, text/image, posisi 9-anchor, opacity slider.

**State khusus auto-mode**: progress overlay di tengah preview ("transcribing" → "analyzing" → "segmenting"), reveal hasil.

**Auto-save**: state project disimpan tiap 30 detik atau saat back.

```
┌────────────────────────┐
│ ✕   Project Name    ⋮  │
├────────────────────────┤
│      [VIDEO 9:16]      │
│   00:23 / 01:23:45     │
├────────────────────────┤
│ ◀◀  ▶  ▶▶   ⤢ 1x   ✂   │
├────────────────────────┤
│ ▁▂▃▅▇▆▅▃▂▁▂▄▇▆▃▂▁▃    │
│ ├──────[clip1]─────┤   │
│         ├─[clip2]──┤   │
├────────────────────────┤
│ [Clips] [Style] [Audio]│
│ [Caption] [Watermark]  │
│ (panel content)        │
├────────────────────────┤
│ [    Export    ]       │
└────────────────────────┘
```

---

## Page 8 — Caption Editor (Sub-screen)

**Tujuan**: koreksi typo Whisper + style caption.

**Layout**:
- Top bar back.
- Preview kecil video di atas.
- Dropdown "Bahasa" (sumber transcript).
- List word-timestamp editable inline (tap edit).
- Style controls bawah: font, size slider, highlight color swatches, animasi, posisi 9-grid.

**Behavior**:
- Edit text only → timestamp tidak berubah.
- Edit timing → drag handle di list.
- Live preview real-time.

```
┌────────────────────────┐
│ ←  Caption             │
│ [video preview]        │
│                        │
│ Bahasa [Indonesia ▼]   │
│ 00:00.2  "Halo semua"  │
│ 00:01.8  "hari ini"    │
│ 00:03.1  "kita bahas"  │
│                        │
│ Font [Inter ▼]         │
│ Size  ●────────        │
│ Highlight ⬛⬛⬛⬛⬛       │
│ Animasi [Karaoke ▼]    │
│ Posisi  ┌─┐ 9-grid     │
└────────────────────────┘
```

---

## Page 9 — Export Sheet

**Tujuan**: pilih kualitas, codec, format → render.

**Layout** (bottom sheet):
- Drag handle.
- Title "Export".
- Resolusi: segmented 720 / 1080 / 4K.
- Frame rate: segmented 30 / 60.
- Codec: segmented H.264 / HEVC.
- Estimasi size + duration ("24MB · 45s").
- Toggle "Simpan ke Galeri".
- Toggle "Bagikan langsung".
- CTA "Mulai Export".

**Saat export jalan**: sheet jadi progress view dengan persen, ETA, tombol "Jalankan di Background" → kirim ke workmanager + foreground notification.

**Selesai**: sheet jadi success view dengan tombol Share / Open / Done.

---

## Page 10 — Library

**Tujuan**: list project & clip yang pernah dibuat.

**Layout**:
- Top bar dengan title + search icon.
- Filter chips: All / Drafts / Done.
- List vertikal 1 row per project.
- Row: thumbnail 64×64 kiri, title + meta (jumlah clip / status / waktu relatif), more icon kanan.

**Behavior**:
- Tap row → buka project di Editor (kalau draft) atau Project Detail (kalau done).
- More menu: rename, duplicate, export ulang, delete.
- Search field full-width saat aktif.

**Empty state**: ilustrasi outline + "Belum ada project" + CTA "Buat Clip Baru".

```
┌────────────────────────┐
│ Library            🔍  │
│ [All] [Drafts] [Done]  │
│                        │
│ ┌──┐  Podcast Ep 12    │
│ │▶ │  3 clips · 2 hari │
│ └──┘                ⋮  │
│ ─────────────────────  │
│ ┌──┐  Gaming Stream    │
│ │▶ │  Draft · 5 hari   │
│ └──┘                ⋮  │
└────────────────────────┘
```

---

## Page 11 — Project Detail

**Tujuan**: lihat semua clip dari satu project.

**Layout**:
- Top bar back + title + more.
- Source card (thumb, nama, durasi).
- Section "Clips (N)" — list dengan thumbnail 9:16 mini, durasi, score AI.
- CTA "Tambah Clip" bottom.

**Behavior**:
- Tap clip → viewer fullscreen + share/save/edit/delete.
- "Tambah Clip" → buka editor dengan source yang sama.

```
┌────────────────────────┐
│ ←  Podcast Ep 12   ⋮   │
│                        │
│ Source                 │
│ [thumb] podcast.mp4    │
│         01:23:45       │
│                        │
│ Clips (3)              │
│ [thumb] Clip 1         │
│  0:32 · ★ 92           │
│ [thumb] Clip 2         │
│  0:45 · ★ 87           │
│ [thumb] Clip 3         │
│  0:28 · ★ 81           │
│                        │
│ [+ Tambah Clip]        │
└────────────────────────┘
```

---

## Page 12 — Settings

**Tujuan**: kelola akun, tampilan, render, info.

**Layout** (group cards):
- **Akun & API**: Groq API Key (masked), Google Drive (connect/disconnect).
- **Tampilan**: Tema (System/Light/Dark), Bahasa (ID/EN).
- **Render**: Codec default, Bitrate default, Hapus cache (size info).
- **Tentang**: Privacy Policy, Terms, OSS License, Versi.

**Behavior**:
- Tap row → buka detail screen / dialog.
- "Hapus cache" → dialog konfirmasi + show size sebelum/sesudah.
- API key row tap → buka editor key (paste baru, validasi).

```
┌────────────────────────┐
│ Settings               │
│                        │
│ Akun & API             │
│ Groq API Key  ›        │
│ ••••••••3f2a           │
│ Google Drive  ›        │
│ Tidak terhubung        │
│                        │
│ Tampilan               │
│ Tema   [System ▼]      │
│ Bahasa [ID ▼]          │
│                        │
│ Render                 │
│ Codec default ›        │
│ Bitrate       ›        │
│ Hapus cache (124 MB)   │
│                        │
│ Tentang                │
│ Privacy Policy ›       │
│ Terms          ›       │
│ OSS License    ›       │
│ Versi 0.1.0            │
└────────────────────────┘
```

---

## Navigation Graph (go_router)

```
/                          # Splash
/onboarding                # Onboarding
/setup/api-key             # API Key Setup
/home                      # Home (tab)
/library                   # Library (tab)
/settings                  # Settings (tab)
/import                    # Import sheet (modal)
/project/setup/:fileId     # Project Setup
/project/:id/editor        # Editor
/project/:id/editor/caption # Caption Editor
/project/:id/export        # Export Sheet (modal)
/project/:id               # Project Detail
/settings/api-key          # API key editor
/settings/render           # Render preferences
/settings/about            # About + license
```

## Loading Pattern

| Konteks | Pattern |
|---|---|
| Library first load | Skeleton 3 row |
| Probe video | Full-screen loader, "Mempersiapkan video…" |
| Transcribing | Overlay editor, persen + cancel |
| LLM scoring | Progress lanjutan tahap 2/3 |
| Export | Bottom sheet → minimize ke notification |
| Network error | Inline banner top + retry |
| API key invalid | Modal "Update Key" / "Gunakan Manual" |
