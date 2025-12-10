# Release Checklist

- **Versions**: Update `pubspec.yaml` version and changelog; tag matches build.
- **Backend**: Confirm mock backend or real endpoints are reachable; bump `API_BASE_URL`/`USE_MOCKS` in `.env` or launch config.
- **Assets**: Run `flutter pub get` and verify fonts/images load offline; remove stray test assets.
- **Quality gates**: `flutter analyze`, `flutter test` (goldens up to date), CI green.
- **Goldens**: If UI changed intentionally, regenerate with `flutter test --update-goldens test/golden_screens_test.dart`.
- **Accessibility**: Spot-check semantics labels on primary flows (requests, notifications, projects, calendar).
- **Builds**: `flutter build apk` (or ipa/web/desktop as needed); smoke-test navigation and API calls against the target backend.
- **Docs**: README reflects current setup; `docs/backend_mock.md` and `docs/api_config.md` match the deployed base URL.
