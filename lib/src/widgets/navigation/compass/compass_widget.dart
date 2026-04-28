import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../generated/dart_bindings.dart' as sdk;
import '../../../util/plugin_name.dart';
import '../../common/dgis_color_scheme.dart';
import '../../map/themed_map_controlling_widget.dart';
import '../../map/themed_map_controlling_widget_state.dart';
import './compass_controller.dart';
import './compass_theme.dart';

/// Compass control widget.
class NavigationCompassWidget
    extends ThemedMapControllingWidget<NavigationCompassWidgetTheme> {
  final CompassController controller;
  const NavigationCompassWidget({
    required this.controller,
    super.key,
    NavigationCompassWidgetTheme? light,
    NavigationCompassWidgetTheme? dark,
  }) : super(
          light: light ?? defaultLightColorScheme,
          dark: dark ?? defaultDarkColorScheme,
        );

  /// Widget color scheme for default light mode.
  static const defaultLightColorScheme = NavigationCompassWidgetTheme(
    surfaceColor: DgisColorScheme.whiteFiftyPercent,
  );

  /// Widget color scheme for default dark mode.
  static const defaultDarkColorScheme = NavigationCompassWidgetTheme(
    surfaceColor: DgisColorScheme.blackFiftyPercent,
  );

  // ignore: prefer_constructors_over_static_methods
  static NavigationCompassWidget defaultBuilder(CompassController controller) =>
      NavigationCompassWidget(controller: controller);

  @override
  ThemedMapControllingWidgetState<NavigationCompassWidget,
      NavigationCompassWidgetTheme> createState() => _CompassWidgetState();
}

class _CompassWidgetState extends ThemedMapControllingWidgetState<
    NavigationCompassWidget, NavigationCompassWidgetTheme> {
  @override
  void onAttachedToMap(sdk.Map map) {}

  @override
  void onDetachedFromMap() {}

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller.state,
      child: GestureDetector(
        onTap: widget.controller.rotateToNorth,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colorScheme.surfaceColor,
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            'packages/$pluginName/assets/icons/dgis_compass.svg',
            fit: BoxFit.none,
            width: 24,
            height: 24,
          ),
        ),
      ),
      builder: (context, state, child) {
        final angle = -(pi * state.bearing / 180);
        return AnimatedOpacity(
          opacity: state.bearing == 0 ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Transform.rotate(
            angle: angle,
            child: Visibility(
              visible: state.bearing != 0,
              child: child!,
            ),
          ),
        );
      },
    );
  }
}
