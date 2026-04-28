import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../generated/dart_bindings.dart' as sdk;
import '../../../../generated/stateful_channel.dart';
import '../../../../platform/bss_events_source.dart';
import '../../../../util/plugin_name.dart';
import '../../../widget_shadows.dart';
import '../../themed_map_controlling_widget.dart';
import '../../themed_map_controlling_widget_state.dart';
import 'modern_compass_widget_color_scheme.dart';

/// Map compass control widget (modern version).
/// Can only be used as a child of MapWidget at any nesting level.
class ModernCompassWidget
    extends ThemedMapControllingWidget<ModernCompassWidgetColorScheme> {
  const ModernCompassWidget({
    super.key,
    ModernCompassWidgetColorScheme? light,
    ModernCompassWidgetColorScheme? dark,
  }) : super(
          light: light ?? defaultLightColorScheme,
          dark: dark ?? defaultDarkColorScheme,
        );

  /// Default color scheme of the UI element for light mode.
  static const ModernCompassWidgetColorScheme defaultLightColorScheme =
      ModernCompassWidgetColorScheme(
    surfaceColor: Color(0xFFFFFFFF),
  );

  /// Default color scheme of the UI element for dark mode.
  static const ModernCompassWidgetColorScheme defaultDarkColorScheme =
      ModernCompassWidgetColorScheme(
    surfaceColor: Color(0xFF141414),
  );

  @override
  ThemedMapControllingWidgetState<ModernCompassWidget,
          ModernCompassWidgetColorScheme>
      createState() => _ModernCompassWidgetState();
}

class _ModernCompassWidgetState extends ThemedMapControllingWidgetState<
    ModernCompassWidget, ModernCompassWidgetColorScheme> {
  late sdk.CompassControlModel model;

  StatefulChannel<sdk.Bearing>? bearingSubscription;

  @override
  void onAttachedToMap(sdk.Map map) {
    model = withBssEventsSourceFromSdk(() => sdk.CompassControlModel(map));
    bearingSubscription = model.bearingChannel;
  }

  @override
  void onDetachedFromMap() {
    bearingSubscription = null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: bearingSubscription,
      builder: (context, snapshot) {
        final bearing = snapshot.data?.value ?? 0.0;
        final angle = -(pi * bearing / 180);
        return AnimatedOpacity(
          opacity: bearing == 0 ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: GestureDetector(
            onTap: () => model.onClicked(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.surfaceColor,
                shape: BoxShape.circle,
                boxShadow: WidgetShadows.modernMapWidgetBoxShadows,
              ),
              child: Transform.rotate(
                angle: angle,
                child: SvgPicture.asset(
                  'packages/$pluginName/assets/icons/dgis_compass.svg',
                  fit: BoxFit.none,
                  width: 24,
                  height: 24,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
