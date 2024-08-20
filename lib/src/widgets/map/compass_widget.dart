import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../generated/dart_bindings.dart' as sdk;
import '../../generated/stateful_channel.dart';
import '../../util/plugin_name.dart';

import 'map_widget_theme.dart';
import 'themed_map_controlling_widget.dart';

/// Виджет управления компасом.
class CompassWidget extends ThemedMapControllingWidget<CompassWidgetTheme> {
  const CompassWidget({
    super.key,
    CompassWidgetTheme? light,
    CompassWidgetTheme? dark,
  }) : super(
          light: light ?? CompassWidgetTheme.defaultLight,
          dark: dark ?? CompassWidgetTheme.defaultDark,
        );

  @override
  ThemedMapControllingWidgetState<CompassWidget, CompassWidgetTheme> createState() => _CompassWidgetState();
}

class _CompassWidgetState extends ThemedMapControllingWidgetState<CompassWidget, CompassWidgetTheme> {
  late sdk.CompassControlModel model;

  StatefulChannel<sdk.Bearing>? bearingSubscription;

  @override
  void onAttachedToMap(sdk.Map map) {
    model = sdk.CompassControlModel(map);
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
        final angle = pi * bearing / 180;
        return AnimatedOpacity(
          opacity: bearing == 0 ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: GestureDetector(
            onTap: () => model.onClicked(),
            child: Container(
              width: theme.size,
              height: theme.size,
              decoration: BoxDecoration(
                color: theme.surfaceColor,
                shape: BoxShape.circle,
              ),
              child: Transform.rotate(
                angle: angle,
                child: SvgPicture.asset(
                  'packages/$pluginName/assets/icons/dgis_compass.svg',
                  fit: BoxFit.none,
                  width: theme.iconSize,
                  height: theme.iconSize,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CompassWidgetTheme extends MapWidgetTheme {
  final double size;
  final double iconSize;
  final Color surfaceColor;

  const CompassWidgetTheme({
    required this.surfaceColor,
    required this.size,
    required this.iconSize,
  });

  /// Цветовая схема виджета для светлого режима по умолчанию.
  static const defaultLight = CompassWidgetTheme(
    surfaceColor: Color(0xffffffff),
    size: 40,
    iconSize: 24,
  );

  /// Цветовая схема виджета для темного режима по умолчанию.
  static const defaultDark = CompassWidgetTheme(
    surfaceColor: Color(0xff121212),
    size: 40,
    iconSize: 24,
  );

  @override
  CompassWidgetTheme copyWith({
    Color? surfaceColor,
    double? size,
    double? iconSize,
  }) {
    return CompassWidgetTheme(
      surfaceColor: surfaceColor ?? this.surfaceColor,
      size: size ?? this.size,
      iconSize: iconSize ?? this.iconSize,
    );
  }
}
