import '../constants/api_constants.dart';

enum AppEnvironment {
  development,
  staging,
  production,
}

class AppConfig {
  final AppEnvironment environment;
  final String apiBaseUrl;
  final String webSocketBaseUrl;
  final bool useMockData;

  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.webSocketBaseUrl,
    this.useMockData = false,
  });

  factory AppConfig.fromEnv() {
    const envString = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
    const apiBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: ApiConstants.defaultHost,
    );
    const webSocketBaseUrl = String.fromEnvironment(
      'WEBSOCKET_BASE_URL',
      defaultValue: ApiConstants.wsDefaultHost,
    );
    const useMock = bool.fromEnvironment('USE_MOCK', defaultValue: false);

    AppEnvironment env;
    switch (envString.toLowerCase()) {
      case 'production':
      case 'prod':
        env = AppEnvironment.production;
        break;
      case 'staging':
        env = AppEnvironment.staging;
        break;
      default:
        env = AppEnvironment.development;
    }

    return AppConfig(
      environment: env,
      apiBaseUrl: apiBaseUrl,
      webSocketBaseUrl: webSocketBaseUrl,
      useMockData: useMock,
    );
  }

  AppConfig copyWith({
    AppEnvironment? environment,
    String? apiBaseUrl,
    String? webSocketBaseUrl,
    bool? useMockData,
  }) {
    return AppConfig(
      environment: environment ?? this.environment,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      webSocketBaseUrl: webSocketBaseUrl ?? this.webSocketBaseUrl,
      useMockData: useMockData ?? this.useMockData,
    );
  }
}
