import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';
import '../network/websocket_client.dart';

import '../../features/recording/data/mock_recording_service.dart';
import '../../features/recording/providers/recording_controller.dart';
import '../../features/summary/providers/summary_controller.dart';
import '../../features/chat/providers/chat_controller.dart';
import '../../features/history/data/history_repository.dart';
import '../../features/history/domain/models/history_models.dart';
import '../../features/recorder/ai/ai_service.dart';

import '../network/http_client.dart';

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnv();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(appConfigProvider);
  return ApiClient(baseUrl: config.apiBaseUrl);
});

final httpApiClientProvider = Provider<HttpApiClient>((ref) {
  final config = ref.watch(appConfigProvider);
  return HttpApiClient(baseUrl: config.apiBaseUrl);
});

final webSocketClientProvider = Provider<AppWebSocketClient>((ref) {
  final config = ref.watch(appConfigProvider);
  final client = AppWebSocketClient(wsUrl: config.webSocketBaseUrl);
  ref.onDispose(() => client.dispose());
  return client;
});

final mockRecordingServiceProvider = Provider<MockRecordingService>((ref) {
  final service = MockRecordingService();
  ref.onDispose(() => service.dispose());
  return service;
});

final recordingControllerProvider =
    StateNotifierProvider<RecordingController, RecordingStateData>((ref) {
  final config = ref.watch(appConfigProvider);
  final apiClient = ref.watch(apiClientProvider);
  final wsClient = ref.watch(webSocketClientProvider);
  final mockService = ref.watch(mockRecordingServiceProvider);

  return RecordingController(
    appConfig: config,
    apiClient: apiClient,
    wsClient: wsClient,
    mockService: config.useMockData ? mockService : null,
  );
});

final summaryControllerProvider =
    StateNotifierProvider<SummaryController, SummaryStateData>((ref) {
  final config = ref.watch(appConfigProvider);
  final apiClient = ref.watch(apiClientProvider);
  final wsClient = ref.watch(webSocketClientProvider);
  final mockService = ref.watch(mockRecordingServiceProvider);

  return SummaryController(
    appConfig: config,
    apiClient: apiClient,
    wsClient: wsClient,
    mockService: config.useMockData ? mockService : null,
  );
});

final chatControllerFamily =
    StateNotifierProvider.family<ChatController, ChatStateData, String>((ref, sessionId) {
  final config = ref.watch(appConfigProvider);
  final apiClient = ref.watch(apiClientProvider);
  final wsClient = ref.watch(webSocketClientProvider);
  final mockService = ref.watch(mockRecordingServiceProvider);

  return ChatController(
    sessionId: sessionId,
    appConfig: config,
    apiClient: apiClient,
    wsClient: wsClient,
    mockService: config.useMockData ? mockService : null,
  );
});

final historyRepositoryProvider = Provider<HistoryRepositoryImpl>((ref) {
  final httpClient = ref.watch(httpApiClientProvider);
  final config = ref.watch(appConfigProvider);
  return HistoryRepositoryImpl(httpClient: httpClient, useMock: config.useMockData);
});

final meetingsListProvider = FutureProvider<List<MeetingNote>>((ref) async {
  final repo = ref.watch(historyRepositoryProvider);
  return repo.getMeetings();
});

final selectedDeviceIdProvider = StateProvider<String>((ref) => 'ESP32-S3-Sense');
final serverConfigProvider = StateProvider<String>((ref) {
  final config = ref.watch(appConfigProvider);
  return config.apiBaseUrl;
});
final useMockDataProvider = StateProvider<bool>((ref) {
  final config = ref.watch(appConfigProvider);
  return config.useMockData;
});

final aiServiceProvider = Provider<AiServiceImpl>((ref) {
  final httpClient = ref.watch(httpApiClientProvider);
  final config = ref.watch(appConfigProvider);
  return AiServiceImpl(httpClient: httpClient, useMock: config.useMockData);
});

class CommandStateData {
  final bool relayActive;
  final double fanSpeed;
  final bool isPending;

  const CommandStateData({
    this.relayActive = false,
    this.fanSpeed = 50.0,
    this.isPending = false,
  });

  CommandStateData copyWith({
    bool? relayActive,
    double? fanSpeed,
    bool? isPending,
  }) {
    return CommandStateData(
      relayActive: relayActive ?? this.relayActive,
      fanSpeed: fanSpeed ?? this.fanSpeed,
      isPending: isPending ?? this.isPending,
    );
  }
}

class CommandController extends StateNotifier<CommandStateData> {
  CommandController() : super(const CommandStateData());

  void toggleRelay(String deviceId) {
    state = state.copyWith(relayActive: !state.relayActive);
  }

  void setFanSpeed(String deviceId, double speed) {
    state = state.copyWith(fanSpeed: speed);
  }
}

final commandControllerProvider =
    StateNotifierProvider<CommandController, CommandStateData>((ref) {
  return CommandController();
});

