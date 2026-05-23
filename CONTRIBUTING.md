# Contributing

Langgeng Clip is currently a private development project. Contributions should stay focused on the product roadmap in `CHECKLIST.md` and the planning docs under `docs/`.

## Workflow

1. Create a branch from `main` for each focused change.
2. Keep pull requests small and tied to one checklist item or bug.
3. Update tests and documentation when behavior changes.
4. Do not commit secrets, API keys, keystores, or generated build outputs.

## Local Setup

Requirements:

- Flutter 3.x with Dart 3.x.
- Android Studio or Android SDK command-line tools.
- Android API level matching the project Gradle config.
- A local Android emulator or physical Android device.

Initial setup:

```sh
flutter pub get
flutter doctor
```

Run the app locally:

```sh
flutter run
```

Generate Pigeon bindings after changing files under `pigeons/`:

```sh
dart run pigeon --input pigeons/render_api.dart
```

Release signing files such as `android/key.properties` and keystores must stay local or in secure CI secrets. Never commit them.

## Local Checks

Run these before opening a pull request when possible:

```sh
flutter analyze
flutter test
```

## Code Style

- Follow `analysis_options.yaml` and Flutter lint recommendations.
- Prefer small, readable Dart classes and functions.
- Keep platform-specific Android code isolated behind Pigeon or feature adapters.
- Document non-obvious privacy, storage, rendering, or API-key decisions.
