import 'dart:async';

import 'package:dgis_mobile_sdk_full/src/platform/map/map.dart';
import 'package:dgis_mobile_sdk_full/src/util/rounded_corners.dart';
import 'package:dgis_mobile_sdk_full/src/widgets/map/base_map_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../generated/dart_bindings.dart' as sdk;
import '../../util/plugin_name.dart';

import 'themed_map_controlling_widget.dart';

/// Виджет, переключающий отображение парковок на карте.
/// Может использоваться только как child в MapWidget на любом уровне вложенности.
class ParkingWidget extends ThemedMapControllingWidget<MapControlTheme> {
  const ParkingWidget({
    super.key,
    this.roundedCorners = const RoundedCorners.all(),
    MapControlTheme? light,
    MapControlTheme? dark,
  }) : super(
          light: light ?? MapControlTheme.defaultLight,
          dark: dark ?? MapControlTheme.defaultDark,
        );

  final RoundedCorners roundedCorners;

  @override
  ThemedMapControllingWidgetState<ParkingWidget, MapControlTheme> createState() => _TrafficWidgetState();
}

class _TrafficWidgetState extends ThemedMapControllingWidgetState<ParkingWidget, MapControlTheme> {
  ValueNotifier<bool> isEnabled = ValueNotifier(false);
  StreamSubscription<List<String>>? stateSubscription;

  sdk.Map? map;

  @override
  void onAttachedToMap(sdk.Map map) {
    this.map = map;
    stateSubscription = map.attributes.changed.listen((newState) {
      if (newState.contains(SetAttributesNavigationParking.parkingOnAttributeName)) {
        isEnabled.value = map.isParkingOn();
      }
    });
    isEnabled.value = map.isParkingOn();
  }

  @override
  void onDetachedFromMap() {
    stateSubscription?.cancel();
    stateSubscription = null;
    map = null;
  }

  void _toggleParking() {
    map?.setParkingOn(isOn: !isEnabled.value);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isEnabled,
      builder: (_, currentState, __) {
        return BaseMapControl(
          theme: theme,
          isEnabled: true,
          roundedCorners: widget.roundedCorners,
          onTap: _toggleParking,
          child: Center(
            child: SvgPicture.asset(
              'packages/$pluginName/assets/icons/dgis_parking.svg',
              width: theme.iconSize,
              height: theme.iconSize,
              fit: BoxFit.none,
              colorFilter: ColorFilter.mode(
                currentState ? theme.iconActiveColor : theme.iconInactiveColor,
                BlendMode.srcIn,
              ),
            ),
          ),
        );
      },
    );
  }
}
