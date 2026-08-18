import 'dart:async';
import '../domain/models/device_models.dart';
import '../../../core/network/http_client.dart';
import '../../../core/network/websocket_client.dart';

abstract class IDeviceRepository {
  Future<Device> getDeviceStatus(String deviceId);
  Stream<TelemetryReading> subscribeTelemetry(String deviceId);
}

class DeviceRepositoryImpl implements IDeviceRepository {
  final HttpApiClient httpClient;
  final AppWebSocketClient wsClient;
  bool useMock;

  DeviceRepositoryImpl({
    required this.httpClient,
    required this.wsClient,
    this.useMock = false,
  });

  @override
  Future<Device> getDeviceStatus(String deviceId) async {
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
        name: 'ESP32 Core',
        connectionState: DeviceConnectionState.offline,
        lastSeen: DateTime.now(),
        ipAddress: 'Disconnected',
      );
    }
  }

  @override
  Stream<TelemetryReading> subscribeTelemetry(String deviceId) {
    return wsClient.messageStream.map((data) {
      return TelemetryReading.fromJson(data);
    });
  }
}
