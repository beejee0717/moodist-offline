import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/preset.dart';
import '../../state/mixer_provider.dart';
import '../../state/presets_provider.dart';

Future<void> showPresetsSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => const PresetsSheet(),
    );

final class PresetsSheet extends ConsumerWidget {
  const PresetsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presets = ref.watch(presetsProvider);
    final mixer = ref.watch(mixerProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Presets', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                FilledButton.icon(
                  icon: const Icon(Icons.bookmark_add, size: 18),
                  label: const Text('Save current'),
                  onPressed: mixer.volumes.isEmpty
                      ? null
                      : () async {
                          final name = await _askName(
                            context,
                            title: 'Save preset',
                          );
                          if (name != null) {
                            ref
                                .read(presetsProvider.notifier)
                                .save(name, mixer.volumes);
                          }
                        },
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (presets.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No presets yet. Build a mix, then save it here to '
                  'reapply it instantly.',
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: presets.length,
                  itemBuilder: (context, index) {
                    final preset = presets[index];
                    return ListTile(
                      leading: const Icon(Icons.library_music),
                      title: Text(preset.name),
                      subtitle: Text(
                        '${preset.volumes.length} sound'
                        '${preset.volumes.length == 1 ? '' : 's'}',
                      ),
                      onTap: () async {
                        await ref
                            .read(mixerProvider.notifier)
                            .applyPreset(preset);
                        if (context.mounted) Navigator.pop(context);
                      },
                      trailing: PopupMenuButton<String>(
                        onSelected: (action) =>
                            _onAction(context, ref, action, preset),
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'rename', child: Text('Rename')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _onAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    Preset preset,
  ) async {
    switch (action) {
      case 'rename':
        final name = await _askName(
          context,
          title: 'Rename preset',
          initial: preset.name,
        );
        if (name != null) {
          ref.read(presetsProvider.notifier).rename(preset.name, name);
        }
      case 'delete':
        ref.read(presetsProvider.notifier).delete(preset.name);
    }
  }

  Future<String?> _askName(
    BuildContext context, {
    required String title,
    String initial = '',
  }) async {
    final controller = TextEditingController(text: initial);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    final trimmed = result?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}
