import 'dart:async';

import 'package:dgis_mobile_sdk_full/src/util/color_ramp.dart';
import 'package:dgis_mobile_sdk_full/src/util/rounded_corners.dart';
import 'package:dgis_mobile_sdk_full/src/widgets/map/base_map_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../generated/dart_bindings.dart' as sdk;
import '../../util/plugin_name.dart';
import '../moving_segment_progress_indicator.dart';

import 'map_widget_theme.dart';
import 'themed_map_controlling_widget.dart';

/// Виджет, отображающий пробочный балл в регионе и переключающий отображение
/// пробок на карте.
/// Может использоваться только как child в MapWidget на любом уровне вложенности.
class TrafficWidget extends ThemedMapControllingWidget<TrafficWidgetTheme> {
  const TrafficWidget({
    super.key,
    this.roundedCorners = const RoundedCorners.all(),
    TrafficWidgetTheme? light,
    TrafficWidgetTheme? dark,
  }) : super(
          light: light ?? TrafficWidgetTheme.defaultLight,
          dark: dark ?? TrafficWidgetTheme.defaultDark,
        );

  final RoundedCorners roundedCorners;

  @override
  ThemedMapControllingWidgetState<TrafficWidget, TrafficWidgetTheme> createState() => _TrafficWidgetState();
}

class _TrafficWidgetState extends ThemedMapControllingWidgetState<TrafficWidget, TrafficWidgetTheme> {
  final ValueNotifier<sdk.TrafficControlState?> state = ValueNotifier(null);

  StreamSubscription<sdk.TrafficControlState>? stateSubscription;
  late sdk.TrafficControlModel model;

  @override
  void onAttachedToMap(sdk.Map map) {
    model = sdk.TrafficControlModel(map);
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
        return Visibility(
          maintainSize: true,
          maintainState: true,
          maintainAnimation: true,
          child: BaseMapControl(
            theme: theme.controlTheme,
            isEnabled: currentState != null &&
                currentState.status != sdk.TrafficControlStatus.disabled &&
                currentState.status != sdk.TrafficControlStatus.hidden,
            roundedCorners: widget.roundedCorners,
            onTap: () => model.onClicked(),
            child: Center(
              child: switch ((currentState?.score, currentState?.status)) {
                (_, sdk.TrafficControlStatus.loading) => MovingSegmentProgressIndicator(
                    width: theme.controlTheme.iconSize,
                    height: theme.controlTheme.iconSize,
                    thickness: theme.borderWidth,
                    color: theme.loaderColor,
                    segmentSize: 0.15,
                    duration: const Duration(milliseconds: 2500),
                  ),
                (null, _) => Center(
                    child: SvgPicture.asset(
                      'packages/$pluginName/assets/icons/dgis_traffic.svg',
                      width: 24,
                      height: 24,
                      fit: BoxFit.none,
                      colorFilter: ColorFilter.mode(
                        switch (currentState?.status) {
                          sdk.TrafficControlStatus.enabled => theme.controlTheme.iconActiveColor,
                          sdk.TrafficControlStatus.disabled => theme.controlTheme.iconDisabledColor,
                          _ => theme.controlTheme.iconInactiveColor,
                        },
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                (_, _) => Container(
                    width: theme.controlTheme.iconSize,
                    height: theme.controlTheme.iconSize,
                    decoration: BoxDecoration(
                      color: currentState?.status == sdk.TrafficControlStatus.enabled
                          ? _getTrafficColor(currentState?.score)
                          : theme.controlTheme.surfaceColor, // Inner color
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _getTrafficColor(
                          currentState?.score,
                        ),
                        width: 2, // Border width
                      ),
                    ),
                    child: Center(
                      child: Text(
                        currentState!.score.toString(),
                        textAlign: TextAlign.center,
                        style: theme.scoreTextStyle,
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
      return theme.controlTheme.iconInactiveColor;
    } else {
      return theme.trafficColor.getColor(score);
    }
  }
}

class TrafficWidgetTheme extends MapWidgetTheme {
  final ColorRamp<int> trafficColor;
  final double borderWidth;
  final Color loaderColor;
  final TextStyle scoreTextStyle;
  final MapControlTheme controlTheme;

  const TrafficWidgetTheme({
    required this.trafficColor,
    required this.borderWidth,
    required this.loaderColor,
    required this.scoreTextStyle,
    required this.controlTheme,
  });

  static const TrafficWidgetTheme defaultLight = TrafficWidgetTheme(
    trafficColor: ColorRamp(
      colors: [
        ColorMark(
          color: Color(0xff58a600),
          maxValue: 3,
        ),
        ColorMark(
          color: Color(0xffffba00),
          maxValue: 6,
        ),
        ColorMark(
          color: Color(0xffd15536),
          maxValue: 999,
        ),
      ],
    ),
    borderWidth: 2,
    loaderColor: Color(0xff58a600),
    scoreTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      height: 1,
      color: Color(0xff4d4d4d),
      fontSize: 19,
    ),
    controlTheme: MapControlTheme.defaultLight,
  );

  /// Цветовая схема UI–элемента для темного режима по умолчанию.
  static const TrafficWidgetTheme defaultDark = TrafficWidgetTheme(
    trafficColor: ColorRamp(
      colors: [
        ColorMark(
          color: Color(0xff58a600),
          maxValue: 3,
        ),
        ColorMark(
          color: Color(0xffffba00),
          maxValue: 6,
        ),
        ColorMark(
          color: Color(0xffd15536),
          maxValue: 999,
        ),
      ],
    ),
    borderWidth: 2,
    loaderColor: Color(0xff58a600),
    scoreTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      height: 1,
      color: Colors.white,
      fontSize: 19,
    ),
    controlTheme: MapControlTheme.defaultDark,
  );

  @override
  TrafficWidgetTheme copyWith({
    ColorRamp<int>? trafficColor,
    double? borderWidth,
    Color? loaderColor,
    TextStyle? scoreTextStyle,
    MapControlTheme? controlTheme,
  }) {
    return TrafficWidgetTheme(
      trafficColor: trafficColor ?? this.trafficColor,
      borderWidth: borderWidth ?? this.borderWidth,
      loaderColor: loaderColor ?? this.loaderColor,
      scoreTextStyle: scoreTextStyle ?? this.scoreTextStyle,
      controlTheme: controlTheme ?? this.controlTheme,
    );
  }
}
