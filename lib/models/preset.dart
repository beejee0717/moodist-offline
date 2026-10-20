/// A saved mix: a set of sound ids with their volumes.
final class Preset {
  const Preset({required this.name, required this.volumes});

  factory Preset.fromJson(Map<String, dynamic> json) {
    final rawVolumes = json['volumes'];
    return Preset(
      name: json['name'] as String? ?? 'Untitled',
      volumes: {
        if (rawVolumes is Map)
          for (final entry in rawVolumes.entries)
            entry.key.toString(): (entry.value as num?)?.toDouble() ?? 0.7,
      },
    );
  }

  final String name;

  /// Sound id -> volume (0.0 to 1.0).
  final Map<String, double> volumes;

  Map<String, dynamic> toJson() => {'name': name, 'volumes': volumes};

  Preset copyWith({String? name, Map<String, double>? volumes}) =>
      Preset(name: name ?? this.name, volumes: volumes ?? this.volumes);

  @override
  bool operator ==(Object other) => other is Preset && other.name == name;

  @override
  int get hashCode => name.hashCode;
}
