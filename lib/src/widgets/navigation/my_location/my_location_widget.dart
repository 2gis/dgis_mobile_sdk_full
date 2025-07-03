import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';

import '../../../generated/dart_bindings.dart' as sdk;
import '../../map/themed_map_controlling_widget.dart';
import '../../map/themed_map_controlling_widget_state.dart';

import '../base_map_control.dart';
import '../navigation_map_control_theme.dart';
import './my_location_controller.dart';
import './my_location_model.dart';

/// Виджет для изменения режима слежения за геопозицией,
/// направлением (bearing), и осуществления перелета к текущему местоположению.
class NavigationMyLocationWidget
    extends ThemedMapControllingWidget<NavigationMapControlTheme> {
  final MyLocationController controller;
  const NavigationMyLocationWidget({
    required this.controller,
    super.key,
    NavigationMapControlTheme? light,
    NavigationMapControlTheme? dark,
  }) : super(
          light: light ?? NavigationMapControlTheme.defaultLight,
          dark: dark ?? NavigationMapControlTheme.defaultDark,
        );

  // ignore: prefer_constructors_over_static_methods
  static NavigationMyLocationWidget defaultBuilder(
    MyLocationController controller,
  ) =>
      NavigationMyLocationWidget(
        controller: controller,
      );

  @override
  ThemedMapControllingWidgetState<NavigationMyLocationWidget,
      NavigationMapControlTheme> createState() => _MyLocationWidgetState();
}

class _MyLocationWidgetState extends ThemedMapControllingWidgetState<
    NavigationMyLocationWidget, NavigationMapControlTheme> {
  @override
  void onAttachedToMap(sdk.Map map) {}

  @override
  void onDetachedFromMap() {}

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MyLocationModel>(
      valueListenable: widget.controller.state,
      builder: (context, state, _) {
        final iconAssetName = state.iconAssetName;

        Color iconColor;
        if (state.isActive) {
          iconColor = colorScheme.iconActiveColor;
        } else {
          iconColor = colorScheme.iconInactiveColor;
        }
        return BaseNavigationMapControl(
          theme: colorScheme,
          onTap: widget.controller.processTap,
          isEnabled: true,
          child: Center(
            child: SvgPicture.asset(
              iconAssetName,
              width: colorScheme.iconSize,
              height: colorScheme.iconSize,
              fit: BoxFit.scaleDown,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          ),
        );
      },
    );
  }
}
