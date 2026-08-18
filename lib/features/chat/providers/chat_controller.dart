import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/websocket_client.dart';
import '../../recording/data/mock_recording_service.dart';
import '../../recording/models/recording_models.dart';

enum ChatStatus { idle, sending, streaming, completed, error }

class ChatStateData {
  final ChatStatus status;
  final List<ChatMessage> messages;
  final String? errorMessage;

  const ChatStateData({
    required this.status,
    this.messages = const [],
    this.errorMessage,
  });

  ChatStateData copyWith({
    ChatStatus? status,
    List<ChatMessage>? messages,
    String? errorMessage,
  }) {
    return ChatStateData(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: errorMessage,
    );
  }
}

class ChatController extends StateNotifier<ChatStateData> {
  final String sessionId;
  final AppConfig appConfig;
  final ApiClient apiClient;
  final AppWebSocketClient wsClient;
  final MockRecordingService? mockService;
  StreamSubscription? _wsSubscription;

  ChatController({
    required this.sessionId,
    required this.appConfig,
    required this.apiClient,
    required this.wsClient,
    this.mockService,
  }) : super(const ChatStateData(status: ChatStatus.idle));

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: 'msg_user_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: sessionId,
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    final aiPendingMsgId = 'msg_ai_${DateTime.now().millisecondsSinceEpoch}';
    final aiPendingMsg = ChatMessage(
      id: aiPendingMsgId,
      sessionId: sessionId,
      text: '',
      isUser: false,
      isStreaming: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      status: ChatStatus.sending,
      messages: [...state.messages, userMsg, aiPendingMsg],
      errorMessage: null,
    );

    try {
      if (appConfig.useMockData && mockService != null) {
        state = state.copyWith(status: ChatStatus.streaming);
        _listenToMockWs(aiPendingMsgId);
        mockService!.simulateChatStream(sessionId, text);
      } else {
        wsClient.send({
          'type': 'chat.message',
          'sessionId': sessionId,
          'message': text.trim(),
        });
        state = state.copyWith(status: ChatStatus.streaming);
        _listenToWs(aiPendingMsgId);
      }
    } catch (e) {
      state = state.copyWith(
        status: ChatStatus.error,
        errorMessage: 'Failed to send chat message: $e',
      );
    }
  }

  void _listenToMockWs(String aiMsgId) {
    _wsSubscription?.cancel();
    _wsSubscription = mockService?.mockWsStream.listen((json) => _handleWsEvent(json, aiMsgId));
  }

  void _listenToWs(String aiMsgId) {
    _wsSubscription?.cancel();
    _wsSubscription = wsClient.messageStream.listen((json) => _handleWsEvent(json, aiMsgId));
  }

  void _handleWsEvent(Map<String, dynamic> json, String aiMsgId) {
    final type = json['type'] as String? ?? '';
    final eventSessionId = json['sessionId'] as String? ?? '';

    if (eventSessionId.isNotEmpty && eventSessionId != sessionId) return;

    switch (type) {
      case 'chat.started':
        state = state.copyWith(status: ChatStatus.streaming);
        break;

      case 'chat.delta':
        final deltaText = json['text'] as String? ?? '';
        _updateAiMessageText(aiMsgId, deltaText, isStreaming: true);
        break;

      case 'chat.completed':
        _updateAiMessageStreamingStatus(aiMsgId, isStreaming: false);
        state = state.copyWith(status: ChatStatus.completed);
        break;

      case 'error':
        final msg = json['message'] as String? ?? 'Chat error occurred';
        state = state.copyWith(status: ChatStatus.error, errorMessage: msg);
        break;
    }
  }

  void _updateAiMessageText(String id, String newText, {required bool isStreaming}) {
    final updated = state.messages.map((m) {
      if (m.id == id) {
        return m.copyWith(text: newText, isStreaming: isStreaming);
      }
      return m;
    }).toList();
    state = state.copyWith(messages: updated);
  }

  void _updateAiMessageStreamingStatus(String id, {required bool isStreaming}) {
    final updated = state.messages.map((m) {
      if (m.id == id) {
        return m.copyWith(isStreaming: isStreaming);
      }
      return m;
    }).toList();
    state = state.copyWith(messages: updated);
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    super.dispose();
  }
}
