enum DeviceConnectionState { online, syncing, offline, unknown }

class Device {
  final String id;
  final String name;
  final DeviceConnectionState connectionState;
  final DateTime lastSeen;
  final String ipAddress;

  const Device({
    required this.id,
    required this.name,
    required this.connectionState,
    required this.lastSeen,
    required this.ipAddress,
  });

  Device copyWith({
    String? id,
    String? name,
    DeviceConnectionState? connectionState,
    DateTime? lastSeen,
    String? ipAddress,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      connectionState: connectionState ?? this.connectionState,
      lastSeen: lastSeen ?? this.lastSeen,
      ipAddress: ipAddress ?? this.ipAddress,
    );
  }
}

class TelemetryReading {
  final String deviceId;
  final double temperature;
  final double humidity;
  final double micAudioLevel;
  final bool relayActive;
  final DateTime timestamp;

  const TelemetryReading({
    required this.deviceId,
    required this.temperature,
    required this.humidity,
    required this.micAudioLevel,
    required this.relayActive,
    required this.timestamp,
  });

  factory TelemetryReading.fromJson(Map<String, dynamic> json) {
    return TelemetryReading(
      deviceId: json['deviceId'] ?? 'ESP32-S3-Sense',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 24.5,
      humidity: (json['humidity'] as num?)?.toDouble() ?? 58.0,
      micAudioLevel: (json['micAudioLevel'] as num?)?.toDouble() ?? 0.3,
      relayActive: json['relayActive'] ?? false,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'deviceId': deviceId,
        'temperature': temperature,
        'humidity': humidity,
        'micAudioLevel': micAudioLevel,
        'relayActive': relayActive,
        'timestamp': timestamp.toIso8601String(),
      };
}
