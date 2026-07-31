import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

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
                'Meeting History',
                style: TextStyle(
                  color: AppTheme.royalDarkBlue,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Processed transcripts & AI intelligence logs',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),

              // Search & Filter Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.softBlue),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Search transcripts or tags...',
                          hintStyle: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          icon: Icon(Icons.search_rounded,
                              color: AppTheme.softBlue),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.iceBlue,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.softBlue),
                    ),
                    child: const Icon(
                      Icons.filter_list_rounded,
                      color: AppTheme.royalDarkBlue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // History Log Items
              _buildHistoryCard(
                title: 'Sprint Planning & Design Review',
                date: '30 July 2026 • 14:30',
                duration: '45m 12s',
                summary:
                    'Discussed AWS IoT MQTT payload formats, ESP32 device handshake, and Flutter riverpod state architecture.',
                speakers: 3,
              ),
              const SizedBox(height: 14),
              _buildHistoryCard(
                title: 'Backend API Gateway Contract Sync',
                date: '29 July 2026 • 11:00',
                duration: '28m 05s',
                summary:
                    'Finalized REST endpoint schemas for /devices/claim and WebSocket subscription tokens.',
                speakers: 2,
              ),
              const SizedBox(height: 14),
              _buildHistoryCard(
                title: 'ESP32 Firmware Telemetry Test',
                date: '28 July 2026 • 16:45',
                duration: '12m 40s',
                summary:
                    'Verified noise floor threshold sampling at 100ms intervals over MQTT TLS channel.',
                speakers: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard({
    required String title,
    required String date,
    required String duration,
    required String summary,
    required int speakers,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.softBlue.withValues(alpha: 0.6)),
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
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.royalDarkBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.iceBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  duration,
                  style: const TextStyle(
                    color: AppTheme.vividBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            date,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            summary,
            style: const TextStyle(
              color: Color(0xFF1E3A8A),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.people_outline_rounded,
                  size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text(
                '$speakers Speakers identified',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              const Text(
                'View Transcript',
                style: TextStyle(
                  color: AppTheme.vividBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(Icons.arrow_forward_rounded,
                  size: 16, color: AppTheme.vividBlue),
            ],
          ),
        ],
      ),
    );
  }
}
