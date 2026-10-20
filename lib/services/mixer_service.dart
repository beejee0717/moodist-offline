import 'dart:async';

import 'package:just_audio/just_audio.dart';

import '../models/sound.dart';

/// Raised when the audio engine cannot load or play a bundled sound.
final class AudioEngineException implements Exception {
  const AudioEngineException(this.message);

  final String message;

  @override
  String toString() => 'AudioEngineException: $message';
}

/// Owns a pool of [AudioPlayer]s so many sounds can loop at once, each
/// with its own volume and smooth fade in/out.
///
/// Effective volume per sound is:
/// `sound volume * master volume * master fade * per-sound fade`.
class MixerService {
  final Map<String, AudioPlayer> _players = {};
  final Map<String, double> _volumes = {};
  final Map<String, double> _fadeFactors = {};
  final Map<String, Timer> _fadeTimers = {};

  double _masterVolume = 0.8;
  double _masterFade = 1;
  Timer? _masterFadeTimer;
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  Set<String> get activeSoundIds => _players.keys.toSet();

  /// Starts (or preloads, when paused) [sound] at [volume] with a fade in.
  Future<void> activate(Sound sound, {required double volume}) async {
    if (_players.containsKey(sound.id)) {
      await setVolume(sound.id, volume);
      return;
    }
    final player = AudioPlayer();
    _players[sound.id] = player;
    _volumes[sound.id] = volume;
    _fadeFactors[sound.id] = 0;
    try {
      await player.setAsset(sound.assetPath);
      await player.setLoopMode(LoopMode.one);
      _applyVolume(sound.id);
      if (_isPlaying) {
        unawaited(player.play());
        _rampSoundFade(sound.id, 1);
      }
    } on Exception catch (error) {
      _players.remove(sound.id);
      _volumes.remove(sound.id);
      _fadeFactors.remove(sound.id);
      await player.dispose();
      throw AudioEngineException('Could not load "${sound.label}": $error');
    }
  }

  /// Fades [soundId] out, then stops and disposes its player.
  Future<void> deactivate(String soundId) async {
    final player = _players[soundId];
    if (player == null) return;
    _rampSoundFade(soundId, 0);
    // Give the fade time to finish before tearing the player down.
    await Future<void>.delayed(const Duration(milliseconds: 650));
    _fadeTimers[soundId]?.cancel();
    _players.remove(soundId);
    _volumes.remove(soundId);
    _fadeFactors.remove(soundId);
    await player.stop();
    await player.dispose();
  }

  Future<void> setVolume(String soundId, double volume) async {
    _volumes[soundId] = volume.clamp(0, 1).toDouble();
    _applyVolume(soundId);
  }

  Future<void> setMasterVolume(double volume) async {
    _masterVolume = volume.clamp(0, 1).toDouble();
    for (final id in _players.keys) {
      _applyVolume(id);
    }
  }

  /// Fades the whole mix in and starts every active player.
  Future<void> playAll() async {
    _isPlaying = true;
    for (final player in _players.values) {
      unawaited(player.play());
    }
    // Sounds preloaded while paused have a fade factor of 0; ramp them in.
    for (final id in _players.keys) {
      _rampSoundFade(id, 1);
    }
    _rampMasterFade(1);
  }

  /// Fades the whole mix out and pauses every active player.
  Future<void> pauseAll() async {
    _isPlaying = false;
    _rampMasterFade(
      0,
      onDone: () {
        for (final player in _players.values) {
          unawaited(player.pause());
        }
      },
    );
  }

  /// Long fade used by the sleep timer, then pauses playback.
  Future<void> fadeOutAndPause({
    Duration fade = const Duration(seconds: 20),
  }) async {
    _isPlaying = false;
    final steps = 40;
    final stepDuration = fade ~/ steps;
    var step = 0;
    final startFade = _masterFade;
    await Future.doWhile(() async {
      await Future<void>.delayed(stepDuration);
      step++;
      _masterFade = startFade * (1 - step / steps);
      for (final id in _players.keys) {
        _applyVolume(id);
      }
      return step < steps;
    });
    for (final player in _players.values) {
      await player.pause();
    }
    // Restore full fade so the next play() is audible immediately.
    _masterFade = 1;
    for (final id in _players.keys) {
      _applyVolume(id);
    }
  }

  Future<void> stopAll() async {
    _isPlaying = false;
    _masterFadeTimer?.cancel();
    for (final timer in _fadeTimers.values) {
      timer.cancel();
    }
    _fadeTimers.clear();
    final players = _players.values.toList();
    _players.clear();
    _volumes.clear();
    _fadeFactors.clear();
    _masterFade = 1;
    for (final player in players) {
      await player.stop();
      await player.dispose();
    }
  }

  void _applyVolume(String soundId) {
    final player = _players[soundId];
    if (player == null) return;
    final effective =
        (_volumes[soundId] ?? 0.7) *
        _masterVolume *
        _masterFade *
        (_fadeFactors[soundId] ?? 1);
    unawaited(player.setVolume(effective.clamp(0, 1).toDouble()));
  }

  void _rampSoundFade(String soundId, double target) {
    _fadeTimers[soundId]?.cancel();
    const steps = 12;
    const stepDuration = Duration(milliseconds: 50);
    var step = 0;
    final start = _fadeFactors[soundId] ?? 0;
    _fadeTimers[soundId] = Timer.periodic(stepDuration, (timer) {
      step++;
      _fadeFactors[soundId] = start + (target - start) * (step / steps);
      _applyVolume(soundId);
      if (step >= steps) timer.cancel();
    });
  }

  void _rampMasterFade(double target, {void Function()? onDone}) {
    _masterFadeTimer?.cancel();
    const steps = 16;
    const stepDuration = Duration(milliseconds: 50);
    var step = 0;
    final start = _masterFade;
    _masterFadeTimer = Timer.periodic(stepDuration, (timer) {
      step++;
      _masterFade = start + (target - start) * (step / steps);
      for (final id in _players.keys) {
        _applyVolume(id);
      }
      if (step >= steps) {
        timer.cancel();
        onDone?.call();
      }
    });
  }

  Future<void> dispose() async {
    await stopAll();
  }
}
