import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/preset.dart';
import 'providers.dart';

final presetsProvider = NotifierProvider<PresetsNotifier, List<Preset>>(
  PresetsNotifier.new,
);

final class PresetsNotifier extends Notifier<List<Preset>> {
  @override
  List<Preset> build() => ref.read(presetRepositoryProvider).loadPresets();

  /// Saves [volumes] under [name], replacing any preset with that name.
  void save(String name, Map<String, double> volumes) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    state = [
      for (final preset in state)
        if (preset.name != trimmed) preset,
      Preset(name: trimmed, volumes: Map.of(volumes)),
    ];
    _persist();
  }

  void rename(String oldName, String newName) {
    final trimmed = newName.trim();
    if (trimmed.isEmpty || trimmed == oldName) return;
    state = [
      for (final preset in state)
        if (preset.name == oldName) preset.copyWith(name: trimmed) else preset,
    ];
    _persist();
  }

  void delete(String name) {
    state = [
      for (final preset in state)
        if (preset.name != name) preset,
    ];
    _persist();
  }

  void _persist() {
    unawaited(ref.read(presetRepositoryProvider).savePresets(state));
  }
}
