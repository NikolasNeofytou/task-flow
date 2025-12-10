# Mock Backend (Node/Express)

Paths: `backend_mock/`

Endpoints (http://localhost:4000 by default):
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

Run:
```
cd backend_mock
npm install
npm run dev   # or npm start
```

If npm throws TAR_ENTRY/EBADF errors on OneDrive/long paths, copy to a short path first:
```
$dest="C:\temp\taskflow-backend"
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Copy-Item -Recurse -Force backend_mock\* $dest
Push-Location $dest
npm install
npm run dev
Pop-Location
```

Flutter against mock backend:
```
flutter run --dart-define=API_BASE_URL=http://localhost:4000 --dart-define=USE_MOCKS=false
```

Notes:
- Data is in-memory; restart resets it.
- Logging via `morgan` is enabled.
- Update `server.js` if you need more routes or persistence.
