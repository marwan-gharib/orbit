import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Text and bubble helpers shared by the chart painters.
/// `name: value`, or just `value` when the series has no name.
String chartTooltipLine(String name, String value) =>
    name.isEmpty ? value : '$name: $value';

abstract final class ChartPainting {
  static TextPainter layout(
    String text,
    TextStyle style, {
    double? maxWidth,
    TextAlign align = TextAlign.start,
  }) {
    return TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: align,
      maxLines: 1,
      ellipsis: '\u2026',
    )..layout(maxWidth: maxWidth ?? double.infinity);
  }

  /// Paints [text] with its vertical centre at [center].dy, right-aligned to
  /// [center].dx.
  static void textEndingAt(
    Canvas canvas,
    String text,
    TextStyle style,
    Offset center,
  ) {
    final painter = layout(text, style);
    painter.paint(
      canvas,
      Offset(center.dx - painter.width, center.dy - painter.height / 2),
    );
  }

  /// Paints [text] horizontally centred on [center].dx, top at [center].dy.
  static void textCenteredAt(
    Canvas canvas,
    String text,
    TextStyle style,
    Offset center, {
    double? maxWidth,
  }) {
    final painter = layout(text, style, maxWidth: maxWidth);
    painter.paint(canvas, Offset(center.dx - painter.width / 2, center.dy));
  }

  /// A rounded tooltip bubble with one text line per entry, placed above
  /// [anchor] (below when there is no room) and kept inside [bounds].
  static void bubble(
    Canvas canvas,
    Size bounds,
    Offset anchor,
    List<String> lines, {
    required Color background,
    required TextStyle style,
    required double padding,
    required double radius,
    required double gap,
  }) {
    if (lines.isEmpty) return;
    final painters = [for (final line in lines) layout(line, style)];
    final width = painters.map((p) => p.width).reduce(math.max) + padding * 2;
    final height =
        painters.fold<double>(0, (sum, p) => sum + p.height) + padding * 2;

    var left = anchor.dx - width / 2;
    left = left.clamp(0.0, math.max(0.0, bounds.width - width));
    var top = anchor.dy - height - gap;
    if (top < 0) top = anchor.dy + gap;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, width, height),
      Radius.circular(radius),
    );
    canvas.drawRRect(rect, Paint()..color = background);
    var y = top + padding;
    for (final painter in painters) {
      painter.paint(canvas, Offset(left + padding, y));
      y += painter.height;
    }
  }
}
