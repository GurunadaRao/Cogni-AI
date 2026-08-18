import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/websocket_client.dart';
import '../data/mock_recording_service.dart';
import '../models/recording_models.dart';
import '../../recorder/domain/models/recording_models.dart' show AiMeetingSummary;

class RecordingStateData {
  final RecordingState recordingState;
  final RecordingSession? currentSession;
  final List<TranscriptSegment> transcriptSegments;
  final String currentPartialText;
  final WsConnectionState connectionState;
  final String? errorMessage;
  final Duration elapsedDuration;
  final int sessionCounter;
  final String defaultSessionName;

  const RecordingStateData({
    required this.recordingState,
    this.currentSession,
    this.transcriptSegments = const [],
    this.currentPartialText = '',
    this.connectionState = WsConnectionState.disconnected,
    this.errorMessage,
    this.elapsedDuration = Duration.zero,
    this.sessionCounter = 1,
    this.defaultSessionName = 'Session 1',
  });

  String get liveTranscript {
    final finalTexts = transcriptSegments.map((s) => s.text).join(' ');
    if (currentPartialText.isNotEmpty) {
      return '$finalTexts $currentPartialText'.trim();
    }
    return finalTexts;
  }

  AiMeetingSummary? get aiSummary => null;

  RecordingStateData copyWith({
    RecordingState? recordingState,
    RecordingSession? currentSession,
    List<TranscriptSegment>? transcriptSegments,
    String? currentPartialText,
    WsConnectionState? connectionState,
    String? errorMessage,
    Duration? elapsedDuration,
    int? sessionCounter,
    String? defaultSessionName,
  }) {
    return RecordingStateData(
      recordingState: recordingState ?? this.recordingState,
      currentSession: currentSession ?? this.currentSession,
      transcriptSegments: transcriptSegments ?? this.transcriptSegments,
      currentPartialText: currentPartialText ?? this.currentPartialText,
      connectionState: connectionState ?? this.connectionState,
      errorMessage: errorMessage,
      elapsedDuration: elapsedDuration ?? this.elapsedDuration,
      sessionCounter: sessionCounter ?? this.sessionCounter,
      defaultSessionName: defaultSessionName ?? this.defaultSessionName,
    );
  }
}

class RecordingController extends StateNotifier<RecordingStateData> {
  final AppConfig appConfig;
  final ApiClient apiClient;
  final AppWebSocketClient wsClient;
  final MockRecordingService? mockService;

  StreamSubscription? _wsSubscription;
  StreamSubscription? _wsStateSubscription;
  Timer? _recordingTimer;

  RecordingController({
    required this.appConfig,
    required this.apiClient,
    required this.wsClient,
    this.mockService,
  }) : super(const RecordingStateData(recordingState: RecordingState.idle)) {
    _listenToConnectionState();
  }

  void toggleRecording() {
    if (state.recordingState == RecordingState.recording) {
      stopRecording();
    } else {
      startRecording();
    }
  }

  Future<void> generateAiSummary() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> saveCurrentMeeting(String title) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  void _listenToConnectionState() {
    _wsStateSubscription = wsClient.stateStream.listen((wsState) {
      state = state.copyWith(connectionState: wsState);
    });
  }

  Future<void> startRecording({Map<String, dynamic>? config}) async {
    if (state.recordingState != RecordingState.idle &&
        state.recordingState != RecordingState.completed &&
        state.recordingState != RecordingState.error) {
      return;
    }

    final nextCounter = state.sessionCounter + (state.currentSession != null ? 1 : 0);
    final nextDefaultName = 'Session $nextCounter';

    state = state.copyWith(
      recordingState: RecordingState.starting,
      errorMessage: null,
      transcriptSegments: [],
      currentPartialText: '',
      elapsedDuration: Duration.zero,
      sessionCounter: nextCounter,
      defaultSessionName: nextDefaultName,
    );

    try {
      if (appConfig.useMockData && mockService != null) {
        final res = await mockService!.startRecording(config: config);
        final sessionId = res['sessionId'] as String;
        final session = RecordingSession(
          sessionId: sessionId,
          deviceId: 'esp32_mock_device',
          startTime: DateTime.now(),
          state: RecordingState.recording,
        );

        state = state.copyWith(
          recordingState: RecordingState.connecting,
          currentSession: session,
        );

        _listenToMockWs();
        mockService!.startSimulatingStream(sessionId);

        state = state.copyWith(recordingState: RecordingState.recording);
        _startTimer();
      } else {
        final res = await apiClient.post('/recording/start', body: config ?? {});
        final sessionId = res['sessionId'] as String;
        final wsUrl = res['webSocketUrl'] as String? ??
            '${appConfig.webSocketBaseUrl}/ws/session/$sessionId';

        final session = RecordingSession(
          sessionId: sessionId,
          deviceId: res['deviceId'] as String? ?? 'esp32_device',
          startTime: DateTime.now(),
          state: RecordingState.connecting,
        );

        state = state.copyWith(
          recordingState: RecordingState.connecting,
          currentSession: session,
        );

        _listenToWsEvents();
        wsClient.connect(overrideUrl: wsUrl);
      }
    } catch (e) {
      state = state.copyWith(
        recordingState: RecordingState.error,
        errorMessage: 'Failed to start recording: $e',
      );
    }
  }

  void _listenToWsEvents() {
    _wsSubscription?.cancel();
    _wsSubscription = wsClient.messageStream.listen(_handleIncomingWsMessage);
  }

  void _listenToMockWs() {
    _wsSubscription?.cancel();
    _wsSubscription = mockService?.mockWsStream.listen(_handleIncomingWsMessage);
  }

  void _handleIncomingWsMessage(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? '';

    switch (type) {
      case 'recording.started':
        state = state.copyWith(recordingState: RecordingState.recording);
        _startTimer();
        break;

      case 'transcript.delta':
        final text = json['text'] as String? ?? '';
        final isFinal = json['isFinal'] as bool? ?? false;

        if (isFinal) {
          final updatedSegments = List<TranscriptSegment>.from(state.transcriptSegments)
            ..add(TranscriptSegment(text: text, isFinal: true));
          state = state.copyWith(
            transcriptSegments: updatedSegments,
            currentPartialText: '',
          );
        } else {
          state = state.copyWith(currentPartialText: text);
        }
        break;

      case 'recording.stopped':
        _recordingTimer?.cancel();
        state = state.copyWith(recordingState: RecordingState.processing);
        break;

      case 'recording.completed':
      case 'processing.completed':
        state = state.copyWith(recordingState: RecordingState.completed);
        break;

      case 'recording.error':
      case 'error':
        final msg = json['message'] as String? ?? 'WebSocket error occurred';
        state = state.copyWith(
          recordingState: RecordingState.error,
          errorMessage: msg,
        );
        break;

      default:
        break;
    }
  }

  Future<void> stopRecording() async {
    if (state.recordingState != RecordingState.recording) return;

    state = state.copyWith(recordingState: RecordingState.stopping);
    _recordingTimer?.cancel();

    final sessionId = state.currentSession?.sessionId ?? '';

    try {
      if (appConfig.useMockData && mockService != null) {
        mockService!.stopSimulatingStream(sessionId);
        await mockService!.stopRecording(sessionId);
        state = state.copyWith(recordingState: RecordingState.processing);
        await Future.delayed(const Duration(milliseconds: 600));
        state = state.copyWith(recordingState: RecordingState.completed);
      } else {
        await apiClient.post('/recording/stop', body: {'sessionId': sessionId});
        wsClient.send({
          'type': 'recording.stop',
          'sessionId': sessionId,
        });
        state = state.copyWith(recordingState: RecordingState.processing);
      }
    } catch (e) {
      state = state.copyWith(
        recordingState: RecordingState.error,
        errorMessage: 'Failed to stop recording: $e',
      );
    }
  }

  void _startTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(
        elapsedDuration: state.elapsedDuration + const Duration(seconds: 1),
      );
    });
  }

  void reset() {
    _recordingTimer?.cancel();
    _wsSubscription?.cancel();
    wsClient.disconnect();
    state = const RecordingStateData(recordingState: RecordingState.idle);
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _wsSubscription?.cancel();
    _wsStateSubscription?.cancel();
    super.dispose();
  }
}
