enum CommandStatus { pending, confirmed, failed, timedOut }

class DeviceCommand {
  final String id;
  final String deviceId;
  final String action;
  final Map<String, dynamic> params;
  final CommandStatus status;
  final DateTime timestamp;

  const DeviceCommand({
    required this.id,
    required this.deviceId,
    required this.action,
    required this.params,
    required this.status,
    required this.timestamp,
  });

  DeviceCommand copyWith({
    String? id,
    String? deviceId,
    String? action,
    Map<String, dynamic>? params,
    CommandStatus? status,
    DateTime? timestamp,
  }) {
    return DeviceCommand(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      action: action ?? this.action,
      params: params ?? this.params,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
