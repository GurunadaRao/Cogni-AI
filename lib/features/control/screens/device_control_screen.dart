import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class DeviceControlScreen extends StatefulWidget {
  const DeviceControlScreen({super.key});

  @override
  State<DeviceControlScreen> createState() => _DeviceControlScreenState();
}

class _DeviceControlScreenState extends State<DeviceControlScreen> {
  bool _powerState = true;
  bool _noiseCancelState = true;
  bool _autoUploadState = false;
  double _gainValue = 75.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hardware Control',
                style: TextStyle(
                  color: AppTheme.royalDarkBlue,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Direct AWS IoT Core MQTT Actuator Commands',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),

              // Device Master Power Switch Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.iceBlue,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.softBlue),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _powerState
                                ? AppTheme.vividBlue
                                : AppTheme.softBlue,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.power_settings_new_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ESP32 Power State',
                              style: TextStyle(
                                color: AppTheme.royalDarkBlue,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _powerState ? 'Operational' : 'Standby Mode',
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Switch(
                      value: _powerState,
                      activeColor: AppTheme.vividBlue,
                      onChanged: (val) => setState(() => _powerState = val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Mic Gain Control Slider Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.softBlue),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.royalDarkBlue.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Microphone Gain',
                          style: TextStyle(
                            color: AppTheme.royalDarkBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_gainValue.toInt()}%',
                          style: const TextStyle(
                            color: AppTheme.vividBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: AppTheme.vividBlue,
                        inactiveTrackColor: AppTheme.iceBlue,
                        thumbColor: AppTheme.royalDarkBlue,
                        overlayColor:
                            AppTheme.vividBlue.withValues(alpha: 0.15),
                      ),
                      child: Slider(
                        value: _gainValue,
                        min: 0,
                        max: 100,
                        onChanged: (val) => setState(() => _gainValue = val),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Toggle Actuators List
              const Text(
                'DSP & Transmission Settings',
                style: TextStyle(
                  color: AppTheme.royalDarkBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),

              _buildControlTile(
                title: 'DSP Noise Suppression',
                subtitle: 'Hardware-level ambient noise filter',
                icon: Icons.tune_rounded,
                value: _noiseCancelState,
                onChanged: (val) => setState(() => _noiseCancelState = val),
              ),
              const SizedBox(height: 12),
              _buildControlTile(
                title: 'Auto Cloud Sync',
                subtitle: 'Stream recorded audio chunks to DynamoDB',
                icon: Icons.cloud_upload_rounded,
                value: _autoUploadState,
                onChanged: (val) => setState(() => _autoUploadState = val),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.softBlue.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.iceBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.vividBlue),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.royalDarkBlue,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: value,
            activeColor: AppTheme.vividBlue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
