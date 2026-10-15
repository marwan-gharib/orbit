import 'package:flutter/widgets.dart';
import 'package:orbit/core/responsive/responsive.dart';
import 'package:orbit/core/responsive/responsive_scaler.dart';

/// Wraps the app root: binds the scaling engine on mount, keeps it
/// configured with current metrics, rebuilds the subtree on screen-size
/// changes (rotation, resize, split screen, foldables), and clamps the system
/// text scale once for the whole app. Keep [child] cheap — ordinary MediaQuery
/// changes (the keyboard, say) rebuild only this widget, never the app below.
class ResponsiveScope extends StatefulWidget {
  const ResponsiveScope({
    super.key,
    required this.child,
    this.designSize = Responsive.designSize,
  });

  final Widget child;
  final Size designSize;

  @override
  State<ResponsiveScope> createState() => _ResponsiveScopeState();
}

class _ResponsiveScopeState extends State<ResponsiveScope> {
  Size? _lastSize;

  @override
  void initState() {
    super.initState();
    Responsive.bindDefault();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final metrics = MediaQuery.of(context);
    Responsive.configure(metrics, designSize: widget.designSize);
    if (_lastSize != metrics.size) {
      _lastSize = metrics.size;
      // Scaled values are baked in at build time, so a size change must dirty
      // the subtree explicitly — const/unbuilt parts would keep old sizes.
      (context as Element).visitChildren(_markDirty);
    }
  }

  @override
  void dispose() {
    Responsive.unbind();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metrics = MediaQuery.of(context);
    return MediaQuery(
      data: metrics.copyWith(
        textScaler: metrics.textScaler.clamp(
          maxScaleFactor: ResponsiveScaler.maxTextScale,
        ),
      ),
      child: widget.child,
    );
  }

  void _markDirty(Element element) {
    element.markNeedsBuild();
    element.visitChildren(_markDirty);
  }
}
