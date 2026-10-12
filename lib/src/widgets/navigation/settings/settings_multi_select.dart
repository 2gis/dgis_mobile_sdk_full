import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../util/plugin_name.dart';
import 'navigation_settings_divider.dart';
import 'navigation_settings_theme.dart';

const _iconSize = 24.0;

/// A single choice inside a [NavigationSettingsMultiSelect].
@immutable
class NavigationSettingsMultiSelectOption<T> {
  /// Value this option stands for.
  final T value;

  /// Primary text of the option.
  final String label;

  /// Secondary text shown under [label], or null to hide.
  final String? description;

  /// Shown before [label], or null to hide.
  ///
  /// Sizing and color are left to the caller.
  final Widget? icon;

  const NavigationSettingsMultiSelectOption({
    required this.value,
    required this.label,
    this.description,
    this.icon,
  });
}

/// Multi-choice list with a trailing checkmark on every selected option.
///
/// ```dart
/// NavigationSettingsMultiSelect<PublicTransportType>(
///   label: 'Виды общественного транспорта',
///   selected: types,
///   onChanged: (value) => repository.set(
///     NavigationSettingKeys.ptTransportTypes,
///     value,
///   ),
///   theme: theme,
///   options: const [
///     NavigationSettingsMultiSelectOption(
///       value: PublicTransportType.bus,
///       label: 'Автобус',
///     ),
///   ],
/// )
/// ```
class NavigationSettingsMultiSelect<T> extends StatelessWidget {
  /// Caption shown above the options, inside the same section.
  ///
  /// Null hides it — e.g. when the list gets its own section header.
  final String? label;

  /// Available choices, rendered in order.
  final List<NavigationSettingsMultiSelectOption<T>> options;

  /// Currently selected values. Never modified by this widget.
  ///
  /// The control keeps no state of its own — pass a new set back in response
  /// to [onChanged].
  final Set<T> selected;

  /// Called with a new set containing the updated selection.
  final ValueChanged<Set<T>> onChanged;

  /// Color and typography tokens.
  final NavigationSettingsTheme theme;

  /// Replaces the default checkmark glyph.
  ///
  /// Sizing and color are left to the caller.
  final Widget? icon;

  const NavigationSettingsMultiSelect({
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

  Widget _buildOption(NavigationSettingsMultiSelectOption<T> option) {
    final colors = theme.colors;
    final isSelected = selected.contains(option.value);
    final description = option.description;
    final optionIcon = option.icon;

    return MergeSemantics(
      child: Semantics(
        checked: isSelected,
        child: GestureDetector(
          onTap: () => _toggle(option.value, isSelected),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                if (optionIcon != null) ...[
                  optionIcon,
                  const SizedBox(width: 12),
                ],
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

  /// [isSelected] is the state *before* the tap, so the branches invert it:
  /// a selected option is being switched off, an unselected one switched on.
  void _toggle(T value, bool isSelected) {
    final pressed = {value};
    onChanged(
      isSelected
          ? selected.difference(pressed) // was on -> take it out
          : selected.union(pressed), // was off -> put it in
    );
  }

  Widget _defaultIcon(Color color) => SvgPicture.asset(
        'packages/$pluginName/assets/icons/navigation/dgis_check.svg',
        width: _iconSize,
        height: _iconSize,
        fit: BoxFit.scaleDown,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
}
