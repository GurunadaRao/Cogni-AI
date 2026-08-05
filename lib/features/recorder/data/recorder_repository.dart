import 'dart:async';
import 'dart:math';
import '../../../core/network/http_client.dart';
import '../../../core/network/websocket_client.dart';

abstract class IRecorderRepository {
  Future<void> startRecording();
  Future<void> stopRecording();
  Stream<String> subscribeLiveTranscript();
  Stream<List<double>> subscribeAudioWaveform();
}

class RecorderRepositoryImpl implements IRecorderRepository {
  final HttpApiClient httpClient;
  final WebSocketClient wsClient;
  bool useMock;

  StreamController<String>? _transcriptController;
  StreamController<List<double>>? _waveformController;
  Timer? _mockTimer;

  RecorderRepositoryImpl({
    required this.httpClient,
    required this.wsClient,
    this.useMock = true,
  });

  @override
  Future<void> startRecording() async {
    _transcriptController = StreamController<String>.broadcast();
    _waveformController = StreamController<List<double>>.broadcast();

    if (useMock) {
      final sampleSentences = [
        "Welcome to the AI Voice Recorder session. ",
        "We are discussing the ESP32 IoT hardware integration with Google Gemini AI. ",
        "Key action item: Ensure AWS IoT Core telemetry round-trip latency is under 2 seconds. ",
        "The mobile Flutter app uses Riverpod for clean state management and glassmorphic UI. ",
        "Let's wrap up this meeting and summarize action points."
      ];
      int index = 0;
      StringBuffer buffer = StringBuffer();
      final random = Random();

      _mockTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
        if (index < sampleSentences.length) {
          buffer.write(sampleSentences[index]);
          _transcriptController?.add(buffer.toString());
          index++;
        }
        final waveform = List.generate(20, (_) => random.nextDouble());
        _waveformController?.add(waveform);
      });
    } else {
      wsClient.connect();
    }
  }

  @override
  Future<void> stopRecording() async {
    _mockTimer?.cancel();
    if (!useMock) {
      wsClient.disconnect();
    }
  }

  @override
  Stream<String> subscribeLiveTranscript() {
    return _transcriptController?.stream ?? const Stream.empty();
  }

  @override
  Stream<List<double>> subscribeAudioWaveform() {
    return _waveformController?.stream ?? const Stream.empty();
  }
}
