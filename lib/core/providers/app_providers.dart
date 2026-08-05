import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/http_client.dart';
import '../network/websocket_client.dart';

import '../../features/dashboard/data/device_repository.dart';
import '../../features/dashboard/domain/models/device_models.dart';

import '../../features/recorder/data/recorder_repository.dart';
import '../../features/recorder/ai/ai_service.dart';
import '../../features/recorder/domain/models/recording_models.dart';

import '../../features/device_control/data/command_repository.dart';
import '../../features/device_control/domain/models/command_models.dart';

import '../../features/history/data/history_repository.dart';
import '../../features/history/domain/models/history_models.dart';

// Config State
final serverConfigProvider = StateProvider<String>((ref) => 'http://localhost:8080');
final useMockDataProvider = StateProvider<bool>((ref) => true);

// Core Clients
final httpClientProvider = Provider<HttpApiClient>((ref) {
  final url = ref.watch(serverConfigProvider);
  return HttpApiClient(baseUrl: url);
});

final wsClientProvider = Provider<WebSocketClient>((ref) {
  final url = ref.watch(serverConfigProvider);
  final wsUrl = url.replaceFirst('http', 'ws');
  return WebSocketClient(wsUrl: wsUrl);
});

// Repositories
final deviceRepositoryProvider = Provider<IDeviceRepository>((ref) {
  return DeviceRepositoryImpl(
    httpClient: ref.watch(httpClientProvider),
    wsClient: ref.watch(wsClientProvider),
    useMock: ref.watch(useMockDataProvider),
  );
});

final recorderRepositoryProvider = Provider<IRecorderRepository>((ref) {
  return RecorderRepositoryImpl(
    httpClient: ref.watch(httpClientProvider),
    wsClient: ref.watch(wsClientProvider),
    useMock: ref.watch(useMockDataProvider),
  );
});

final aiServiceProvider = Provider<IAiService>((ref) {
  return AiServiceImpl(
    httpClient: ref.watch(httpClientProvider),
    useMock: ref.watch(useMockDataProvider),
  );
});

final commandRepositoryProvider = Provider<ICommandRepository>((ref) {
  return CommandRepositoryImpl(
    httpClient: ref.watch(httpClientProvider),
    useMock: ref.watch(useMockDataProvider),
  );
});

final historyRepositoryProvider = Provider<IHistoryRepository>((ref) {
  return HistoryRepositoryImpl(
    httpClient: ref.watch(httpClientProvider),
    useMock: ref.watch(useMockDataProvider),
  );
});

// Feature Notifiers & Streams
final selectedDeviceIdProvider = StateProvider<String>((ref) => 'ESP32-S3-Sense');

final deviceStatusProvider = FutureProvider.family<Device, String>((ref, id) async {
  final repo = ref.watch(deviceRepositoryProvider);
  return repo.getDeviceStatus(id);
});

final telemetryStreamProvider = StreamProvider.family<TelemetryReading, String>((ref, id) {
  final repo = ref.watch(deviceRepositoryProvider);
  return repo.subscribeTelemetry(id);
});

// Recorder Controller State
class RecorderControllerState {
  final bool isRecording;
  final String liveTranscript;
  final List<double> audioWaveform;
  final Duration duration;
  final AiMeetingSummary? aiSummary;
  final bool isAnalyzing;

  const RecorderControllerState({
    this.isRecording = false,
    this.liveTranscript = '',
    this.audioWaveform = const [],
    this.duration = Duration.zero,
    this.aiSummary,
    this.isAnalyzing = false,
  });

  RecorderControllerState copyWith({
    bool? isRecording,
    String? liveTranscript,
    List<double>? audioWaveform,
    Duration? duration,
    AiMeetingSummary? aiSummary,
    bool? isAnalyzing,
  }) {
    return RecorderControllerState(
      isRecording: isRecording ?? this.isRecording,
      liveTranscript: liveTranscript ?? this.liveTranscript,
      audioWaveform: audioWaveform ?? this.audioWaveform,
      duration: duration ?? this.duration,
      aiSummary: aiSummary ?? this.aiSummary,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
    );
  }
}

class RecorderNotifier extends StateNotifier<RecorderControllerState> {
  final IRecorderRepository _recorderRepo;
  final IAiService _aiService;
  final IHistoryRepository _historyRepo;

  RecorderNotifier(this._recorderRepo, this._aiService, this._historyRepo)
      : super(const RecorderControllerState());

  void toggleRecording() async {
    if (state.isRecording) {
      await stopRecording();
    } else {
      state = const RecorderControllerState(isRecording: true);
      await _recorderRepo.startRecording();
      _recorderRepo.subscribeLiveTranscript().listen((text) {
        state = state.copyWith(liveTranscript: text);
      });
      _recorderRepo.subscribeAudioWaveform().listen((waveform) {
        state = state.copyWith(audioWaveform: waveform);
      });
    }
  }

  Future<void> stopRecording() async {
    await _recorderRepo.stopRecording();
    state = state.copyWith(isRecording: false);
  }

  Future<void> generateAiSummary() async {
    if (state.liveTranscript.isEmpty) return;
    state = state.copyWith(isAnalyzing: true);
    final summary = await _aiService.generateSummary(state.liveTranscript);
    state = state.copyWith(isAnalyzing: false, aiSummary: summary);
  }

  Future<void> saveCurrentMeeting(String title) async {
    final note = MeetingNote(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      title: title.isEmpty ? 'Voice Recording Note' : title,
      transcript: state.liveTranscript,
      summary: state.aiSummary?.rawSummary ?? '',
      reminders: state.aiSummary?.bulletPoints ?? [],
      recordingWavUrl: '/recordings/audio_${DateTime.now().millisecondsSinceEpoch}.wav',
      createdAt: DateTime.now(),
      duration: state.duration,
    );
    await _historyRepo.saveMeeting(note);
  }
}

final recorderControllerProvider =
    StateNotifierProvider<RecorderNotifier, RecorderControllerState>((ref) {
  return RecorderNotifier(
    ref.watch(recorderRepositoryProvider),
    ref.watch(aiServiceProvider),
    ref.watch(historyRepositoryProvider),
  );
});

// Actuator & Command Controller State
class CommandControllerState {
  final bool relayActive;
  final double fanSpeed;
  final CommandStatus lastCommandStatus;
  final bool isPending;

  const CommandControllerState({
    this.relayActive = false,
    this.fanSpeed = 50.0,
    this.lastCommandStatus = CommandStatus.confirmed,
    this.isPending = false,
  });

  CommandControllerState copyWith({
    bool? relayActive,
    double? fanSpeed,
    CommandStatus? lastCommandStatus,
    bool? isPending,
  }) {
    return CommandControllerState(
      relayActive: relayActive ?? this.relayActive,
      fanSpeed: fanSpeed ?? this.fanSpeed,
      lastCommandStatus: lastCommandStatus ?? this.lastCommandStatus,
      isPending: isPending ?? this.isPending,
    );
  }
}

class CommandNotifier extends StateNotifier<CommandControllerState> {
  final ICommandRepository _commandRepo;

  CommandNotifier(this._commandRepo) : super(const CommandControllerState());

  Future<void> toggleRelay(String deviceId) async {
    final newRelayState = !state.relayActive;
    state = state.copyWith(relayActive: newRelayState, isPending: true);

    final result = await _commandRepo.dispatchCommand(deviceId, 'toggle_relay', {
      'relay': newRelayState,
    });

    state = state.copyWith(
      lastCommandStatus: result.status,
      isPending: false,
    );
  }

  Future<void> setFanSpeed(String deviceId, double speed) async {
    state = state.copyWith(fanSpeed: speed, isPending: true);

    final result = await _commandRepo.dispatchCommand(deviceId, 'set_fan_speed', {
      'speed': speed.toInt(),
    });

    state = state.copyWith(
      lastCommandStatus: result.status,
      isPending: false,
    );
  }
}

final commandControllerProvider =
    StateNotifierProvider<CommandNotifier, CommandControllerState>((ref) {
  return CommandNotifier(ref.watch(commandRepositoryProvider));
});

// Meetings List Provider
final meetingsListProvider = FutureProvider<List<MeetingNote>>((ref) async {
  final repo = ref.watch(historyRepositoryProvider);
  return repo.getMeetings();
});
