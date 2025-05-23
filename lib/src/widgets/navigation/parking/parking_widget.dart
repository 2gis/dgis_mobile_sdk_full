import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';

import '../../../generated/dart_bindings.dart' as sdk;
import '../../../util/plugin_name.dart';
import '../../common/rounded_corners.dart';
import '../../map/themed_map_controlling_widget.dart';
import '../../map/themed_map_controlling_widget_state.dart';

import '../base_map_control.dart';
import '../navigation_map_control_theme.dart';
import './parking_controller.dart';
import './parking_model.dart';

/// Widget that toggles the display of parking lots on the map.
/// Can only be used as a child of MapWidget at any nesting level.
class NavigationParkingWidget
    extends ThemedMapControllingWidget<NavigationMapControlTheme> {
  final ParkingController controller;
  const NavigationParkingWidget({
    required this.controller,
    super.key,
    this.roundedCorners = const RoundedCorners.all(),
    NavigationMapControlTheme? light,
    NavigationMapControlTheme? dark,
  }) : super(
          light: light ?? NavigationMapControlTheme.defaultLight,
          dark: dark ?? NavigationMapControlTheme.defaultDark,
        );

  final RoundedCorners roundedCorners;

  // ignore: prefer_constructors_over_static_methods
  static NavigationParkingWidget defaultBuilder(
    RoundedCorners corners,
    ParkingController controller,
  ) =>
      NavigationParkingWidget(
        roundedCorners: corners,
        controller: controller,
      );

  @override
  ThemedMapControllingWidgetState<NavigationParkingWidget,
          NavigationMapControlTheme>
      createState() => _NavigationParkingWidgetState();
}

class _NavigationParkingWidgetState extends ThemedMapControllingWidgetState<
    NavigationParkingWidget, NavigationMapControlTheme> {
  @override
  void onAttachedToMap(sdk.Map map) {}

  @override
  void onDetachedFromMap() {}

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ParkingModel>(
      valueListenable: widget.controller.state,
      builder: (_, state, __) {
        return BaseNavigationMapControl(
          theme: colorScheme,
          isEnabled: true,
          roundedCorners: widget.roundedCorners,
          onTap: widget.controller.toggleParking,
          child: Center(
            child: SvgPicture.asset(
              'packages/$pluginName/assets/icons/dgis_parking.svg',
              width: colorScheme.iconSize,
              height: colorScheme.iconSize,
              fit: BoxFit.scaleDown,
              colorFilter: ColorFilter.mode(
                state.isActive
                    ? colorScheme.iconActiveColor
                    : colorScheme.iconInactiveColor,
                BlendMode.srcIn,
              ),
            ),
          ),
        );
      },
    );
  }
}
