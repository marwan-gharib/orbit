import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../tokens/app_curves.dart';
import '../tokens/app_durations.dart';

/// Formats one intermediate value of an [AnimatedCounter].
typedef AnimatedCounterFormatter = String Function(num value);

/// Counts from the previously displayed number to [value], formatting every
/// intermediate step on tabular figures so the digits never jitter.
///
/// On first display it counts up from zero — pass `animateFromZero: false`
/// to show [value] right away — and on every later change it ticks from the
/// old value to the new one. A rebuild with an unchanged [value] never
/// restarts the count.
///
/// ```dart
/// // Locale-aware integer, e.g. ١٬٢٣٤ while the app is in Arabic.
/// AnimatedCounter(value: total, locale: Localizations.localeOf(context));
///
/// // Fixed number of decimals.
/// AnimatedCounter(value: revenue, decimalPlaces: 2);
///
/// // Custom format, e.g. compact numbers like 1.2K.
/// AnimatedCounter(value: views, formatter: NumberFormat.compact().format);
/// ```
///
/// Formatting: [formatter] wins; otherwise an intl [NumberFormat] in [locale]
/// (intl's current locale when null) with exactly [decimalPlaces] digits
/// after the separator.
class AnimatedCounter extends StatefulWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration = AppDurations.normal,
    this.curve = AppCurves.standard,
    this.decimalPlaces = 0,
    this.locale,
    this.formatter,
    this.animateFromZero = true,
    this.style,
    this.textAlign,
  }) : assert(decimalPlaces >= 0, 'decimalPlaces cannot be negative.');

  /// The number to end up at; animates from the previously displayed one.
  final num value;

  /// How long one count runs.
  final Duration duration;

  /// Easing of the count.
  final Curve curve;

  /// Digits kept after the decimal separator; ignored when [formatter] is set.
  final int decimalPlaces;

  /// Locale tag for the built-in formatting, e.g. `ar` or `en-US`.
  ///
  /// Null formats with intl's current locale. Pass the app locale to get
  /// locale-aware digits: `Localizations.localeOf(context)`.
  final Locale? locale;

  /// Builds the string for every intermediate value; wins over [locale] and
  /// [decimalPlaces]. Example: `NumberFormat.compact().format`.
  final AnimatedCounterFormatter? formatter;

  /// Whether the first display counts up from zero instead of showing
  /// [value] immediately.
  final bool animateFromZero;

  /// Style of the number; tabular figures are appended so digit widths stay
  /// fixed while the value ticks.
  final TextStyle? style;

  /// How the number sits inside the space it is given.
  final TextAlign? textAlign;

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _displayedValue;
  late AnimatedCounterFormatter _formatter;
  late num _from;
  late num _to;
  bool _disableAnimations = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _formatter = _resolveFormatter();
    _retarget(widget.animateFromZero ? 0 : widget.value, widget.value);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (_disableAnimations) {
      _controller.value = 1.0;
    } else if (_controller.status == AnimationStatus.dismissed &&
        _from != _to) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
    if (widget.value != oldWidget.value) {
      final shown = _displayedValue.value;
      _retarget(shown, widget.value);
      if (_disableAnimations) {
        _controller.value = 1.0;
      } else if (shown != widget.value) {
        _controller.forward(from: 0.0);
      }
    } else if (widget.curve != oldWidget.curve) {
      _retarget(_from, _to);
    }
    if (widget.locale != oldWidget.locale ||
        widget.decimalPlaces != oldWidget.decimalPlaces ||
        widget.formatter != oldWidget.formatter) {
      _formatter = _resolveFormatter();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Points the count at [to], starting from [from]; the caller decides
  /// whether to run or jump the controller, so a rebuild alone never
  /// replays an old count.
  void _retarget(num from, num to) {
    _from = from;
    _to = to;
    final eased = _controller.drive(CurveTween(curve: widget.curve));
    _displayedValue = Tween<double>(
      begin: from.toDouble(),
      end: to.toDouble(),
    ).animate(eased);
  }

  /// Builds the intl formatter once per configuration instead of per tick.
  AnimatedCounterFormatter _resolveFormatter() {
    final custom = widget.formatter;
    if (custom != null) {
      return custom;
    }
    final format = NumberFormat.decimalPattern(widget.locale?.toLanguageTag());
    format.minimumFractionDigits = widget.decimalPlaces;
    format.maximumFractionDigits = widget.decimalPlaces;
    return (value) => format.format(value);
  }

  /// Merges tabular figures into the caller's style; the fallback keeps
  /// [TextStyle.inherit] so [DefaultTextStyle] still applies underneath.
  TextStyle _tabularStyle() {
    final base = widget.style ?? const TextStyle();
    return base.copyWith(
      fontFeatures: <FontFeature>[
        ...?base.fontFeatures,
        const FontFeature.tabularFigures(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = _tabularStyle();
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Text(
        _formatter(_displayedValue.value),
        style: style,
        textAlign: widget.textAlign,
      ),
    );
  }
}
