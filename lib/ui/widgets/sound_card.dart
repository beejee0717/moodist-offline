import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/sound.dart';
import '../../state/mixer_provider.dart';

final class SoundCard extends ConsumerWidget {
  const SoundCard({required this.sound, super.key});

  final Sound sound;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mixer = ref.watch(mixerProvider);
    final isActive = mixer.isActive(sound.id);
    final isFavorite = mixer.favorites.contains(sound.id);
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: isActive
          ? theme.colorScheme.primaryContainer
          : theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          try {
            await ref.read(mixerProvider.notifier).toggleSound(sound);
          } on Exception {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Could not play "${sound.label}"')),
              );
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    sound.icon,
                    size: 26,
                    color: isActive
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const Spacer(),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: isFavorite
                        ? 'Remove from favorites'
                        : 'Add to favorites',
                    icon: Icon(
                      isFavorite ? Icons.star : Icons.star_border,
                      size: 20,
                      color: isFavorite
                          ? Colors.amber
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () => ref
                        .read(mixerProvider.notifier)
                        .toggleFavorite(sound.id),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                sound.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurface,
                ),
              ),
              if (isActive)
                Slider(
                  value: mixer.volumeOf(sound.id),
                  onChanged: (value) => ref
                      .read(mixerProvider.notifier)
                      .setVolume(sound.id, value),
                )
              else
                const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
