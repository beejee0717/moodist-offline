import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/mixer_provider.dart';
import 'presets_sheet.dart';
import 'sleep_timer_sheet.dart';

final class NowPlayingBar extends ConsumerStatefulWidget {
  const NowPlayingBar({super.key});

  @override
  ConsumerState<NowPlayingBar> createState() => _NowPlayingBarState();
}

final class _NowPlayingBarState extends ConsumerState<NowPlayingBar> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Rebuild once a second so the sleep-timer countdown stays current.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mixer = ref.watch(mixerProvider);
    if (mixer.volumes.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final deadline = mixer.sleepDeadline;
    final remaining = deadline?.difference(DateTime.now());

    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton.filled(
                    tooltip: mixer.isPlaying ? 'Pause' : 'Play',
                    icon: Icon(
                      mixer.isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                    onPressed: () =>
                        ref.read(mixerProvider.notifier).togglePlaying(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${mixer.volumes.length} sound'
                          '${mixer.volumes.length == 1 ? '' : 's'} '
                          '${mixer.isPlaying ? 'playing' : 'paused'}',
                          style: theme.textTheme.titleSmall,
                        ),
                        if (remaining != null && !remaining.isNegative)
                          Text(
                            'Sleep in ${formatRemaining(remaining)}',
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Sleep timer',
                    icon: Icon(
                      Icons.bedtime,
                      color: deadline != null
                          ? theme.colorScheme.primary
                          : null,
                    ),
                    onPressed: () => showSleepTimerSheet(context),
                  ),
                  IconButton(
                    tooltip: 'Presets',
                    icon: const Icon(Icons.library_music),
                    onPressed: () => showPresetsSheet(context),
                  ),
                  IconButton(
                    tooltip: 'Stop all',
                    icon: const Icon(Icons.stop_circle_outlined),
                    onPressed: () =>
                        ref.read(mixerProvider.notifier).clearMix(),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.volume_down, size: 18),
                  Expanded(
                    child: Slider(
                      value: mixer.masterVolume,
                      onChanged: (value) => ref
                          .read(mixerProvider.notifier)
                          .setMasterVolume(value),
                    ),
                  ),
                  const Icon(Icons.volume_up, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
