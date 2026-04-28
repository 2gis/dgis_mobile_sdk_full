import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../generated/dart_bindings.dart' as sdk;
import '../../../../util/plugin_name.dart';

import '../../../widget_shadows.dart';
import '../../themed_map_controlling_widget.dart';
import '../../themed_map_controlling_widget_state.dart';
import 'modern_my_location_controller.dart';
import 'modern_my_location_model.dart';
import 'modern_my_location_widget_color_scheme.dart';

/// Widget for controlling the geolocation follow mode, bearing,
/// and flying to the current location.
/// Can only be used as a child of MapWidget at any level of nesting.
///
/// This widget is purely visual — all logic is managed by the
/// [ModernMyLocationController] passed via the [controller] parameter.
class ModernMyLocationWidget
    extends ThemedMapControllingWidget<ModernMyLocationWidgetColorScheme> {
  /// Controller that manages location permission logic and SDK interaction.
  final ModernMyLocationController controller;

  const ModernMyLocationWidget({
    required this.controller,
    super.key,
    ModernMyLocationWidgetColorScheme? light,
    ModernMyLocationWidgetColorScheme? dark,
  }) : super(
          light: light ?? defaultLightColorScheme,
          dark: dark ?? defaultDarkColorScheme,
        );

  /// Default color scheme for light mode.
  static const ModernMyLocationWidgetColorScheme defaultLightColorScheme =
      ModernMyLocationWidgetColorScheme(
    surfaceColor: Color(0xffffffff),
    iconInactiveColor: Color(0xff000000),
    iconDisabledColor: Color(0xffcccccc),
    iconActiveColor: Color(0xff0059d6),
  );

  /// Default color scheme for dark mode.
  static const ModernMyLocationWidgetColorScheme defaultDarkColorScheme =
      ModernMyLocationWidgetColorScheme(
    surfaceColor: Color(0xff141414),
    iconInactiveColor: Color(0xffffffff),
    iconDisabledColor: Color(0xff808080),
    iconActiveColor: Color(0xff3588fd),
  );

  @override
  ThemedMapControllingWidgetState<ModernMyLocationWidget,
          ModernMyLocationWidgetColorScheme>
      createState() => _ModernMyLocationWidgetState();
}

class _ModernMyLocationWidgetState extends ThemedMapControllingWidgetState<
    ModernMyLocationWidget, ModernMyLocationWidgetColorScheme> {
  @override
  void onAttachedToMap(sdk.Map map) {}

  @override
  void onDetachedFromMap() {}

  static const double _widgetSize = 44;
  static const double _innerFrameSize = 24;
  static const double _innerFrameSizeFollowDirection = 32;
  static const double _borderRadius = 10;
  static const double _padding = 8;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ModernMyLocationModel>(
      valueListenable: widget.controller.state,
      builder: (context, model, _) {
        final isEnabled = model.isEnabled;
        final isPermissionRequired = model.isPermissionRequired;
        final followState = model.followState;

        return GestureDetector(
          onTap: () => widget.controller.processTap(),
          child: Container(
            width: _widgetSize,
            height: _widgetSize,
            padding: const EdgeInsets.all(_padding),
            decoration: BoxDecoration(
              color: colorScheme.surfaceColor,
              borderRadius: BorderRadius.circular(_borderRadius),
              boxShadow: WidgetShadows.modernMapWidgetBoxShadows,
            ),
            child: Center(
              child: _buildIcon(
                isEnabled: isEnabled,
                isPermissionRequired: isPermissionRequired,
                followState: followState,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIcon({
    required bool isEnabled,
    required bool isPermissionRequired,
    required sdk.CameraFollowState followState,
  }) {
    if (!isEnabled) {
      return SvgPicture.asset(
        'packages/$pluginName/assets/icons/dgis_my_location_modern.svg',
        width: _innerFrameSize,
        height: _innerFrameSize,
        colorFilter: ColorFilter.mode(
          colorScheme.iconDisabledColor,
          BlendMode.srcIn,
        ),
      );
    }

    if (isPermissionRequired) {
      return SvgPicture.asset(
        'packages/$pluginName/assets/icons/dgis_no_geo.svg',
        width: _innerFrameSize,
        height: _innerFrameSize,
        colorFilter: ColorFilter.mode(
          colorScheme.iconInactiveColor,
          BlendMode.srcIn,
        ),
      );
    }

    final isFollowDirection =
        followState == sdk.CameraFollowState.followDirection;

    final iconAssetName = isFollowDirection
        ? 'packages/$pluginName/assets/icons/dgis_map_follow_direction.svg'
        : 'packages/$pluginName/assets/icons/dgis_my_location_modern.svg';

    Color iconColor;
    switch (followState) {
      case sdk.CameraFollowState.off:
        iconColor = colorScheme.iconInactiveColor;
      case sdk.CameraFollowState.followPosition:
        iconColor = colorScheme.iconActiveColor;
      case sdk.CameraFollowState.followDirection:
        iconColor = colorScheme.iconActiveColor;
    }

    final size =
        isFollowDirection ? _innerFrameSizeFollowDirection : _innerFrameSize;

    final colorFilter = isFollowDirection
        ? null
        : ColorFilter.mode(
            iconColor,
            BlendMode.srcIn,
          );

    return SvgPicture.asset(
      iconAssetName,
      width: size,
      height: size,
      colorFilter: colorFilter,
    );
  }
}
