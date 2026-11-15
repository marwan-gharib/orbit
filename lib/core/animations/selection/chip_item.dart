import 'package:flutter/material.dart';

/// One selectable chip in an [AnimatedChipSelector].
final class ChipItem<T> {
  const ChipItem({
    required this.value,
    required this.label,
    this.icon,
    this.badge,
  });

  final T value;
  final String label;
  final IconData? icon;

  /// Optional count badge shown on the trailing edge of the chip. Hidden when
  /// null or zero.
  final int? badge;
}
