import 'package:flutter/material.dart';

import 'sound.dart';

/// A named group of [Sound]s, e.g. Nature or Rain.
final class SoundCategory {
  const SoundCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.sounds,
  });

  final String id;
  final String title;
  final IconData icon;
  final List<Sound> sounds;
}
