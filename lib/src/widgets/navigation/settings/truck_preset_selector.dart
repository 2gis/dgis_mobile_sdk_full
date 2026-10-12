import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meta/meta.dart';

import '../../../util/plugin_name.dart';
import 'navigation_settings_theme.dart';
import 'settings_segmented_strip.dart';
import 'truck_preset.dart';

/// Insets of the strip against the surrounding section.
const _padding = EdgeInsets.fromLTRB(16, 16, 16, 10);

const _iconExtent = 24.0;

/// Gap between the strip and the mass captions below it.
const _captionGap = 14.0;

/// Truck size classes as an icon strip with the mass each class stands for.
@internal
class TruckPresetSelector extends StatelessWidget {
  /// Currently selected size class.
  final TruckPreset selected;

  /// Called with the tapped class, including when it is already [selected].
  final ValueChanged<TruckPreset> onChanged;

  /// Renders the caption under a segment, e.g. `3,5`.
  final String Function(TruckPreset preset) captionBuilder;

  /// Color and typography tokens.
  final NavigationSettingsTheme theme;

  const TruckPresetSelector({
    required this.selected,
    required this.onChanged,
    required this.captionBuilder,
    required this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: _padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NavigationSettingsSegmentedStrip(
              theme: theme,
              segments: [
                for (final preset in TruckPreset.values) _segment(preset),
              ],
            ),
            const SizedBox(height: _captionGap),
            Row(
              children: [
                for (final preset in TruckPreset.values)
                  Expanded(
                    child: Text(
                      captionBuilder(preset),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.settingValue.copyWith(
                        color: theme.colors.settingDescription,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      );

  Widget _segment(TruckPreset preset) {
    final isSelected = preset == selected;

    return NavigationSettingsSegment(
      isSelected: isSelected,
      onTap: () => onChanged(preset),
      theme: theme,
      child: SvgPicture.asset(
        'packages/$pluginName/assets/icons/navigation/settings/'
        '${_asset(preset)}.svg',
        width: _iconExtent,
        height: _iconExtent,
        fit: BoxFit.scaleDown,
        colorFilter: ColorFilter.mode(
          isSelected
              ? theme.colors.settingLabel
              : theme.colors.settingDescription,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  String _asset(TruckPreset preset) => switch (preset) {
        TruckPreset.small => 'dgis_truck_preset_small',
        TruckPreset.medium => 'dgis_truck_preset_medium',
        TruckPreset.large => 'dgis_truck_preset_large',
      };
}
