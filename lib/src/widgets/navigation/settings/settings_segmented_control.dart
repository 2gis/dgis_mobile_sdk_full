import 'package:flutter/widgets.dart';

import 'navigation_settings_theme.dart';
import 'settings_segmented_strip.dart';

/// A single choice inside a [NavigationSettingsSegmentedControl].
@immutable
class NavigationSettingsSegmentedOption<T> {
  /// Value this option stands for.
  final T value;

  /// Text shown inside the segment.
  final String label;

  const NavigationSettingsSegmentedOption({
    required this.value,
    required this.label,
  });
}

/// Single-line label with an optional segmented strip below it.
///
/// > [!NOTE]
/// > The header is rendered above the strip: [label] uses the primary
/// > settings label style and [subtitle], when present, sits under it in the
/// > description style.
///
/// ```dart
/// NavigationSettingsSegmentedControl<SoundMode>(
///   label: 'Голосовые инструкции',
///   subtitle: 'Камеры и дорожные события',
///   selected: SoundMode.important,
///   onChanged: (value) => repository.set(
///     NavigationSettingKeys.soundMode,
///     value,
///   ),
///   theme: theme,
///   options: const [
///     NavigationSettingsSegmentedOption(
///       value: SoundMode.muted,
///       label: 'Выключены',
///     ),
///     NavigationSettingsSegmentedOption(
///       value: SoundMode.important,
///       label: 'Важные',
///     ),
///     NavigationSettingsSegmentedOption(
///       value: SoundMode.all,
///       label: 'Все события',
///     ),
///   ],
/// )
/// ```
class NavigationSettingsSegmentedControl<T> extends StatelessWidget {
  /// Primary text shown above the strip.
  final String label;

  /// Secondary text shown under [label], or null to hide.
  final String? subtitle;

  /// Currently selected value.
  final T selected;

  /// Available choices, rendered in order and sharing the strip width.
  final List<NavigationSettingsSegmentedOption<T>> options;

  /// Called with the value of the segment the user tapped.
  ///
  /// Fired even when the tapped segment is already selected.
  final ValueChanged<T> onChanged;

  /// Color and typography tokens.
  final NavigationSettingsTheme theme;

  const NavigationSettingsSegmentedControl({
    required this.label,
    required this.selected,
    required this.options,
    required this.onChanged,
    required this.theme,
    this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.typography.settingLabel.copyWith(
                  color: theme.colors.settingLabel,
                ),
              ),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    subtitle,
                    style: theme.typography.settingDescription.copyWith(
                      color: theme.colors.settingDescription,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
          child: NavigationSettingsSegmentedStrip(
            theme: theme,
            segments: [
              for (final option in options) _buildSegment(option),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSegment(NavigationSettingsSegmentedOption<T> option) =>
      NavigationSettingsSegment(
        isSelected: option.value == selected,
        onTap: () => onChanged(option.value),
        theme: theme,
        child: Text(
          option.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.typography.segmentedLabel.copyWith(
            color: theme.colors.settingLabel,
          ),
        ),
      );
}
