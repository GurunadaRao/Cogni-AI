import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../shell/presentation/main_shell_screen.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Screen 1 — Device Configuration Form
// ══════════════════════════════════════════════════════════════════════════════
class DeviceConfigScreen extends StatefulWidget {
  const DeviceConfigScreen({super.key});

  @override
  State<DeviceConfigScreen> createState() => _DeviceConfigScreenState();
}

class _DeviceConfigScreenState extends State<DeviceConfigScreen> {
  final _serverUrlCtrl =
      TextEditingController(text: 'https://192.168.1.100:8080');
  final _deviceIdCtrl = TextEditingController(text: 'DEVICE_001');
  bool _testing = false;
  bool _tested = false;

  Future<void> _testConnection() async {
    setState(() => _testing = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    setState(() {
      _testing = false;
      _tested = true;
    });
  }

  void _configure() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const ConfiguringProgressScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Device Configuration',
            style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.iceBlue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Device Configuration',
                      style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text('Configure your device before first use.',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _FieldLabel('Server URL'),
            _TextField(controller: _serverUrlCtrl,
                hint: 'https://192.168.1.100:8080'),
            const SizedBox(height: 16),

            _FieldLabel('Device ID'),
            _TextField(controller: _deviceIdCtrl, hint: 'DEVICE_001'),
            const SizedBox(height: 16),

            _FieldLabel('WiFi Status'),
            _StatusRow(label: 'WiFi', value: 'Connected', isGood: true),
            const SizedBox(height: 8),
            _FieldLabel('Server Connection'),
            _StatusRow(
              label: 'Server',
              value: _tested ? 'Connected' : 'Not Tested',
              isGood: _tested,
            ),
            const SizedBox(height: 32),

            // Need help
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text('Need Help? View Guide',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.primary)),
              ),
            ),
            const SizedBox(height: 16),

            // Test Connection
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _testing ? null : _testConnection,
                child: _testing
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.primary))
                    : Text('Test Connection',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, fontSize: 14)),
              ),
            ),
            const SizedBox(height: 12),

            // Configure Device
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _configure,
                child: Text('Configure Device',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary)),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  const _TextField({required this.controller, required this.hint});
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: AppColors.borderDivider)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: AppColors.borderDivider)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5)),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isGood;
  const _StatusRow(
      {required this.label, required this.value, required this.isGood});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderDivider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textMuted)),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isGood
                  ? AppColors.successBackground
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isGood ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                  color: isGood ? AppColors.success : AppColors.textMuted,
                  size: 13,
                ),
                const SizedBox(width: 5),
                Text(value,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isGood
                            ? AppColors.success
                            : AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Screen 2 — Configuring Progress
// ══════════════════════════════════════════════════════════════════════════════
class ConfiguringProgressScreen extends StatefulWidget {
  const ConfiguringProgressScreen({super.key});

  @override
  State<ConfiguringProgressScreen> createState() =>
      _ConfiguringProgressScreenState();
}

class _ConfiguringProgressScreenState
    extends State<ConfiguringProgressScreen> {
  int _step = 0;
  double _progress = 0;

  static const _steps = [
    'Connecting to Server',
    'Verifying Device',
    'Installing Dependencies',
    'Testing Microphone',
    'Testing Speaker',
    'Verifying Storage',
    'Synchronizing Time',
    'Finalizing Configuration',
  ];

  @override
  void initState() {
    super.initState();
    _runSteps();
  }

  Future<void> _runSteps() async {
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 380));
      if (!mounted) return;
      setState(() {
        _step = i + 1;
        _progress = (i + 1) / _steps.length;
      });
    }
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('device_configured', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const ConfigSuccessScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text('Configuring Device',
                  style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              Text('Please wait while we set up your device.',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textMuted)),
              const SizedBox(height: 32),

              Expanded(
                child: ListView.builder(
                  itemCount: _steps.length,
                  itemBuilder: (_, i) {
                    final done = i < _step;
                    final active = i == _step - 1 && _step < _steps.length;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: done
                                  ? AppColors.success
                                  : active
                                      ? AppColors.primary.withValues(alpha: 0.12)
                                      : const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: done
                                ? const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 16)
                                : active
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: Padding(
                                          padding: EdgeInsets.all(6),
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.primary),
                                        ))
                                    : null,
                          ),
                          const SizedBox(width: 14),
                          Text(
                            _steps[i],
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: done
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: done
                                  ? AppColors.textPrimary
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(_progress * 100).toInt()}%',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 8,
                      backgroundColor: AppColors.iceBlue,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Screen 3 — Configuration Success
// ══════════════════════════════════════════════════════════════════════════════
class ConfigSuccessScreen extends StatelessWidget {
  const ConfigSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              // Success animation
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.successBackground,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.25),
                      blurRadius: 30,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(Icons.check_rounded,
                    color: AppColors.success, size: 60),
              ),
              const SizedBox(height: 32),
              Text('Device Ready!',
                  style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Text(
                'Everything has been configured\nsuccessfully.',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textMuted,
                    height: 1.6),
                textAlign: TextAlign.center,
              ),
              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (_) => const MainShellScreen()),
                      (_) => false,
                    );
                  },
                  child: Text('Go to Dashboard',
                      style: GoogleFonts.inter(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
