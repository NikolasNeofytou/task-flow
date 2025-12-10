# API Configuration

The app reads its API settings from compile-time environment variables:

- `API_BASE_URL` (string): Base URL for the backend, e.g. `https://api.yourdomain.com`.
- `USE_MOCKS` (bool as string: `true`/`false`): Toggle between mock repositories and real network repositories.

Defaults:
- `API_BASE_URL`: `https://api.example.com`
- `USE_MOCKS`: `true` (keeps the app offline-friendly until the backend is ready).

Examples:
- Run with real API and a base URL:
  ```
  flutter run --dart-define=API_BASE_URL=https://api.yourdomain.com --dart-define=USE_MOCKS=false
  ```
- Keep mocks:
  ```
  flutter run --dart-define=USE_MOCKS=true
  ```

Current mock backend (Node in `backend_mock/server.js`) endpoints:
- Requests:
  - GET `/requests`
  - POST `/requests` body `{ title, dueDate? }`
  - PATCH `/requests/{id}` body `{ status }`
- Notifications:
  - GET `/notifications`
- Projects:
  - GET `/projects`
  - GET `/projects/{id}/tasks`
- Calendar:
  - GET `/calendar/tasks`

Start mock backend:
```
cd backend_mock
npm install
npm run dev   # defaults to http://localhost:4000
```

Run Flutter against it:
```
flutter run --dart-define=API_BASE_URL=http://localhost:4000 --dart-define=USE_MOCKS=false
```

Update endpoints/DTOs if your real backend differs. Ensure auth token retrieval is wired (see `auth_token_provider.dart` and `dioProvider`).
