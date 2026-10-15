/// Overlay widgets and entry points: dialogs, snackbars, bottom sheets, popup menus.
///
/// One import gives every feature its overlays:
///
/// ```dart
/// import 'package:orbit/core/animations/overlays/overlays.dart';
///
/// await showAppDialog<bool>(context: context, builder: (_) => const Confirm());
/// await AppSnackbar.show(context, message: t.saved, type: AppSnackbarType.success);
/// ```
library;

export 'app_bottom_sheet.dart';
export 'app_dialog_route.dart';
export 'app_overlay_motion.dart';
export 'app_popup_menu.dart';
export 'app_snackbar.dart';
