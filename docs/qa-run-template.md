# QA Run Template

Use one copy of this template per release candidate. Keep raw test videos outside the repository.

## Release Candidate

| Field | Value |
|---|---|
| Version name |  |
| Version code |  |
| Git commit |  |
| Build artifact |  |
| Tester |  |
| Date |  |

## Device Matrix

| Tier | Device | Android API | RAM | Vendor skin | Result | Notes |
|---|---|---:|---:|---|---|---|
| Low |  |  |  |  | Not run |  |
| Mid |  |  |  |  | Not run |  |
| Mid |  |  |  |  | Not run |  |
| High |  |  |  |  | Not run |  |
| High alt |  |  |  |  | Not run |  |

Allowed result values: `Pass`, `Fail`, `Blocked`, `Not run`.

## Test Assets

| Asset ID | Source device/tool | Duration | Resolution | Codec | FPS behavior | Size | Notes |
|---|---|---:|---|---|---|---:|---|
| A1 |  |  |  |  | CFR |  | Happy path trim |
| A2 |  |  |  |  | CFR |  | Landscape re-encode |
| A3 |  |  |  |  | CFR |  | Rotated metadata |
| A4 |  |  |  |  | VFR |  | Screen recording / OBS |
| A5 |  |  |  |  | CFR/VFR | >2 GB | Large file |

## Scenario Results

| Scenario | Asset | Device tier(s) | Expected result | Result | Evidence | Notes |
|---|---|---|---|---|---|---|
| Happy path trim | A1 | All | Export completes and appears in Library | Not run |  |  |
| Media3 re-encode | A2 | Mid, High | Output is 9:16, selected resolution, H.264 encoded | Not run |  |  |
| Rotated metadata | A3 | All | UI treats display size as portrait | Not run |  |  |
| VFR input | A4 | Mid, High | Export completes without obvious audio drift | Not run |  |  |
| Storage pressure | A1 | Low | Readable error, no crash | Not run |  |  |
| Large file | A5 | Mid, High | Succeeds or fails with readable error | Not run |  |  |
| Cancel export | A2 | All | Export stops and no Library item is created | Not run |  |  |
| Share export | A1 | All | Android share sheet opens with video URI | Not run |  |  |

## Crash And Error Review

| Source | Check | Result | Notes |
|---|---|---|---|
| Sentry | No new crash groups from QA run | Not run |  |
| Device logs | No native fatal exception during export | Not run |  |
| App UI | All errors are user-readable | Not run |  |

## Sign-Off

| Gate | Result | Owner | Notes |
|---|---|---|---|
| CI pass | Not run |  |  |
| 5-device QA pass | Not run |  |  |
| Storage edge cases pass | Not run |  |  |
| VFR/rotated metadata pass | Not run |  |  |
| Release AAB available | Not run |  |  |

## Open Issues

| ID | Severity | Device | Scenario | Description | Owner | Status |
|---|---|---|---|---|---|---|
|  |  |  |  |  |  |  |
