# Phase 3 Polish Audit

Use this checklist for V1.5 polish work that can be validated locally before Play Console production rollout.

## Performance Audit

Target scenarios:

| Area | Scenario | Pass criteria | Evidence |
|---|---|---|---|
| Memory | Import 10-20 minute 1080p MP4, open editor, scrub timeline for 2 minutes | No app kill, no visible memory warning, no repeated GC jank | Android Studio profiler screenshot or notes |
| Frame drops | Scrub editor timeline, drag clip handles, open caption preview | UI remains responsive; visible jank is rare and not sustained | Flutter performance overlay screenshot or notes |
| Render speed | Export 30s 9:16 720p H.264 clip | Export completes; duration and output size are recorded | QA run timing |
| Render cancel | Cancel export at 25-75% progress | Foreground work stops, UI exits progress, no corrupt Library item | Screen recording or notes |
| Large media | Import and attempt export from >2 GB file | Success or readable error; no crash | QA run notes |

Recommended local commands:

```sh
flutter analyze
flutter test
flutter run --profile
```

Optional profiler checks:

- Flutter DevTools frame chart during timeline scrub.
- Android Studio Memory Profiler during import and export.
- Device `adb logcat` scan for fatal exceptions and Media3 errors.

## Accessibility Audit

Target screens:

| Screen | Checks |
|---|---|
| Home | Main CTA reachable with TalkBack; pricing promo text is readable |
| Import sheet | File import action has clear label and focus order |
| Project setup | Mode selector, template dropdown, and duration controls are reachable |
| Editor | Transport controls and timeline actions have accessible labels |
| Caption editor | Editable words, style controls, and preview are navigable |
| Export sheet | Resolution/FPS/codec choices are reachable and announced |
| Library | Search, filter chips, project actions, and share/delete actions are reachable |
| Settings | API key, pricing, help, feedback, privacy, and terms links are reachable |

Pass criteria:

- TalkBack can complete import -> edit -> export happy path without hidden blockers.
- Text remains usable at Android display/font size 200%.
- Interactive controls have meaningful text labels or semantics.
- Color is not the only indicator for selected/locked/error states.
- Touch targets are visually and practically large enough for common Android devices.

Record issues in `docs/qa-run-template.md` under Open Issues with severity and screen.
