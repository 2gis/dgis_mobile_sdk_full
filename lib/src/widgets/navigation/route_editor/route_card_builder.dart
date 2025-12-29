import 'package:flutter/material.dart';

import '../../../../../l10n/generated/dgis_localizations.dart';
import '../../../../../l10n/generated/dgis_localizations_en.dart';
import '../../../generated/dart_bindings.dart' as sdk;
import './route_editor_controller.dart';
import './route_editor_theme.dart';

abstract class RouteCardBuilder {
  Widget build(
    sdk.TrafficRoute route,
    void Function()? onStartNavigation,
    int index,
    RouteEditorController controller,
    RouteCardTheme theme,
  );
}

class DefaultRouteCardBuilder implements RouteCardBuilder {
  const DefaultRouteCardBuilder();

  @override
  Widget build(
    sdk.TrafficRoute route,
    void Function()? onStartNavigation,
    int index,
    RouteEditorController controller,
    RouteCardTheme theme,
  ) {
    return _DefaultRouteCard(
      route: route,
      onStartNavigation: onStartNavigation,
      index: index,
      controller: controller,
      theme: theme,
    );
  }
}

class _DefaultRouteCard extends StatelessWidget {
  final sdk.TrafficRoute route;
  final int index;
  final void Function()? onStartNavigation;
  final RouteEditorController controller;
  final RouteCardTheme theme;

  const _DefaultRouteCard({
    required this.route,
    required this.onStartNavigation,
    required this.index,
    required this.controller,
    required this.theme,
  });

  String _formatDuration(int milliseconds, DgisLocalizations localizations) {
    final minutes = (milliseconds / 60000).round();
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return localizations.dgis_h__hours_format(hours);
      }
      return '${localizations.dgis_h__hours_format(hours)} ${localizations.dgis_min__minutes_format(remainingMinutes)}';
    }
    return localizations.dgis_min__minutes_format(minutes);
  }

  String _formatDistance(int meters, DgisLocalizations localizations) {
    if (meters >= 1000) {
      final km = meters / 1000;
      final kmValue = double.parse(km.toStringAsFixed(km % 1 == 0 ? 0 : 1));
      return localizations.dgis_km_format(kmValue);
    }
    return localizations.dgis_m__meters_format(meters);
  }

  @override
  Widget build(BuildContext context) {
    final localizations =
        DgisLocalizations.of(context) ?? DgisLocalizationsEn();

    final duration = route.traffic.durations.duration.inMilliseconds;
    final distance = (route.route.geometry.length.millimeters / 1000).ceil();
    final isBestRoute = index == 0;

    return Container(
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(theme.borderRadius),
      ),
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 1),
                  child: Text(
                    _formatDuration(duration, localizations),
                    style: theme.durationTextStyle,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 1, bottom: 7),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          _formatDistance(distance, localizations),
                          style: theme.distanceTextStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isBestRoute) ...[
                        Text(
                          ' • ',
                          style: theme.distanceTextStyle,
                        ),
                        Text(
                          localizations.dgis_best_route,
                          style: theme.distanceTextStyle,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: GestureDetector(
              onTap: () {
                onStartNavigation?.call();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: theme.goButtonBackground,
                  borderRadius: BorderRadius.circular(theme.goButtonRadius),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 14,
                ),
                child: Text(
                  localizations.dgis_route_editor_start,
                  style: theme.goButtonTextStyle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
