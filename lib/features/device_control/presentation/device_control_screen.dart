import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';

class DeviceControlScreen extends ConsumerWidget {
  const DeviceControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceId = ref.watch(selectedDeviceIdProvider);
    final commandState = ref.watch(commandControllerProvider);
    final notifier = ref.read(commandControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Actuator Controls'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Target Device Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.tune, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Paired Target: $deviceId',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Row(
                          children: [
                            const Text('ACK Status: ', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            if (commandState.isPending) ...[
                              const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.warning),
                              ),
                              const SizedBox(width: 4),
                              const Text('Pending...', style: TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.bold)),
                            ] else ...[
                              const Icon(Icons.check_circle, size: 14, color: AppColors.success),
                              const SizedBox(width: 4),
                              const Text('Confirmed', style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.bold)),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Relay Switch Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.power, color: commandState.relayActive ? AppColors.success : AppColors.textMuted, size: 28),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Main Relay Switch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(
                            commandState.relayActive ? 'Relay is ON' : 'Relay is OFF',
                            style: TextStyle(color: commandState.relayActive ? AppColors.success : AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Switch(
                    value: commandState.relayActive,
                    activeColor: AppColors.primary,
                    onChanged: (_) => notifier.toggleRelay(deviceId),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Fan Speed PWM Slider Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.toys, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text('Fan Speed PWM Controller', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                      Text(
                        '${commandState.fanSpeed.toInt()}%',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: commandState.fanSpeed,
                    min: 0.0,
                    max: 100.0,
                    activeColor: AppColors.primary,
                    onChanged: (val) => notifier.setFanSpeed(deviceId, val),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
