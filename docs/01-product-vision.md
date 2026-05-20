# 01 — Product Vision

## Ringkasan

Langgeng Clip adalah aplikasi Android yang membantu content creator mengubah video panjang menjadi short-form clip (9:16) dengan cepat. Fokus utamanya: **otomasi clipping** untuk podcast, gaming, dan talking-head content, dengan kontrol manual penuh kalau dibutuhkan.

## Problem Statement

Content creator yang punya konten panjang (podcast 1-3 jam, stream gaming 4+ jam, kuliah/talk 30-60 menit) harus:
- Tonton ulang full video untuk cari highlight.
- Edit manual di CapCut/Premiere untuk crop 9:16, tambah subtitle, watermark.
- Repeat 5-10 kali per video panjang untuk dapat banyak shorts.

Total waktu: **3-5 jam edit per 1 jam video sumber**. Ini bottleneck utama yang ingin dipecahkan.

## Target Pengguna

### Primary Persona

**1. Podcaster Indie**
- Punya episode 1-2 jam yang ingin di-repurpose ke Shorts/Reels.
- Butuh subtitle akurat (bahasa Indonesia + Inggris).
- Tidak punya tim editor.
- Pain: edit manual makan 4+ jam per episode.

**2. Streamer / Gamer**
- Stream 3-6 jam, ingin ekstrak momen lucu/clutch.
- Butuh kecepatan: bisa langsung clip dari device tanpa ke laptop.
- Pain: VOD panjang, sulit cari momen bagus.

**3. Talking-head Creator (edukator, motivator)**
- Rekam panjang sekali, potong jadi banyak short.
- Butuh subtitle dengan styling menarik.
- Pain: sinkronisasi caption manual lambat.

### Secondary Persona

- Mahasiswa rekam kuliah → ringkasan visual.
- Marketer kecil yang repurpose webinar.

## Value Proposition

- **Hemat waktu**: 4 jam edit → 15 menit dengan auto-mode.
- **Berjalan di HP**: tidak perlu laptop, semua di Android.
- **AI yang berempati**: tidak memotong di tengah kalimat (sentence-boundary lock) supaya tidak salah konteks.
- **Template siap pakai**: 4 preset awal (Podcast, Gaming, Talking, Tutorial).
- **Kontrol penuh**: 3 mode (Manual, Semi-Auto, Auto AI), user bisa pilih.

## Diferensiasi vs Kompetitor

| App | Platform | AI | Local-first | Harga | Catatan |
|---|---|---|---|---|---|
| Opus Clip | Web | Yes | No | $15-29/mo | Dominan, web-only |
| Vizard | Web | Yes | No | $20+/mo | Cloud heavy |
| Submagic | Web | Yes | No | $10-25/mo | Fokus subtitle |
| CapCut | Mobile | Partial | Yes | Free + Pro | Manual editor, bukan auto-clipper |
| Klap | Web | Yes | No | $29+/mo | |
| **Langgeng Clip** | **Android** | **Yes (BYOK)** | **Yes** | **Free + Pro nanti** | **Mobile-native, BYOK gratis** |

Diferensiasi utama:
- **Mobile-first** untuk Android (semua kompetitor utama web/desktop).
- **BYOK gratis**: user pakai Groq key sendiri = unlimited tanpa langganan.
- **Render lokal**: privacy lebih baik, tidak upload video ke server kita.

## Prinsip Produk

1. **Tidak salah konteks**: clip selalu mulai di awal kalimat dan berakhir di akhir kalimat. Lebih baik clip 5 detik lebih panjang daripada misleading.
2. **Mobile-first, bukan port web**: UI dirancang khusus untuk thumb interaction.
3. **Privacy by default**: BYOK, video tidak di-upload ke server kita, transcript pun langsung dari device user ke Groq.
4. **Minimalis & tidak berisik**: tema dark/light clean, satu primary action per layar, tidak ada gradient ramai.
5. **Berjalan di mid-range device**: target Android API 26+ dengan RAM 4GB.

## Bisnis Model (Phase 2)

- **Free tier**: BYOK aktif, ada AdMob banner + rewarded ads untuk export ekstra, daily limit 3 export.
- **Pro tier (subscription Play Billing)**: tanpa iklan, unlimited export, premium templates, watermark removal.
- **Managed mode** (post V2): user tidak perlu BYOK, kita yang bayar API.

## Definisi Sukses

### MVP (3 bulan setelah mulai)
- 100 install closed beta tester.
- 80%+ tester berhasil export minimal 1 clip tanpa crash.
- Kualitas auto-highlight: 70%+ clip dianggap "usable" oleh tester (survey manual).

### V1 Launch (6 bulan)
- 1,000 install Play Store production.
- Crash-free rate >99%.
- Rating Play Store >4.0.

### V1.5 (9 bulan, monetisasi aktif)
- 5,000 install.
- 3% conversion ke Pro tier.
- Cost per acquisition < harga subscription bulan pertama.

## Out of Scope (untuk MVP & V1)

- iOS port (V2).
- Web/desktop version.
- Tim/collaboration feature.
- Custom AI training.
- Live streaming clip.
- Direct upload ke TikTok/YouTube/Instagram (user manual share).
- Cloud project sync.
