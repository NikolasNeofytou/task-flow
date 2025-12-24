/// API configuration
class ApiConfig {
  ApiConfig._();

  // TODO: Move to .env file for different environments
  static const String baseUrl = 'http://localhost:3000';
  
  // Use mock data instead of real API (for development)
  static const bool useMocks = true;
  
  // API version
  static const String apiVersion = 'v1';
  
  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Endpoints
  static const String authEndpoint = '/api/auth';
  static const String requestsEndpoint = '/api/requests';
  static const String notificationsEndpoint = '/api/notifications';
  static const String projectsEndpoint = '/api/projects';
  static const String tasksEndpoint = '/api/tasks';
  static const String commentsEndpoint = '/api/comments';
  static const String usersEndpoint = '/api/users';
  static const String teamsEndpoint = '/api/teams';
  static const String invitesEndpoint = '/api/invites';
}
