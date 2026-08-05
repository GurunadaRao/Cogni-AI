import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../history/domain/models/history_models.dart';
import 'session_summary_screen.dart';

class RecordingInProgressScreen extends ConsumerStatefulWidget {
  const RecordingInProgressScreen({super.key});

  @override
  ConsumerState<RecordingInProgressScreen> createState() =>
      _RecordingInProgressScreenState();
}

class _RecordingInProgressScreenState
    extends ConsumerState<RecordingInProgressScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveCtrl;
  late AnimationController _blinkCtrl;
  int _elapsed = 0;
  bool _running = true;

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..repeat(reverse: true);
    _blinkCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _tick();
  }

  Future<void> _tick() async {
    while (_running && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !_running) break;
      setState(() => _elapsed++);
    }
  }

  @override
  void dispose() {
    _running = false;
    _waveCtrl.dispose();
    _blinkCtrl.dispose();
    super.dispose();
  }

  String _fmt(int s) {
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    return '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:'
        '${sec.toString().padLeft(2, '0')}';
  }

  void _showStopDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) => _StopDialog(
        elapsed: _elapsed,
        onStop: _stopAndSummarize,
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  Future<void> _stopAndSummarize() async {
    Navigator.of(context).pop(); // close dialog
    _running = false;

    final notifier = ref.read(recorderControllerProvider.notifier);
    await notifier.stopRecording();

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => GeneratingSummaryScreen(
          elapsed: _elapsed,
          transcript: ref.read(recorderControllerProvider).liveTranscript,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recorderControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.navyDark,
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    // Recording chip
                    AnimatedBuilder(
                      animation: _blinkCtrl,
                      builder: (_, __) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.recording.withValues(
                              alpha: 0.15 + 0.1 * _blinkCtrl.value),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.recording.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle,
                                color: AppColors.recording,
                                size: 8 + 2 * _blinkCtrl.value),
                            const SizedBox(width: 6),
                            Text('Recording',
                                style: GoogleFonts.inter(
                                    color: AppColors.recording,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.minimize_rounded,
                          color: Colors.white54),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Minimize',
                    ),
                  ],
                ),
              ),

              // ── Tabs ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TabBar(
                  tabs: const [
                    Tab(text: 'Recording'),
                    Tab(text: 'Live Transcripts'),
                  ],
                  labelStyle: GoogleFonts.inter(
                      fontWeight: FontWeight.w700, fontSize: 13),
                  unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white38,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 2.5,
                  dividerColor: Colors.white12,
                ),
              ),

              // ── Tab Views ────────────────────────────────────
              Expanded(
                child: TabBarView(
                  children: [
                    _RecordingTab(
                      elapsed: _elapsed,
                      fmt: _fmt,
                      waveCtrl: _waveCtrl,
                      transcript: state.liveTranscript,
                      onStop: _showStopDialog,
                    ),
                    _TranscriptsTab(transcript: state.liveTranscript),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Recording Tab ────────────────────────────────────────────────────────────
class _RecordingTab extends StatelessWidget {
  final int elapsed;
  final String Function(int) fmt;
  final AnimationController waveCtrl;
  final String transcript;
  final VoidCallback onStop;

  const _RecordingTab({
    required this.elapsed,
    required this.fmt,
    required this.waveCtrl,
    required this.transcript,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        children: [
          const Spacer(),

          // Timer
          Text(
            fmt(elapsed),
            style: GoogleFonts.outfit(
              fontSize: 52,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Recording in progress...',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 32),

          // Stop button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.recording,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 4,
              ),
              onPressed: onStop,
              icon: const Icon(Icons.stop_rounded, size: 20),
              label: Text('Stop Recording',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 32),

          // Status row
          _StatusIconRow(),
          const SizedBox(height: 28),

          // Live level
          _LiveLevelBar(controller: waveCtrl),
          const SizedBox(height: 16),

          // Duration / Speakers footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _FooterStat(label: 'Duration', value: fmt(elapsed)),
              Container(width: 1, height: 32, color: Colors.white12),
              _FooterStat(label: 'Speakers', value: '2'),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _StatusIconRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        _StatusIcon(icon: Icons.dns_rounded, label: 'Server\nConnected', ok: true),
        _StatusIcon(icon: Icons.developer_board_rounded, label: 'Device\nOnline', ok: true),
        _StatusIcon(icon: Icons.volume_up_rounded, label: 'Audio\nConnected', ok: true),
      ],
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool ok;
  const _StatusIcon({required this.icon, required this.label, required this.ok});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: ok
                ? AppColors.success.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon,
              color: ok ? AppColors.success : Colors.white38, size: 20),
        ),
        const SizedBox(height: 6),
        Text(label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.6),
                height: 1.3)),
      ],
    );
  }
}

class _LiveLevelBar extends StatelessWidget {
  final AnimationController controller;
  const _LiveLevelBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Live Level',
                style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.5))),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Good',
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(30, (i) {
                final phase = (controller.value + i / 30) % 1.0;
                final h = 4.0 + 24.0 * (0.5 + 0.5 * math.sin(phase * 2 * math.pi));
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    height: h,
                    decoration: BoxDecoration(
                      color: h > 16
                          ? AppColors.primary.withValues(alpha: 0.8)
                          : AppColors.primary.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}

class _FooterStat extends StatelessWidget {
  final String label;
  final String value;
  const _FooterStat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 2),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.5))),
      ],
    );
  }
}

// ── Live Transcripts Tab ─────────────────────────────────────────────────────
class _TranscriptsTab extends StatelessWidget {
  final String transcript;
  const _TranscriptsTab({required this.transcript});

  @override
  Widget build(BuildContext context) {
    // Parse simple speaker segments for display
    final bubbles = transcript.isEmpty
        ? <_TranscriptBubble>[]
        : _parseBubbles(transcript);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              const Icon(Icons.closed_caption_rounded,
                  color: Colors.white54, size: 16),
              const SizedBox(width: 8),
              Text('Live Transcripts',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70)),
            ],
          ),
        ),
        Expanded(
          child: transcript.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.closed_caption_off_rounded,
                          color: Colors.white24, size: 40),
                      const SizedBox(height: 12),
                      Text('Transcript will appear here...',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.white38)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: bubbles.length,
                  itemBuilder: (_, i) => _TranscriptBubbleTile(
                    bubble: bubbles[i],
                    index: i,
                  ),
                ),
        ),
      ],
    );
  }

  List<_TranscriptBubble> _parseBubbles(String text) {
    // Simple split into alternating speakers for demo
    final sentences = text
        .split(RegExp(r'(?<=[.!?])\s+'))
        .where((s) => s.trim().isNotEmpty)
        .toList();
    return sentences.asMap().entries.map((e) {
      final isDoctor = e.key % 2 == 0;
      return _TranscriptBubble(
        speaker: isDoctor ? 'Doctor' : 'Patient',
        text: e.value.trim(),
        time: '10:${(20 + e.key).toString().padLeft(2, '0')} AM',
        isDoctor: isDoctor,
      );
    }).toList();
  }
}

class _TranscriptBubble {
  final String speaker;
  final String text;
  final String time;
  final bool isDoctor;
  _TranscriptBubble({
    required this.speaker,
    required this.text,
    required this.time,
    required this.isDoctor,
  });
}

class _TranscriptBubbleTile extends StatelessWidget {
  final _TranscriptBubble bubble;
  final int index;
  const _TranscriptBubbleTile({required this.bubble, required this.index});

  @override
  Widget build(BuildContext context) {
    final isRight = !bubble.isDoctor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment:
            isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isRight ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isRight) ...[
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 12),
                ),
                const SizedBox(width: 6),
              ],
              Text(bubble.speaker,
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white54)),
              const SizedBox(width: 6),
              Text(bubble.time,
                  style: GoogleFonts.inter(
                      fontSize: 10, color: Colors.white38)),
              if (isRight) ...[
                const SizedBox(width: 6),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_outline, color: Colors.white, size: 12),
                ),
              ],
            ],
          ),
          const SizedBox(height: 5),
          Align(
            alignment: isRight ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isRight
                    ? AppColors.primary.withValues(alpha: 0.25)
                    : AppColors.navyCard,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(isRight ? 14 : 3),
                  bottomRight: Radius.circular(isRight ? 3 : 14),
                ),
              ),
              child: Text(bubble.text,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.45)),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Stop Confirmation Dialog
// ══════════════════════════════════════════════════════════════════════════════
class _StopDialog extends StatelessWidget {
  final int elapsed;
  final VoidCallback onStop;
  final VoidCallback onCancel;

  const _StopDialog(
      {required this.elapsed,
      required this.onStop,
      required this.onCancel});

  String _fmt(int s) {
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.errorBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mic_off_rounded,
                  color: AppColors.error, size: 32),
            ),
            const SizedBox(height: 20),
            Text('Stop Recording?',
                style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(
              'The recording will be stopped and the\nconversation will be summarized.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textMuted, height: 1.5),
            ),
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer_outlined,
                      color: AppColors.textMuted, size: 16),
                  const SizedBox(width: 6),
                  Text('Duration: ${_fmt(elapsed)}',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: onStop,
                child: Text('Stop & Summarize',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onCancel,
                child: Text('Cancel',
                    style: GoogleFonts.inter(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Generating Summary Progress Screen
// ══════════════════════════════════════════════════════════════════════════════
class GeneratingSummaryScreen extends ConsumerStatefulWidget {
  final int elapsed;
  final String transcript;

  const GeneratingSummaryScreen(
      {super.key, required this.elapsed, required this.transcript});

  @override
  ConsumerState<GeneratingSummaryScreen> createState() =>
      _GeneratingSummaryScreenState();
}

class _GeneratingSummaryScreenState
    extends ConsumerState<GeneratingSummaryScreen> {
  int _step = 0;
  double _progress = 0;

  static const _steps = [
    'Stopping Recording',
    'Processing Audio',
    'Generating Transcript',
    'AI Summarization',
  ];

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(Duration(milliseconds: i == 3 ? 1200 : 700));
      if (!mounted) return;
      setState(() {
        _step = i + 1;
        _progress = (i + 1) / _steps.length;
      });
    }

    // Generate AI summary
    final notifier = ref.read(recorderControllerProvider.notifier);
    await notifier.generateAiSummary();

    if (!mounted) return;
    final state = ref.read(recorderControllerProvider);
    final note = MeetingNote(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Session ${DateString.now()}',
      transcript: widget.transcript,
      summary: state.aiSummary?.rawSummary ?? '',
      reminders: state.aiSummary?.bulletPoints ?? [],
      recordingWavUrl: '',
      createdAt: DateTime.now(),
      duration: Duration(seconds: widget.elapsed),
    );

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => SessionSummaryScreen(note: note),
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
              const SizedBox(height: 24),
              Text('Processing',
                  style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              Text('Please wait while we generate the summary...',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textMuted)),
              const SizedBox(height: 40),

              // Steps
              ...List.generate(_steps.length, (i) {
                final done = i < _step;
                final active = i == _step - 1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: done
                              ? AppColors.successBackground
                              : active
                                  ? AppColors.iceBlue
                                  : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: done
                            ? const Icon(Icons.check_rounded,
                                color: AppColors.success, size: 18)
                            : active
                                ? const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: AppColors.primary))
                                : null,
                      ),
                      const SizedBox(width: 16),
                      Text(_steps[i],
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: done
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: done
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                          )),
                    ],
                  ),
                );
              }),

              const Spacer(),
              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${(_progress * 100).toInt()}%',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 10,
                      backgroundColor: AppColors.iceBlue,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('This may take a few moments',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class DateString {
  static String now() {
    final d = DateTime.now();
    return '${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
}
