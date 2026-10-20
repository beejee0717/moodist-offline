import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/mixer_provider.dart';

String formatRemaining(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  if (minutes >= 60) {
    return '${duration.inHours}h ${minutes % 60}m';
  }
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

Future<void> showSleepTimerSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => const SleepTimerSheet(),
    );

final class SleepTimerSheet extends ConsumerWidget {
  const SleepTimerSheet({super.key});

  static const _options = [5, 10, 15, 30, 45, 60];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deadline = ref.watch(mixerProvider).sleepDeadline;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sleep timer', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              deadline == null
                  ? 'Playback fades out and stops when the timer ends.'
                  : 'Timer ends at '
                        '${TimeOfDay.fromDateTime(deadline).format(context)}.',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final minutes in _options)
                  ChoiceChip(
                    label: Text('$minutes min'),
                    selected: false,
                    onSelected: (_) {
                      ref
                          .read(mixerProvider.notifier)
                          .startSleepTimer(Duration(minutes: minutes));
                      Navigator.pop(context);
                    },
                  ),
                ChoiceChip(
                  label: const Text('Custom…'),
                  selected: false,
                  onSelected: (_) async {
                    final minutes = await _askCustomMinutes(context);
                    if (minutes != null && context.mounted) {
                      ref
                          .read(mixerProvider.notifier)
                          .startSleepTimer(Duration(minutes: minutes));
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
            if (deadline != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.timer_off),
                label: const Text('Cancel timer'),
                onPressed: () {
                  ref.read(mixerProvider.notifier).cancelSleepTimer();
                  Navigator.pop(context);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<int?> _askCustomMinutes(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom timer'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Minutes',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, int.tryParse(controller.text)),
            child: const Text('Start'),
          ),
        ],
      ),
    );
    controller.dispose();
    return (result != null && result > 0) ? result : null;
  }
}
