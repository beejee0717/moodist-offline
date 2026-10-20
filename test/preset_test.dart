import 'package:flutter_test/flutter_test.dart';
import 'package:moodist/models/preset.dart';

void main() {
  group('Preset', () {
    test('JSON round-trip preserves name and volumes', () {
      const preset = Preset(
        name: 'Rainy cabin',
        volumes: {'light-rain': 0.8, 'campfire': 0.4},
      );
      final restored = Preset.fromJson(preset.toJson());
      expect(restored.name, 'Rainy cabin');
      expect(restored.volumes, {'light-rain': 0.8, 'campfire': 0.4});
    });

    test('fromJson tolerates missing fields', () {
      final restored = Preset.fromJson(const {});
      expect(restored.name, 'Untitled');
      expect(restored.volumes, isEmpty);
    });
  });
}
