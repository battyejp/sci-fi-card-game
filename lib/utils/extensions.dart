import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  /// Converts a Color to a hex string
  String toHex() {
    final a = (alpha * 255.0).round() & 0xff;
    final r = (red * 255.0).round() & 0xff;
    final g = (green * 255.0).round() & 0xff;
    final b = (blue * 255.0).round() & 0xff;
    return '#${a.toRadixString(16).padLeft(2, '0')}${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
  }
}

extension DoubleExtensions on double {
  /// Clamps a double between min and max values
  double clampTo(double min, double max) {
    return clamp(min, max).toDouble();
  }
}

extension ListExtensions<T> on List<T> {
  /// Safely gets an element at index, returns null if out of bounds
  T? safeGet(int index) {
    if (index >= 0 && index < length) {
      return this[index];
    }
    return null;
  }
  
  /// Shuffles the list in place and returns it
  List<T> shuffled() {
    shuffle();
    return this;
  }
}
