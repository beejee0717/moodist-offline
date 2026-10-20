import 'package:audio_service/audio_service.dart';

/// Bridges the mixer to Android's media notification / lock screen.
///
/// The handler itself holds no playback state: play/pause/stop are
/// forwarded to callbacks registered by the mixer state notifier, and
/// the notifier pushes display state back via [updatePlayback].
final class MoodistAudioHandler extends BaseAudioHandler {
  Future<void> Function()? _onPlay;
  Future<void> Function()? _onPause;
  Future<void> Function()? _onStop;

  void registerCallbacks({
    required Future<void> Function() onPlay,
    required Future<void> Function() onPause,
    required Future<void> Function() onStop,
  }) {
    _onPlay = onPlay;
    _onPause = onPause;
    _onStop = onStop;
  }

  @override
  Future<void> play() async => _onPlay?.call();

  @override
  Future<void> pause() async => _onPause?.call();

  @override
  Future<void> stop() async {
    await _onStop?.call();
    await super.stop();
  }

  /// Refreshes the media notification to reflect the current mix.
  void updatePlayback({required bool playing, required String summary}) {
    mediaItem.add(
      MediaItem(
        id: 'moodist_mix',
        album: 'Moodist (offline)',
        title: 'Ambient mix',
        artist: summary,
        artUri: null,
      ),
    );
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
        ],
        systemActions: const {MediaAction.play, MediaAction.pause},
        androidCompactActionIndices: const [0],
        playing: playing,
        processingState: AudioProcessingState.ready,
      ),
    );
  }
}
