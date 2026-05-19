# 08 — Go to Market

Strategi launch, branding, monetisasi, dan komunikasi pengguna.

## Brand Identity

### Nama

**Langgeng Clip** — "langgeng" (Bahasa Jawa/Indonesia) = abadi/tahan lama. Pesan: clip yang langgeng (timeless / shareable).

### Tagline (kandidat)

- "Clip smarter, not harder."
- "Long video, short story."
- "From hours to seconds."
- "AI clipper di kantongmu."

Pilih 1 untuk listing utama, sisanya untuk variasi marketing.

### Voice & Tone

- **Friendly tapi profesional** — bukan formal kaku, bukan slang berlebihan.
- **Empowering** — fokus pada hasil yang user dapatkan, bukan teknologi.
- **Honest** — jangan over-claim akurasi AI.
- **Bahasa Indonesia** primary di pasar lokal, English untuk global.

### Logo

- Mark + wordmark.
- Mark: bentuk geometris sederhana (mis. potongan film + spark, atau "L" dengan cut).
- Wordmark: Inter Bold atau custom.
- Color: accent indigo (#6366F1) di light bg, indigo lighter di dark bg.
- Variasi:
  - Full color
  - Mono dark (untuk light bg)
  - Mono light (untuk dark bg)
  - Mark only (icon app, social profile)

### Visual Style untuk Marketing

- Konsisten dengan design system (minimalist clean).
- Banyak whitespace.
- Foto/video sample beragam (podcast, gaming, talking head).
- Tidak pakai stock photo cliche.

## Pra-Launch (3-4 minggu sebelum closed beta)

### Landing Page

URL: `langgengclip.com` (kalau available) atau GitHub Pages sementara.

Sections:
1. Hero — tagline + screenshot + CTA "Join Waitlist".
2. Problem — "Edit shorts manual makan 4 jam? Ini solusinya."
3. Features — 3-4 fitur utama dengan visual.
4. How it works — 3 step (Import → AI Clip → Export).
5. Demo video — 60 detik.
6. Pricing teaser — Free + Pro coming soon.
7. FAQ — 5-7 pertanyaan basic.
8. Footer — Privacy, Terms, Contact, Sosial.

Stack: Astro / Next.js + Tailwind, host di Vercel/Cloudflare Pages.

### Waitlist

- Form email (gratis di Tally/Formspree).
- Auto-reply: thanks + early access date.
- Goal: 200-500 signup sebelum closed beta.

### Beta Tester Recruitment

Target: 20-30 tester aktif.

Channel:
- Komunitas podcaster Indonesia (Telegram, Discord, FB Group).
- Komunitas gaming streamer.
- Komunitas content creator (YouTube, IG creator group).
- Twitter/X build-in-public.
- Reddit: r/IndonesiaBaru, r/podcasting, r/contentcreation.

Pesan rekrutmen jelas:
- Apa yang dapet (early access, free Pro saat launch).
- Apa yang diharap (feedback honest 1x/minggu, isi form).
- Durasi (4-6 minggu).

### Build in Public

- Twitter/X thread mingguan progress.
- Devlog di blog atau YouTube.
- Discord/Telegram komunitas (tunggu sampai ada 50+ waitlist).

## Launch Strategy

### Closed Beta (Phase 1 selesai)

- Distribute via Play Console closed testing track.
- Min 12 tester aktif 14 hari (Play Store requirement).
- Feedback channel: Discord + form.
- Iterate cepat: ship update mingguan.

### Open Beta (Phase 2 selesai)

- Public sign-up via Play Console open testing.
- Goal: 500-1000 install.
- Tetap free, tanpa AdMob aktif.

### Production Launch (Phase 3 selesai)

- Staged rollout 10% → 50% → 100%.
- Monitor crash rate 48 jam tiap stage.
- Press release: TechInAsia, DailySocial, blog kontributor.
- Product Hunt launch (opsional, kalau ada audience global).
- IG/TikTok video demo (10 video, 1 minggu sebelum launch).

## Monetisasi

### Free Tier

- BYOK aktif (user pakai Groq key sendiri).
- 3 export per hari (reset jam 00:00 WIB).
- Watermark "Made with Langgeng Clip" di kanan bawah, opacity 60%.
- Banner ad di Library + Home.
- Rewarded ad: tonton iklan = +1 export hari ini.
- Interstitial: max 1x per 3 menit, hanya setelah export complete.

### Pro Tier

Pricing kandidat:
- **Bulanan**: Rp 49.000 / month (~$3 USD).
- **Tahunan**: Rp 399.000 / year (~$25 USD, ~30% diskon).
- **Lifetime** (opsional, early bird launch): Rp 999.000 (~$60).

Benefit:
- Unlimited export.
- No ads.
- No watermark default.
- Premium templates (extra preset selain 4 dasar).
- Priority support.
- Free trial 7 hari.

### Pricing Strategy

- **Lebih murah dari kompetitor web** (Opus $15-29/mo, Submagic $10-25/mo).
- **Aksesibilitas Indonesia**: harga lokal yang masuk akal untuk creator pemula.
- **Lifetime offer** untuk early adopter sebagai bentuk apresiasi & funding awal.

### A/B Test Pricing (Phase 4)

- Test paywall placement (after first export vs after 3rd export).
- Test trial length (7 vs 14 hari).
- Test annual discount % (20 vs 30 vs 40).

## Marketing Channels

### Organic

- **TikTok / Reels / Shorts**: demo "before vs after" use case.
- **YouTube**: tutorial cara pakai per template (Podcast, Gaming, dll).
- **Twitter/X**: build-in-public + tip threads.
- **Instagram**: carousel feature explanation.
- **Reddit**: subreddit content creation, hindari spam.

### Komunitas

- Sponsor/kolab podcaster Indonesia kecil (gratis akses + share).
- Komunitas Discord content creator.
- Workshop/webinar gratis "Cara repurpose podcast pakai AI".

### Paid (Phase 4+)

- Google Ads search keyword "auto clip android", "podcast clipper".
- Meta Ads ke audience interested in: video editing, podcasting, content creation.
- Influencer micro (10-50k follower) dengan flat fee.

### SEO

- Landing page target keyword: "auto video clipper android", "AI subtitle Indonesia", "clip podcast otomatis".
- Blog content (post-V1):
  - "10 cara repurpose podcast jadi viral shorts"
  - "Perbandingan Langgeng Clip vs Opus Clip"
  - "Tutorial dapat Groq API key gratis"
  - "Auto subtitle Bahasa Indonesia akurat"

## Metrics Sukses GTM

### Phase 1 (Closed Beta)
- 30 tester aktif (DAU >50%).
- NPS >7.
- Crash-free rate >99%.
- 80% berhasil export 1+ clip.

### Phase 2 (Open Beta)
- 1,000 install.
- 200 DAU.
- Rating Play Store >4.0.
- 70% auto-mode "usable" rate (survey).

### Phase 3 (Production V1.5)
- 10,000 install (3 bulan post-launch).
- 1,500 DAU.
- 3% conversion ke Pro.
- ARR (Annual Recurring Revenue) trajectory positive.

### Phase 4 (V2)
- 50,000+ install.
- iOS port live.
- 5%+ conversion ke Pro.

## Customer Support

### Channel

- **Email**: support@langgengclip.com (fallback Gmail dulu).
- **Discord**: server komunitas (juga jadi feedback channel).
- **In-app feedback**: form di Settings → "Send Feedback".

### Response Time SLA

- Beta: <24 jam (komitmen pribadi).
- Production: <48 jam business day.
- Pro user: prioritas <24 jam.

### Knowledge Base

Wajib ada sebelum production launch:
1. Cara dapat Groq API key gratis.
2. Cara import dari Google Drive.
3. Kenapa render lambat? Tips optimasi.
4. Cara update API key.
5. Auto subtitle salah, gimana edit?
6. Cara cancel subscription.
7. App crash, apa yang harus dilakukan?
8. Format video apa saja yang didukung?
9. Bahasa apa saja untuk subtitle?
10. Privacy: apakah video saya di-upload ke server?

Format: artikel pendek (<500 kata), screenshot inline. Host di Notion publik atau Mintlify.

## Update & Communication Cadence

- **Patch (bug fix)**: as needed, max <1 minggu untuk crash.
- **Minor (fitur kecil)**: 2-4 minggu cycle.
- **Major (versi baru)**: 3 bulan cycle.
- **Changelog**: in-app + email subscriber + Discord announcement.
- **Roadmap**: Featurebase atau GitHub Project public.

## Risk GTM

| Risk | Mitigasi |
|---|---|
| Tidak cukup beta tester | Mulai recruit 6 minggu sebelum, expand channel |
| Crash rate tinggi saat open beta | Soft launch staged rollout 10% dulu |
| Review Play Store negatif soal AI accuracy | Disclaimer jelas, expectation setting di onboarding |
| Kompetitor (Opus, dll) launch app Android lebih dulu | Diferensiasi BYOK + privacy + harga lokal |
| Groq API harga naik / ToS berubah | Abstraksi `TranscriptionProvider`, siap swap |
| Indonesian regulator (Kominfo PSE) | Daftar kalau user >100k, pantau threshold |
