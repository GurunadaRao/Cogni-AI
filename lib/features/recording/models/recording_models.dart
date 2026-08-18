enum RecordingState {
  idle,
  starting,
  connecting,
  recording,
  stopping,
  processing,
  completed,
  summarizing,
  chatting,
  error,
}

class RecordingSession {
  final String sessionId;
  final String deviceId;
  final DateTime startTime;
  final DateTime? endTime;
  final RecordingState state;

  const RecordingSession({
    required this.sessionId,
    required this.deviceId,
    required this.startTime,
    this.endTime,
    required this.state,
  });

  RecordingSession copyWith({
    String? sessionId,
    String? deviceId,
    DateTime? startTime,
    DateTime? endTime,
    RecordingState? state,
  }) {
    return RecordingSession(
      sessionId: sessionId ?? this.sessionId,
      deviceId: deviceId ?? this.deviceId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      state: state ?? this.state,
    );
  }

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'deviceId': deviceId,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'state': state.name,
      };

  factory RecordingSession.fromJson(Map<String, dynamic> json) => RecordingSession(
        sessionId: json['sessionId'] as String,
        deviceId: json['deviceId'] as String? ?? 'esp32_default',
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
        state: RecordingState.values.firstWhere(
          (e) => e.name == json['state'],
          orElse: () => RecordingState.idle,
        ),
      );
}

class TranscriptChunk {
  final String sessionId;
  final String text;
  final bool isFinal;
  final int sequenceId;
  final DateTime timestamp;

  const TranscriptChunk({
    required this.sessionId,
    required this.text,
    required this.isFinal,
    this.sequenceId = 0,
    required this.timestamp,
  });

  factory TranscriptChunk.fromJson(Map<String, dynamic> json) => TranscriptChunk(
        sessionId: json['sessionId'] as String? ?? '',
        text: json['text'] as String? ?? '',
        isFinal: json['isFinal'] as bool? ?? false,
        sequenceId: json['sequenceId'] as int? ?? 0,
        timestamp: json['timestamp'] != null
            ? DateTime.parse(json['timestamp'] as String)
            : DateTime.now(),
      );
}

class TranscriptSegment {
  final String text;
  final bool isFinal;

  const TranscriptSegment({required this.text, required this.isFinal});
}

class WebSocketEvent {
  final String type;
  final String sessionId;
  final Map<String, dynamic> payload;

  const WebSocketEvent({
    required this.type,
    required this.sessionId,
    required this.payload,
  });

  factory WebSocketEvent.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'unknown';
    final sessionId = json['sessionId'] as String? ?? '';
    return WebSocketEvent(
      type: type,
      sessionId: sessionId,
      payload: json,
    );
  }
}

class ChatMessage {
  final String id;
  final String sessionId;
  final String text;
  final bool isUser;
  final bool isStreaming;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.sessionId,
    required this.text,
    required this.isUser,
    this.isStreaming = false,
    required this.timestamp,
  });

  ChatMessage copyWith({
    String? id,
    String? sessionId,
    String? text,
    bool? isUser,
    bool? isStreaming,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      isStreaming: isStreaming ?? this.isStreaming,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
