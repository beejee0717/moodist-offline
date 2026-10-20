import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sound_catalog.dart';
import '../models/preset.dart';
import '../models/sound.dart';
import 'providers.dart';

/// Immutable snapshot of the current mix.
final class MixerState {
  const MixerState({
    this.volumes = const {},
    this.favorites = const {},
    this.isPlaying = false,
    this.masterVolume = 0.8,
    this.sleepDeadline,
  });

  /// Active sounds: sound id -> volume (0.0 to 1.0).
  final Map<String, double> volumes;

  final Set<String> favorites;
  final bool isPlaying;
  final double masterVolume;

  /// When the sleep timer fires, or null when no timer is running.
  final DateTime? sleepDeadline;

  bool isActive(String soundId) => volumes.containsKey(soundId);

  double volumeOf(String soundId) => volumes[soundId] ?? 0.7;

  MixerState copyWith({
    Map<String, double>? volumes,
    Set<String>? favorites,
    bool? isPlaying,
    double? masterVolume,
    DateTime? sleepDeadline,
    bool clearSleepDeadline = false,
  }) => MixerState(
    volumes: volumes ?? this.volumes,
    favorites: favorites ?? this.favorites,
    isPlaying: isPlaying ?? this.isPlaying,
    masterVolume: masterVolume ?? this.masterVolume,
    sleepDeadline: clearSleepDeadline
        ? null
        : (sleepDeadline ?? this.sleepDeadline),
  );
}

final mixerProvider = NotifierProvider<MixerNotifier, MixerState>(
  MixerNotifier.new,
);

final class MixerNotifier extends Notifier<MixerState> {
  Timer? _sleepTimer;
  bool _hydrated = false;

  @override
  MixerState build() {
    final repository = ref.read(presetRepositoryProvider);
    final handler = ref.read(audioHandlerProvider);
    handler?.registerCallbacks(
      onPlay: () async => setPlaying(true),
      onPause: () async => setPlaying(false),
      onStop: () async => clearMix(),
    );
    ref.onDispose(() => _sleepTimer?.cancel());

    // Restore the previous soundscape without auto-playing it.
    final lastMix = repository.loadLastMix();
    final restored = <String, double>{
      if (lastMix != null)
        for (final entry in lastMix.entries)
          if (SoundCatalog.byId(entry.key) != null) entry.key: entry.value,
    };
    if (restored.isNotEmpty) {
      Future.microtask(() => _hydrate(restored));
    }
    return MixerState(
      volumes: restored,
      favorites: repository.loadFavorites(),
      masterVolume: repository.loadMasterVolume(),
    );
  }

  Future<void> _hydrate(Map<String, double> restored) async {
    if (_hydrated) return;
    _hydrated = true;
    final mixer = ref.read(mixerServiceProvider);
    await mixer.setMasterVolume(state.masterVolume);
    for (final entry in restored.entries) {
      final sound = SoundCatalog.byId(entry.key);
      if (sound == null) continue;
      try {
        await mixer.activate(sound, volume: entry.value);
      } on Exception {
        // A missing/corrupt asset must not block the rest of the mix.
      }
    }
  }

  Future<void> toggleSound(Sound sound) async {
    final mixer = ref.read(mixerServiceProvider);
    if (state.isActive(sound.id)) {
      state = state.copyWith(volumes: {...state.volumes}..remove(sound.id));
      unawaited(mixer.deactivate(sound.id));
    } else {
      const volume = 0.7;
      state = state.copyWith(volumes: {...state.volumes, sound.id: volume});
      if (!state.isPlaying) state = state.copyWith(isPlaying: true);
      try {
        await mixer.activate(sound, volume: volume);
        if (state.isPlaying) await mixer.playAll();
      } on Exception {
        state = state.copyWith(volumes: {...state.volumes}..remove(sound.id));
        rethrow;
      }
    }
    _persistMix();
    _syncNotification();
  }

  Future<void> setVolume(String soundId, double volume) async {
    state = state.copyWith(
      volumes: {...state.volumes, soundId: volume.clamp(0, 1).toDouble()},
    );
    await ref.read(mixerServiceProvider).setVolume(soundId, volume);
    _persistMix();
  }

  Future<void> setMasterVolume(double volume) async {
    state = state.copyWith(masterVolume: volume.clamp(0, 1).toDouble());
    await ref.read(mixerServiceProvider).setMasterVolume(volume);
    unawaited(
      ref.read(presetRepositoryProvider).saveMasterVolume(state.masterVolume),
    );
  }

  Future<void> setPlaying(bool playing) async {
    if (state.volumes.isEmpty) return;
    state = state.copyWith(isPlaying: playing);
    final mixer = ref.read(mixerServiceProvider);
    if (playing) {
      await mixer.playAll();
    } else {
      await mixer.pauseAll();
    }
    _syncNotification();
  }

  Future<void> togglePlaying() => setPlaying(!state.isPlaying);

  Future<void> clearMix() async {
    _sleepTimer?.cancel();
    state = state.copyWith(
      volumes: const {},
      isPlaying: false,
      clearSleepDeadline: true,
    );
    await ref.read(mixerServiceProvider).stopAll();
    _persistMix();
    _syncNotification();
  }

  Future<void> applyPreset(Preset preset) async {
    final mixer = ref.read(mixerServiceProvider);
    await mixer.stopAll();
    final volumes = <String, double>{
      for (final entry in preset.volumes.entries)
        if (SoundCatalog.byId(entry.key) != null) entry.key: entry.value,
    };
    state = state.copyWith(volumes: volumes, isPlaying: volumes.isNotEmpty);
    for (final entry in volumes.entries) {
      final sound = SoundCatalog.byId(entry.key);
      if (sound == null) continue;
      try {
        await mixer.activate(sound, volume: entry.value);
      } on Exception {
        // Skip sounds that fail to load; keep applying the rest.
      }
    }
    if (volumes.isNotEmpty) await mixer.playAll();
    _persistMix();
    _syncNotification();
  }

  void toggleFavorite(String soundId) {
    final favorites = {...state.favorites};
    if (!favorites.remove(soundId)) favorites.add(soundId);
    state = state.copyWith(favorites: favorites);
    unawaited(ref.read(presetRepositoryProvider).saveFavorites(favorites));
  }

  void startSleepTimer(Duration duration) {
    _sleepTimer?.cancel();
    state = state.copyWith(sleepDeadline: DateTime.now().add(duration));
    _sleepTimer = Timer(duration, _onSleepTimerFired);
    _syncNotification();
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    state = state.copyWith(clearSleepDeadline: true);
  }

  Future<void> _onSleepTimerFired() async {
    state = state.copyWith(isPlaying: false, clearSleepDeadline: true);
    await ref
        .read(mixerServiceProvider)
        .fadeOutAndPause(fade: const Duration(seconds: 20));
    _syncNotification();
  }

  void _persistMix() {
    unawaited(ref.read(presetRepositoryProvider).saveLastMix(state.volumes));
  }

  void _syncNotification() {
    final labels = [
      for (final id in state.volumes.keys) SoundCatalog.byId(id)?.label,
    ].whereType<String>();
    ref
        .read(audioHandlerProvider)
        ?.updatePlayback(
          playing: state.isPlaying,
          summary: labels.isEmpty ? 'No sounds selected' : labels.join(', '),
        );
  }
}
