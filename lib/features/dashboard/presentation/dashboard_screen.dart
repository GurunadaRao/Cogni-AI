import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../history/domain/models/history_models.dart';
import '../../recording/presentation/recording_in_progress_screen.dart';


class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingsAsync = ref.watch(meetingsListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ─────────────────────────────────────────
          SliverAppBar(
            backgroundColor: AppColors.background,
            floating: true,
            snap: true,
            elevation: 0,
            title: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_greeting()},',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.textMuted)),
                  Text('Hello, User 👋',
                      style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined,
                    color: AppColors.textMuted),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const SettingsNavigationScreen()),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Device Status Row ──────────────────────────
                _DeviceStatusCard(),
                const SizedBox(height: 20),

                // ── Start Recording Card ───────────────────────
                _StartRecordingCard(
                  onTap: () async {
                    // Start recording, then push full-screen
                    final notifier =
                        ref.read(recorderControllerProvider.notifier);
                    notifier.toggleRecording();
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) =>
                              const RecordingInProgressScreen()),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // ── Status indicators ──────────────────────────
                _SystemStatusRow(),
                const SizedBox(height: 24),

                // ── Recent Sessions ────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Sessions',
                        style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                    meetingsAsync.maybeWhen(
                      data: (m) => m.isNotEmpty
                          ? GestureDetector(
                              onTap: () {},
                              child: Text('View all',
                                  style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600)),
                            )
                          : const SizedBox.shrink(),
                      orElse: () => const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                meetingsAsync.when(
                  data: (meetings) {
                    if (meetings.isEmpty) return const _EmptyRecentCard();
                    return Column(
                      children: meetings
                          .take(3)
                          .map((m) => _SessionCard(
                              note: m, index: meetings.indexOf(m)))
                          .toList(),
                    );
                  },
                  loading: () => const Center(
                      child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 2.5),
                  )),
                  error: (_, __) => const _EmptyRecentCard(),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Device Status Card ────────────────────────────────────────────────────────
class _DeviceStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Device Status',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
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
                    const Icon(Icons.circle,
                        color: AppColors.success, size: 7),
                    const SizedBox(width: 5),
                    Text('Connected',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Timer display
          Center(
            child: Text(
              '00:00:00',
              style: GoogleFonts.outfit(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 2,
              ),
            ),
          ),
          Center(
            child: Text(
              'Ready to start recording',
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Start Recording Card ──────────────────────────────────────────────────────
class _StartRecordingCard extends StatefulWidget {
  final VoidCallback onTap;
  const _StartRecordingCard({required this.onTap});

  @override
  State<_StartRecordingCard> createState() => _StartRecordingCardState();
}

class _StartRecordingCardState extends State<_StartRecordingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.95, end: 1.05)
        .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDeep, Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _scale,
                  builder: (_, __) => Transform.scale(
                    scale: _scale.value,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mic_rounded,
                          color: Colors.white, size: 26),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Start Recording',
                          style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 3),
                      Text(
                          'Tap to begin real-time transcription',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.75))),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white54, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── System Status Row ─────────────────────────────────────────────────────────
class _SystemStatusRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
            child: _StatusDot(
                label: 'Server\nConnected', icon: Icons.dns_rounded, ok: true)),
        Expanded(
            child: _StatusDot(
                label: 'Device\nConnected',
                icon: Icons.developer_board_rounded,
                ok: true)),
        Expanded(
            child: _StatusDot(
                label: 'Microphone\nReady', icon: Icons.mic_rounded, ok: true)),
        Expanded(
            child: _StatusDot(
                label: 'Storage\nReady',
                icon: Icons.storage_rounded,
                ok: true)),
      ],
    );
  }
}

class _StatusDot extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool ok;
  const _StatusDot(
      {required this.label, required this.icon, required this.ok});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: ok ? AppColors.successBackground : AppColors.errorBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(icon,
              color: ok ? AppColors.success : AppColors.error, size: 18),
        ),
        const SizedBox(height: 6),
        Text(label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 10, color: AppColors.textMuted, height: 1.3)),
      ],
    );
  }
}

// ── Session Card ─────────────────────────────────────────────────────────────
class _SessionCard extends StatelessWidget {
  final MeetingNote note;
  final int index;
  const _SessionCard({required this.note, required this.index});

  String _fmtDuration(Duration d) {
    if (d == Duration.zero) return '';
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMM yyyy • hh:mm a').format(note.createdAt);
    final dur = _fmtDuration(note.duration);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: AppColors.iceBlue,
                borderRadius: BorderRadius.circular(11)),
            child: const Icon(Icons.mic_rounded,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Session #${index + 1}',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(dateStr,
                    style: GoogleFonts.inter(
                        fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          if (dur.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: AppColors.iceBlue,
                  borderRadius: BorderRadius.circular(20)),
              child: Text(dur,
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}

class _EmptyRecentCard extends StatelessWidget {
  const _EmptyRecentCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.iceBlue, width: 2)),
      child: Column(
        children: [
          Icon(Icons.mic_none_rounded,
              size: 44,
              color: AppColors.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text('No recordings yet',
              style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text('Tap "Start Recording" to begin',
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

// Placeholder for settings navigation — the actual Settings screen is in settings/
class SettingsNavigationScreen extends StatelessWidget {
  const SettingsNavigationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // Import and return the actual settings screen
    return const _SettingsProxy();
  }
}

class _SettingsProxy extends StatelessWidget {
  const _SettingsProxy();
  @override
  Widget build(BuildContext context) {
    // Late import to avoid circular — use the settings screen directly
    return const _FullSettingsScreen();
  }
}

// ── Inlined full settings screen ──────────────────────────────────────────────
class _FullSettingsScreen extends StatelessWidget {
  const _FullSettingsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Settings',
            style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          _SectionHeader('Device'),
          _SettingsTile(
              icon: Icons.settings_input_antenna_rounded,
              label: 'Device Configuration',
              onTap: () {}),
          _SettingsTile(
              icon: Icons.restart_alt_rounded,
              label: 'Reconfigure Device',
              onTap: () {}),
          _SettingsTile(
              icon: Icons.health_and_safety_outlined,
              label: 'Check Device Health',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const _DeviceHealthScreen()))),
          _SettingsTile(
              icon: Icons.dns_rounded,
              label: 'Server Settings',
              onTap: () {}),
          const SizedBox(height: 8),
          _SectionHeader('App'),
          _SettingsTile(
              icon: Icons.bar_chart_rounded,
              label: 'Analytics Dashboard',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const _AnalyticsScreen()))),
          _SettingsTile(
              icon: Icons.assignment_outlined,
              label: 'Logs',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const _LogsScreen()))),
          _SettingsTile(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              trailing: Switch(
                value: true,
                onChanged: (_) {},
                activeColor: AppColors.primary,
              ),
              onTap: () {}),
          _SettingsTile(
              icon: Icons.dark_mode_outlined,
              label: 'Theme',
              trailing: Text('System',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textMuted)),
              onTap: () {}),
          const SizedBox(height: 8),
          _SectionHeader('About'),
          _SettingsTile(
              icon: Icons.info_outlined,
              label: 'About App',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const _AboutScreen()))),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final prefs = await SharedPreferencesHelper.instance;
                await prefs.setBool('device_configured', false);
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/', (_) => false);
                }
              },
              icon: const Icon(Icons.logout_rounded),
              label: Text('Logout',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 10),
      child: Text(title.toUpperCase(),
          style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 0.8)),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: AppColors.iceBlue,
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        title: Text(label,
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary)),
        trailing: trailing ??
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted, size: 20),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

// ── Device Health Screen ──────────────────────────────────────────────────────
class _DeviceHealthScreen extends StatelessWidget {
  const _DeviceHealthScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Device Health',
            style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // All Systems banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.successBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 24),
                const SizedBox(width: 12),
                Text('All Systems Operational',
                    style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...[
            ('Microphone', Icons.mic_rounded, 'Working Properly', true),
            ('Speaker', Icons.volume_up_rounded, 'Working Properly', true),
            ('Storage', Icons.storage_rounded, '12.0 GB Free', true),
            ('Battery', Icons.battery_charging_full_rounded, '85%', true),
            ('Network', Icons.wifi_rounded, 'Strong', true),
          ].map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: AppColors.iceBlue,
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(item.$2, color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(item.$1,
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: item.$4
                            ? AppColors.successBackground
                            : AppColors.errorBackground,
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                            item.$4
                                ? Icons.check_circle_rounded
                                : Icons.error_rounded,
                            color: item.$4
                                ? AppColors.success
                                : AppColors.error,
                            size: 12),
                        const SizedBox(width: 5),
                        Text(item.$3,
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: item.$4
                                    ? AppColors.success
                                    : AppColors.error)),
                      ],
                    ),
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

// ── Analytics Screen ──────────────────────────────────────────────────────────
class _AnalyticsScreen extends ConsumerWidget {
  const _AnalyticsScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingsAsync = ref.watch(meetingsListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Analytics',
            style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: AppColors.iceBlue,
                  borderRadius: BorderRadius.circular(20)),
              child: Text('This Week',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: meetingsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (_, __) => const Center(child: Text('Error loading analytics')),
        data: (meetings) {
          final total = meetings.length;
          final totalDur = meetings.fold(
              Duration.zero, (sum, m) => sum + m.duration);
          final avgDur = total > 0
              ? Duration(seconds: totalDur.inSeconds ~/ total)
              : Duration.zero;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Stats grid
              Row(
                children: [
                  Expanded(
                      child: _AnalyticsStat(
                          label: 'Total Sessions',
                          value: '$total')),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _AnalyticsStat(
                          label: 'Total Duration',
                          value: _fmtDur(totalDur))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _AnalyticsStat(
                          label: 'Avg Duration',
                          value: _fmtDur(avgDur))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _AnalyticsStat(
                          label: 'Avg Speakers',
                          value: total > 0 ? '2' : '0')),
                ],
              ),
              const SizedBox(height: 24),
              // Trend chart (simple bar)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Session Trend',
                        style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 16),
                    SizedBox(
                        height: 80,
                        child: _SimpleBarChart(meetings: meetings)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Speaker distribution
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Speaker Distribution',
                        style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 16),
                    ...[
                      ('Doctor', 0.60, AppColors.primary),
                      ('Patient', 0.30, AppColors.success),
                      ('Others', 0.10, AppColors.textMuted),
                    ].map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              SizedBox(
                                  width: 60,
                                  child: Text(item.$1,
                                      style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: AppColors.textMuted))),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: item.$2,
                                    minHeight: 8,
                                    backgroundColor: const Color(0xFFF1F5F9),
                                    color: item.$3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text('${(item.$2 * 100).toInt()}%',
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _fmtDur(Duration d) {
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    if (d.inMinutes > 0) return '${d.inMinutes}m';
    return '${d.inSeconds}s';
  }
}

class _AnalyticsStat extends StatelessWidget {
  final String label;
  final String value;
  const _AnalyticsStat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _SimpleBarChart extends StatelessWidget {
  final List<MeetingNote> meetings;
  const _SimpleBarChart({required this.meetings});

  @override
  Widget build(BuildContext context) {
    final days = List.generate(7, (i) {
      final d = DateTime.now().subtract(Duration(days: 6 - i));
      return meetings
          .where((m) =>
              m.createdAt.year == d.year &&
              m.createdAt.month == d.month &&
              m.createdAt.day == d.day)
          .length;
    });
    final max = days.reduce((a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (i) {
        final height = max == 0 ? 4.0 : 8.0 + 60.0 * days[i] / max;
        final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 300 + i * 50),
                height: height,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: days[i] > 0
                      ? AppColors.primary
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dayLabels[
                    (DateTime.now().weekday - 7 + i) % 7],
                style: GoogleFonts.inter(
                    fontSize: 9, color: AppColors.textMuted),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Logs Screen ───────────────────────────────────────────────────────────────
class _LogsScreen extends StatelessWidget {
  const _LogsScreen();

  static final _logs = [
    ('Recording Started', '10:24:08 AM', Icons.fiber_manual_record_rounded,
        AppColors.error),
    ('Device Connected', '10:24:08 AM', Icons.developer_board_rounded,
        AppColors.success),
    ('Audio Stream Active', '10:24:08 AM', Icons.graphic_eq_rounded,
        AppColors.primary),
    ('Transcript Received', '10:29:08 AM', Icons.subtitles_rounded,
        AppColors.primary),
    ('Recording Stopped', '10:32:08 AM', Icons.stop_rounded,
        AppColors.textMuted),
    ('Processing Summary', '10:32:10 AM', Icons.auto_awesome_rounded,
        const Color(0xFF7B1FA2)),
    ('Summary Generated', '10:32:28 AM', Icons.check_circle_rounded,
        AppColors.success),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Logs',
            style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: AppColors.iceBlue,
                  borderRadius: BorderRadius.circular(20)),
              child: Text('All Logs',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _logs.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
        itemBuilder: (_, i) {
          final log = _logs[i];
          return Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                      color: log.$4.withValues(alpha: 0.12),
                      shape: BoxShape.circle),
                  child: Icon(log.$3, color: log.$4, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(log.$1,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary)),
                ),
                Text(log.$2,
                    style: GoogleFonts.inter(
                        fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── About Screen ──────────────────────────────────────────────────────────────
class _AboutScreen extends StatelessWidget {
  const _AboutScreen();

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
        title: Text('About',
            style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(28),
        children: [
          // Icon / Logo
          Center(
            child: Container(
              width: 90,
              height: 90,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/echo_clip_logo.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text('EchoClip',
                style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
          ),
          Center(
            child: Text('Version 1.0.0',
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textMuted)),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Record Once. Remember Forever.\nSmart AI Voice Recorder & Real-time Assistant.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textMuted, height: 1.6),
            ),
          ),
          const SizedBox(height: 32),
          ...[
            'Privacy Policy',
            'Terms of Service',
            'Open Source Licenses',
          ].map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderDivider),
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(item,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary)),
                trailing: const Icon(Icons.open_in_new_rounded,
                    color: AppColors.textMuted, size: 16),
                onTap: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper for SharedPreferences
class SharedPreferencesHelper {
  static Future<SharedPreferences> get instance =>
      SharedPreferences.getInstance();
}
