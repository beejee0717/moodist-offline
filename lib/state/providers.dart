import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../persistence/preset_repository.dart';
import '../services/audio_handler.dart';
import '../services/mixer_service.dart';

/// Overridden in `main()` with the app-wide mixer instance.
final mixerServiceProvider = Provider<MixerService>(
  (ref) => throw UnimplementedError('mixerServiceProvider must be overridden'),
);

/// Overridden in `main()`; null when background audio init failed, in
/// which case playback still works while the app is in the foreground.
final audioHandlerProvider = Provider<MoodistAudioHandler?>((ref) => null);

/// Overridden in `main()` with a repository backed by SharedPreferences.
final presetRepositoryProvider = Provider<PresetRepository>(
  (ref) =>
      throw UnimplementedError('presetRepositoryProvider must be overridden'),
);
