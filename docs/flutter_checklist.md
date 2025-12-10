# Flutter App Progress Checklist (Taskflow)

## Overall Status
- [x] Project scaffolded with Flutter 3.24, go_router, Riverpod, dio, secure storage, intl, freezed toolchain.
- [x] Design tokens and light theme (colors, spacing, radii, typography, shadows) wired with Inter.
- [x] Navigation shell with bottom tabs (Requests, Notifications, Calendar, Projects, Profile).
- [x] Feature screens with mock data + loading/empty/error via Riverpod (requests, notifications, calendar, projects).
- [x] Project detail route with task list and task create/edit form.
- [x] Request detail + send modal; notification detail; invite dialog (QR/link placeholder); chat stub route.
- [x] Shared UI components started (AppCard, AppPill, AppState) and screens refactored to use them.
- [x] Added AppBadge, AppAvatar and widget tests for design-system components.
- [x] Added data layer scaffolding: config, Dio client, repository interfaces, mock repository providers.
- [x] Tests and analyze passing (`flutter analyze`, `flutter test`).
- [x] Added analytics service (console), wired request accept/reject/send and chat send events; request modal calls controller.
- [x] Environment-configurable API settings (`API_BASE_URL`, `USE_MOCKS`) documented in `docs/api_config.md`.
- [ ] Extract shared UI components (cards, tags, pills) into design-system folder + widget/golden tests.
  - Progress: base components added; widget tests in place; more components and goldens still pending.
- [ ] Implement real data layer (dio interceptors, secure storage for tokens), API contracts, and offline states.
- [ ] Flesh out chat/send behavior and invite QR/link (clipboard/QR gen), accept/decline actions.
- [ ] Add accessibility labels, analytics event map, and release checklist.
  - Progress: semantics labels added to request actions; console analytics logging in place.

## Remaining Milestones
- Data/Networking
  - [ ] API client with interceptors (auth, logging, retry/backoff).
  - [ ] Env/secrets handling and mock/server toggle.
  - [x] Repository layer with DTOs/models and error handling.
- UI/UX Polish
  - [ ] Empty/error/loading visuals aligned to Figma.
  - [ ] Shared component library extraction and usage across screens.
  - [ ] Golden tests for key states (requests, notifications, calendar, project detail).
  - [ ] Accessibility: semantics, focus order, large text support.
- Features
  - [x] Requests: accept/decline flows, history, filters.
  - [ ] Notifications: deep links to context, mark read/all.
  - [ ] Calendar: real date picker integration and schedule interactions.
  - [x] Projects/Tasks: CRUD with validation, status transitions, task detail.
  - [x] **Task Comments**: View and add comments on tasks (Axis 1 - Collaborative Computing).
  - [ ] Invites: QR/link generation, copy/clipboard success/fail states.
  - [ ] Chat: send/receive with async state, typing indicators (if available).
- Mobile-Specific (Axis 2 & 3)
  - [ ] **Haptics**: Vibration feedback for key actions (Axis 2 - Device Interaction).
  - [ ] **Sound Effects**: Audio feedback for user actions (Axis 2 - Device Interaction).
  - [ ] **Camera/QR**: QR code scanning and generation for invites (Axis 2 - Device Interaction).
  - [ ] **Deep Links**: Handle invite links and navigation (Axis 3 - Connectivity).
- Ops/Quality
  - [ ] Analytics event taxonomy; error reporting (Sentry/Crashlytics).
  - [ ] CI: add workflows for analyze/test/build; cache pub.
  - [ ] Release checklist and store asset stubs.
