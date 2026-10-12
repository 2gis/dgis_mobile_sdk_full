import 'package:flutter/widgets.dart';

import 'navigation_settings_theme.dart';

/// A one-pixel separator between navigation settings rows.
class NavigationSettingsDivider extends StatelessWidget {
  /// Theme that supplies the divider color.
  final NavigationSettingsTheme theme;

  const NavigationSettingsDivider({
    required this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        color: theme.colors.divider,
      );
}
