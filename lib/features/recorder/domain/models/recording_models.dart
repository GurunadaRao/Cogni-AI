class RecordingSession {
  final String id;
  final String title;
  final String liveTranscript;
  final bool isRecording;
  final Duration duration;
  final List<double> audioWaveform;

  const RecordingSession({
    required this.id,
    required this.title,
    required this.liveTranscript,
    required this.isRecording,
    required this.duration,
    required this.audioWaveform,
  });

  RecordingSession copyWith({
    String? id,
    String? title,
    String? liveTranscript,
    bool? isRecording,
    Duration? duration,
    List<double>? audioWaveform,
  }) {
    return RecordingSession(
      id: id ?? this.id,
      title: title ?? this.title,
      liveTranscript: liveTranscript ?? this.liveTranscript,
      isRecording: isRecording ?? this.isRecording,
      duration: duration ?? this.duration,
      audioWaveform: audioWaveform ?? this.audioWaveform,
    );
  }
}

class AiMeetingSummary {
  final String rawSummary;
  final List<String> bulletPoints;
  final List<String> actionItems;

  const AiMeetingSummary({
    required this.rawSummary,
    required this.bulletPoints,
    required this.actionItems,
  });

  factory AiMeetingSummary.fromJson(Map<String, dynamic> json) {
    return AiMeetingSummary(
      rawSummary: json['summary'] ?? '',
      bulletPoints: List<String>.from(json['bulletPoints'] ?? json['reminders'] ?? []),
      actionItems: List<String>.from(json['actionItems'] ?? []),
    );
  }
}
