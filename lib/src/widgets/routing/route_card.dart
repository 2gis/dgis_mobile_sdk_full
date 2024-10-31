import 'package:dgis_mobile_sdk_full/src/util/format_duration.dart';
import 'package:dgis_mobile_sdk_full/src/util/fromat_distance.dart';
import 'package:flutter/cupertino.dart';

import '../../generated/dart_bindings.dart' as sdk;
import '../map/map_widget_theme.dart';

class RouteCard extends StatelessWidget {
  const RouteCard({
    super.key,
    required this.route,
    required this.theme,
    required this.onGoPressed,
  });

  final sdk.TrafficRoute route;
  final RouteCardTheme theme;

  final ValueChanged<sdk.TrafficRoute> onGoPressed;

  @override
  Widget build(BuildContext context) {
    final distance = formatMeters(route.distance() ?? 0);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(theme.borderRadius),
        color: theme.backgroundColor,
      ),
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatDuration(route.duration() ?? Duration.zero),
                style: theme.durationTextStyle,
              ),
              Text(
                "${distance.value}${distance.unit}",
                style: theme.distanceTextStyle,
              ),
            ],
          ),
          CupertinoButton(
            minSize: 0,
            padding: EdgeInsets.zero,
            child: DefaultTextStyle.merge(
              style: const TextStyle(
                letterSpacing: 0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.goButtonBackground,
                  borderRadius: BorderRadius.circular(theme.goButtonRadius),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 14,
                ),
                child: Text(
                  'В путь',
                  style: theme.goButtonTextStyle,
                ),
              ),
            ),
            onPressed: () => onGoPressed(route),
          )
        ],
      ),
    );
  }
}

class RouteCardTheme extends MapWidgetTheme {
  const RouteCardTheme({
    required this.backgroundColor,
    required this.borderRadius,
    required this.durationTextStyle,
    required this.distanceTextStyle,
    required this.goButtonBackground,
    required this.goButtonRadius,
    required this.goButtonTextStyle,
  });

  final Color backgroundColor;
  final double borderRadius;

  final TextStyle durationTextStyle;
  final TextStyle distanceTextStyle;

  final Color goButtonBackground;
  final double goButtonRadius;
  final TextStyle goButtonTextStyle;

  static const defaultLight = RouteCardTheme(
    backgroundColor: Color(0xFFFFFFFF),
    borderRadius: 12,
    durationTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      color: Color(0xFF141414),
      fontSize: 19,
      height: 1.2,
    ),
    distanceTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      color: Color(0xFF898989),
      fontSize: 15,
      height: 1.3,
    ),
    goButtonBackground: Color(0xFF1DB93C),
    goButtonRadius: 8,
    goButtonTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      color: Color(0xFFFFFFFF),
      fontSize: 15,
      height: 1.3,
    ),
  );
  static const defaultDark = RouteCardTheme(
    backgroundColor: Color(0x0FFFFFFF),
    borderRadius: 12,
    durationTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w500,
      color: Color(0xFFFFFFFF),
      fontSize: 19,
      height: 1.2,
    ),
    distanceTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFF898989),
      fontSize: 15,
      height: 1.3,
    ),
    goButtonBackground: Color(0xFF1DB93C),
    goButtonRadius: 8,
    goButtonTextStyle: TextStyle(
      fontWeight: FontWeight.w600,
      leadingDistribution: TextLeadingDistribution.even,
      color: Color(0xFFFFFFFF),
      fontSize: 15,
      height: 1.3,
    ),
  );

  @override
  RouteCardTheme copyWith({
    Color? backgroundColor,
    double? borderRadius,
    TextStyle? durationTextStyle,
    TextStyle? distanceTextStyle,
    Color? goButtonBackground,
    double? goButtonRadius,
    TextStyle? goButtonTextStyle,
  }) {
    return RouteCardTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      durationTextStyle: durationTextStyle ?? this.durationTextStyle,
      distanceTextStyle: distanceTextStyle ?? this.distanceTextStyle,
      goButtonBackground: goButtonBackground ?? this.goButtonBackground,
      goButtonRadius: goButtonRadius ?? this.goButtonRadius,
      goButtonTextStyle: goButtonTextStyle ?? this.goButtonTextStyle,
    );
  }
}

extension RouteDistanceDuration on sdk.TrafficRoute {
  int? distance() {
    return route.geometry.length.millimeters;
  }

  Duration? duration() {
    final firstPoint = route.geometry.first;
    final lastPoint = route.geometry.last;

    if (firstPoint == null || lastPoint == null) {
      return null;
    }

    final duration = traffic.durations.calculateDuration(firstPoint.point, lastPoint.point);

    return duration;
  }
}
