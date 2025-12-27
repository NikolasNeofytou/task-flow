/// Environment configuration
enum Environment {
  development,
  staging,
  production,
}

/// API Configuration with environment support
class ApiConfig {
  /// Current environment
  static Environment get environment {
    const envString =
        String.fromEnvironment('ENV', defaultValue: 'development');
    switch (envString.toLowerCase()) {
      case 'production':
      case 'prod':
        return Environment.production;
      case 'staging':
      case 'stage':
        return Environment.staging;
      default:
        return Environment.development;
    }
  }

  /// Base URL for the backend API based on environment
  static String get baseUrl {
    const customUrl = String.fromEnvironment('API_BASE_URL');
    if (customUrl.isNotEmpty) return customUrl;

    switch (environment) {
      case Environment.production:
        return 'https://api.taskflow.app';
      case Environment.staging:
        return 'https://staging-api.taskflow.app';
      case Environment.development:
        return 'http://localhost:3000';
    }
  }

  /// Whether to use mock data instead of real API
  static const bool useMocks = bool.fromEnvironment(
    'USE_MOCKS',
    defaultValue: false,
  );

  /// Enable debug logging
  static bool get enableLogging {
    const customValue = bool.fromEnvironment('ENABLE_LOGGING');
    return customValue || environment != Environment.production;
  }

  /// Request timeout duration
  static const Duration timeout = Duration(seconds: 30);

  /// API Version
  static const String apiVersion = 'v1';

  /// Full API base path
  static String get apiBasePath => '$baseUrl/api';

  /// API endpoints
  static const String authEndpoint = '/auth';
  static const String requestsEndpoint = '/requests';
  static const String notificationsEndpoint = '/notifications';
  static const String projectsEndpoint = '/projects';
  static const String tasksEndpoint = '/tasks';
  static const String usersEndpoint = '/users';
  static const String chatEndpoint = '/chat';
  static const String commentsEndpoint = '/comments';
  static const String calendarEndpoint = '/calendar/tasks';
  static const String inviteEndpoint = '/invite';

  /// Feature flags
  static const bool enablePushNotifications = bool.fromEnvironment(
    'ENABLE_PUSH',
    defaultValue: true,
  );

  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: true,
  );

  static const bool enableCrashReporting = bool.fromEnvironment(
    'ENABLE_CRASH_REPORTING',
    defaultValue: true,
  );

  /// App Configuration
  static const String appName = 'TaskFlow';
  static const String appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );
  static const String buildNumber = String.fromEnvironment(
    'BUILD_NUMBER',
    defaultValue: '1',
  );

  /// Print current configuration
  static void printConfig() {
    print('🚀 TaskFlow Configuration');
    print('   Environment: ${environment.name}');
    print('   API Base URL: $baseUrl');
    print('   Use Mocks: $useMocks');
    print('   Logging: $enableLogging');
    print('   Version: $appVersion ($buildNumber)');
    print('   Push Notifications: $enablePushNotifications');
    print('   Analytics: $enableAnalytics');
  }
}
