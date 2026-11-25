import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';

import '../../../generated/dart_bindings.dart' as sdk;
import '../../../util/plugin_name.dart';
import '../../common/rounded_corners.dart';
import '../../map/themed_map_controlling_widget.dart';
import '../../map/themed_map_controlling_widget_state.dart';

import '../base_map_control.dart';
import '../navigation_map_control_theme.dart';
import './zoom_controller.dart';
import './zoom_model.dart';

/// Map widget that provides controls for zooming.
/// Can only be used as a child of a MapWidget at any nesting level.
class NavigationZoomWidget
    extends ThemedMapControllingWidget<NavigationMapControlTheme> {
  final ZoomController controller;

  const NavigationZoomWidget({
    required this.controller,
    super.key,
    NavigationMapControlTheme? light,
    NavigationMapControlTheme? dark,
  }) : super(
         light: light ?? NavigationMapControlTheme.defaultLight,
         dark: dark ?? NavigationMapControlTheme.defaultDark,
       );

  // ignore: prefer_constructors_over_static_methods
  static NavigationZoomWidget defaultBuilder(ZoomController controller) =>
      NavigationZoomWidget(
        controller: controller,
      );

  @override
  ThemedMapControllingWidgetState<
    NavigationZoomWidget,
    NavigationMapControlTheme
  >
  createState() => _ZoomWidgetState();
}

class _ZoomWidgetState
    extends
        ThemedMapControllingWidgetState<
          NavigationZoomWidget,
          NavigationMapControlTheme
        > {
  @override
  void onAttachedToMap(sdk.Map map) {}

  @override
  void onDetachedFromMap() {}

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ValueListenableBuilder<ZoomModel>(
            valueListenable: widget.controller.state,
            builder: (_, state, _) => BaseNavigationMapControl(
              theme: colorScheme,
              isEnabled: state.zoomInEnabled,
              onPress: () => widget.controller.startZoomIn(),
              onRelease: () => widget.controller.endZoomIn(),
              roundedCorners: const RoundedCorners.top(),
              child: Center(
                child: SvgPicture.asset(
                  'packages/$pluginName/assets/icons/dgis_zoom_in.svg',
                  width: colorScheme.iconSize,
                  height: colorScheme.iconSize,
                  fit: BoxFit.none,
                  colorFilter: ColorFilter.mode(
                    state.zoomInEnabled
                        ? colorScheme.iconInactiveColor
                        : colorScheme.iconDisabledColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          Divider(color: colorScheme.dividerColor, height: 0),
          ValueListenableBuilder<ZoomModel>(
            valueListenable: widget.controller.state,
            builder: (_, state, _) => BaseNavigationMapControl(
              theme: colorScheme,
              isEnabled: state.zoomOutEnabled,
              onPress: () => widget.controller.startZoomOut(),
              onRelease: () => widget.controller.endZoomOut(),
              roundedCorners: const RoundedCorners.bottom(),
              child: Center(
                child: SvgPicture.asset(
                  'packages/$pluginName/assets/icons/dgis_zoom_out.svg',
                  width: colorScheme.iconSize,
                  height: colorScheme.iconSize,
                  fit: BoxFit.none,
                  colorFilter: ColorFilter.mode(
                    state.zoomOutEnabled
                        ? colorScheme.iconInactiveColor
                        : colorScheme.iconDisabledColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
