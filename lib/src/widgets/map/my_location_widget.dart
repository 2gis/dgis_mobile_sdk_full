import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../generated/dart_bindings.dart' as sdk;
import '../../util/plugin_name.dart';

import 'base_map_control.dart';
import 'themed_map_controlling_widget.dart';

/// Виджет для изменения режима слежения за геопозицией,
/// направлением (bearing), и осуществления перелета к текущему местоположению.
class MyLocationWidget extends ThemedMapControllingWidget<MapControlTheme> {
  const MyLocationWidget({
    super.key,
    MapControlTheme? light,
    MapControlTheme? dark,
  }) : super(
          light: light ?? MapControlTheme.defaultLight,
          dark: dark ?? MapControlTheme.defaultDark,
        );

  @override
  ThemedMapControllingWidgetState<MyLocationWidget, MapControlTheme> createState() => _MyLocationWidgetState();
}

class _MyLocationWidgetState extends ThemedMapControllingWidgetState<MyLocationWidget, MapControlTheme> {
  late sdk.MyLocationControlModel model;

  ValueNotifier<bool?> isEnabled = ValueNotifier(null);
  ValueNotifier<sdk.CameraFollowState?> followState = ValueNotifier(null);

  StreamSubscription<bool>? isEnabledSuscription;
  StreamSubscription<sdk.CameraFollowState>? followStateSubscription;

  @override
  void onAttachedToMap(sdk.Map map) {
    model = sdk.MyLocationControlModel(map);
    isEnabledSuscription = model.isEnabledChannel.listen((state) => isEnabled.value = state);
    followStateSubscription = model.followStateChannel.listen((state) => followState.value = state);
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
        return BaseMapControl(
          theme: theme,
          onTap: isEnabledState ?? false ? model.onClicked : () {},
          isEnabled: isEnabledState ?? false,
          child: ValueListenableBuilder<sdk.CameraFollowState?>(
            valueListenable: followState,
            builder: (context, state, _) {
              final iconAssetName = state == sdk.CameraFollowState.followDirection
                  ? 'packages/$pluginName/assets/icons/dgis_follow_direction.svg'
                  : 'packages/$pluginName/assets/icons/dgis_my_location.svg';

              Color iconColor;
              if (isEnabledState != true) {
                iconColor = theme.iconDisabledColor;
              } else {
                switch (state) {
                  case sdk.CameraFollowState.off:
                    iconColor = theme.iconInactiveColor;
                  case sdk.CameraFollowState.followPosition:
                    iconColor = theme.iconActiveColor;
                  case sdk.CameraFollowState.followDirection:
                    iconColor = theme.iconActiveColor;
                  default:
                    iconColor = theme.iconInactiveColor;
                }
              }

              return Center(
                child: SvgPicture.asset(
                  iconAssetName,
                  width: theme.iconSize,
                  height: theme.iconSize,
                  fit: BoxFit.none,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
