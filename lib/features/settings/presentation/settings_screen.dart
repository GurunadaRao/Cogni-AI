import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _urlController;
  late TextEditingController _deviceIdController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: ref.read(serverConfigProvider));
    _deviceIdController = TextEditingController(text: ref.read(selectedDeviceIdProvider));
  }

  @override
  void dispose() {
    _urlController.dispose();
    _deviceIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final useMock = ref.watch(useMockDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Demo Mode Card
          Card(
            child: SwitchListTile(
              title: const Text('Demo Mock Data Mode', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Use offline telemetry & AI mock data', style: TextStyle(fontSize: 12)),
              value: useMock,
              activeColor: AppColors.primary,
              onChanged: (val) {
                ref.read(useMockDataProvider.notifier).state = val;
              },
            ),
          ),
          const SizedBox(height: 16),

          // Network Config Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Backend Server Host', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      hintText: 'http://54.237.76.182:8080',
                      prefixIcon: Icon(Icons.dns, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Paired Device ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _deviceIdController,
                    decoration: const InputDecoration(
                      hintText: 'ESP32-S3-Sense',
                      prefixIcon: Icon(Icons.developer_board, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 46)),
                    onPressed: () {
                      ref.read(serverConfigProvider.notifier).state = _urlController.text.trim();
                      ref.read(selectedDeviceIdProvider.notifier).state = _deviceIdController.text.trim();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Configuration saved!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Save Settings'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Info Card
          const Card(
            color: AppColors.surfaceCard,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('EchoClip Core System', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  SizedBox(height: 4),
                  Text('Port: 8080 • Model: gemini-3.5-flash • STT: ElevenLabs Scribe', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
                  SizedBox(height: 2),
                  Text('Architecture: Clean MVP + Riverpod', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
