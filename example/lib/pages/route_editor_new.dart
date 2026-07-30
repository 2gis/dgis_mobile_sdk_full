import 'dart:async';

import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:dgis_mobile_sdk_full/l10n/generated/dgis_localizations.dart';
import 'package:dgis_mobile_sdk_full/l10n/generated/dgis_localizations_en.dart';
import 'package:flutter/material.dart';

import 'common.dart';
import 'route_editor_widgets/location_selector_sheet.dart';
import 'route_editor_widgets/route_points_editor_theme.dart';
import 'route_editor_widgets/route_points_editor_widget.dart';

class RouteEditorNewPage extends StatefulWidget {
  final String title;

  const RouteEditorNewPage({required this.title, super.key});

  @override
  State<RouteEditorNewPage> createState() => _RouteEditorNewPageState();
}

class _RouteEditorNewPageState extends State<RouteEditorNewPage> {
  final mapWidgetController = sdk.MapWidgetController();
  final sdkContext = AppContainer().initializeSdk();

  sdk.Map? sdkMap;
  sdk.MapObjectManager? mapObjectManager;
  sdk.RouteEditor? routeEditor;
  sdk.RouteEditorSource? routeEditorSource;
  sdk.RouteEditorController? routeEditorController;
  sdk.SearchManager? searchManager;
  sdk.TrafficRouter? trafficRouter;

  StreamSubscription<sdk.RouteEditorRoutesInfo>? _routesInfoSubscription;
  StreamSubscription<sdk.RouteIndex?>? _routesIndexSubscription;

  sdk.Marker? startMarker;
  sdk.Marker? finishMarker;
  List<sdk.Marker> intermediateMarkers = [];

  late sdk.ImageLoader loader;
  bool showCrosshair = false;
  bool isSelectingLocation = false;
  bool isSelectingStart = true;
  bool useTrafficRouterProvider = false;
  bool useDarkTheme = false;
  bool showRouteEditor = false;
  bool showPointsEditor = false;
  int? editingPointIndex;
  double routeEditorHeight = 0;

  final defaultStartPoint = const sdk.GeoPoint(
    latitude: sdk.Latitude(55.7558),
    longitude: sdk.Longitude(37.6176),
  );
  final defaultFinishPoint = const sdk.GeoPoint(
    latitude: sdk.Latitude(55.7522),
    longitude: sdk.Longitude(37.6156),
  );

  final pinStartPath = 'assets/icons/pina64.png';
  final pinIntermediatePath = 'assets/icons/pin64.png';
  final pinFinishPath = 'assets/icons/pinb64.png';

  final _stackKey = GlobalKey();
  final _cameraPadding = 32;

  @override
  void initState() {
    super.initState();
    loader = sdk.ImageLoader(sdkContext);
    final locationService = sdk.LocationService(sdkContext);
    checkLocationPermissions(locationService).then((_) {
      mapWidgetController
        ..getMapAsync((map) {
          final locationSource = sdk.MyLocationMapObjectSource(sdkContext);
          map.addSource(locationSource);

          routeEditor = sdk.RouteEditor(sdkContext);
          routeEditorSource = sdk.RouteEditorSource(sdkContext, routeEditor!);
          map.addSource(routeEditorSource!);

          routeEditorController = sdk.RouteEditorController(
            routeEditor: routeEditor!,
            briefInfoProvider: _createBriefInfoProvider(),
          );

          searchManager = sdk.SearchManager.createOnlineManager(sdkContext);
          trafficRouter = sdk.TrafficRouter(sdkContext);

          setState(() {
            sdkMap = map;
            showRouteEditor = true;
          });

          map.camera.position = const sdk.CameraPosition(
            point: sdk.GeoPoint(
              latitude: sdk.Latitude(55.75),
              longitude: sdk.Longitude(37.62),
            ),
            zoom: sdk.Zoom(12),
          );
          mapObjectManager = sdk.MapObjectManager(map);

          _addDefaultMarkers().then((_) {
            _setDefaultRoutePoints();
          });

          _routesInfoSubscription =
              routeEditor!.routesInfoChannel.listen(_onRoutesChanged);
          _routesIndexSubscription = routeEditor!.activeRouteIndexChannel
              .listen(_onActiveRouteIndexChanged);
        })
        ..addObjectTappedCallback(_handleRouteObjectTapped)
        ..addObjectLongTouchCallback(_handleMapLongTouch);
    });
  }

  @override
  void dispose() {
    _routesInfoSubscription?.cancel();
    _routesIndexSubscription?.cancel();
    routeEditorController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        key: _stackKey,
        children: [
          sdk.MapWidget(
            sdkContext: sdkContext,
            mapOptions: sdk.MapOptions(),
            controller: mapWidgetController,
            child: Padding(
              padding: EdgeInsets.only(
                left: 6,
                top: 6,
                right: 6,
                bottom: routeEditorHeight + 6,
              ),
              child: Row(
                children: [
                  Column(
                    children: [
                      _ProviderSwitchButton(
                        useTrafficRouterProvider: useTrafficRouterProvider,
                        onTap: _switchBriefInfoProvider,
                      ),
                      const SizedBox(height: 8),
                      _ThemeSwitchButton(
                        useDarkTheme: useDarkTheme,
                        onTap: _switchTheme,
                      ),
                      const Spacer(),
                    ],
                  ),
                  const Spacer(),
                  const Column(
                    children: [
                      sdk.TrafficWidget(),
                      Spacer(),
                      sdk.ZoomWidget(),
                      Spacer(),
                      sdk.CompassWidget(),
                      SizedBox(height: 8),
                      sdk.MyLocationWidget(),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (routeEditorController != null &&
              showRouteEditor &&
              !isSelectingLocation &&
              !showPointsEditor)
            sdk.RouteEditorWidget(
              theme: useDarkTheme
                  ? sdk.RouteEditorViewTheme.defaultDark
                  : sdk.RouteEditorViewTheme.defaultLight,
              controller: routeEditorController!,
              onSwapCallback: _updateMarkers,
              routeSearchPointBuilder: _CustomRouteSearchPointBuilder(
                controller: routeEditorController!,
                onTap: _showPointsEditor,
              ),
              onStartNavigation: (route) {
                _showMessage('Starting navigation');
              },
              onClose: () {
                _setDefaultRoutePoints();
                mapObjectManager?.removeAll();
                _addDefaultMarkers();
              },
              onCollapsed: (height) {
                setState(() {
                  routeEditorHeight = height;
                });
              },
            ),
          if (showPointsEditor && routeEditorController != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: RoutePointsEditorWidget(
                controller: routeEditorController!,
                theme: useDarkTheme
                    ? RoutePointsEditorTheme.defaultDark
                    : RoutePointsEditorTheme.defaultLight,
                routeDuration: _getRouteDuration(),
                onCancel: _hidePointsEditor,
                onPointTap: _onPointTap,
                onAddStop: _onAddStop,
                onPointDeleted: _updateMarkers,
              ),
            ),
          if (showCrosshair && isSelectingLocation)
            const Center(
              child: Icon(
                Icons.add,
                color: Colors.red,
                size: 30,
              ),
            ),
          if (showCrosshair && isSelectingLocation)
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _confirmLocationSelection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Confirm Location'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _cancelLocationSelection,
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _addDefaultMarkers() async {
    if (mapObjectManager == null) return;

    if (startMarker != null) {
      mapObjectManager?.removeObject(startMarker!);
    }
    if (finishMarker != null) {
      mapObjectManager?.removeObject(finishMarker!);
    }

    final startMarkerObj = sdk.Marker(
      sdk.MarkerOptions(
        position: sdk.GeoPointWithElevation(
          latitude: defaultStartPoint.latitude,
          longitude: defaultStartPoint.longitude,
        ),
        icon: await loader.loadPngFromAsset(pinStartPath, 64, 64),
      ),
    );
    mapObjectManager?.addObject(startMarkerObj);
    startMarker = startMarkerObj;

    final finishMarkerObj = sdk.Marker(
      sdk.MarkerOptions(
        position: sdk.GeoPointWithElevation(
          latitude: defaultFinishPoint.latitude,
          longitude: defaultFinishPoint.longitude,
        ),
        icon: await loader.loadPngFromAsset(pinFinishPath, 64, 64),
      ),
    );
    mapObjectManager?.addObject(finishMarkerObj);
    finishMarker = finishMarkerObj;
  }

  void _setDefaultRoutePoints() {
    if (routeEditorController == null) return;

    final startRoutePoint = sdk.RoutePointUI(
      point: sdk.RouteSearchPoint(coordinates: defaultStartPoint),
      label: 'Red Square, Moscow',
    );

    final finishRoutePoint = sdk.RoutePointUI(
      point: sdk.RouteSearchPoint(coordinates: defaultFinishPoint),
      label: 'Kremlin, Moscow',
    );

    routeEditorController!.setRoutePoints([startRoutePoint, finishRoutePoint]);
  }

  void _showLocationSelector(bool isStart) {
    setState(() {
      isSelectingStart = isStart;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildLocationSelectorSheet(),
    );
  }

  Widget _buildLocationSelectorSheet() {
    return LocationSelectorSheet(
      isSelectingStart: isSelectingStart,
      searchManager: searchManager,
      onDirectoryObjectSelected: _onSearchDirectoryObjectSelected,
      onMyLocationPressed: _useMyLocation,
      onChooseOnMapPressed: _chooseOnMap,
      theme: useDarkTheme
          ? LocationSelectorTheme.defaultDark
          : LocationSelectorTheme.defaultLight,
    );
  }

  void _onSearchDirectoryObjectSelected(sdk.DirectoryObject location) {
    Navigator.pop(context);

    final position = location.markerPosition?.point;
    if (position != null) {
      final routePoint = sdk.RoutePointUI(
        point: sdk.RouteSearchPoint(coordinates: position),
        label: location.title,
      );

      final currentPoints =
          List<sdk.RoutePointUI>.from(routeEditorController!.routePoints.value);
      if (isSelectingStart && currentPoints.isNotEmpty) {
        currentPoints[0] = routePoint;
      } else if (!isSelectingStart && currentPoints.length > 1) {
        currentPoints[currentPoints.length - 1] = routePoint;
      }

      routeEditorController!.setRoutePoints(currentPoints);
      _updateMarkers();
    }
  }

  Future<void> _useMyLocation() async {
    Navigator.pop(context);

    final locationService = sdk.LocationService(sdkContext);
    final lastLocation = locationService.lastLocation().value;

    if (lastLocation != null) {
      final newPoint = lastLocation.coordinates.value;

      final routePoint = sdk.RoutePointUI(
        point: sdk.RouteSearchPoint(coordinates: newPoint),
        label: 'My Location',
      );

      final currentPoints =
          List<sdk.RoutePointUI>.from(routeEditorController!.routePoints.value);
      if (isSelectingStart && currentPoints.isNotEmpty) {
        currentPoints[0] = routePoint;
      } else if (!isSelectingStart && currentPoints.length > 1) {
        currentPoints[currentPoints.length - 1] = routePoint;
      }

      routeEditorController!.setRoutePoints(currentPoints);

      await _updateMarkers();
    }
  }

  void _chooseOnMap() {
    Navigator.pop(context);
    setState(() {
      isSelectingLocation = true;
      showCrosshair = true;
    });
  }

  Future<void> _confirmLocationSelection() async {
    if (sdkMap == null) {
      return;
    }

    final selectedPoint = sdkMap!.camera.position.point;

    if (_stackKey.currentContext == null) {
      return;
    }

    final renderBox = _stackKey.currentContext!.findRenderObject();
    if (renderBox == null || renderBox is! RenderBox) {
      return;
    }

    final size = renderBox.size;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final centerX = (size.width / 2) * devicePixelRatio;
    final centerY = (size.height / 2) * devicePixelRatio;

    final renderedObjects = await sdkMap!
        .getRenderedObjects(
          sdk.ScreenPoint(x: centerX, y: centerY),
        )
        .value;

    var label =
        '${selectedPoint.latitude.value.toStringAsFixed(4)}, ${selectedPoint.longitude.value.toStringAsFixed(4)}';
    var coordinates = selectedPoint;

    for (final objectInfo in renderedObjects) {
      final object = objectInfo.item.item;
      if (object is sdk.DgisMapObject) {
        coordinates = objectInfo.closestMapPoint.point;
        final objectId = object.id;
        if (searchManager != null) {
          final directoryObject =
              await searchManager!.searchByDirectoryObjectId(objectId).value;
          if (directoryObject != null) {
            label = directoryObject.title;
          }
        }
        break;
      }
    }

    final routePoint = sdk.RoutePointUI(
      point: sdk.RouteSearchPoint(coordinates: coordinates),
      label: label,
    );

    final currentPoints =
        List<sdk.RoutePointUI>.from(routeEditorController!.routePoints.value);

    if (editingPointIndex == -1) {
      currentPoints.insert(currentPoints.length - 1, routePoint);
    } else if (isSelectingStart && currentPoints.isNotEmpty) {
      currentPoints[0] = routePoint;
    } else if (!isSelectingStart && currentPoints.length > 1) {
      currentPoints[currentPoints.length - 1] = routePoint;
    }

    routeEditorController!.setRoutePoints(currentPoints);

    setState(() {
      isSelectingLocation = false;
      showCrosshair = false;
      editingPointIndex = null;
    });

    await _updateMarkers();
  }

  void _cancelLocationSelection() {
    setState(() {
      isSelectingLocation = false;
      showCrosshair = false;
      editingPointIndex = null;
    });
  }

  Future<void> _updateMarkers() async {
    if (mapObjectManager == null || routeEditorController == null) return;

    if (startMarker != null) {
      mapObjectManager?.removeObject(startMarker!);
      startMarker = null;
    }
    if (finishMarker != null) {
      mapObjectManager?.removeObject(finishMarker!);
      finishMarker = null;
    }
    intermediateMarkers
      ..forEach(mapObjectManager!.removeObject)
      ..clear();

    final routePoints = routeEditorController!.routePoints.value;

    if (routePoints.isNotEmpty) {
      final startPoint = routePoints[0].point.coordinates;
      final marker = sdk.Marker(
        sdk.MarkerOptions(
          position: sdk.GeoPointWithElevation(
            latitude: startPoint.latitude,
            longitude: startPoint.longitude,
          ),
          icon: await loader.loadPngFromAsset(pinStartPath, 64, 64),
        ),
      );
      mapObjectManager?.addObject(marker);
      startMarker = marker;
    }

    if (routePoints.length > 2) {
      for (var i = 1; i < routePoints.length - 1; i++) {
        final intermediatePoint = routePoints[i].point.coordinates;
        final marker = sdk.Marker(
          sdk.MarkerOptions(
            position: sdk.GeoPointWithElevation(
              latitude: intermediatePoint.latitude,
              longitude: intermediatePoint.longitude,
            ),
            icon: await loader.loadPngFromAsset(pinIntermediatePath, 64, 64),
          ),
        );
        mapObjectManager?.addObject(marker);
        intermediateMarkers.add(marker);
      }
    }

    if (routePoints.length > 1) {
      final finishPoint = routePoints[routePoints.length - 1].point.coordinates;
      final marker = sdk.Marker(
        sdk.MarkerOptions(
          position: sdk.GeoPointWithElevation(
            latitude: finishPoint.latitude,
            longitude: finishPoint.longitude,
          ),
          icon: await loader.loadPngFromAsset(pinFinishPath, 64, 64),
        ),
      );
      mapObjectManager?.addObject(marker);
      finishMarker = marker;
    }
  }

  Future<void> _handleRouteObjectTapped(
    sdk.RenderedObjectInfo objectInfo,
  ) async {
    final object = objectInfo.item.item;

    if (object is sdk.RouteMapObject && routeEditorController != null) {
      final routeIndex = object.routeIndex.value;
      routeEditorController!.setActiveRouteIndex(routeIndex);
    }
  }

  Future<void> _handleMapLongTouch(sdk.RenderedObjectInfo objectInfo) async {
    if (!showRouteEditor || routeEditorController == null) return;
    if (isSelectingLocation || showPointsEditor) return;

    final currentPoints = routeEditorController!.routePoints.value;
    if (currentPoints.length < 2) return;

    final object = objectInfo.item.item;
    String label;
    sdk.GeoPoint coordinates;

    final closestPoint = sdk.GeoPoint(
      latitude: objectInfo.closestMapPoint.latitude,
      longitude: objectInfo.closestMapPoint.longitude,
    );

    if (object is sdk.DgisMapObject && searchManager != null) {
      final objectId = object.id;
      final directoryObject =
          await searchManager!.searchByDirectoryObjectId(objectId).value;

      if (directoryObject != null) {
        label = directoryObject.title;
        coordinates = directoryObject.markerPosition?.point ?? closestPoint;
      } else {
        coordinates = closestPoint;
        label =
            '${coordinates.latitude.value.toStringAsFixed(4)}, ${coordinates.longitude.value.toStringAsFixed(4)}';
      }
    } else {
      coordinates = closestPoint;
      label =
          '${coordinates.latitude.value.toStringAsFixed(4)}, ${coordinates.longitude.value.toStringAsFixed(4)}';
    }

    final routePoint = sdk.RoutePointUI(
      point: sdk.RouteSearchPoint(coordinates: coordinates),
      label: label,
    );

    final newPoints = List<sdk.RoutePointUI>.from(currentPoints);
    newPoints.insert(newPoints.length - 1, routePoint);

    routeEditorController!.setRoutePoints(newPoints);
    await _updateMarkers();
  }

  sdk.BriefInfoProvider _createBriefInfoProvider() {
    if (useTrafficRouterProvider && trafficRouter != null) {
      return sdk.TrafficRouterBriefInfoProvider(trafficRouter: trafficRouter!);
    } else {
      return sdk.ActiveRouteBriefInfoProvider();
    }
  }

  void _switchTheme() {
    setState(() {
      useDarkTheme = !useDarkTheme;
    });
  }

  void _onRoutesChanged(sdk.RouteEditorRoutesInfo routesInfo) {
    if (routesInfo.routes.isNotEmpty && sdkMap != null) {
      _fitCameraToActiveRoute(routesInfo);
    }
  }

  void _onActiveRouteIndexChanged(sdk.RouteIndex? routeIndex) {
    if (routeIndex != null && routeEditor != null) {
      final routesInfo = routeEditor!.routesInfoChannel.value;
      if (routesInfo.routes.isNotEmpty && sdkMap != null) {
        _fitCameraToActiveRoute(routesInfo);
      }
    }
  }

  Future<void> _fitCameraToActiveRoute(
    sdk.RouteEditorRoutesInfo routesInfo,
  ) async {
    if (sdkMap == null || routesInfo.routes.isEmpty) return;

    final activeRouteIndex =
        routeEditor?.activeRouteIndexChannel.value?.value ?? 0;
    final activeRoute = routesInfo.routes[activeRouteIndex].route;
    final routeGeometry = activeRoute.geometry;

    final mapGeometry = sdk.toMapGeometry(routeGeometry);

    final dpi = MediaQuery.of(context).devicePixelRatio;

    final cameraPosition = sdk.calcPositionForGeometry(
      sdkMap!.camera,
      mapGeometry,
      null,
      sdk.Padding(
        top: (_cameraPadding * dpi).ceil(),
        bottom: ((routeEditorHeight + _cameraPadding) * dpi).ceil(),
        left: (_cameraPadding * dpi).ceil(),
        right: (_cameraPadding * dpi).ceil(),
      ),
      null,
      null,
      null,
    );

    await sdkMap!.camera.moveToCameraPosition(cameraPosition).value;
  }

  void _switchBriefInfoProvider() {
    setState(() {
      useTrafficRouterProvider = !useTrafficRouterProvider;
    });

    if (routeEditor != null) {
      final oldController = routeEditorController;
      final oldRoutePoints = oldController?.routePoints.value ?? [];

      oldController?.dispose();

      routeEditorController = sdk.RouteEditorController(
        routeEditor: routeEditor!,
        briefInfoProvider: _createBriefInfoProvider(),
      );

      if (oldRoutePoints.isNotEmpty) {
        routeEditorController!.setRoutePoints(oldRoutePoints);
      } else {
        _setDefaultRoutePoints();
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showPointsEditor() {
    setState(() {
      showPointsEditor = true;
    });
  }

  void _hidePointsEditor() {
    setState(() {
      showPointsEditor = false;
      editingPointIndex = null;
    });
    _updateMarkers();
  }

  String? _getRouteDuration() {
    if (routeEditor == null) return null;
    final routesInfo = routeEditor!.routesInfoChannel.value;
    if (routesInfo.routes.isEmpty) return null;

    final activeIndex = routeEditor!.activeRouteIndexChannel.value?.value ?? 0;
    if (activeIndex >= routesInfo.routes.length) return null;

    final trafficRoute = routesInfo.routes[activeIndex];
    final durationMinutes = trafficRoute.traffic.durations.duration.inMinutes;

    final localizations =
        DgisLocalizations.of(context) ?? DgisLocalizationsEn();
    return localizations.dgis_min__minutes_format(durationMinutes);
  }

  void _onPointTap(int index) {
    setState(() {
      editingPointIndex = index;
      isSelectingStart = index == 0;
    });
    _hidePointsEditor();
    _showLocationSelector(index == 0);
  }

  void _onAddStop() {
    _hidePointsEditor();
    setState(() {
      editingPointIndex = routeEditorController!.routePoints.value.length - 1;
      isSelectingStart = false;
    });
    _showLocationSelectorForIntermediatePoint();
  }

  void _showLocationSelectorForIntermediatePoint() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LocationSelectorSheet(
        isSelectingStart: false,
        searchManager: searchManager,
        onDirectoryObjectSelected: _onIntermediatePointSelected,
        onMyLocationPressed: _useMyLocationForIntermediatePoint,
        onChooseOnMapPressed: _chooseOnMapForIntermediatePoint,
        theme: useDarkTheme
            ? LocationSelectorTheme.defaultDark
            : LocationSelectorTheme.defaultLight,
      ),
    );
  }

  void _onIntermediatePointSelected(sdk.DirectoryObject location) {
    Navigator.pop(context);

    final position = location.markerPosition?.point;
    if (position != null) {
      final routePoint = sdk.RoutePointUI(
        point: sdk.RouteSearchPoint(coordinates: position),
        label: location.title,
      );

      final currentPoints =
          List<sdk.RoutePointUI>.from(routeEditorController!.routePoints.value);
      currentPoints.insert(currentPoints.length - 1, routePoint);

      routeEditorController!.setRoutePoints(currentPoints);
      _updateMarkers();
    }
  }

  Future<void> _useMyLocationForIntermediatePoint() async {
    Navigator.pop(context);

    final locationService = sdk.LocationService(sdkContext);
    final lastLocation = locationService.lastLocation().value;

    if (lastLocation != null) {
      final newPoint = lastLocation.coordinates.value;

      final routePoint = sdk.RoutePointUI(
        point: sdk.RouteSearchPoint(coordinates: newPoint),
        label: 'My Location',
      );

      final currentPoints =
          List<sdk.RoutePointUI>.from(routeEditorController!.routePoints.value);

      currentPoints.insert(currentPoints.length - 1, routePoint);

      routeEditorController!.setRoutePoints(currentPoints);
      await _updateMarkers();
    }
  }

  void _chooseOnMapForIntermediatePoint() {
    Navigator.pop(context);
    setState(() {
      isSelectingLocation = true;
      showCrosshair = true;
      editingPointIndex = -1;
    });
  }
}

class _ProviderSwitchButton extends StatefulWidget {
  final bool useTrafficRouterProvider;
  final VoidCallback onTap;

  const _ProviderSwitchButton({
    required this.useTrafficRouterProvider,
    required this.onTap,
  });

  @override
  State<_ProviderSwitchButton> createState() => _ProviderSwitchButtonState();
}

class _ProviderSwitchButtonState extends State<_ProviderSwitchButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        setState(() {
          isPressed = true;
        });
      },
      onTapUp: (details) {
        setState(() {
          isPressed = false;
        });
        widget.onTap();
      },
      onTapCancel: () {
        setState(() {
          isPressed = false;
        });
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isPressed
              ? Colors.grey[600]
              : Colors.black.withValues(alpha: 0.7),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x33141414),
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            widget.useTrafficRouterProvider ? Icons.network_check : Icons.route,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _ThemeSwitchButton extends StatefulWidget {
  final bool useDarkTheme;
  final VoidCallback onTap;

  const _ThemeSwitchButton({
    required this.useDarkTheme,
    required this.onTap,
  });

  @override
  State<_ThemeSwitchButton> createState() => _ThemeSwitchButtonState();
}

class _ThemeSwitchButtonState extends State<_ThemeSwitchButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        setState(() {
          isPressed = true;
        });
      },
      onTapUp: (details) {
        setState(() {
          isPressed = false;
        });
        widget.onTap();
      },
      onTapCancel: () {
        setState(() {
          isPressed = false;
        });
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isPressed
              ? Colors.grey[600]
              : Colors.black.withValues(alpha: 0.7),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x33141414),
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            widget.useDarkTheme ? Icons.dark_mode : Icons.light_mode,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _CustomRouteSearchPointBuilder implements sdk.RouteSearchPointBuilder {
  final sdk.RouteEditorController controller;
  final VoidCallback onTap;

  const _CustomRouteSearchPointBuilder({
    required this.controller,
    required this.onTap,
  });

  @override
  Widget buildStartPointView(
    sdk.RoutePointUI point,
    sdk.RouteEditorController controller,
    sdk.RouteEditorViewTheme theme,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              point.label,
              style: theme.startLabelTextStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.edit,
            size: 14,
            color: theme.startLabelTextStyle.color?.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildFinishPointView(
    sdk.RoutePointUI point,
    sdk.RouteEditorController controller,
    sdk.RouteEditorViewTheme theme,
  ) {
    return _FinishPointView(
      point: point,
      controller: this.controller,
      theme: theme,
      onTap: onTap,
    );
  }
}

class _FinishPointView extends StatelessWidget {
  final sdk.RoutePointUI point;
  final sdk.RouteEditorController controller;
  final sdk.RouteEditorViewTheme theme;
  final VoidCallback onTap;

  const _FinishPointView({
    required this.point,
    required this.controller,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<sdk.RoutePointUI>>(
      valueListenable: controller.routePoints,
      builder: (context, points, _) {
        final intermediateCount = points.length - 2;
        final localizations =
            DgisLocalizations.of(context) ?? DgisLocalizationsEn();

        final label = intermediateCount > 0
            ? localizations.dgis_stops(intermediateCount)
            : point.label;

        return GestureDetector(
          onTap: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: theme.finishLabelTextStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.edit,
                size: 14,
                color: theme.finishLabelTextStyle.color?.withValues(alpha: 0.7),
              ),
            ],
          ),
        );
      },
    );
  }
}
