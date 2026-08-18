import 'package:flutter/material.dart';

class ConfigureScreen extends StatefulWidget {
  final Function(Map<String, dynamic> config)? onSave;

  const ConfigureScreen({super.key, this.onSave});

  @override
  State<ConfigureScreen> createState() => _ConfigureScreenState();
}

class _ConfigureScreenState extends State<ConfigureScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedDevice = 'ESP32_Mic_01';
  String _audioSampleRate = '16000 Hz';
  String _serverHost = 'http://localhost:8080';
  bool _noiseCancellation = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recording Configuration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hardware & Audio Settings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDevice,
                decoration: const InputDecoration(
                  labelText: 'Physical Recording Device (ESP32)',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'ESP32_Mic_01', child: Text('ESP32 Mic #1 (Primary)')),
                  DropdownMenuItem(value: 'ESP32_Mic_02', child: Text('ESP32 Mic #2 (Conference)')),
                ],
                onChanged: (val) => setState(() => _selectedDevice = val!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _audioSampleRate,
                decoration: const InputDecoration(
                  labelText: 'Sample Rate',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: '16000 Hz', child: Text('16000 Hz (Optimal for STT)')),
                  DropdownMenuItem(value: '44100 Hz', child: Text('44100 Hz (High Fidelity)')),
                ],
                onChanged: (val) => setState(() => _audioSampleRate = val!),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Enable ESP32 Noise Suppression'),
                subtitle: const Text('Filters background ambient noise on device hardware'),
                value: _noiseCancellation,
                onChanged: (val) => setState(() => _noiseCancellation = val),
              ),
              const Divider(height: 32),
              Text(
                'Server Endpoint Configuration',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _serverHost,
                decoration: const InputDecoration(
                  labelText: 'AWS EC2 Server URL',
                  border: OutlineInputBorder(),
                  hintText: 'http://<ec2-ip>:8080',
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please enter server URL';
                  return null;
                },
                onSaved: (val) => _serverHost = val!,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      final config = {
                        'deviceId': _selectedDevice,
                        'sampleRate': _audioSampleRate,
                        'noiseCancellation': _noiseCancellation,
                        'serverHost': _serverHost,
                      };
                      if (widget.onSave != null) {
                        widget.onSave!(config);
                      }
                      Navigator.pop(context, config);
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Save Configuration', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
