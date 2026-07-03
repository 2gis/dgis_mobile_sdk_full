import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../generated/dart_bindings.dart' as sdk;
import '../../../generated/stateful_channel.dart';
import '../../../platform/bss_events_source.dart';
import '../../../util/plugin_name.dart';
import '../../widget_shadows.dart';
import '../themed_map_controlling_widget.dart';
import '../themed_map_controlling_widget_state.dart';
import 'compass_widget_color_scheme.dart';

/// Map compass control widget (modern version).
/// Can only be used as a child of MapWidget at any nesting level.
class CompassWidget
    extends ThemedMapControllingWidget<CompassWidgetColorScheme> {
  const CompassWidget({
    super.key,
    CompassWidgetColorScheme? light,
    CompassWidgetColorScheme? dark,
  }) : super(
          light: light ?? defaultLightColorScheme,
          dark: dark ?? defaultDarkColorScheme,
        );

  /// Default color scheme of the UI element for light mode.
  static const CompassWidgetColorScheme defaultLightColorScheme =
      CompassWidgetColorScheme(
    surfaceColor: Color(0x80FFFFFF),
  );

  /// Default color scheme of the UI element for dark mode.
  static const CompassWidgetColorScheme defaultDarkColorScheme =
      CompassWidgetColorScheme(
    surfaceColor: Color(0x80141414),
  );

  @override
  ThemedMapControllingWidgetState<CompassWidget, CompassWidgetColorScheme>
      createState() => _CompassWidgetState();
}

class _CompassWidgetState extends ThemedMapControllingWidgetState<CompassWidget,
    CompassWidgetColorScheme> {
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
