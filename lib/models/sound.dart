import 'package:flutter/material.dart';

/// A single ambient sound in the catalog.
final class Sound {
  const Sound({
    required this.id,
    required this.label,
    required this.assetPath,
    required this.icon,
  });

  final String id;
  final String label;
  final String assetPath;
  final IconData icon;

  @override
  bool operator ==(Object other) => other is Sound && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
