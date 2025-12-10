/// API Configuration
class ApiConfig {
  /// Base URL for the backend API
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:4000',
  );

  /// Whether to use mock data instead of real API
  static const bool useMocks = bool.fromEnvironment(
    'USE_MOCKS',
    defaultValue: true,
  );

  /// Request timeout duration
  static const Duration timeout = Duration(seconds: 30);

  /// API endpoints
  static const String requestsEndpoint = '/requests';
  static const String notificationsEndpoint = '/notifications';
  static const String projectsEndpoint = '/projects';
  static const String calendarEndpoint = '/calendar/tasks';
  static const String inviteEndpoint = '/invite';
}
