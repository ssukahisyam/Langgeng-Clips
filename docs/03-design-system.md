# 03 — Design System

Tema: **minimalist clean**, **dual theme dark/light**, ringan secara visual. Whitespace lega, sedikit border, tipografi sebagai hierarki utama.

## Color Tokens

### Light Theme

| Token | Hex | Pemakaian |
|---|---|---|
| Background | `#FAFAFA` | Canvas utama |
| Surface | `#FFFFFF` | Card, sheet |
| Surface Variant | `#F4F4F5` | Input, chip background |
| Border | `#E5E5E5` | Divider tipis 1px |
| Text Primary | `#0A0A0A` | Heading, body utama |
| Text Secondary | `#71717A` | Helper, meta |
| Text Tertiary | `#A1A1AA` | Placeholder, hint |
| Accent (Primary) | `#6366F1` | CTA, link, focus |
| Accent Soft | `#EEF2FF` | Background highlight |
| Success | `#10B981` | Confirm, complete |
| Warning | `#F59E0B` | Caution, low quota |
| Error | `#EF4444` | Validation fail, destructive |

### Dark Theme

| Token | Hex | Pemakaian |
|---|---|---|
| Background | `#0A0A0A` | Canvas utama (hemat OLED) |
| Surface | `#141414` | Card, sheet |
| Surface Variant | `#1F1F1F` | Input, chip background |
| Border | `#262626` | Divider tipis 1px |
| Text Primary | `#FAFAFA` | Heading, body utama |
| Text Secondary | `#A1A1AA` | Helper, meta |
| Text Tertiary | `#52525B` | Placeholder, hint |
| Accent (Primary) | `#818CF8` | CTA, link, focus |
| Accent Soft | `#1E1B4B` | Background highlight |
| Success | `#34D399` | Confirm |
| Warning | `#FBBF24` | Caution |
| Error | `#F87171` | Validation fail |

Aksen tunggal (indigo). Tidak ada gradient ramai. Status warna hanya muncul kontekstual (toast, badge, progress).

## Tipografi

Font:
- **Inter** untuk semua UI text.
- **JetBrains Mono** untuk timestamp (`00:01:23.456`) dan duration.

| Style | Size/Line | Weight | Letter | Pemakaian |
|---|---|---|---|---|
| Display | 28/34 | 700 | -0.5px | Judul page besar |
| Title | 20/28 | 600 | -0.2px | Heading section |
| Body L | 16/24 | 500 | 0 | CTA, label penting |
| Body M | 14/20 | 400 | 0 | Default text |
| Body S | 12/16 | 400 | 0 | Helper, caption |
| Mono | 13/16 | 500 | 0 | Timestamp, duration |

## Spacing

```
4 / 8 / 12 / 16 / 20 / 24 / 32 / 48
```

- Padding default screen: **16px** horizontal, **20px** vertikal.
- Gap antar section: **24px** atau **32px**.
- Gap antar item dalam list: **8px** atau **12px**.

## Radius

| Token | Value | Pemakaian |
|---|---|---|
| sm | 8 | Chip, badge |
| md | 12 | Button, input |
| lg | 16 | Card, panel |
| xl | 24 | Bottom sheet |
| pill | 9999 | Tag, filter chip |

## Elevation

- Light theme: shadow tipis hanya di bottom sheet (`0 -2 8 rgba(0,0,0,0.04)`).
- Dark theme: tanpa shadow, gunakan border atau surface variant untuk separasi.
- **Border 1px** lebih disukai daripada drop shadow untuk look minimalis.

## Iconography

- **Lucide icons** — stroke 1.5px, ukuran 20px (dense) atau 24px (default).
- Tidak pakai filled icon kecuali untuk state aktif (mis. play button).
- Custom icon harus ikut sistem stroke 1.5px.

## Motion

- **Micro interaction**: 150ms (button press, toggle).
- **Page transition**: 250ms easeOutCubic.
- **Bottom sheet**: 300ms with 0.95 → 1 scale.
- **Skeleton shimmer**: 1500ms loop.
- Hindari bounce / spring berlebihan.
- Honor `MediaQuery.disableAnimations` (reduce motion).

## Komponen Inti

### Button

| Variant | Background | Text | Border | Tinggi | Radius |
|---|---|---|---|---|---|
| Filled | accent | white/dark | none | 44 | 12 |
| Tonal | surface variant | text primary | none | 44 | 12 |
| Outline | transparent | text primary | 1px border | 44 | 12 |
| Text | transparent | accent | none | 36 | 8 |
| Destructive | error | white | none | 44 | 12 |

State: hover (+5% lightness), pressed (-5% lightness), disabled (40% opacity).

### Input (TextField)

- Outline 1px border, focus ring 2px accent-soft.
- Tinggi 48px, padding horizontal 16px, radius 12.
- Helper text 12px di bawah, error state warna error + border error.

### Card

- Surface, radius 16, padding 16.
- Optional border 1px untuk separasi tanpa shadow.
- Hover state (mouse): slight surface variant (web preview, opsional).

### Chip

- Pill shape, padding 8 vertikal / 12 horizontal.
- Filter chip: tonal saat unselected, accent soft + accent text saat selected.
- Tag chip: surface variant, text secondary.

### Bottom Sheet

- Drag handle 36×4 dengan radius pill, color text tertiary.
- Max-height 90%.
- Radius 24 di top corner.
- Backdrop overlay `rgba(0,0,0,0.4)`.

### Snackbar

- Surface variant background.
- Single line text, max 2 line wrap.
- Optional action button (text variant accent).
- Auto-dismiss 4 detik (8 detik kalau ada action).

### Empty State

- Icon outline 48px, color text tertiary.
- Title (Body L, text primary).
- Helper 1 kalimat (Body M, text secondary).
- CTA tonal (opsional).
- Padding 48px vertikal, center align.

### Progress

- Linear: tinggi 4px, radius pill, accent fill di surface variant track.
- Circular: stroke 3px, ukuran 24/40/56.
- Determinate untuk render/transcribe (ada percentage), indeterminate untuk validate API key.

## Layout Prinsip

- **Bottom navigation 3-tab**: Home, Library, Settings. Tinggi 64px, ikon 24px + label 12px.
- **Safe area** dijaga, padding minimum 16px horizontal.
- **List density**: 1 item utama per layar fokus, bukan grid padat.
- **One primary action** per layar (FAB atau bottom-anchored button).
- **Top bar**: tinggi 56px, title left-align (Title style), action icon right.

## Accessibility

- Kontras AA minimum di kedua tema. Aksen indigo lulus AA di putih dan hitam.
- Touch target minimum 44×44px (timeline handle 48px untuk presisi).
- Semantic label untuk semua icon-only button.
- `MediaQuery.textScaleFactor` di-honor — UI scale up sampai 200%.
- Dynamic type test wajib di QA.
- Reduce motion: matikan transisi page kalau OS request.

## Haptic Feedback

| Action | Feedback |
|---|---|
| Split clip | Selection (light) |
| Snap to keyframe | Selection (light) |
| Toggle major mode | Light impact |
| Export complete | Success notification |
| Validation error | Error pattern |

## Token Mapping ke Flutter

```dart
// Akan diimplementasikan di lib/app/theme/
abstract class AppColors {
  Color get background;
  Color get surface;
  Color get surfaceVariant;
  Color get border;
  Color get textPrimary;
  Color get textSecondary;
  Color get textTertiary;
  Color get accent;
  Color get accentSoft;
  Color get success;
  Color get warning;
  Color get error;
}

class LightColors implements AppColors { ... }
class DarkColors implements AppColors { ... }
```

Theme provider via Riverpod, persisted di SharedPreferences (`system` / `light` / `dark`).

## Naming Convention Asset

```
assets/
  icons/             # custom svg, lucide-style
    icon-name.svg
  illustrations/     # onboarding, empty state
    illu-empty-library.svg
  lottie/
    transcribe.json
  fonts/
    Inter/Inter-Regular.ttf
    JetBrainsMono/JetBrainsMono-Regular.ttf
```

## Visual Reference

- Linear (clean list, density)
- Things 3 (whitespace, tipografi)
- Arc browser settings (form layout)
- Raycast (command palette feel, kalau implement search global Phase 2)

## Out of Scope (untuk MVP)

- Custom theme color picker.
- Animated icons di nav bar.
- Material You dynamic color.
- Tablet-specific layout (gunakan stretched mobile dulu).
