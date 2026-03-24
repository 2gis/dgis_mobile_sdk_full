import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../generated/dart_bindings.dart' as sdk;
import '../../util/plugin_name.dart';
import '../moving_segment_progress_indicator.dart';
import '../widget_shadows.dart';

import 'map_widget_color_scheme.dart';
import 'themed_map_controlling_widget.dart';
import 'themed_map_controlling_widget_state.dart';

/// Виджет, отображающий пробочный балл в регионе и переключающий отображение
/// пробок на карте.
/// Может использоваться только как child в MapWidget на любом уровне вложенности.
class TrafficWidget
    extends ThemedMapControllingWidget<TrafficWidgetColorScheme> {
  const TrafficWidget({
    super.key,
    TrafficWidgetColorScheme? light,
    TrafficWidgetColorScheme? dark,
  }) : super(
          light: light ?? defaultLightColorScheme,
          dark: dark ?? defaultDarkColorScheme,
        );

  @override
  ThemedMapControllingWidgetState<TrafficWidget, TrafficWidgetColorScheme>
      createState() => _TrafficWidgetState();

  /// Цветовая схема UI–элемента для светлого режима по умолчанию.
  static const TrafficWidgetColorScheme defaultLightColorScheme =
      TrafficWidgetColorScheme(
    heavyTrafficColor: Color(0xffd15536),
    mediumTrafficColor: Color(0xffffba00),
    lightTrafficColor: Color(0xff58a600),
    unactiveColor: Color(0xffffffff),
    surfaceColor: Color(0xffffffff),
    iconColor: Color(0xff4d4d4d),
    iconColorEnabled: Color(0xff057ddf),
    scoreTextColor: Color(0xff4d4d4d),
    scoreTextColorEnabled: Color(0xffffffff),
  );

  /// Цветовая схема UI–элемента для темного режима по умолчанию.
  static const TrafficWidgetColorScheme defaultDarkColorScheme =
      TrafficWidgetColorScheme(
    heavyTrafficColor: Color(0xffd15536),
    mediumTrafficColor: Color(0xffffba00),
    lightTrafficColor: Color(0xff58a600),
    unactiveColor: Color(0xff121212),
    surfaceColor: Color(0xff121212),
    iconColor: Color(0xffcccccc),
    iconColorEnabled: Color(0xff70aee0),
    scoreTextColor: Color(0xffcccccc),
    scoreTextColorEnabled: Color(0xffffffff),
  );
}

class _TrafficWidgetState extends ThemedMapControllingWidgetState<TrafficWidget,
    TrafficWidgetColorScheme> {
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
          visible: currentState != null &&
              currentState.status != sdk.TrafficControlStatus.hidden,
          child: GestureDetector(
            onTap: () => model.onClicked(),
            child: Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    boxShadow: const [
                      WidgetShadows.mapWidgetBoxShadow,
                    ],
                    color:
                        currentState?.status == sdk.TrafficControlStatus.enabled
                            ? _getTrafficColor(currentState?.score)
                            : colorScheme.surfaceColor, // Inner color
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: currentState?.status ==
                              sdk.TrafficControlStatus.enabled
                          ? colorScheme.surfaceColor
                          : _getTrafficColor(
                              currentState?.score,
                            ), // Border color
                      width: 2, // Border width
                    ),
                  ),
                  child: currentState?.score == null
                      ? Center(
                          child: SvgPicture.asset(
                            'packages/$pluginName/assets/icons/dgis_traffic_icon.svg',
                            width: 24,
                            height: 24,
                            fit: BoxFit.none,
                            colorFilter: ColorFilter.mode(
                              currentState?.status ==
                                      sdk.TrafficControlStatus.enabled
                                  ? colorScheme.iconColorEnabled
                                  : colorScheme.iconColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            currentState!.score.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              leadingDistribution: TextLeadingDistribution.even,
                              height: 1,
                              color: currentState.status ==
                                      sdk.TrafficControlStatus.enabled
                                  ? colorScheme.scoreTextColorEnabled
                                  : colorScheme.scoreTextColor,
                              fontSize: 19,
                            ),
                          ),
                        ),
                ),
                Visibility(
                  visible:
                      currentState?.status == sdk.TrafficControlStatus.loading,
                  child: MovingSegmentProgressIndicator(
                    width: 44,
                    height: 44,
                    thickness: 2,
                    color: colorScheme.lightTrafficColor,
                    segmentSize: 0.15,
                    duration: const Duration(milliseconds: 2500),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getTrafficColor(int? score) {
    if (score == null) {
      return colorScheme.unactiveColor;
    } else if (score <= 3) {
      return colorScheme.lightTrafficColor;
    } else if (score <= 6) {
      return colorScheme.mediumTrafficColor;
    } else {
      return colorScheme.heavyTrafficColor;
    }
  }
}

class TrafficWidgetColorScheme extends MapWidgetColorScheme {
  final Color heavyTrafficColor;
  final Color mediumTrafficColor;
  final Color lightTrafficColor;
  final Color unactiveColor;
  final Color surfaceColor;
  final Color iconColor;
  final Color iconColorEnabled;
  final Color scoreTextColor;
  final Color scoreTextColorEnabled;

  const TrafficWidgetColorScheme({
    required this.heavyTrafficColor,
    required this.mediumTrafficColor,
    required this.lightTrafficColor,
    required this.unactiveColor,
    required this.surfaceColor,
    required this.iconColor,
    required this.iconColorEnabled,
    required this.scoreTextColor,
    required this.scoreTextColorEnabled,
  });

  @override
  TrafficWidgetColorScheme copyWith({
    Color? heavyTrafficColor,
    Color? mediumTrafficColor,
    Color? lightTrafficColor,
    Color? unactiveColor,
    Color? surfaceColor,
    Color? iconColor,
    Color? iconColorEnabled,
    Color? scoreTextColor,
    Color? scoreTextColorEnabled,
  }) {
    return TrafficWidgetColorScheme(
      heavyTrafficColor: heavyTrafficColor ?? this.heavyTrafficColor,
      mediumTrafficColor: mediumTrafficColor ?? this.mediumTrafficColor,
      lightTrafficColor: lightTrafficColor ?? this.lightTrafficColor,
      unactiveColor: unactiveColor ?? this.unactiveColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      iconColor: iconColor ?? this.iconColor,
      iconColorEnabled: iconColorEnabled ?? this.iconColorEnabled,
      scoreTextColor: scoreTextColor ?? this.scoreTextColor,
      scoreTextColorEnabled:
          scoreTextColorEnabled ?? this.scoreTextColorEnabled,
    );
  }
}
