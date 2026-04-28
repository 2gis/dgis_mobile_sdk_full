import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../generated/dart_bindings.dart' as sdk;
import '../../../../platform/bss_events_source.dart';
import '../../../../util/plugin_name.dart';
import '../../../common/color_ramp.dart';
import '../../../common/dgis_color_scheme.dart';
import '../../../moving_segment_progress_indicator.dart';
import '../../../widget_shadows.dart';
import '../../themed_map_controlling_widget.dart';
import '../../themed_map_controlling_widget_state.dart';
import 'modern_traffic_widget_color_scheme.dart';

/// Map traffic control widget (modern version).
/// Displays the traffic score in a region and toggles the display of traffic on the map.
/// Can only be used as a child of MapWidget at any nesting level.
class ModernTrafficWidget
    extends ThemedMapControllingWidget<ModernTrafficWidgetColorScheme> {
  const ModernTrafficWidget({
    super.key,
    ModernTrafficWidgetColorScheme? light,
    ModernTrafficWidgetColorScheme? dark,
  }) : super(
          light: light ?? defaultLightColorScheme,
          dark: dark ?? defaultDarkColorScheme,
        );

  /// Default color scheme of the UI element for light mode.
  static const ModernTrafficWidgetColorScheme defaultLightColorScheme =
      ModernTrafficWidgetColorScheme(
    backgroundColor: Color(0xFFFFFFFF),
    pressedBackgroundColor: Color(0xFFEEEEEE),
    iconInactiveColor: Color(0xFF141414),
    iconDisabledColor: Color(0xFFB8B8B8),
    iconActiveColor: Color(0xFF057DDF),
    loaderColor: DgisColorScheme.trafficGreen,
    trafficColor: ColorRamp(
      colors: [
        ColorMark(color: DgisColorScheme.trafficGreen, maxValue: 3),
        ColorMark(color: DgisColorScheme.trafficYellow, maxValue: 6),
        ColorMark(color: DgisColorScheme.trafficRed, maxValue: 999),
      ],
    ),
    scoreTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      height: 1,
      color: Color(0xFF141414),
      fontSize: 19,
    ),
    scoreTextStyleEnabled: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      height: 1,
      color: Color(0xFFFFFFFF),
      fontSize: 19,
    ),
    scoreStrokeSize: Size(24, 24),
    borderWidth: 2,
    iconSize: 24,
  );

  /// Default color scheme of the UI element for dark mode.
  static const ModernTrafficWidgetColorScheme defaultDarkColorScheme =
      ModernTrafficWidgetColorScheme(
    backgroundColor: Color(0xFF141414),
    pressedBackgroundColor: Color(0xFF3C3C3C),
    iconInactiveColor: Color(0xFFFFFFFF),
    iconDisabledColor: Color(0xFF5A5A5A),
    iconActiveColor: Color(0xFF70AEE0),
    loaderColor: DgisColorScheme.trafficGreen,
    trafficColor: ColorRamp(
      colors: [
        ColorMark(color: DgisColorScheme.trafficGreen, maxValue: 3),
        ColorMark(color: DgisColorScheme.trafficYellow, maxValue: 6),
        ColorMark(color: DgisColorScheme.trafficRed, maxValue: 999),
      ],
    ),
    scoreTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      height: 1,
      color: Color(0xFFFFFFFF),
      fontSize: 19,
    ),
    scoreTextStyleEnabled: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      height: 1,
      color: Color(0xFF141414),
      fontSize: 19,
    ),
    scoreStrokeSize: Size(24, 24),
    borderWidth: 2,
    iconSize: 24,
  );

  @override
  ThemedMapControllingWidgetState<ModernTrafficWidget,
          ModernTrafficWidgetColorScheme>
      createState() => _ModernTrafficWidgetState();
}

class _ModernTrafficWidgetState extends ThemedMapControllingWidgetState<
    ModernTrafficWidget, ModernTrafficWidgetColorScheme> {
  final ValueNotifier<sdk.TrafficControlState?> state = ValueNotifier(null);

  StreamSubscription<sdk.TrafficControlState>? stateSubscription;
  late sdk.TrafficControlModel model;

  bool isPressed = false;

  @override
  void onAttachedToMap(sdk.Map map) {
    model = withBssEventsSourceFromSdk(() => sdk.TrafficControlModel(map));
    stateSubscription = model.stateChannel.listen((newState) {
      state.value = newState;
    });
  }

  @override
  void onDetachedFromMap() {
    stateSubscription?.cancel();
    stateSubscription = null;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<sdk.TrafficControlState?>(
      valueListenable: state,
      builder: (_, currentState, __) {
        final isEnabled = currentState != null &&
            currentState.status != sdk.TrafficControlStatus.disabled &&
            currentState.status != sdk.TrafficControlStatus.hidden;

        return Visibility(
          maintainSize: true,
          maintainState: true,
          maintainAnimation: true,
          visible: currentState != null &&
              currentState.status != sdk.TrafficControlStatus.hidden,
          child: GestureDetector(
            onTap: () => withBssEventsSourceFromSdk(model.onClicked),
            onTapDown: (_) {
              if (isEnabled) {
                setState(() => isPressed = true);
              }
            },
            onTapUp: (_) {
              setState(() => isPressed = false);
            },
            onLongPressUp: () {
              setState(() => isPressed = false);
            },
            onLongPressCancel: () {
              setState(() => isPressed = false);
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isPressed
                    ? colorScheme.pressedBackgroundColor
                    : colorScheme.backgroundColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: WidgetShadows.modernMapWidgetBoxShadows,
              ),
              child: Center(
                child: _buildContent(currentState),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(sdk.TrafficControlState? currentState) {
    if (currentState?.status == sdk.TrafficControlStatus.loading) {
      return MovingSegmentProgressIndicator(
        width: colorScheme.iconSize,
        height: colorScheme.iconSize,
        thickness: colorScheme.borderWidth,
        color: colorScheme.loaderColor,
        segmentSize: 0.15,
        duration: const Duration(milliseconds: 2500),
      );
    }

    if (currentState?.score == null) {
      return SvgPicture.asset(
        'packages/$pluginName/assets/icons/dgis_traffic_icon.svg',
        width: colorScheme.iconSize,
        height: colorScheme.iconSize,
        fit: BoxFit.scaleDown,
        colorFilter: ColorFilter.mode(
          switch (currentState?.status) {
            sdk.TrafficControlStatus.enabled => colorScheme.iconActiveColor,
            sdk.TrafficControlStatus.disabled => colorScheme.iconDisabledColor,
            _ => colorScheme.iconInactiveColor,
          },
          BlendMode.srcIn,
        ),
      );
    }

    return Container(
      width: colorScheme.scoreStrokeSize.width,
      height: colorScheme.scoreStrokeSize.height,
      decoration: BoxDecoration(
        color: currentState?.status == sdk.TrafficControlStatus.enabled
            ? _getTrafficColor(currentState?.score)
            : colorScheme.backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: _getTrafficColor(currentState?.score),
          width: colorScheme.borderWidth,
        ),
      ),
      child: Center(
        child: Text(
          currentState!.score.toString(),
          textAlign: TextAlign.center,
          style: currentState.status == sdk.TrafficControlStatus.enabled
              ? colorScheme.scoreTextStyleEnabled
              : colorScheme.scoreTextStyle,
        ),
      ),
    );
  }

  Color _getTrafficColor(int? score) {
    if (score == null) {
      return colorScheme.iconInactiveColor;
    } else {
      return colorScheme.trafficColor.getColor(score);
    }
  }
}
