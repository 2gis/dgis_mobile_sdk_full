import 'dart:async';
import 'dart:io' show Platform;

import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:flutter/material.dart';

import 'common.dart';

class NavigatorPage extends StatefulWidget {
  final String title;

  const NavigatorPage({required this.title, super.key});

  @override
  State<NavigatorPage> createState() => _NavigatorPageState();
}

class _NavigatorPageState extends State<NavigatorPage> {
  final mapWidgetController = sdk.MapWidgetController();
  final sdkContext = AppContainer().initializeSdk();

  late sdk.NavigationManager navigationManager;
  late sdk.TrafficRouter trafficRouter;

  final _startPoint = const sdk.RouteSearchPoint(
    coordinates: sdk.GeoPoint(
      latitude: sdk.Latitude(55.730034),
      longitude: sdk.Longitude(37.623121),
    ),
  );
  final _finishPoint = const sdk.RouteSearchPoint(
    coordinates: sdk.GeoPoint(
      latitude: sdk.Latitude(55.7060),
      longitude: sdk.Longitude(37.5369),
    ),
  );
  final _options = sdk.RouteSearchOptions.car(
    const sdk.CarRouteSearchOptions(),
  );

  final _minSpeedForCarSimulation = 46.0;
  final _maxSpeedForCarSimulaton = 67.0;
  final _simulationCarSpeedStep = 3.0;
  late double _currentSpeed;
  bool _isSpeedIncreasing = true;

  Timer? _speedUpdateTimer;

  @override
  void initState() {
    _currentSpeed = _minSpeedForCarSimulation;
    navigationManager = sdk.NavigationManager(sdkContext);
    trafficRouter = sdk.TrafficRouter(sdkContext);

    super.initState();
    mapWidgetController.getMapAsync((map) {
      unawaited(
        _startNavigation(map),
      );
    });
  }

  void _startSpeedSimulation() {
    _speedUpdateTimer?.cancel();
    _currentSpeed = _minSpeedForCarSimulation;

    _speedUpdateTimer = Timer.periodic(
      const Duration(seconds: 2), // adjust interval as needed
      (timer) => _updateSimulationSpeed(),
    );
  }

  void _updateSimulationSpeed() {
    navigationManager.simulationSettings.speedMode =
        sdk.SimulationSpeedMode.speed(
      sdk.SimulationConstantSpeed(
        _kilometersPerHourToMetersPerSecond(_currentSpeed),
      ),
    );

    if (_isSpeedIncreasing) {
      _currentSpeed += _simulationCarSpeedStep;
      if (_currentSpeed >= _maxSpeedForCarSimulaton) {
        _isSpeedIncreasing = false;
        _currentSpeed = _maxSpeedForCarSimulaton;
      }
    } else {
      _currentSpeed -= _simulationCarSpeedStep;
      if (_currentSpeed <= _minSpeedForCarSimulation) {
        _isSpeedIncreasing = true;
        _currentSpeed = _minSpeedForCarSimulation;
      }
    }
  }

  void _stopSpeedSimulation() {
    _speedUpdateTimer?.cancel();
    _speedUpdateTimer = null;
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
      map.addSource(
        sdk.MyLocationMapObjectSource(
          sdkContext,
        ),
      );

      final route = routes.first;

      // TODO: перенести в настройки, когда они появятся.
      navigationManager.alternativeRoutesProviderSettings.routeSearchDelay =
          const Duration(seconds: 5);
      navigationManager.alternativeRoutesProviderSettings
          .betterRouteTimeCostThreshold = Duration.zero;
      navigationManager.alternativeRoutesProviderSettings
          .betterRouteLengthThreshold = const sdk.RouteDistance();

      navigationManager.startSimulation(
        sdk.RouteBuildOptions(
          finishPoint: _finishPoint,
          routeSearchOptions: _options,
        ),
        route,
      );
      _startSpeedSimulation();
    }
  }

  @override
  void dispose() {
    _stopSpeedSimulation();
    navigationManager.stop();
    super.dispose();
  }

  double _kilometersPerHourToMetersPerSecond(double kmh) {
    return kmh / 3.6; // converts km/h to m/s
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: sdk.MapWidget(
        sdkContext: sdkContext,
        mapOptions: sdk.MapOptions(),
        controller: mapWidgetController,
        child: Padding(
          padding: EdgeInsets.only(
            right: 8,
            left: 8,
            bottom: Platform.isIOS ? 0 : 8,
          ),
          child: sdk.NavigationLayoutWidget(
            navigationManager: navigationManager,
            dashboardWidgetBuilder: (controller, onHeaderChangeSize) =>
                sdk.DashboardWidget(
              controller: controller,
              onHeaderChangeSize: onHeaderChangeSize,
              onFinishClicked: () {
                Navigator.pop(context);
                controller.stopNavigation();
              },
            ),
            finishRouteWidgetBuilder: (controller) => sdk.FinishRouteWidget(
              controller: controller,
              onFinishClicked: () {
                Navigator.pop(context);
                controller.stopNavigation();
              },
            ),
            myLocationWidgetBuilder:
                sdk.NavigationMyLocationWidget.defaultBuilder,
            compassWidgetbuilder: sdk.NavigationCompassWidget.defaultBuilder,
            zoomWidgetBuilder: sdk.NavigationZoomWidget.defaultBuilder,
            parkingWidgetBuilder: sdk.NavigationParkingWidget.defaultBuilder,
            trafficWidgetBuilder: sdk.NavigationTrafficWidget.defaultBuilder,
            speedLimitWidgetBuilder: sdk.SpeedLimitWidget.defaultBuilder,
            maneuverWidgetBuilder: sdk.ManeuverWidget.defaultBuilder,
            trafficLineWidgetBuilder: sdk.TrafficLineWidget.defaultBuilder,
            betterRoutePromptWidgetBuilder:
                sdk.BetterRoutePromptWidget.defaultBuilder,
          ),
        ),
      ),
    );
  }
}
