import 'dart:async';

import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'common.dart';

class MiniMapPage extends StatefulWidget {
  final String title;

  const MiniMapPage({required this.title, super.key});

  @override
  State<MiniMapPage> createState() => _MiniMapPageState();
}

class _MiniMapPageState extends State<MiniMapPage> {
  sdk.MapWidgetController? mapWidgetController;
  late final sdk.MapWidgetController miniMapWidgetController;
  late final sdk.MapWidgetController finishMiniMapWidgetController;
  final sdkContext = AppContainer().initializeSdk();
  final pinAssetsPath = 'assets/icons/pin.png';
  final _imageCache = <String, sdk.Image>{};
  final simulationSpeed = 80.0 * 1000 / 3600;

  sdk.Map? sdkMap;
  sdk.Map? miniMap;
  sdk.Map? finishMiniMap;
  sdk.MapObjectManager? mapObjectManager;

  late sdk.ImageLoader loader;
  late sdk.NavigationManager navigationManager;
  late sdk.TrafficRouter trafficRouter;
  late sdk.File miniMapStyleFile;

  final startPointDubai = const sdk.GeoPoint(
    latitude: sdk.Latitude(25.198014),
    longitude: sdk.Longitude(55.272859),
  );
  final finishPointDubai = const sdk.GeoPoint(
    latitude: sdk.Latitude(25.133561),
    longitude: sdk.Longitude(55.118765),
  );
  final startPointNsk = const sdk.GeoPoint(
    latitude: sdk.Latitude(55.030662),
    longitude: sdk.Longitude(82.921695),
  );
  final finishPointNsk = const sdk.GeoPoint(
    latitude: sdk.Latitude(54.979594),
    longitude: sdk.Longitude(82.899686),
  );
  final startPointMsk = const sdk.GeoPoint(
    latitude: sdk.Latitude(55.724451),
    longitude: sdk.Longitude(37.622573),
  );
  final finishPointMsk = const sdk.GeoPoint(
    latitude: sdk.Latitude(57.633945),
    longitude: sdk.Longitude(39.860694),
  );

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    loader = sdk.ImageLoader(sdkContext);
    navigationManager = sdk.NavigationManager(sdkContext);
    trafficRouter = sdk.TrafficRouter(sdkContext);
    miniMapStyleFile = sdk.File.fromAsset(
      sdkContext,
      'minimap_styles.2gis',
    );
    unawaited(_createMapControllers());
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    navigationManager.stop();
    super.dispose();
  }

  Future<void> _createMapControllers() async {
    final createdMapWidgetController =
        await createMapWidgetController(sdkContext);
    miniMapWidgetController = await createMapWidgetController(
      sdkContext,
      controllerOptions: sdk.MapControllerOptions(
        styleFile: miniMapStyleFile,
        maxFps: const sdk.Fps(20),
      ),
    );
    finishMiniMapWidgetController = await createMapWidgetController(
      sdkContext,
      controllerOptions: sdk.MapControllerOptions(
        styleFile: miniMapStyleFile,
        maxFps: const sdk.Fps(20),
      ),
    );
    if (!mounted) {
      return;
    }

    sdkMap = createdMapWidgetController.map;
    miniMap = miniMapWidgetController.map;
    miniMap?.interactive = false;
    finishMiniMap = finishMiniMapWidgetController.map;
    mapObjectManager = sdk.MapObjectManager(finishMiniMap!);

    setState(() {
      mapWidgetController = createdMapWidgetController;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentMapWidgetController = mapWidgetController;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: currentMapWidgetController == null
          ? const SizedBox.shrink()
          : sdk.MapWidget(
              sdkContext: sdkContext,
              controller: currentMapWidgetController,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Stack(
                  children: [
                    sdk.NavigationLayoutWidget(
                      navigationManager: navigationManager,
                      speedLimitWidgetBuilder: sdk.SpeedLimitWidget.defaultBuilder,
                      parkingWidgetBuilder:
                          sdk.NavigationParkingWidget.defaultBuilder,
                      zoomWidgetBuilder: sdk.NavigationZoomWidget.defaultBuilder,
                      trafficWidgetBuilder:
                          sdk.NavigationTrafficWidget.defaultBuilder,
                      compassWidgetbuilder:
                          sdk.NavigationCompassWidget.defaultBuilder,
                      myLocationWidgetBuilder:
                          sdk.NavigationMyLocationWidget.defaultBuilder,
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: sdk.IndoorWidget(),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: CupertinoButton(
                        onPressed: _show,
                        child: const Icon(Icons.format_list_bulleted),
                      ),
                    ),
                    OrientationBuilder(
                      builder: (context, orientation) {
                        return Stack(
                          children: [
                            Positioned(
                              bottom: 16,
                              left: 16,
                              child: sdk.NavigationMiniMapWidget(
                                sdkContext: sdkContext,
                                controller: miniMapWidgetController,
                                miniMapController: sdk.NavigationMiniMapController(
                                  navigationManager: navigationManager,
                                ),
                                size: 150,
                              ),
                            ),
                            Positioned(
                              bottom: orientation == Orientation.landscape
                                  ? 16
                                  : null,
                              top: orientation == Orientation.portrait
                                  ? 16
                                  : null,
                              right: 60,
                              child: sdk.MiniMapWidget(
                                sdkContext: sdkContext,
                                controller: finishMiniMapWidgetController,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _show() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Routes'),
        actions: <Widget>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context, 'One');
              _startNavigation(startPointNsk, finishPointNsk);
            },
            child: const Text('Novosibirsk'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context, 'One');
              _startNavigation(startPointDubai, finishPointDubai);
            },
            child: const Text('Dubai'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context, 'One');
              _startNavigation(startPointMsk, finishPointMsk);
            },
            child: const Text('Moscow-Yaroslavl'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context, 'Cancel');
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Future<void> addFinishMarker(sdk.GeoPoint point) async {
    final marker = sdk.Marker(
      sdk.MarkerOptions(
        position: sdk.GeoPointWithElevation(
          latitude: point.latitude,
          longitude: point.longitude,
        ),
        icon: _imageCache[pinAssetsPath] ??=
            await loader.loadPngFromAsset(pinAssetsPath, 160, 160),
        text: 'Finish point',
      ),
    );
    mapObjectManager?.addObject(marker);
  }

  Future<void> _startNavigation(
    sdk.GeoPoint startPoint,
    sdk.GeoPoint finishPoint,
  ) async {
    final options = sdk.RouteSearchOptions.car(
      const sdk.CarRouteSearchOptions(),
    );

    final routes = await trafficRouter
        .findRoute(
          sdk.RouteSearchPoint(coordinates: startPoint),
          sdk.RouteSearchPoint(coordinates: finishPoint),
          options,
        )
        .valueOrCancellation();

    if (routes != null) {
      final navigationMiniMap = miniMap;
      if (navigationMiniMap == null) {
        return;
      }

      navigationManager.mapManager.addMap(navigationMiniMap);

      navigationMiniMap.camera.addFollowController(
        sdk.StyleZoomFollowController(),
      );

      finishMiniMap?.camera.position = sdk.CameraPosition(
        point: finishPoint,
        zoom: const sdk.Zoom(14),
      );

      final route = routes.first;

      navigationManager.simulationSettings.speedMode =
          sdk.SimulationSpeedMode.speed(
        sdk.SimulationConstantSpeed(simulationSpeed),
      );
      navigationManager.startSimulation(
        sdk.RouteBuildOptions(
          finishPoint: sdk.RouteSearchPoint(coordinates: finishPoint),
          routeSearchOptions: options,
        ),
        route,
      );
      await addFinishMarker(finishPoint);
    }
  }
}
