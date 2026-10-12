import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../util/plugin_name.dart';
import 'navigation_settings_divider.dart';
import 'navigation_settings_theme.dart';

/// A single choice inside a [NavigationSettingsRadioGroup].
@immutable
class NavigationSettingsRadioOption<T> {
  /// Value this option stands for.
  final T value;

  /// Primary text of the option.
  final String label;

  /// Secondary text shown under [label], or null to hide.
  final String? description;

  const NavigationSettingsRadioOption({
    required this.value,
    required this.label,
    this.description,
  });
}

/// Single-choice list with a trailing checkmark on the selected option.
///
/// ```dart
/// NavigationSettingsRadioGroup<RouteSearchType>(
///   label: 'Тип маршрута',
///   selected: routeType,
///   onChanged: (value) => repository.set(
///     NavigationSettingKeys.carRouteSearchType,
///     value,
///   ),
///   theme: theme,
///   options: const [
///     NavigationSettingsRadioOption(
///       value: RouteSearchType.jam,
///       label: 'С учётом пробок',
///     ),
///     NavigationSettingsRadioOption(
///       value: RouteSearchType.shortest,
///       label: 'Короткий',
///       description: 'Минимальное расстояние',
///     ),
///   ],
/// )
/// ```
class NavigationSettingsRadioGroup<T> extends StatelessWidget {
  /// Caption shown above the options, inside the same section.
  ///
  /// Null hides it — e.g. when the group gets its own section header.
  final String? label;

  /// Available choices, rendered in order.
  final List<NavigationSettingsRadioOption<T>> options;

  /// Currently selected value.
  final T selected;

  /// Called with the value of the option the user picked.
  final ValueChanged<T> onChanged;

  /// Color and typography tokens.
  final NavigationSettingsTheme theme;

  /// Replaces the default checkmark glyph.
  ///
  /// Sizing and color are left to the caller.
  final Widget? icon;

  const NavigationSettingsRadioGroup({
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.theme,
    this.label,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = theme.colors;
    final label = this.label;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              label,
              style: theme.typography.sectionHeader.copyWith(
                color: colors.sectionHeader,
              ),
            ),
          ),
        for (var index = 0; index < options.length; index++) ...[
          if (index > 0) NavigationSettingsDivider(theme: theme),
          _buildOption(options[index]),
        ],
      ],
    );
  }

  Widget _buildOption(NavigationSettingsRadioOption<T> option) {
    final colors = theme.colors;
    final isSelected = option.value == selected;
    final description = option.description;

    return MergeSemantics(
      child: Semantics(
        inMutuallyExclusiveGroup: true,
        selected: isSelected,
        child: GestureDetector(
          onTap: () {
            if (!isSelected) {
              onChanged(option.value);
            }
          },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.label,
                        style: theme.typography.radioOptionLabel.copyWith(
                          color: colors.settingLabel,
                        ),
                      ),
                      if (description != null)
                        Text(
                          description,
                          style:
                              theme.typography.radioOptionDescription.copyWith(
                            color: colors.settingDescription,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Opacity(
                  opacity: isSelected ? 1 : 0,
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
