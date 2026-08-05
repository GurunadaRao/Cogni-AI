import 'dart:async';
import '../domain/models/command_models.dart';
import '../../../core/network/http_client.dart';

abstract class ICommandRepository {
  Future<DeviceCommand> dispatchCommand(String deviceId, String action, Map<String, dynamic> params);
}

class CommandRepositoryImpl implements ICommandRepository {
  final HttpApiClient httpClient;
  bool useMock;

  CommandRepositoryImpl({
    required this.httpClient,
    this.useMock = true,
  });

  @override
  Future<DeviceCommand> dispatchCommand(
      String deviceId, String action, Map<String, dynamic> params) async {
    final commandId = 'cmd_${DateTime.now().millisecondsSinceEpoch}';

    if (useMock) {
      // Simulate optimistic UI dispatch + delay for MQTT ack confirmation
      await Future.delayed(const Duration(seconds: 1));
      return DeviceCommand(
        id: commandId,
        deviceId: deviceId,
        action: action,
        params: params,
        status: CommandStatus.confirmed,
        timestamp: DateTime.now(),
      );
    }

    try {
      final response = await httpClient.post('/devices/$deviceId/commands', {
        'action': action,
        'params': params,
      });
      return DeviceCommand(
        id: response['commandId'] ?? commandId,
        deviceId: deviceId,
        action: action,
        params: params,
        status: response['status'] == 'confirmed'
            ? CommandStatus.confirmed
            : CommandStatus.pending,
        timestamp: DateTime.now(),
      );
    } catch (_) {
      return DeviceCommand(
        id: commandId,
        deviceId: deviceId,
        action: action,
        params: params,
        status: CommandStatus.failed,
        timestamp: DateTime.now(),
      );
    }
  }
}
