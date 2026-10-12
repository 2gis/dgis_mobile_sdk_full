import 'package:flutter/cupertino.dart';

import 'navigation_settings_theme.dart';

/// Slider for an integer setting, snapped to [step].
///
/// When [showValue] is true the current value and [unit] are shown at the end
/// of the label row. Callers that already carry the value inside [label] pass
/// `showValue: false` and may add the boundary captions [minLabel] and
/// [maxLabel] under the track.
///
/// ```dart
/// NavigationSettingsSlider(
///   label: 'Notification volume',
///   value: volume,
///   onChanged: (v) => repository.set(NavigationSettingKeys.soundVolume, v),
///   min: 0,
///   max: 100,
///   theme: theme,
///   unit: '%',
/// )
/// ```
///
/// A range with captions and the value already in the label:
///
/// ```dart
/// NavigationSettingsSlider(
///   label: 'Warning at 0 км/ч',
///   value: speedLimit,
///   onChanged: (v) => repository.set(NavigationSettingKeys.speedLimit, v),
///   min: -15,
///   max: 35,
///   step: 5,
///   theme: theme,
///   showValue: false,
///   minLabel: '-15 км/ч',
///   maxLabel: '+35 км/ч',
/// )
/// ```
class NavigationSettingsSlider extends StatelessWidget {
  /// Descriptive text shown above the track.
  final String label;

  /// Current value. Values outside [min]–[max] are clamped for display.
  final int value;

  /// Called with the snapped value while the user drags.
  final ValueChanged<int> onChanged;

  /// Lowest selectable value; may be negative.
  final int min;

  /// Highest selectable value.
  final int max;

  /// Color and typography tokens.
  final NavigationSettingsTheme theme;

  /// Snap interval. Zero or less makes the track continuous.
  ///
  /// [max] must sit a whole number of steps above [min]. The slider is built
  /// from `(max - min) ~/ step` equal divisions, so a range the step does not
  /// divide snaps to those divisions rather than to the step.
  final int step;

  /// Appended to the displayed value, e.g. `км/ч`. Empty hides it.
  final String unit;

  /// Caption under the left end of the track, e.g. `-15 км/ч`.
  ///
  /// Hidden when null.
  final String? minLabel;

  /// Caption under the right end of the track, e.g. `+35 км/ч`.
  ///
  /// Hidden when null.
  final String? maxLabel;

  /// Whether the current value and [unit] are rendered next to [label].
  ///
  /// Set to false when the caller already carries the value inside [label];
  /// the readout is then omitted entirely. Defaults to true.
  final bool showValue;

  const NavigationSettingsSlider({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
    required this.theme,
    this.step = 1,
    this.unit = '',
    this.minLabel,
    this.maxLabel,
    this.showValue = true,
    super.key,
  }) : assert(
          step <= 0 || (max - min) % step == 0,
          'max - min must be a whole number of steps. The slider is built '
          'from (max - min) ~/ step equal divisions, so a range the step '
          'does not divide snaps to those divisions instead: 0..100 with '
          'step 30 gives 0 / 33 / 67 / 100, not multiples of 30.',
        );

  @override
  Widget build(BuildContext context) {
    final colors = theme.colors;
    final safeValue = value.clamp(min, max);
    final steps = step > 0 ? (max - min) ~/ step : 0;
    final valueText = unit.isEmpty ? '$safeValue' : '$safeValue $unit';
    final hasCaptions = minLabel != null || maxLabel != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.typography.settingLabel.copyWith(
                    color: colors.settingLabel,
                  ),
                ),
              ),
              if (showValue) ...[
                const SizedBox(width: 8),
                Text(
                  valueText,
                  style: theme.typography.settingValue.copyWith(
                    color: colors.settingValue,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          CupertinoSlider(
            value: safeValue.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: steps > 0 ? steps : null,
            activeColor: colors.primary,
            thumbColor: colors.switchThumb,
            onChanged: (raw) => onChanged(raw.round()),
          ),
          if (hasCaptions) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                if (minLabel != null)
                  Expanded(
                    child: Text(
                      minLabel!,
                      textAlign: TextAlign.left,
                      style: theme.typography.settingDescription.copyWith(
                        color: colors.settingDescription,
                      ),
                    ),
                  )
                else
                  const Spacer(),
                if (maxLabel != null)
                  Expanded(
                    child: Text(
                      maxLabel!,
                      textAlign: TextAlign.right,
                      style: theme.typography.settingDescription.copyWith(
                        color: colors.settingDescription,
                      ),
                    ),
                  )
                else
                  const Spacer(),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
