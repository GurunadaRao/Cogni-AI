import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_voice_recorder/core/config/app_config.dart';
import 'package:ai_voice_recorder/core/network/api_client.dart';
import 'package:ai_voice_recorder/core/network/websocket_client.dart';
import 'package:ai_voice_recorder/features/recording/data/mock_recording_service.dart';
import 'package:ai_voice_recorder/features/recording/models/recording_models.dart';
import 'package:ai_voice_recorder/features/recording/providers/recording_controller.dart';
import 'package:ai_voice_recorder/features/summary/providers/summary_controller.dart';
import 'package:ai_voice_recorder/features/chat/providers/chat_controller.dart';

void main() {
  group('Recording State Machine & Controller Unit Tests', () {
    late AppConfig appConfig;
    late MockRecordingService mockService;
    late AppWebSocketClient wsClient;
    late ApiClient apiClient;

    setUp(() {
      appConfig = const AppConfig(
        environment: AppEnvironment.development,
        apiBaseUrl: 'http://localhost:8080',
        webSocketBaseUrl: 'ws://localhost:8080',
        useMockData: true,
      );
      mockService = MockRecordingService();
      wsClient = AppWebSocketClient(wsUrl: appConfig.webSocketBaseUrl);
      apiClient = ApiClient(baseUrl: appConfig.apiBaseUrl);
    });

    tearDown(() {
      mockService.dispose();
      wsClient.dispose();
    });

    test('Initial recording state should be idle', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = RecordingController(
        appConfig: appConfig,
        apiClient: apiClient,
        wsClient: wsClient,
        mockService: mockService,
      );

      expect(controller.state.recordingState, RecordingState.idle);
      expect(controller.state.transcriptSegments, isEmpty);
    });

    test('Start recording transitions to connecting and recording', () async {
      final controller = RecordingController(
        appConfig: appConfig,
        apiClient: apiClient,
        wsClient: wsClient,
        mockService: mockService,
      );

      await controller.startRecording();

      expect(controller.state.currentSession, isNotNull);
      expect(controller.state.recordingState, RecordingState.recording);

      await Future.delayed(const Duration(milliseconds: 400));
      expect(controller.state.currentPartialText, isNotEmpty);
    });

    test('Stop recording transitions from recording to completed', () async {
      final controller = RecordingController(
        appConfig: appConfig,
        apiClient: apiClient,
        wsClient: wsClient,
        mockService: mockService,
      );

      await controller.startRecording();
      await controller.stopRecording();

      expect(controller.state.recordingState, RecordingState.completed);
    });
  });

  group('Summary & Chat Controller Unit Tests', () {
    late AppConfig appConfig;
    late MockRecordingService mockService;
    late AppWebSocketClient wsClient;
    late ApiClient apiClient;

    setUp(() {
      appConfig = const AppConfig(
        environment: AppEnvironment.development,
        apiBaseUrl: 'http://localhost:8080',
        webSocketBaseUrl: 'ws://localhost:8080',
        useMockData: true,
      );
      mockService = MockRecordingService();
      wsClient = AppWebSocketClient(wsUrl: appConfig.webSocketBaseUrl);
      apiClient = ApiClient(baseUrl: appConfig.apiBaseUrl);
    });

    tearDown(() {
      mockService.dispose();
      wsClient.dispose();
    });

    test('Summary controller streams summary deltas', () async {
      final summaryCtrl = SummaryController(
        appConfig: appConfig,
        apiClient: apiClient,
        wsClient: wsClient,
        mockService: mockService,
      );

      await summaryCtrl.generateSummary('test_session_123');
      expect(summaryCtrl.state.status, SummaryStatus.streaming);

      await Future.delayed(const Duration(milliseconds: 2500));
      expect(summaryCtrl.state.text, isNotEmpty);
    });

    test('Chat controller sends message and receives streaming AI response', () async {
      final chatCtrl = ChatController(
        sessionId: 'test_session_123',
        appConfig: appConfig,
        apiClient: apiClient,
        wsClient: wsClient,
        mockService: mockService,
      );

      await chatCtrl.sendMessage('What are the action items?');
      expect(chatCtrl.state.messages.length, equals(2));

      await Future.delayed(const Duration(milliseconds: 2200));
      final aiMessage = chatCtrl.state.messages.last;
      expect(aiMessage.isUser, isFalse);
      expect(aiMessage.text, isNotEmpty);
    });
  });
}
