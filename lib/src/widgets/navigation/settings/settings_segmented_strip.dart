import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'navigation_settings_theme.dart';

const _trackHeight = 36.0;
const _trackPadding = EdgeInsets.all(2);
const _trackRadius = 10.0;
const _segmentHeight = 32.0;
const _segmentRadius = 8.0;
const _selectedShadow = [
  BoxShadow(color: Color(0x14000000), blurRadius: 4),
  BoxShadow(color: Color(0x0A000000)),
];

/// Track of a segmented control, holding [NavigationSettingsSegment]s that
/// share its width.
@internal
class NavigationSettingsSegmentedStrip extends StatelessWidget {
  /// Segments rendered in order.
  final List<Widget> segments;

  /// Color and typography tokens.
  final NavigationSettingsTheme theme;

  const NavigationSettingsSegmentedStrip({
    required this.segments,
    required this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Container(
        height: _trackHeight,
        padding: _trackPadding,
        decoration: BoxDecoration(
          color: theme.colors.segmentedTrack,
          borderRadius: BorderRadius.circular(_trackRadius),
        ),
        child: Row(children: segments),
      );
}

/// One choice of a [NavigationSettingsSegmentedStrip].
@internal
class NavigationSettingsSegment extends StatelessWidget {
  /// Whether this segment carries the selected decoration.
  final bool isSelected;

  /// Called on every tap, including when the segment is already selected.
  final VoidCallback onTap;

  /// Content centred inside the segment, e.g. a label or an icon.
  final Widget child;

  /// Color and typography tokens.
  final NavigationSettingsTheme theme;

  const NavigationSettingsSegment({
    required this.isSelected,
    required this.onTap,
    required this.child,
    required this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: MergeSemantics(
          child: Semantics(
            selected: isSelected,
            button: true,
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: _segmentHeight,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colors.segmentedSelectedBackground
                      : null,
                  borderRadius: BorderRadius.circular(_segmentRadius),
                  boxShadow: isSelected ? _selectedShadow : null,
                ),
                child: child,
              ),
            ),
          ),
        ),
      );
}
