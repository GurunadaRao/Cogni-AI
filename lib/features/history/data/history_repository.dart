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

  final List<MeetingNote> _inMemoryList = [];

  HistoryRepositoryImpl({
    required this.httpClient,
    this.useMock = false,
  });

  @override
  Future<List<MeetingNote>> getMeetings() async {
    if (useMock) {
      return List.unmodifiable(_inMemoryList);
    }
    try {
      final response = await httpClient.get('/meetings');
      List items = [];
      if (response is List) {
        items = response;
      } else if (response is Map && response['meetings'] != null) {
        items = response['meetings'];
      }

      final parsed = items.map((item) {
        if (item is Map<String, dynamic>) {
          return MeetingNote.fromJson(item);
        } else if (item is String) {
          // Process meeting timestamp string format from server
          return MeetingNote(
            id: item,
            title: 'Session $item',
            transcript: '',
            summary: '',
            reminders: [],
            recordingWavUrl: '',
            createdAt: DateTime.tryParse(item) ?? DateTime.now(),
          );
        }
        return MeetingNote(
          id: 'm_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Session Note',
          transcript: '',
          summary: '',
          reminders: [],
          recordingWavUrl: '',
          createdAt: DateTime.now(),
        );
      }).toList();

      final combined = [..._inMemoryList, ...parsed];
      final uniqueMap = <String, MeetingNote>{};
      for (final n in combined) {
        uniqueMap[n.id] = n;
      }
      return uniqueMap.values.toList();
    } catch (_) {
      return List.unmodifiable(_inMemoryList);
    }
  }

  @override
  Future<void> saveMeeting(MeetingNote note) async {
    _inMemoryList.insert(0, note);
    if (!useMock) {
      try {
        await httpClient.post('/new-meeting', {
          'id': note.id,
          'title': note.title,
          'transcript': note.transcript,
          'summary': note.summary,
          'reminders': note.reminders,
        });
      } catch (_) {
        // Fallback to local memory list
      }
    }
  }
}
