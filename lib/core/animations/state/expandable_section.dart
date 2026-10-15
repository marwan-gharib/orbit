import 'package:flutter/material.dart';

import '../tokens/app_animation_constants.dart';
import '../tokens/app_curves.dart';
import '../tokens/app_durations.dart';

/// A tappable header over a body with an animated height and an arrow that
/// flips half a turn — for accordions, filter panels and expandable rows.
///
/// Uncontrolled: the section owns its state and the header toggles it.
///
/// ```dart
/// ExpandableSection(
///   header: Text(context.t.orders.filters),
///   body: const FiltersPanel(),
/// )
/// ```
///
/// Controlled: the caller — a Cubit or `setState` — owns the state; the
/// section only reports intent and follows [expanded].
///
/// ```dart
/// ExpandableSection(
///   expanded: isAdvancedOpen,
///   onChanged: (open) => cubit.setAdvanced(open),
///   header: Text(context.t.orders.advanced),
///   body: const AdvancedFilters(),
/// )
/// ```
///
/// [body] leaves the tree as soon as a collapse finishes; pass
/// `maintainState: true` to keep it mounted — zero height, without pointers
/// or semantics — so it can hold scroll or text-field state. When
/// `MediaQuery.disableAnimations` is true the body appears or disappears
/// immediately. The header only responds to taps when the section is
/// uncontrolled or [onChanged] is set.
class ExpandableSection extends StatefulWidget {
  const ExpandableSection({
    super.key,
    required this.header,
    required this.body,
    this.initiallyExpanded = false,
    this.expanded,
    this.onChanged,
    this.maintainState = false,
    this.duration = AppDurations.normal,
    this.curve = AppCurves.standard,
    this.icon = const Icon(Icons.keyboard_arrow_down),
  }) : assert(
         expanded == null || !initiallyExpanded,
         'Pass either expanded (controlled) or initiallyExpanded '
         '(uncontrolled), not both.',
       );

  /// Row shown above the body; the whole row toggles the section.
  final Widget header;

  /// Content revealed under the header.
  final Widget body;

  /// Starting state when the section owns its state.
  final bool initiallyExpanded;

  /// Current state in controlled mode; `null` means uncontrolled.
  final bool? expanded;

  /// Reports the requested new state in both modes; required in controlled
  /// mode for the header to be tappable.
  final ValueChanged<bool>? onChanged;

  /// Keeps [body] mounted while collapsed instead of removing it.
  final bool maintainState;

  /// How long expanding or collapsing takes.
  final Duration duration;

  /// Easing of the height change and of the arrow rotation.
  final Curve curve;

  /// Arrow at the end of the header; rotated half a turn while expanded.
  final Widget icon;

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _sizeFactor;
  late Animation<double> _arrowTurns;
  late bool _internalExpanded;
  bool _disableAnimations = false;

  bool get _isExpanded => widget.expanded ?? _internalExpanded;

  bool get _isInteractive =>
      widget.expanded == null || widget.onChanged != null;

  @override
  void initState() {
    super.initState();
    _internalExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: _isExpanded ? 1.0 : 0.0,
    );
    _refreshAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (_disableAnimations) {
      _controller.value = _isExpanded ? 1.0 : 0.0;
    }
  }

  @override
  void didUpdateWidget(covariant ExpandableSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expanded != null && widget.expanded != oldWidget.expanded) {
      _animateTo(widget.expanded!);
    }
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
    if (widget.curve != oldWidget.curve) {
      _refreshAnimations();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _refreshAnimations() {
    final eased = _controller.drive(CurveTween(curve: widget.curve));
    _sizeFactor = eased;
    _arrowTurns = Tween<double>(
      begin: 0.0,
      end: AppAnimationConstants.expandArrowHalfTurn,
    ).animate(eased);
  }

  void _animateTo(bool target) {
    if (_disableAnimations) {
      _controller.value = target ? 1.0 : 0.0;
      return;
    }
    if (target) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _handleToggle() {
    final next = !_isExpanded;
    if (widget.expanded == null) {
      setState(() => _internalExpanded = next);
      _animateTo(next);
    }
    widget.onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final header = InkWell(
      onTap: _isInteractive ? _handleToggle : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
        child: Row(
          children: [
            Expanded(child: widget.header),
            RotationTransition(turns: _arrowTurns, child: widget.icon),
          ],
        ),
      ),
    );
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, body) {
        if (!_isExpanded &&
            !widget.maintainState &&
            _controller.status == AnimationStatus.dismissed) {
          return header;
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            header,
            SizeTransition(
              alignment: AlignmentDirectional.topStart,
              sizeFactor: _sizeFactor,
              child: IgnorePointer(
                ignoring: !_isExpanded,
                child: ExcludeSemantics(excluding: !_isExpanded, child: body),
              ),
            ),
          ],
        );
      },
      child: widget.body,
    );
  }
}
