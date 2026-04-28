import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../generated/dart_bindings.dart' as sdk;
import '../../generated/stateful_channel.dart';
import '../../platform/bss_events_source.dart';
import '../../util/plugin_name.dart';
import '../common/dgis_color_scheme.dart';
import 'map_widget_color_scheme.dart';
import 'themed_map_controlling_widget.dart';
import 'themed_map_controlling_widget_state.dart';

/// Виджет управления компасом.
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

  /// Цветовая схема виджета для светлого режима по умолчанию.
  static const defaultLightColorScheme = CompassWidgetColorScheme(
    surfaceColor: DgisColorScheme.whiteFiftyPercent,
  );

  /// Цветовая схема виджета для темного режима по умолчанию.
  static const defaultDarkColorScheme = CompassWidgetColorScheme(
    surfaceColor: DgisColorScheme.blackSixPercent,
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
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colorScheme.surfaceColor,
                shape: BoxShape.circle,
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

class CompassWidgetColorScheme extends MapWidgetColorScheme {
  final Color surfaceColor;

  const CompassWidgetColorScheme({required this.surfaceColor});

  @override
  CompassWidgetColorScheme copyWith({Color? surfaceColor}) {
    return CompassWidgetColorScheme(
      surfaceColor: surfaceColor ?? this.surfaceColor,
    );
  }
}
