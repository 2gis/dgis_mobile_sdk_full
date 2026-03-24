import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'common.dart';

class MiniMapPage extends StatefulWidget {
  final String title;

  const MiniMapPage({required this.title, super.key});

  @override
  State<MiniMapPage> createState() => _MiniMapPageState();
}

class _MiniMapPageState extends State<MiniMapPage> {
  final mapWidgetController = sdk.MapWidgetController();
  final miniMapWidgetController = sdk.MapWidgetController();
  final finishMiniMapWidgetController = sdk.MapWidgetController();
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

  sdk.Style? _finishMiniMapStyle;

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
    loader = sdk.ImageLoader(sdkContext);
    navigationManager = sdk.NavigationManager(sdkContext);
    trafficRouter = sdk.TrafficRouter(sdkContext);

    _loadMiniMapStyle();

    mapWidgetController.getMapAsync((map) {
      sdkMap = map;
    });

    miniMapWidgetController
      ..getMapAsync((map) {
        miniMap = map;
        miniMap?.interactive = false;
      })
      ..maxFps = const sdk.Fps(20);

    finishMiniMapWidgetController
      ..getMapAsync((map) {
        finishMiniMap = map;
        mapObjectManager = sdk.MapObjectManager(map);
      })
      ..maxFps = const sdk.Fps(20);
  }

  Future<void> _loadMiniMapStyle() async {
    final style = await sdk.StyleBuilder(sdkContext)
        .loadStyle(
          sdk.File.fromAsset(
            sdkContext,
            'minimap_styles.2gis',
          ),
        )
        .value;

    if (!mounted) {
      _finishMiniMapStyle = style;
      return;
    }

    setState(() {
      _finishMiniMapStyle = style;
    });
  }

  @override
  void dispose() {
    super.dispose();
    navigationManager.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: sdk.MapWidget(
        sdkContext: sdkContext,
        mapOptions: sdk.MapOptions(),
        controller: mapWidgetController,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Stack(
            children: [
              sdk.NavigationLayoutWidget(
                navigationManager: navigationManager,
                speedLimitWidgetBuilder: sdk.SpeedLimitWidget.defaultBuilder,
                parkingWidgetBuilder: sdk.NavigationParkingWidget.defaultBuilder,
                zoomWidgetBuilder: sdk.NavigationZoomWidget.defaultBuilder,
                trafficWidgetBuilder: sdk.NavigationTrafficWidget.defaultBuilder,
                compassWidgetbuilder: sdk.NavigationCompassWidget.defaultBuilder,
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
                          mapOptions:
                              sdk.MapOptions(style: _finishMiniMapStyle),
                          controller: miniMapWidgetController,
                          miniMapController: sdk.NavigationMiniMapController(
                            navigationManager: navigationManager,
                          ),
                          size: 150,
                        ),
                      ),
                      Positioned(
                        bottom:
                            orientation == Orientation.landscape ? 16 : null,
                        top: orientation == Orientation.portrait ? 16 : null,
                        right: 60,
                        child: _finishMiniMapStyle == null
                            ? const SizedBox.shrink()
                            : sdk.MiniMapWidget(
                                sdkContext: sdkContext,
                                mapOptions:
                                    sdk.MapOptions(style: _finishMiniMapStyle),
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
      navigationManager.mapManager.addMap(miniMap!);

      miniMap?.camera.addFollowController(
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
