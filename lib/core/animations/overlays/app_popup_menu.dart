import 'package:flutter/material.dart';

import 'app_overlay_motion.dart';

/// Dropdown that opens from the position of [child] with Orbit's anchored
/// motion: a fast scale and fade that grows out of the anchor.
///
/// The menu opens below the anchor and flips to whichever side has room,
/// staying attached to the edge it grew from. The anchor is laid out by the
/// ambient text direction, so that mirrors in RTL: an anchor at the trailing
/// edge opens the menu off its trailing edge. Motion comes from
/// [AppOverlayMotion.anchoredOf]; with `MediaQuery.disableAnimations` the
/// menu appears in place on the first frame.
///
/// ```dart
/// AppPopupMenu<String>(
///   tooltip: context.strings.moreActions,
///   onSelected: (action) => onRowAction(action),
///   items: [
///     PopupMenuItem(value: 'edit', child: Text(context.strings.edit)),
///     PopupMenuItem(value: 'archive', child: Text(context.strings.archive)),
///   ],
/// )
/// ```
class AppPopupMenu<T> extends StatelessWidget {
  const AppPopupMenu({
    super.key,
    required this.items,
    required this.onSelected,
    this.onCanceled,
    this.child = const Icon(Icons.more_vert),
    this.tooltip,
  });

  /// The menu entries, usually [PopupMenuItem]s.
  final List<PopupMenuEntry<T>> items;

  /// Called with the value of the entry the user picked.
  final PopupMenuItemSelected<T> onSelected;

  /// Called when the menu was dismissed without picking anything.
  final PopupMenuCanceled? onCanceled;

  /// The anchor shown in the trailing icon button; the menu opens from its
  /// position.
  final Widget child;

  /// Accessible name of the anchor button, e.g. "More actions".
  final String? tooltip;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: () => _show(context),
    icon: child,
  );

  Future<void> _show(BuildContext context) {
    final RenderObject? anchorRender = context.findRenderObject();
    if (anchorRender is! RenderBox || !anchorRender.attached) {
      // The anchor is not laid out yet; there is no position to open from.
      return Future<void>.value();
    }
    // Every ambient read happens before the first await, so the context is
    // never used across an async gap.
    final Rect anchorRect =
        anchorRender.localToGlobal(Offset.zero) & anchorRender.size;
    final Size screen = MediaQuery.sizeOf(context);
    // A physical rect on purpose: the route grows the menu toward whichever
    // side has room, staying attached to the edge it grew from. The anchor
    // itself is laid out by the ambient text direction, so that mirrors in
    // RTL — a trailing anchor opens the menu off its trailing edge.
    return showMenu<T>(
      context: context,
      items: items,
      position: RelativeRect.fromLTRB(
        anchorRect.left,
        anchorRect.bottom,
        screen.width - anchorRect.right,
        screen.height - anchorRect.top,
      ),
      popUpAnimationStyle: AppOverlayMotion.anchoredOf(context),
    ).then((T? value) {
      if (value != null) {
        onSelected(value);
      } else {
        onCanceled?.call();
      }
    });
  }
}
