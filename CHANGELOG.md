# Changelog

All notable changes to Langgeng Clip are tracked here.

This project uses a simple Keep a Changelog-style format until release automation is configured.

## [Unreleased]

### Added

- Changelog automation helper for simple Added entries.
- ID/EN localization scaffold with persisted language override.
- Repo governance templates for issues, pull requests, contribution guidance, conduct, and security reporting.
- Phase 3 first-week unlimited promo model and messaging.
- Client-side receipt validation model for Pro subscription state.
- Phase 3 performance and accessibility audit checklist.
- ADR documentation with the initial rendering architecture decision.

### Changed

- Bottom-tab back navigation now returns to Home first and requires double-back to exit.
- Release minification ignores optional Play Core deferred-component classes for APK builds.
- Release workflow now builds a signed APK and publishes it to GitHub Releases for tester installs.
- Release workflow falls back to a temporary test keystore when signing secrets are not configured, keeping APK output in release mode.
- Expanded QA run template with Phase 3 polish audit checks.
- Expanded contributor setup instructions for local Flutter development.
