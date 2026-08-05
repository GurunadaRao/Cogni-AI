import 'dart:async';
import 'dart:math';
import '../domain/models/device_models.dart';
import '../../../core/network/http_client.dart';
import '../../../core/network/websocket_client.dart';

abstract class IDeviceRepository {
  Future<Device> getDeviceStatus(String deviceId);
  Stream<TelemetryReading> subscribeTelemetry(String deviceId);
}

class DeviceRepositoryImpl implements IDeviceRepository {
  final HttpApiClient httpClient;
  final WebSocketClient wsClient;
  bool useMock;

  DeviceRepositoryImpl({
    required this.httpClient,
    required this.wsClient,
    this.useMock = true,
  });

  @override
  Future<Device> getDeviceStatus(String deviceId) async {
    if (useMock) {
      return Device(
        id: deviceId,
        name: 'ESP32-S3 Voice Core',
        connectionState: DeviceConnectionState.online,
        lastSeen: DateTime.now(),
        ipAddress: '192.168.1.105',
      );
    }
    try {
      final json = await httpClient.get('/devices/$deviceId');
      return Device(
        id: json['id'] ?? deviceId,
        name: json['name'] ?? 'ESP32 Device',
        connectionState: json['status'] == 'online'
            ? DeviceConnectionState.online
            : DeviceConnectionState.offline,
        lastSeen: json['lastSeen'] != null
            ? DateTime.parse(json['lastSeen'])
            : DateTime.now(),
        ipAddress: json['ipAddress'] ?? '10.0.0.1',
      );
    } catch (_) {
      return Device(
        id: deviceId,
        name: 'ESP32-S3 Core (Offline)',
        connectionState: DeviceConnectionState.offline,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 5)),
        ipAddress: 'Disconnected',
      );
    }
  }

  @override
  Stream<TelemetryReading> subscribeTelemetry(String deviceId) {
    if (useMock) {
      late StreamController<TelemetryReading> controller;
      Timer? timer;
      controller = StreamController<TelemetryReading>(
        onListen: () {
          final random = Random();
          timer = Timer.periodic(const Duration(seconds: 2), (_) {
            if (!controller.isClosed) {
              controller.add(
                TelemetryReading(
                  deviceId: deviceId,
                  temperature: 23.5 + random.nextDouble() * 2.0,
                  humidity: 55.0 + random.nextDouble() * 5.0,
                  micAudioLevel: random.nextDouble(),
                  relayActive: random.nextBool(),
                  timestamp: DateTime.now(),
                ),
              );
            }
          });
        },
        onCancel: () {
          timer?.cancel();
        },
      );
      return controller.stream;
    }

    return wsClient.stream.map((data) {
      if (data is Map<String, dynamic>) {
        return TelemetryReading.fromJson(data);
      }
      // Fallback telemetry reading
      return TelemetryReading(
        deviceId: deviceId,
        temperature: 24.0,
        humidity: 60.0,
        micAudioLevel: 0.1,
        relayActive: false,
        timestamp: DateTime.now(),
      );
    });
  }
}
