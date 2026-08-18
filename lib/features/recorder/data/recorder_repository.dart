import 'dart:async';
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
  final AppWebSocketClient wsClient;
  bool useMock;

  StreamController<String>? _transcriptController;
  StreamController<List<double>>? _waveformController;

  RecorderRepositoryImpl({
    required this.httpClient,
    required this.wsClient,
    this.useMock = false,
  });

  @override
  Future<void> startRecording() async {
    _transcriptController = StreamController<String>.broadcast();
    _waveformController = StreamController<List<double>>.broadcast();
    wsClient.connect();
  }

  @override
  Future<void> stopRecording() async {
    wsClient.disconnect();
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
