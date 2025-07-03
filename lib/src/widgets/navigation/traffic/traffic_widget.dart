import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../generated/dart_bindings.dart' as sdk;
import '../../../util/plugin_name.dart';
import '../../common/rounded_corners.dart';
import '../../map/themed_map_controlling_widget.dart';
import '../../map/themed_map_controlling_widget_state.dart';
import '../../moving_segment_progress_indicator.dart';
import '../base_map_control.dart';
import './traffic_controller.dart';
import './traffic_model.dart';
import './traffic_widget_theme.dart';

/// Widget that displays the traffic score in a region and toggles the display of traffic on the map.
/// Can only be used as a child of MapWidget at any nesting level.
class NavigationTrafficWidget
    extends ThemedMapControllingWidget<TrafficWidgetTheme> {
  final TrafficController controller;
  const NavigationTrafficWidget({
    required this.controller,
    super.key,
    this.roundedCorners = const RoundedCorners.all(),
    TrafficWidgetTheme? light,
    TrafficWidgetTheme? dark,
  }) : super(
          light: light ?? TrafficWidgetTheme.defaultLight,
          dark: dark ?? TrafficWidgetTheme.defaultDark,
        );

  final RoundedCorners roundedCorners;

  // ignore: prefer_constructors_over_static_methods
  static NavigationTrafficWidget defaultBuilder(
    RoundedCorners roundedCorners,
    TrafficController controller,
  ) =>
      NavigationTrafficWidget(
        controller: controller,
        roundedCorners: roundedCorners,
      );

  @override
  ThemedMapControllingWidgetState<NavigationTrafficWidget, TrafficWidgetTheme>
      createState() => _NavigationTrafficWidgetState();
}

class _NavigationTrafficWidgetState extends ThemedMapControllingWidgetState<
    NavigationTrafficWidget, TrafficWidgetTheme> {
  @override
  void onAttachedToMap(sdk.Map map) {}

  @override
  void onDetachedFromMap() {}

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TrafficModel>(
      valueListenable: widget.controller.state,
      builder: (_, currentState, __) {
        return Visibility(
          maintainSize: true,
          maintainState: true,
          maintainAnimation: true,
          child: BaseNavigationMapControl(
            theme: colorScheme.controlTheme,
            isEnabled:
                currentState.status != sdk.TrafficControlStatus.disabled &&
                    currentState.status != sdk.TrafficControlStatus.hidden,
            roundedCorners: widget.roundedCorners,
            onTap: widget.controller.toggleTraffic,
            child: Center(
              child: switch ((currentState.score, currentState.status)) {
                (_, sdk.TrafficControlStatus.loading) =>
                  MovingSegmentProgressIndicator(
                    width: colorScheme.controlTheme.iconSize,
                    height: colorScheme.controlTheme.iconSize,
                    thickness: colorScheme.borderWidth,
                    color: colorScheme.loaderColor,
                    segmentSize: 0.15,
                    duration: const Duration(milliseconds: 2500),
                  ),
                (null, _) => Center(
                    child: SvgPicture.asset(
                      'packages/$pluginName/assets/icons/dgis_traffic_icon.svg',
                      width: colorScheme.iconSize,
                      height: colorScheme.iconSize,
                      fit: BoxFit.scaleDown,
                      colorFilter: ColorFilter.mode(
                        switch (currentState.status) {
                          sdk.TrafficControlStatus.enabled =>
                            colorScheme.controlTheme.iconActiveColor,
                          sdk.TrafficControlStatus.disabled =>
                            colorScheme.controlTheme.iconDisabledColor,
                          _ => colorScheme.controlTheme.iconInactiveColor,
                        },
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                (_, _) => Container(
                    width: colorScheme.scoreStrokeSize.width,
                    height: colorScheme.scoreStrokeSize.height,
                    decoration: BoxDecoration(
                      color: currentState.status ==
                              sdk.TrafficControlStatus.enabled
                          ? _getTrafficColor(currentState.score)
                          : colorScheme
                              .controlTheme.surfaceColor, // Inner color
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _getTrafficColor(
                          currentState.score,
                        ),
                        width: 2, // Border width
                      ),
                    ),
                    child: Center(
                      child: Text(
                        currentState.score.toString(),
                        textAlign: TextAlign.center,
                        style: colorScheme.scoreTextStyle,
                      ),
                    ),
                  ),
              },
            ),
          ),
        );
      },
    );
  }

  Color _getTrafficColor(int? score) {
    if (score == null) {
      return colorScheme.controlTheme.iconInactiveColor;
    } else {
      return colorScheme.trafficColor.getColor(score);
    }
  }
}
