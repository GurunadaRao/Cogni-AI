import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class RecorderScreen extends StatefulWidget {
  const RecorderScreen({super.key});

  @override
  State<RecorderScreen> createState() => _RecorderScreenState();
}

class _RecorderScreenState extends State<RecorderScreen> {
  bool _isRecording = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            children: [
              // Screen Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'AI Studio Recorder',
                    style: TextStyle(
                      color: AppTheme.royalDarkBlue,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isRecording
                          ? const Color(0xFFFEE2E2)
                          : AppTheme.iceBlue,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isRecording
                            ? const Color(0xFFEF4444)
                            : AppTheme.softBlue,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 4,
                          backgroundColor: _isRecording
                              ? const Color(0xFFEF4444)
                              : AppTheme.vividBlue,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isRecording ? 'LIVE RECORDING' : 'IDLE',
                          style: TextStyle(
                            color: _isRecording
                                ? const Color(0xFFDC2626)
                                : AppTheme.royalDarkBlue,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Timer Display
              Text(
                _isRecording ? '00:14:28' : '00:00:00',
                style: const TextStyle(
                  color: AppTheme.royalDarkBlue,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'AI Noise Cancellation Active',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 40),

              // Animated Waveform Visualizer
              Container(
                height: 80,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppTheme.iceBlue,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.softBlue),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    24,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 4,
                      height: _isRecording
                          ? (15 + (index % 5) * 12.0)
                          : 8.0,
                      decoration: BoxDecoration(
                        color: _isRecording
                            ? AppTheme.vividBlue
                            : AppTheme.softBlue,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Hero Record Action Button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isRecording = !_isRecording;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording
                        ? const Color(0xFFDC2626)
                        : AppTheme.vividBlue,
                    boxShadow: [
                      BoxShadow(
                        color: (_isRecording
                                ? const Color(0xFFDC2626)
                                : AppTheme.vividBlue)
                            .withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRecording
                        ? Icons.stop_rounded
                        : Icons.mic_rounded,
                    size: 44,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isRecording ? 'Tap to Pause / Stop' : 'Tap to Start Recording',
                style: const TextStyle(
                  color: AppTheme.royalDarkBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
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
