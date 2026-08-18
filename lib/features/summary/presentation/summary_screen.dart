import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../providers/summary_controller.dart';


class SummaryScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const SummaryScreen({super.key, required this.sessionId});

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(summaryControllerProvider.notifier).generateSummary(widget.sessionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final summaryState = ref.watch(summaryControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Session Summary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(summaryControllerProvider.notifier).generateSummary(widget.sessionId);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                  avatar: CircleAvatar(
                    backgroundColor: summaryState.status == SummaryStatus.streaming
                        ? Colors.amber
                        : summaryState.status == SummaryStatus.completed
                            ? Colors.green
                            : Colors.grey,
                  ),
                  label: Text('Status: ${summaryState.status.name.toUpperCase()}'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (summaryState.status == SummaryStatus.loading) ...[
                        const Center(child: CircularProgressIndicator()),
                        const SizedBox(height: 16),
                        const Center(child: Text('Generating summary from transcript...')),
                      ] else if (summaryState.status == SummaryStatus.error) ...[
                        Text(
                          summaryState.errorMessage ?? 'Error generating summary',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ] else ...[
                        Text(
                          summaryState.text.isEmpty
                              ? 'Waiting for summary stream...'
                              : summaryState.text,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                height: 1.5,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
