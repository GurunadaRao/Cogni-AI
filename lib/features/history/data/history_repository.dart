import 'dart:async';
import '../domain/models/history_models.dart';
import '../../../core/network/http_client.dart';

abstract class IHistoryRepository {
  Future<List<MeetingNote>> getMeetings();
  Future<void> saveMeeting(MeetingNote note);
}

class HistoryRepositoryImpl implements IHistoryRepository {
  final HttpApiClient httpClient;
  bool useMock;

  final List<MeetingNote> _mockList = [
    MeetingNote(
      id: 'm1',
      title: 'IoT Telemetry Architecture Sync',
      transcript:
          'Discussed ESP32-S3 sensor polling rate over AWS IoT Core MQTT broker.',
      summary:
          'Confirmed sub-2s latency requirement and set up WebSocket bridge.',
      reminders: ['Check DynamoDB time series index', 'Verify Riverpod provider scope'],
      recordingWavUrl: '/recordings/rec_001.wav',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    MeetingNote(
      id: 'm2',
      title: 'Gemini AI Integration Review',
      transcript:
          'Tested ElevenLabs STT stream output fed into Gemini summary endpoint.',
      summary:
          'AI accurately generated meeting action points and reminder bullets.',
      reminders: ['Optimize prompt tokens for Gemini Flash model'],
      recordingWavUrl: '/recordings/rec_002.wav',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  HistoryRepositoryImpl({
    required this.httpClient,
    this.useMock = true,
  });

  @override
  Future<List<MeetingNote>> getMeetings() async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return List.unmodifiable(_mockList);
    }
    try {
      final List response = await httpClient.get('/meetings');
      return response.map((item) => MeetingNote.fromJson(item)).toList();
    } catch (_) {
      return List.unmodifiable(_mockList);
    }
  }

  @override
  Future<void> saveMeeting(MeetingNote note) async {
    if (useMock) {
      _mockList.insert(0, note);
      return;
    }
    try {
      await httpClient.post('/new-meeting', {
        'title': note.title,
        'transcript': note.transcript,
        'summary': note.summary,
        'reminders': note.reminders,
      });
    } catch (_) {
      _mockList.insert(0, note);
    }
  }
}
