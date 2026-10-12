import 'package:flutter/widgets.dart';

import 'navigation_settings_switch.dart';
import 'navigation_settings_theme.dart';

/// Gap between a label and the description below it.
const _descriptionGap = 2.0;

/// Label and switch row for a binary navigation setting.
class NavigationSettingsToggle extends StatelessWidget {
  /// Descriptive text shown to the left of the switch.
  final String label;

  /// Secondary text shown under [label], or null to hide.
  ///
  /// Lives inside the row padding, so the switch stays centred against the
  /// label and description block. Runs over several lines when needed.
  final String? description;

  /// Current state of the switch.
  final bool value;

  /// Called when the user toggles the switch.
  ///
  /// Not called while [enabled] is false.
  final ValueChanged<bool> onChanged;

  /// Color and typography tokens.
  final NavigationSettingsTheme theme;

  /// When false the row is visually dimmed and not interactive.
  final bool enabled;

  /// Marks the row as a heading for assistive technologies. Used by NavigationSettingsMasterToggle.
  final bool isHeader;

  const NavigationSettingsToggle({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.theme,
    this.description,
    this.enabled = true,
    this.isHeader = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = theme.colors;
    final description = this.description;

    final Widget labelArea;
    if (description == null) {
      // Without a description the row keeps the plain label it always had.
      labelArea = Text(
        label,
        style: theme.typography.settingLabel.copyWith(
          color: enabled ? colors.settingLabel : colors.disabled,
        ),
      );
    } else {
      labelArea = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.typography.settingLabel.copyWith(
              color: enabled ? colors.settingLabel : colors.disabled,
            ),
          ),
          const SizedBox(height: _descriptionGap),
          Text(
            description,
            style: theme.typography.settingDescription.copyWith(
              color: enabled ? colors.settingDescription : colors.disabled,
            ),
          ),
        ],
      );
    }

    return MergeSemantics(
      child: Semantics(
        header: isHeader,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: navigationSettingsRowHeight,
          ),
          child: Padding(
            // Without a description the row is exactly as tall as the design
            // says; with one it grows around the text instead of clipping it.
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: description == null ? 0 : 12,
            ),
            child: Row(
              children: [
                Expanded(child: labelArea),
                const SizedBox(width: 16),
                NavigationSettingsSwitch(
                  value: value,
                  onChanged: enabled ? onChanged : null,
                  theme: theme,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
