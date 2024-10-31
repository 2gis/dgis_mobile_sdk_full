import 'dart:async';

import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:flutter/material.dart';

class NavigatorPage extends StatefulWidget {
  final String title;

  const NavigatorPage({required this.title, super.key});

  @override
  State<NavigatorPage> createState() => _NavigatorPageState();
}

class _NavigatorPageState extends State<NavigatorPage> {
  final mapWidgetController = sdk.MapWidgetController();
  final sdkContext = sdk.DGis.initialize();

  late sdk.NavigationManager navigationManager;
  late sdk.TrafficRouter trafficRouter;

  final _startPoint = sdk.RouteSearchPoint(
    coordinates: sdk.GeoPoint(
      latitude: sdk.Latitude(55.749451),
      longitude: sdk.Longitude(37.542824),
    ),
  );
  final _finishPoint = sdk.RouteSearchPoint(
    coordinates: sdk.GeoPoint(
      latitude: sdk.Latitude(55.757670),
      longitude: sdk.Longitude(37.660160),
    ),
  );
  final _options = sdk.RouteSearchOptions.car(
    sdk.CarRouteSearchOptions(),
  );

  @override
  void initState() {
    navigationManager = sdk.NavigationManager(sdkContext);
    trafficRouter = sdk.TrafficRouter(sdkContext);

    super.initState();
    mapWidgetController.getMapAsync((map) {
      unawaited(
        _startNavigation(map),
      );
    });
  }

  Future<void> _startNavigation(sdk.Map map) async {
    final routes = await trafficRouter
        .findRoute(
          _startPoint,
          _finishPoint,
          _options,
        )
        .valueOrCancellation();

    if (routes != null) {
      navigationManager.mapManager.addMap(map);

      map.addSource(
        sdk.MyLocationMapObjectSource(
          sdkContext,
        ),
      );
      map.camera.addFollowController(
        sdk.StyleZoomFollowController(),
      );

      final route = routes.first;

      navigationManager.simulationSettings.speedMode = sdk.SimulationSpeedMode.overSpeed(
        sdk.SimulationAutoWithOverSpeed(10),
      );
      navigationManager.startSimulation(
        sdk.RouteBuildOptions(
          finishPoint: _finishPoint,
          routeSearchOptions: _options,
        ),
        route,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: sdk.MapWidget(
        sdkContext: sdkContext,
        // TODO: пофиксить краш при const sdk.MapOptions()
        // ignore: prefer_const_constructors
        mapOptions: sdk.MapOptions(),
        controller: mapWidgetController,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      sdk.ManeuverWidget(
                        navigationManager: navigationManager,
                      ),
                      Spacer(),
                      sdk.SpeedLimitWidget(
                        navigationManager: navigationManager,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    children: [
                      sdk.ZoomWidget(),
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: sdk.MyLocationWidget(),
                      ),
                    ],
                  ),
                ),
                Spacer(),
              ],
            ),
            sdk.DashboardWidget(
              navigationManager: navigationManager,
            ),
          ],
        ),
      ),
    );
  }
}
