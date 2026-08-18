import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/websocket_client.dart';
import '../../recording/data/mock_recording_service.dart';

enum SummaryStatus { idle, loading, streaming, completed, error }

class SummaryStateData {
  final SummaryStatus status;
  final String text;
  final String? errorMessage;

  const SummaryStateData({
    required this.status,
    this.text = '',
    this.errorMessage,
  });

  SummaryStateData copyWith({
    SummaryStatus? status,
    String? text,
    String? errorMessage,
  }) {
    return SummaryStateData(
      status: status ?? this.status,
      text: text ?? this.text,
      errorMessage: errorMessage,
    );
  }
}

class SummaryController extends StateNotifier<SummaryStateData> {
  final AppConfig appConfig;
  final ApiClient apiClient;
  final AppWebSocketClient wsClient;
  final MockRecordingService? mockService;
  StreamSubscription? _wsSubscription;

  SummaryController({
    required this.appConfig,
    required this.apiClient,
    required this.wsClient,
    this.mockService,
  }) : super(const SummaryStateData(status: SummaryStatus.idle));

  Future<void> generateSummary(String sessionId) async {
    state = state.copyWith(status: SummaryStatus.loading, text: '', errorMessage: null);

    try {
      if (appConfig.useMockData && mockService != null) {
        state = state.copyWith(status: SummaryStatus.streaming);
        _listenToMockWs(sessionId);
        mockService!.simulateSummaryStream(sessionId);
      } else {
        await apiClient.post('/sessions/$sessionId/summarize');
        state = state.copyWith(status: SummaryStatus.streaming);
        _listenToWs(sessionId);
      }
    } catch (e) {
      state = state.copyWith(
        status: SummaryStatus.error,
        errorMessage: 'Failed to request summary: $e',
      );
    }
  }

  void _listenToMockWs(String sessionId) {
    _wsSubscription?.cancel();
    _wsSubscription = mockService?.mockWsStream.listen((json) => _handleWsEvent(json, sessionId));
  }

  void _listenToWs(String sessionId) {
    _wsSubscription?.cancel();
    _wsSubscription = wsClient.messageStream.listen((json) => _handleWsEvent(json, sessionId));
  }

  void _handleWsEvent(Map<String, dynamic> json, String targetSessionId) {
    final type = json['type'] as String? ?? '';
    final sessionId = json['sessionId'] as String? ?? '';

    if (sessionId.isNotEmpty && sessionId != targetSessionId) return;

    switch (type) {
      case 'summary.started':
        state = state.copyWith(status: SummaryStatus.streaming);
        break;
      case 'summary.delta':
        final deltaText = json['text'] as String? ?? '';
        state = state.copyWith(text: deltaText);
        break;
      case 'summary.completed':
        state = state.copyWith(status: SummaryStatus.completed);
        break;
      case 'error':
        final msg = json['message'] as String? ?? 'Error generating summary';
        state = state.copyWith(status: SummaryStatus.error, errorMessage: msg);
        break;
    }
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    super.dispose();
  }
}
