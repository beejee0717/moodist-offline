import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodist/data/sound_catalog.dart';
import 'package:moodist/models/preset.dart';
import 'package:moodist/models/sound.dart';
import 'package:moodist/persistence/preset_repository.dart';
import 'package:moodist/services/mixer_service.dart';
import 'package:moodist/state/mixer_provider.dart';
import 'package:moodist/state/presets_provider.dart';
import 'package:moodist/state/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A [MixerService] that never touches real audio players.
final class FakeMixerService extends MixerService {
  final List<String> activated = [];
  final List<String> deactivated = [];
  bool playing = false;

  @override
  Future<void> activate(Sound sound, {required double volume}) async {
    activated.add(sound.id);
  }

  @override
  Future<void> deactivate(String soundId) async {
    deactivated.add(soundId);
  }

  @override
  Future<void> setVolume(String soundId, double volume) async {}

  @override
  Future<void> setMasterVolume(double volume) async {}

  @override
  Future<void> playAll() async => playing = true;

  @override
  Future<void> pauseAll() async => playing = false;

  @override
  Future<void> stopAll() async => playing = false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeMixerService fakeMixer;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    fakeMixer = FakeMixerService();
    container = ProviderContainer(
      overrides: [
        mixerServiceProvider.overrideWithValue(fakeMixer),
        presetRepositoryProvider.overrideWithValue(PresetRepository(prefs)),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('MixerNotifier', () {
    test('toggling a sound activates it and starts playback', () async {
      final river = SoundCatalog.byId('river')!;
      await container.read(mixerProvider.notifier).toggleSound(river);
      final state = container.read(mixerProvider);
      expect(state.isActive('river'), isTrue);
      expect(state.isPlaying, isTrue);
      expect(fakeMixer.activated, ['river']);
    });

    test('toggling an active sound removes and deactivates it', () async {
      final river = SoundCatalog.byId('river')!;
      final notifier = container.read(mixerProvider.notifier);
      await notifier.toggleSound(river);
      await notifier.toggleSound(river);
      expect(container.read(mixerProvider).isActive('river'), isFalse);
      expect(fakeMixer.deactivated, ['river']);
    });

    test('applying a preset replaces the mix and plays it', () async {
      await container
          .read(mixerProvider.notifier)
          .applyPreset(const PresetFixture().toPreset());
      final state = container.read(mixerProvider);
      expect(state.volumes, {'rain-on-window': 0.5, 'cafe': 0.3});
      expect(state.isPlaying, isTrue);
      expect(fakeMixer.activated, ['rain-on-window', 'cafe']);
    });

    test('favorites toggle on and off', () {
      final notifier = container.read(mixerProvider.notifier);
      notifier.toggleFavorite('river');
      expect(container.read(mixerProvider).favorites, {'river'});
      notifier.toggleFavorite('river');
      expect(container.read(mixerProvider).favorites, isEmpty);
    });

    test('sleep timer sets and clears a deadline', () {
      final notifier = container.read(mixerProvider.notifier);
      notifier.startSleepTimer(const Duration(minutes: 10));
      expect(container.read(mixerProvider).sleepDeadline, isNotNull);
      notifier.cancelSleepTimer();
      expect(container.read(mixerProvider).sleepDeadline, isNull);
    });
  });

  group('PresetsNotifier', () {
    test('save, rename, and delete round-trip through state', () {
      final notifier = container.read(presetsProvider.notifier);
      notifier.save('Focus', {'river': 0.5});
      expect(container.read(presetsProvider).single.name, 'Focus');
      notifier.rename('Focus', 'Deep focus');
      expect(container.read(presetsProvider).single.name, 'Deep focus');
      expect(container.read(presetsProvider).single.volumes, {'river': 0.5});
      notifier.delete('Deep focus');
      expect(container.read(presetsProvider), isEmpty);
    });

    test('saving with an existing name replaces it', () {
      final notifier = container.read(presetsProvider.notifier);
      notifier.save('Focus', {'river': 0.5});
      notifier.save('Focus', {'waves': 1});
      final presets = container.read(presetsProvider);
      expect(presets, hasLength(1));
      expect(presets.single.volumes, {'waves': 1.0});
    });
  });
}

/// Small helper so the preset test reads declaratively.
final class PresetFixture {
  const PresetFixture();

  Preset toPreset() =>
      const Preset(name: 'Test', volumes: {'rain-on-window': 0.5, 'cafe': 0.3});
}
