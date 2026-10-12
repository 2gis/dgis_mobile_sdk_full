import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'navigation_settings_theme.dart';

/// Anchors the ambient text style of a settings subtree.
///
/// Settings controls always pass an explicit token style, so only the
/// properties no token sets can leak in from an ancestor. Where the SDK
/// presents its own route — the settings flow and the date-time sheet — there
/// is no `Material` or `Cupertino` text ancestor at all, and Flutter's
/// fallback is the monospace, yellow double-underlined error style. This
/// replaces that fallback with a non-inheriting base so tokens resolve to
/// exactly what they declare.
///
/// Layouts embedded in a host screen are deliberately not wrapped: there the
/// ambient style is the app's own, which tokens should merge with.
@internal
Widget navigationSettingsTextScope({
  required NavigationSettingsTheme theme,
  required Widget child,
}) =>
    DefaultTextStyle(
      style: TextStyle(inherit: false, color: theme.colors.settingLabel),
      child: child,
    );
