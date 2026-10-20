import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'persistence/preset_repository.dart';
import 'services/audio_handler.dart';
import 'services/mixer_service.dart';
import 'state/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final mixer = MixerService();

  MoodistAudioHandler? handler;
  try {
    handler = await AudioService.init(
      builder: MoodistAudioHandler.new,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'net.mvze.moodist.audio',
        androidNotificationChannelName: 'Moodist playback',
        androidNotificationOngoing: false,
        androidStopForegroundOnPause: true,
      ),
    );
  } on Exception catch (error) {
    // Background audio is best-effort; foreground playback still works.
    debugPrint('AudioService.init failed: $error');
  }

  try {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  } on Exception catch (error) {
    debugPrint('AudioSession configure failed: $error');
  }

  runApp(
    ProviderScope(
      overrides: [
        mixerServiceProvider.overrideWithValue(mixer),
        audioHandlerProvider.overrideWithValue(handler),
        presetRepositoryProvider.overrideWithValue(PresetRepository(prefs)),
      ],
      child: const MoodistApp(),
    ),
  );
}
