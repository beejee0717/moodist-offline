import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:moodist/data/sound_catalog.dart';

void main() {
  group('SoundCatalog', () {
    test('has 8 categories and 84 sounds', () {
      expect(SoundCatalog.categories, hasLength(8));
      expect(SoundCatalog.allSounds, hasLength(84));
    });

    test('category sound counts match upstream', () {
      final counts = {
        for (final category in SoundCatalog.categories)
          category.id: category.sounds.length,
      };
      expect(counts, {
        'nature': 12,
        'rain': 8,
        'animals': 16,
        'urban': 7,
        'places': 16,
        'transport': 6,
        'things': 16,
        'noise': 3,
      });
    });

    test('sound ids are unique and resolvable', () {
      final ids = [for (final sound in SoundCatalog.allSounds) sound.id];
      expect(ids.toSet(), hasLength(ids.length));
      for (final id in ids) {
        expect(SoundCatalog.byId(id), isNotNull);
      }
      expect(SoundCatalog.byId('does-not-exist'), isNull);
    });

    test('every catalog asset exists on disk and is non-empty', () {
      for (final sound in SoundCatalog.allSounds) {
        final file = File(sound.assetPath);
        expect(
          file.existsSync(),
          isTrue,
          reason: 'Missing asset for ${sound.id}: ${sound.assetPath}',
        );
        expect(
          file.lengthSync(),
          greaterThan(0),
          reason: 'Empty asset for ${sound.id}',
        );
      }
    });
  });
}
