import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../history/domain/models/history_models.dart';
import '../../history/presentation/recording_detail_screen.dart';

class SessionSummaryScreen extends ConsumerWidget {
  final MeetingNote note;
  const SessionSummaryScreen({super.key, required this.note});

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${m}m ${s}s';
  }

  int _wordCount(String text) => text
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .length;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr = DateFormat('d MMM yyyy • hh:mm a').format(note.createdAt);
    final wordCount = _wordCount(note.transcript);

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
        title: Text('Session Summary',
            style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dateStr,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textMuted)),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.success, size: 12),
                      const SizedBox(width: 5),
                      Text('Completed',
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Summary text ──────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderDivider),
              ),
              child: Text(
                note.summary.isNotEmpty
                    ? note.summary
                    : note.transcript.isNotEmpty
                        ? note.transcript
                        : 'No summary available.',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.7),
              ),
            ),
            const SizedBox(height: 24),

            // ── Stats row ─────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _StatBox(
                    icon: Icons.timer_outlined,
                    label: 'Duration',
                    value: note.duration != Duration.zero
                        ? _formatDuration(note.duration)
                        : '—',
                    color: AppColors.primary,
                    bg: AppColors.iceBlue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatBox(
                    icon: Icons.people_outlined,
                    label: 'Speakers',
                    value: '2',
                    color: const Color(0xFF7B1FA2),
                    bg: const Color(0xFFF3E5F5),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatBox(
                    icon: Icons.text_fields_rounded,
                    label: 'Words',
                    value: wordCount > 0
                        ? '${(wordCount / 1000).toStringAsFixed(1)}k'
                            .replaceAll('.0k', ' ')
                            .trim()
                            .isEmpty
                            ? '$wordCount'
                            : '$wordCount'
                        : '0',
                    color: const Color(0xFF00897B),
                    bg: const Color(0xFFE0F2F1),
                  ),
                ),
              ],
            ),

            if (note.reminders.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Key Points',
                  style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              ...note.reminders.map(
                (p) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: AppColors.borderDivider),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Icon(Icons.circle,
                            color: AppColors.primary, size: 7),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(p,
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.5)),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // ── Action buttons ────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        _snack('Share feature coming soon'),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.picture_as_pdf_outlined,
                    label: 'Export PDF',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        _snack('PDF export coming soon'),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.question_answer_rounded,
                    label: 'Ask',
                    primary: true,
                    onTap: () {
                      // Save note first then open chat
                      ref.read(recorderControllerProvider.notifier)
                          .saveCurrentMeeting(note.title);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RecordingDetailScreen(
                              note: note, initialTab: 2),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  SnackBar _snack(String msg) => SnackBar(
        content: Text(msg,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      );
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bg;

  const _StatBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool primary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: primary ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: primary ? AppColors.primary : AppColors.borderDivider),
          boxShadow: primary
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(icon,
                color: primary ? Colors.white : AppColors.textPrimary,
                size: 20),
            const SizedBox(height: 5),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primary ? Colors.white : AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
