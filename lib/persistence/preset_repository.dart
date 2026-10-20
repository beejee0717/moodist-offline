import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/preset.dart';

/// Persists presets, favorites, and the last active mix locally.
///
/// Everything is stored on-device in [SharedPreferences]; no network is
/// ever involved.
final class PresetRepository {
  const PresetRepository(this._prefs);

  final SharedPreferences _prefs;

  static const String _presetsKey = 'presets';
  static const String _favoritesKey = 'favorites';
  static const String _lastMixKey = 'last_mix';
  static const String _masterVolumeKey = 'master_volume';

  List<Preset> loadPresets() {
    final raw = _prefs.getString(_presetsKey);
    if (raw == null) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return [
        for (final item in decoded)
          if (item is Map<String, dynamic>) Preset.fromJson(item),
      ];
    } on FormatException {
      return const [];
    }
  }

  Future<void> savePresets(List<Preset> presets) async {
    try {
      await _prefs.setString(
        _presetsKey,
        jsonEncode([for (final preset in presets) preset.toJson()]),
      );
    } on Exception {
      // Persistence is best-effort; a failed write must not break playback.
    }
  }

  Set<String> loadFavorites() =>
      (_prefs.getStringList(_favoritesKey) ?? const []).toSet();

  Future<void> saveFavorites(Set<String> favorites) async {
    try {
      await _prefs.setStringList(_favoritesKey, favorites.toList());
    } on Exception {
      // Best-effort, see savePresets.
    }
  }

  /// The last active mix as sound id -> volume, or null if none was saved.
  Map<String, double>? loadLastMix() {
    final raw = _prefs.getString(_lastMixKey);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return {
        for (final entry in decoded.entries)
          entry.key: (entry.value as num?)?.toDouble() ?? 0.7,
      };
    } on FormatException {
      return null;
    }
  }

  Future<void> saveLastMix(Map<String, double> volumes) async {
    try {
      await _prefs.setString(_lastMixKey, jsonEncode(volumes));
    } on Exception {
      // Best-effort, see savePresets.
    }
  }

  double loadMasterVolume() => _prefs.getDouble(_masterVolumeKey) ?? 0.8;

  Future<void> saveMasterVolume(double volume) async {
    try {
      await _prefs.setDouble(_masterVolumeKey, volume);
    } on Exception {
      // Best-effort, see savePresets.
    }
  }
}
