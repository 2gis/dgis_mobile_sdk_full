import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../util/plugin_name.dart';
import 'navigation_settings_theme.dart';

/// Label and checkmark row for a binary setting inside a group.
class NavigationSettingsCheckmark extends StatelessWidget {
  /// Descriptive text shown to the left of the checkmark.
  final String label;

  /// Whether the checkmark is shown.
  final bool value;

  /// Called with the inverted value when the user taps the row.
  final ValueChanged<bool> onChanged;

  /// Color and typography tokens.
  final NavigationSettingsTheme theme;

  /// When false the row is visually dimmed and not interactive.
  final bool enabled;

  /// Replaces the default checkmark glyph.
  ///
  /// Sizing and color are left to the caller.
  final Widget? icon;

  /// Optional 24x24 icon rendered before [label].
  ///
  /// Multicolour icons are shown as-is — they are not tinted with the row
  /// colour and are only dimmed via opacity while [enabled] is false.
  final Widget? leading;

  const NavigationSettingsCheckmark({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.theme,
    this.enabled = true,
    this.icon,
    this.leading,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = theme.colors;
    final labelColor = enabled ? colors.settingLabel : colors.disabled;

    return MergeSemantics(
      child: Semantics(
        checked: value,
        enabled: enabled,
        child: GestureDetector(
          onTap: enabled ? () => onChanged(!value) : null,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                if (leading != null) ...[
                  Opacity(
                    opacity: enabled ? 1 : 0.4,
                    child: SizedBox.square(dimension: 24, child: leading),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: theme.typography.settingLabel.copyWith(
                      color: labelColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Opacity(
                  opacity: value && enabled ? 1 : 0,
                  child: icon ?? _defaultIcon(colors.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _defaultIcon(Color color) => SvgPicture.asset(
        'packages/$pluginName/assets/icons/navigation/dgis_check.svg',
        width: 24,
        height: 24,
        fit: BoxFit.scaleDown,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
}
