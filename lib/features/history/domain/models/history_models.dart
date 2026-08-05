class MeetingNote {
  final String id;
  final String title;
  final String transcript;
  final String summary;
  final List<String> reminders;
  final String recordingWavUrl;
  final DateTime createdAt;
  final Duration duration;

  const MeetingNote({
    required this.id,
    required this.title,
    required this.transcript,
    required this.summary,
    required this.reminders,
    required this.recordingWavUrl,
    required this.createdAt,
    this.duration = Duration.zero,
  });

  factory MeetingNote.fromJson(Map<String, dynamic> json) {
    return MeetingNote(
      id: json['id'] ?? 'meeting_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] ?? 'Voice Note',
      transcript: json['transcript'] ?? '',
      summary: json['summary'] ?? '',
      reminders: List<String>.from(json['reminders'] ?? []),
      recordingWavUrl: json['recordingFile'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      duration: json['durationSeconds'] != null
          ? Duration(seconds: json['durationSeconds'] as int)
          : Duration.zero,
    );
  }
}
