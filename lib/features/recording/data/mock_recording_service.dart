import 'dart:async';

class MockRecordingService {

  Timer? _timer;
  int _step = 0;
  final StreamController<Map<String, dynamic>> _mockWsController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get mockWsStream => _mockWsController.stream;

  final List<String> _sampleTranscriptWords = [
    "Today", "we", "are", "discussing", "the", "new", "real-time", "AI",
    "voice", "recorder", "architecture", "and", "the", "next", "steps",
    "for", "the", "ESP32", "hardware", "integration.", "The", "system",
    "streams", "audio", "chunks", "to", "AWS", "EC2", "where", "speech-to-text",
    "is", "performed", "instantly."
  ];

  Future<Map<String, dynamic>> startRecording({Map<String, dynamic>? config}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final sessionId = 'mock_session_${DateTime.now().millisecondsSinceEpoch}';
    return {
      'sessionId': sessionId,
      'status': 'starting',
      'webSocketUrl': 'ws://mock-server/ws/session/$sessionId',
    };
  }

  Future<Map<String, dynamic>> stopRecording(String sessionId) async {
    _timer?.cancel();
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'sessionId': sessionId,
      'status': 'stopped',
    };
  }

  void startSimulatingStream(String sessionId) {
    _timer?.cancel();
    _step = 0;
    _mockWsController.add({
      'type': 'recording.started',
      'sessionId': sessionId,
    });

    _timer = Timer.periodic(const Duration(milliseconds: 350), (timer) {
      if (_step >= _sampleTranscriptWords.length) {
        timer.cancel();
        return;
      }

      final textChunk = _sampleTranscriptWords.sublist(0, _step + 1).join(" ");
      final isFinal = (_step + 1) % 5 == 0 || _step == _sampleTranscriptWords.length - 1;

      _mockWsController.add({
        'type': 'transcript.delta',
        'sessionId': sessionId,
        'text': textChunk,
        'isFinal': isFinal,
        'sequenceId': _step,
      });

      _step++;
    });
  }

  void stopSimulatingStream(String sessionId) {
    _timer?.cancel();
    _mockWsController.add({
      'type': 'recording.stopped',
      'sessionId': sessionId,
    });
  }

  Timer? _summaryTimer;
  Timer? _chatTimer;

  void simulateSummaryStream(String sessionId) {
    _summaryTimer?.cancel();
    const summaryTexts = [
      "The meeting focused on ",
      "The meeting focused on establishing the real-time AI voice recorder architecture. ",
      "The meeting focused on establishing the real-time AI voice recorder architecture. Key discussion points included ESP32 audio streaming to AWS EC2, ",
      "The meeting focused on establishing the real-time AI voice recorder architecture. Key discussion points included ESP32 audio streaming to AWS EC2, WebSocket delta transcription delivery, and session-aware AI summarization and chat features."
    ];

    if (_mockWsController.isClosed) return;
    _mockWsController.add({'type': 'summary.started', 'sessionId': sessionId});

    int index = 0;
    _summaryTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (_mockWsController.isClosed) {
        timer.cancel();
        return;
      }
      if (index >= summaryTexts.length) {
        timer.cancel();
        _mockWsController.add({'type': 'summary.completed', 'sessionId': sessionId});
        return;
      }
      _mockWsController.add({
        'type': 'summary.delta',
        'sessionId': sessionId,
        'text': summaryTexts[index],
      });
      index++;
    });
  }

  void simulateChatStream(String sessionId, String userPrompt) {
    _chatTimer?.cancel();
    if (_mockWsController.isClosed) return;
    _mockWsController.add({'type': 'chat.started', 'sessionId': sessionId});

    final responses = [
      "Based on ",
      "Based on the recording session, ",
      "Based on the recording session, the main architectural components are the ESP32 hardware recorder, ",
      "Based on the recording session, the main architectural components are the ESP32 hardware recorder, AWS EC2 backend orchestrator, and the Flutter WebSocket stream reader."
    ];

    int index = 0;
    _chatTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_mockWsController.isClosed) {
        timer.cancel();
        return;
      }
      if (index >= responses.length) {
        timer.cancel();
        _mockWsController.add({'type': 'chat.completed', 'sessionId': sessionId});
        return;
      }
      _mockWsController.add({
        'type': 'chat.delta',
        'sessionId': sessionId,
        'text': responses[index],
      });
      index++;
    });
  }

  void dispose() {
    _timer?.cancel();
    _summaryTimer?.cancel();
    _chatTimer?.cancel();
    _mockWsController.close();
  }

}
