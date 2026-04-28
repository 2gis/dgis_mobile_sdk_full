import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../generated/dart_bindings.dart' as sdk;
import '../../platform/bss_events_source.dart';
import '../../util/plugin_name.dart';
import '../widget_shadows.dart';

import 'map_widget_color_scheme.dart';
import 'themed_map_controlling_widget.dart';
import 'themed_map_controlling_widget_state.dart';

/// Виджет для изменения режима слежения за геопозицией,
/// направлением (bearing), и осуществления перелета к текущему местоположению.
class MyLocationWidget
    extends ThemedMapControllingWidget<MyLocationWidgetColorScheme> {
  const MyLocationWidget({
    super.key,
    MyLocationWidgetColorScheme? light,
    MyLocationWidgetColorScheme? dark,
  }) : super(
          light: light ?? defaultLightColorScheme,
          dark: dark ?? defaultDarkColorScheme,
        );

  /// Цветовая схема UI–элемента для светлого режима по умолчанию.
  static const MyLocationWidgetColorScheme defaultLightColorScheme =
      MyLocationWidgetColorScheme(
    surfaceColor: Color(0xffffffff),
    iconInactiveColor: Color(0xff4d4d4d),
    iconDisabledColor: Color(0xffcccccc),
    iconActiveColor: Color(0xff057ddf),
  );

  /// Цветовая схема UI–элемента для темного режима по умолчанию.
  static const MyLocationWidgetColorScheme defaultDarkColorScheme =
      MyLocationWidgetColorScheme(
    surfaceColor: Color(0xff121212),
    iconInactiveColor: Color(0xffcccccc),
    iconDisabledColor: Color(0xff808080),
    iconActiveColor: Color(0xff70aee0),
  );

  @override
  ThemedMapControllingWidgetState<MyLocationWidget, MyLocationWidgetColorScheme>
      createState() => _MyLocationWidgetState();
}

class _MyLocationWidgetState extends ThemedMapControllingWidgetState<
    MyLocationWidget, MyLocationWidgetColorScheme> {
  late sdk.MyLocationControlModel model;

  ValueNotifier<bool?> isEnabled = ValueNotifier(null);
  ValueNotifier<sdk.CameraFollowState?> followState = ValueNotifier(null);

  StreamSubscription<bool>? isEnabledSuscription;
  StreamSubscription<sdk.CameraFollowState>? followStateSubscription;

  @override
  void onAttachedToMap(sdk.Map map) {
    model = withBssEventsSourceFromSdk(() => sdk.MyLocationControlModel(map));
    isEnabledSuscription =
        model.isEnabledChannel.listen((state) => isEnabled.value = state);
    followStateSubscription =
        model.followStateChannel.listen((state) => followState.value = state);
  }

  @override
  void onDetachedFromMap() {
    isEnabledSuscription?.cancel();
    followStateSubscription?.cancel();
    isEnabledSuscription = null;
    followStateSubscription = null;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool?>(
      valueListenable: isEnabled,
      builder: (context, isEnabledState, _) {
        return GestureDetector(
          onTap: isEnabledState ?? false ? model.onClicked : () {},
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.surfaceColor,
              shape: BoxShape.circle,
              boxShadow: const [
                WidgetShadows.mapWidgetBoxShadow,
              ],
            ),
            child: ValueListenableBuilder<sdk.CameraFollowState?>(
              valueListenable: followState,
              builder: (context, state, _) {
                final iconAssetName = state ==
                        sdk.CameraFollowState.followDirection
                    ? 'packages/$pluginName/assets/icons/dgis_follow_direction.svg'
                    : 'packages/$pluginName/assets/icons/dgis_my_location.svg';

                Color iconColor;
                if (isEnabledState != true) {
                  iconColor = colorScheme.iconDisabledColor;
                } else {
                  switch (state) {
                    case sdk.CameraFollowState.off:
                      iconColor = colorScheme.iconInactiveColor;
                    case sdk.CameraFollowState.followPosition:
                      iconColor = colorScheme.iconActiveColor;
                    case sdk.CameraFollowState.followDirection:
                      iconColor = colorScheme.iconActiveColor;
                    default:
                      iconColor = colorScheme.iconInactiveColor;
                  }
                }

                return SvgPicture.asset(
                  iconAssetName,
                  width: 24,
                  height: 24,
                  fit: BoxFit.none,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class MyLocationWidgetColorScheme extends MapWidgetColorScheme {
  final Color surfaceColor;
  final Color iconDisabledColor;
  final Color iconInactiveColor;
  final Color iconActiveColor;

  const MyLocationWidgetColorScheme({
    required this.surfaceColor,
    required this.iconDisabledColor,
    required this.iconInactiveColor,
    required this.iconActiveColor,
  });
  @override
  MyLocationWidgetColorScheme copyWith({
    Color? surfaceColor,
    Color? iconDisabledColor,
    Color? iconInactiveColor,
    Color? iconActiveColor,
  }) {
    return MyLocationWidgetColorScheme(
      surfaceColor: surfaceColor ?? this.surfaceColor,
      iconDisabledColor: iconDisabledColor ?? this.iconDisabledColor,
      iconInactiveColor: iconInactiveColor ?? this.iconInactiveColor,
      iconActiveColor: iconActiveColor ?? this.iconActiveColor,
    );
  }
}
