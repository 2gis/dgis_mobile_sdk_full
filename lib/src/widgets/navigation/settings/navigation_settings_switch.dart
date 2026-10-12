import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

import 'navigation_settings_theme.dart';

/// Обертка над CupertinoSwitch, которая использует цветовую палитру из [NavigationSettingsTheme].
/// Не экспортируется в публичное АПИ, т.к. примитив и используется в NavigationSettingsToggle.
@internal
class NavigationSettingsSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final NavigationSettingsTheme theme;

  const NavigationSettingsSwitch({
    required this.value,
    required this.onChanged,
    required this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = theme.colors;
    return CupertinoSwitch(
      value: value,
      onChanged: onChanged,
      activeTrackColor: colors.primary,
      inactiveTrackColor: colors.divider,
      thumbColor: colors.switchThumb,
      applyTheme: false,
    );
  }
}
