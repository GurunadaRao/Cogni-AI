import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/websocket_client.dart';
import '../../../core/providers/app_providers.dart';
import '../../chat/presentation/chat_screen.dart';
import '../../summary/presentation/summary_screen.dart';
import '../models/recording_models.dart';
import '../providers/recording_controller.dart';
import 'configure_screen.dart';


class RecordingScreen extends ConsumerStatefulWidget {
  const RecordingScreen({super.key});

  @override
  ConsumerState<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends ConsumerState<RecordingScreen> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final recordingStateData = ref.watch(recordingControllerProvider);
    final controller = ref.read(recordingControllerProvider.notifier);
    final state = recordingStateData.recordingState;

    if (state == RecordingState.recording) {
      _scrollToBottom();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Voice Recorder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configure Settings',
            onPressed: state == RecordingState.idle || state == RecordingState.completed
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ConfigureScreen()),
                    );
                  }
                : null,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            children: [
              _buildHeaderStatus(recordingStateData),
              const SizedBox(height: 20),
              Expanded(
                child: _buildTranscriptContainer(context, recordingStateData),
              ),
              const SizedBox(height: 20),
              _buildControlsArea(context, recordingStateData, controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderStatus(RecordingStateData stateData) {
    final state = stateData.recordingState;
    final connState = stateData.connectionState;

    Color statusColor = Colors.grey;
    String statusText = 'Ready to record';

    switch (state) {
      case RecordingState.idle:
        statusText = 'Ready to record';
        statusColor = Colors.green;
        break;
      case RecordingState.starting:
        statusText = 'Starting session...';
        statusColor = Colors.amber;
        break;
      case RecordingState.connecting:
        statusText = 'Connecting to ESP32...';
        statusColor = Colors.orange;
        break;
      case RecordingState.recording:
        statusText = '● Recording';
        statusColor = Colors.red;
        break;
      case RecordingState.stopping:
        statusText = 'Stopping recording...';
        statusColor = Colors.amber;
        break;
      case RecordingState.processing:
        statusText = 'Processing transcript...';
        statusColor = Colors.blue;
        break;
      case RecordingState.completed:
        statusText = 'Recording completed';
        statusColor = Colors.blueAccent;
        break;
      case RecordingState.error:
        statusText = 'Error occurred';
        statusColor = Colors.redAccent;
        break;
      default:
        break;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            if (state == RecordingState.recording)
              Text(
                _formatDuration(stateData.elapsedDuration),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.red,
                ),
              )
            else if (connState != WsConnectionState.disconnected)
              Text(
                connState.name.toUpperCase(),
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranscriptContainer(BuildContext context, RecordingStateData stateData) {
    final state = stateData.recordingState;

    if (state == RecordingState.idle) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mic_none, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Press START to begin recording session',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Live Transcript',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              if (state == RecordingState.recording)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const Divider(height: 20),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
                  children: [
                    ...stateData.transcriptSegments.map(
                      (segment) => TextSpan(
                        text: '${segment.text} ',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                    if (stateData.currentPartialText.isNotEmpty)
                      TextSpan(
                        text: stateData.currentPartialText,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsArea(
    BuildContext context,
    RecordingStateData stateData,
    RecordingController controller,
  ) {
    final state = stateData.recordingState;
    final sessionId = stateData.currentSession?.sessionId;

    if (state == RecordingState.completed && sessionId != null) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SummaryScreen(sessionId: sessionId),
                      ),
                    );
                  },
                  icon: const Icon(Icons.summarize),
                  label: const Text('Summarise'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(sessionId: sessionId),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat),
                  label: const Text('Chat'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => controller.reset(),
            child: const Text('New Recording'),
          ),
        ],
      );
    }

    if (state == RecordingState.recording) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () => controller.stopRecording(),
          icon: const Icon(Icons.stop),
          label: const Text('STOP RECORDING', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }

    final isBusy = state == RecordingState.starting ||
        state == RecordingState.connecting ||
        state == RecordingState.stopping ||
        state == RecordingState.processing;

    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: isBusy
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ConfigureScreen()),
                  );
                },
          icon: const Icon(Icons.tune),
          label: const Text('Configure'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: isBusy ? null : () => controller.startRecording(),
              icon: isBusy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.mic),
              label: Text(
                isBusy ? 'PLEASE WAIT...' : 'START RECORDING',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
