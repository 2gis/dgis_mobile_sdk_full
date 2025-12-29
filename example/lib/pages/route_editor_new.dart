import 'dart:async';

import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:flutter/material.dart';

import 'common.dart';

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

  late sdk.ImageLoader loader;
  bool showCrosshair = false;
  bool isSelectingLocation = false;
  bool isSelectingStart = true;
  bool useTrafficRouterProvider = false;
  bool useDarkTheme = false;
  bool showRouteEditor = false;
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
  final pinFinishPath = 'assets/icons/pinb64.png';

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
        ..addObjectTappedCallback(_handleRouteObjectTapped);
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
              !isSelectingLocation)
            sdk.RouteEditorWidget(
              theme: useDarkTheme
                  ? sdk.RouteEditorViewTheme.defaultDark
                  : sdk.RouteEditorViewTheme.defaultLight,
              controller: routeEditorController!,
              onSwapCallback: _updateMarkers,
              routeSearchPointBuilder: _CustomRouteSearchPointBuilder(
                onStartPointTap: () => _showLocationSelector(true),
                onFinishPointTap: () => _showLocationSelector(false),
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
      sdkContext: sdkContext,
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

  void _confirmLocationSelection() {
    if (sdkMap == null) return;

    final selectedPoint = sdkMap!.camera.position.point;

    final routePoint = sdk.RoutePointUI(
      point: sdk.RouteSearchPoint(coordinates: selectedPoint),
      label:
          '${selectedPoint.latitude.value.toStringAsFixed(4)}, ${selectedPoint.longitude.value.toStringAsFixed(4)}',
    );

    final currentPoints =
        List<sdk.RoutePointUI>.from(routeEditorController!.routePoints.value);
    if (isSelectingStart && currentPoints.isNotEmpty) {
      currentPoints[0] = routePoint;
    } else if (!isSelectingStart && currentPoints.length > 1) {
      currentPoints[currentPoints.length - 1] = routePoint;
    }

    routeEditorController!.setRoutePoints(currentPoints);

    setState(() {
      isSelectingLocation = false;
      showCrosshair = false;
    });

    _updateMarkers();
  }

  void _cancelLocationSelection() {
    setState(() {
      isSelectingLocation = false;
      showCrosshair = false;
    });
  }

  Future<void> _updateMarkers() async {
    if (mapObjectManager == null || routeEditorController == null) return;

    if (startMarker != null) {
      mapObjectManager?.removeObject(startMarker!);
    }
    if (finishMarker != null) {
      mapObjectManager?.removeObject(finishMarker!);
    }

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
}

class LocationSelectorSheet extends StatefulWidget {
  final bool isSelectingStart;
  final sdk.SearchManager? searchManager;
  final Function(sdk.DirectoryObject) onDirectoryObjectSelected;
  final VoidCallback onMyLocationPressed;
  final VoidCallback onChooseOnMapPressed;
  final sdk.Context sdkContext;

  const LocationSelectorSheet({
    required this.isSelectingStart,
    required this.searchManager,
    required this.onDirectoryObjectSelected,
    required this.onMyLocationPressed,
    required this.onChooseOnMapPressed,
    required this.sdkContext,
    super.key,
  });

  @override
  State<LocationSelectorSheet> createState() => _LocationSelectorSheetState();
}

class _LocationSelectorSheetState extends State<LocationSelectorSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.isSelectingStart
                      ? 'Select start location'
                      : 'Select destination',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: widget.onMyLocationPressed,
                        icon: const Icon(Icons.my_location),
                        label: const Text('My Location'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: widget.onChooseOnMapPressed,
                        icon: const Icon(Icons.map),
                        label: const Text('Choose on Map'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: widget.searchManager != null
                ? sdk.DgisSearchWidget(
                    searchManager: widget.searchManager!,
                    onObjectSelected: widget.onDirectoryObjectSelected,
                  )
                : const Center(
                    child: Text(
                      'Search not available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
          ),
        ],
      ),
    );
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
  final VoidCallback onStartPointTap;
  final VoidCallback onFinishPointTap;

  const _CustomRouteSearchPointBuilder({
    required this.onStartPointTap,
    required this.onFinishPointTap,
  });

  @override
  Widget buildStartPointView(
    sdk.RoutePointUI point,
    sdk.RouteEditorController controller,
    sdk.RouteEditorViewTheme theme,
  ) {
    return GestureDetector(
      onTap: onStartPointTap,
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
    return GestureDetector(
      onTap: onFinishPointTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              point.label,
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
  }
}
