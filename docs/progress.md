# Project Progress (Flutter Scaffold)

## Completed
- Scaffolded Flutter app (`taskflow`) with `MaterialApp.router`, go_router shell, and bottom navigation tabs (Requests, Notifications, Calendar, Projects, Profile).
- Added design system tokens (colors, spacing, radii, shadows, typography) and wired a light theme with Inter via `google_fonts`.
- Implemented feature screens reflecting the Figma flows with Riverpod-backed mock data and states (loading/empty/error).
- Set up core dependencies: riverpod, go_router, dio, secure storage, intl, freezed/json tooling, google_fonts.
- CI sanity: `flutter analyze` and `flutter test` pass locally.
- Added domain models and mock providers; project detail screen with task list; task form (create/edit) routes and navigation from projects.
- Added request/notification detail routes, request send modal, invite dialog (QR/link), and chat stub route.
- **Task Comments System** - Full collaborative commenting on tasks (Axis 1 requirement):
  - Comment model and DTOs with JSON serialization
  - Repository layer with mock and remote implementations
  - Riverpod state management with optimistic updates
  - Enhanced task detail screen with comments list and input
  - Backend endpoints for GET/POST comments
  - Time-ago formatting, empty states, error handling
- **Calendar Enhancements** - Quick task creation and multiple view modes:
  - **Quick Task Creation FAB**: Floating action button on calendar screen opens project selection dialog with status-based color coding, navigates to task creation form with project ID pre-filled
  - **Multiple View Modes**: Month (existing grid), Week (7-day horizontal layout with task count badges), Day (detailed single-day view with large header)
  - View mode toggle with segmented control styling and smooth transitions
  - Task count indicators on week and day views
  - Maintains selected date across view mode changes
  - Empty states for all view modes
  - Technical: `CalendarViewMode` enum, `_ViewModeButton`/`_WeekView`/`_DayView` widgets, Riverpod integration for project loading

## Next Up

- Start extracting shared UI components (cards, tags, pills) into a design-system folder and add widget/golden tests.
- Wire data layer (dio + interceptors) and analytics hooks; expand tests and accessibility labels.
- Implement remaining Axis 2 features: haptics, sound feedback, camera/QR functionality.
- Implement Axis 3 features: deep-link handling for invites.

