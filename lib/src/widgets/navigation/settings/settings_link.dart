import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../util/plugin_name.dart';
import 'navigation_settings_theme.dart';

/// Row that opens another settings screen.
///
/// Shows [label] on the left, an optional [subtitle] with the current value,
/// and a chevron on the right. Tapping anywhere on the row calls [onTap].
class NavigationSettingsLink extends StatelessWidget {
  /// Primary text of the row.
  final String label;

  /// Called when the user taps the row.
  final VoidCallback onTap;

  /// Color and typography tokens.
  final NavigationSettingsTheme theme;

  /// Current value shown between [label] and the chevron, or null to hide.
  final String? subtitle;

  /// When false the row is visually dimmed and not interactive.
  final bool enabled;

  /// Replaces the default chevron glyph.
  ///
  /// Sizing and color are left to the caller.
  final Widget? icon;

  const NavigationSettingsLink({
    required this.label,
    required this.onTap,
    required this.theme,
    this.subtitle,
    this.enabled = true,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = theme.colors;
    final labelColor = enabled ? colors.settingLabel : colors.disabled;
    final valueColor = enabled ? colors.settingValue : colors.disabled;
    final chevronColor = enabled ? colors.chevron : colors.disabled;

    return MergeSemantics(
      child: Semantics(
        button: true,
        enabled: enabled,
        child: GestureDetector(
          onTap: enabled ? onTap : null,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          style: theme.typography.settingLabel.copyWith(
                            color: labelColor,
                          ),
                        ),
                      ),
                      if (subtitle != null)
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                              style: theme.typography.settingLabel.copyWith(
                                color: valueColor,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                icon ?? _defaultIcon(chevronColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _defaultIcon(Color color) => SvgPicture.asset(
        'packages/$pluginName/assets/icons/navigation/dgis_chevron.svg',
        width: 24,
        height: 24,
        fit: BoxFit.scaleDown,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
}
