# ADR 0001: Use Pigeon And Media3 For Android Rendering

## Status

Accepted

## Context

Langgeng Clip needs reliable Android video operations for trim, crop, scale, overlays, progress updates, cancellation, and saving completed exports. Flutter handles UI and orchestration well, but heavy media transforms should use Android native APIs for hardware acceleration and foreground-service behavior.

The project also needs a stable bridge between Dart and Kotlin. Plain `MethodChannel` calls are flexible, but string-based method names and untyped payloads make render pipeline changes easy to break.

## Decision

Use Pigeon as the typed bridge between Flutter and Android native rendering code.

Use Media3 Transformer as the primary Android render engine for standard exports:

- Trim ranges.
- Center crop / 9:16 transform.
- Scale to target resolution.
- H.264 encode.
- Subtitle and watermark overlays.
- Progress and cancellation through native render orchestration.

Keep FFmpeg-style tooling as a fallback only for cases where Media3 cannot cover the required operation cleanly.

## Consequences

Benefits:

- Compile-time checked bridge types reduce Dart/Kotlin contract drift.
- Media3 uses Android-native media components and hardware acceleration where available.
- Long-running export can integrate with Android foreground-service and notification behavior.
- Render options stay explicit in the Pigeon API instead of ad-hoc maps.

Tradeoffs:

- Pigeon generated files must be regenerated whenever bridge specs change.
- Media3 behavior can vary by Android version, codec, and device vendor.
- Some advanced filters may still require fallback implementation.

## Follow-Ups

- Keep render API changes small and covered by Dart tests where possible.
- Add QA coverage for rotated metadata, VFR files, large files, and cancellation.
- Record future render fallback decisions in separate ADRs if they affect shipped behavior.
