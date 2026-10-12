import 'package:flutter/widgets.dart';

import 'navigation_settings_theme.dart';
import 'settings_toggle.dart';

/// Builds the rows gated by a [NavigationSettingsMasterToggle].
///
/// [enabled] mirrors the master switch; the caller decides what gating means.
/// It can forward [enabled] to the `enabled` argument of the child rows, which
/// dims them while the master is off, or hide the rows entirely when the
/// master is off. Both strategies are used in the SDK.
typedef NavigationSettingsGroupBuilder = Widget Function(
  BuildContext context,
  // ignore: avoid_positional_boolean_parameters
  bool enabled,
);

/// Master switch that gates a group of dependent rows.
class NavigationSettingsMasterToggle extends StatelessWidget {
  /// Descriptive text shown to the left of the switch.
  final String label;

  /// Secondary text shown under [label], or null to hide.
  ///
  /// Forwarded to the header toggle; the gated rows stay below it.
  final String? description;

  /// Current state of the master switch.
  final bool value;

  /// Called when the user toggles the master switch.
  final ValueChanged<bool> onChanged;

  /// Color and typography tokens.
  final NavigationSettingsTheme theme;

  /// Builds the gated rows, receiving the master switch state.
  final NavigationSettingsGroupBuilder builder;

  const NavigationSettingsMasterToggle({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.theme,
    required this.builder,
    this.description,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NavigationSettingsToggle(
          label: label,
          description: description,
          value: value,
          onChanged: onChanged,
          theme: theme,
          isHeader: true,
        ),
        builder(context, value),
      ],
    );
  }
}
