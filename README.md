# Taskflow (Flutter + Mock Backend)

Figma-inspired task manager with requests, notifications, calendar, projects, chat, and profile screens. Built with Flutter, Riverpod, go_router, and a lightweight Node/Express mock backend.

## Documentation
- Course-only docs index: `docs/course_docs/README.md`
- App setup: `docs/api_config.md`, `docs/backend_mock.md`
- Design tokens/checklists: `docs/design-tokens.md`, `docs/flutter_checklist.md`
- Release + progress: `docs/release_checklist.md`, `docs/progress.md`
- **Project plan:** `docs/project_plan.md` - Phased implementation roadmap
- Features:
  - `docs/comments_system.md` - Task comments implementation (Axis 1)

## Prerequisites
- Flutter 3.24+ (add `flutter` to PATH)
- Node.js 18+ (for the mock backend)

## Run the mock backend
```
cd backend_mock
npm install        # first run
npm run dev
```
If OneDrive/long paths cause npm tar errors, copy the folder to a short path first:
```
set dest=C:\temp\taskflow-backend
mkdir %dest% && xcopy /E /I backend_mock %dest%
cd %dest% && npm install && npm run dev
```

## Run the Flutter app
```
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:4000 --dart-define=USE_MOCKS=false
```
- Set `USE_MOCKS=true` to use in-app fake data without the backend.
- Update `API_BASE_URL` to point at a real server when ready.

## Tests and goldens
```
flutter analyze
flutter test
# Update goldens after intentional UI changes:
flutter test --update-goldens test/golden_screens_test.dart
```

## Project docs
- `docs/backend_mock.md` – endpoints and run notes
- `docs/api_config.md` – API base URL + mock toggles
- `docs/flutter_checklist.md` – day-to-day dev checklist
- `docs/progress.md` – status log
- `docs/release_checklist.md` – ship checklist
