class AppConfig {
  const AppConfig({required this.environment, required this.apiUrl});

  final String environment;
  final String apiUrl;

  factory AppConfig.fromEnvironment() => const AppConfig(
        environment: String.fromEnvironment('APP_ENV', defaultValue: 'development'),
        apiUrl: String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8000/api/v1'),
      );
}

