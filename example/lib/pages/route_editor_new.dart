import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:dgis_mobile_sdk_full/l10n/generated/dgis_localizations.dart';
import 'package:dgis_mobile_sdk_full/l10n/generated/dgis_localizations_en.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

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
  final sdkContext = AppContainer().initializeSdk();
  late final sdk.MapWidgetController mapWidgetController =
      createMapWidgetController(sdkContext);

  final _showCrosshairNotifier = ValueNotifier<bool>(false);
  final _isSelectingLocationNotifier = ValueNotifier<bool>(false);
  final _isSelectingStartNotifier = ValueNotifier<bool>(false);
  final _useTrafficRouterProviderNotifier = ValueNotifier<bool>(false);
  final _showRouteEditorNotifier = ValueNotifier<bool>(false);
  final _showPointsEditorNotifier = ValueNotifier<bool>(false);
  final _hasRouteEditorInitializedNotifier = ValueNotifier<bool>(false);
  final _editorInsetsNotifier = ValueNotifier<EdgeInsets>(EdgeInsets.zero);
  final _editingPointIndexNotifier = ValueNotifier<int?>(null);

  sdk.MapObjectManager? mapObjectManager;
  sdk.RouteEditor? routeEditor;
  sdk.RouteEditorSource? routeEditorSource;
  sdk.RouteEditorController? routeEditorController;
  sdk.SearchManager? searchManager;
  sdk.TrafficRouter? trafficRouter;

  StreamSubscription<sdk.RouteEditorRoutesInfo>? _routesInfoSubscription;
  StreamSubscription<sdk.RouteIndex?>? _routesIndexSubscription;

  sdk.MyLocationController? _myLocationController;

  sdk.NavigationSettingsRepository? _navigationSettings;
  sdk.SettingsTransportModeProvider? _settingsProvider;

  sdk.Marker? startMarker;
  sdk.Marker? finishMarker;
  List<sdk.Marker> intermediateMarkers = [];

  late sdk.ImageLoader loader;

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

    unawaited(_initContext(locationService));
  }

  @override
  void dispose() {
    _showCrosshairNotifier.dispose();
    _isSelectingLocationNotifier.dispose();
    _isSelectingStartNotifier.dispose();
    _useTrafficRouterProviderNotifier.dispose();
    _showRouteEditorNotifier.dispose();
    _showPointsEditorNotifier.dispose();
    _hasRouteEditorInitializedNotifier.dispose();
    _editorInsetsNotifier.dispose();
    _editingPointIndexNotifier.dispose();

    _routesInfoSubscription?.cancel();
    _routesIndexSubscription?.cancel();
    routeEditorController?.dispose();
    _myLocationController?.dispose();
    _navigationSettings?.dispose();
    super.dispose();
  }

  Future<void> _initContext(sdk.LocationService locationService) async {
    await checkLocationPermissions(locationService);

    final map = await mapWidgetController.mapAsync;
    if (!mounted) {
      return;
    }

    final locationSource = sdk.MyLocationMapObjectSource(sdkContext);
    map.addSource(locationSource);

    routeEditor = sdk.RouteEditor(sdkContext);
    routeEditorSource = sdk.RouteEditorSource(sdkContext, routeEditor!);
    map.addSource(routeEditorSource!);

    _navigationSettings = await sdk.NavigationSettingsRepository.defaults();
    _settingsProvider = sdk.SettingsTransportModeProvider(_navigationSettings!);

    routeEditorController = sdk.RouteEditorController(
      routeEditor: routeEditor!,
      briefInfoProvider: _createBriefInfoProvider(),
      transportTypeOptionsProvider: _settingsProvider,
    );

    searchManager = sdk.SearchManager.createOnlineManager(sdkContext);
    trafficRouter = sdk.TrafficRouter(sdkContext);

    map.camera.position = const sdk.CameraPosition(
      point: sdk.GeoPoint(
        latitude: sdk.Latitude(55.75),
        longitude: sdk.Longitude(37.62),
      ),
      zoom: sdk.Zoom(12),
    );
    mapObjectManager = sdk.MapObjectManager(map);

    unawaited(
      _addDefaultMarkers().then((_) {
        _setDefaultRoutePoints();
      }),
    );

    _routesInfoSubscription = routeEditor!.routesInfoChannel.listen(
      _onRoutesChanged,
    );
    _routesIndexSubscription = routeEditor!.activeRouteIndexChannel.listen(
      _onActiveRouteIndexChanged,
    );

    if (!mounted) return;

    _showRouteEditorNotifier.value = true;

    setState(() {
      mapWidgetController
        ..addObjectTappedCallback(_handleRouteObjectTapped)
        ..addObjectLongTouchCallback(_handleMapLongTouch);
      _myLocationController = sdk.MyLocationController(
        map: map,
        onPermissionRequest: () async {
          await Permission.location.request();
        },
        onTapFeedback: HapticFeedback.mediumImpact,
      );
    });
  }

  /// Determines physical location of the front camera in landscape orientation
  double _getControlsInsets(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    if (!isLandscape) return 0;

    final padding = mediaQuery.padding;
    if (Platform.isAndroid) {
      // Check if there is a camera block in the horizontal orientation on the
      // left side
      return padding.right > 0 ? padding.right : 8;
    } else if (Platform.isIOS) {
      // And also on iOS
      final isLeftSide = mediaQuery.viewPadding.top == 0;

      return !isLeftSide ? mediaQuery.viewPadding.left : 8;
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isSystemThemeDark = mediaQuery.platformBrightness == Brightness.dark;
    final theme = isSystemThemeDark
        ? sdk.RouteEditorViewTheme.defaultDark
        : sdk.RouteEditorViewTheme.defaultLight;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    return Scaffold(
      appBar: !isLandscape
          ? AppBar(
              title: Text(
                widget.title,
                style: theme.finishLabelTextStyle.copyWith(fontSize: 22),
              ),
              backgroundColor: theme.backgroundColor,
              iconTheme: IconThemeData(
                color: isSystemThemeDark ? Colors.white : Colors.black,
              ),
            )
          : null,
      backgroundColor: theme.backgroundColor,
      body: Stack(
        key: _stackKey,
        children: [
          sdk.MapWidget(
            sdkContext: sdkContext,
            controller: mapWidgetController,
            child: ValueListenableBuilder(
              valueListenable: _editorInsetsNotifier,
              builder: (context, editorInsets, child) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: 6 + editorInsets.left,
                    top: 6 + editorInsets.top,
                    right: 6 + editorInsets.right,
                    bottom: 6 + editorInsets.bottom,
                  ),
                  child: child,
                );
              },
              child: Row(
                children: [
                  Column(
                    children: [
                      ValueListenableBuilder(
                        valueListenable: _useTrafficRouterProviderNotifier,
                        builder: (context, useTrafficRouterProvider, child) {
                          return _ProviderSwitchButton(
                            useTrafficRouterProvider: useTrafficRouterProvider,
                            onTap: _switchBriefInfoProvider,
                          );
                        },
                      ),
                      const Spacer(),
                    ],
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.only(
                      right: _getControlsInsets(context),
                      top: isLandscape ? 8 : 0,
                      bottom: isLandscape ? 8 : 0,
                    ),
                    child: Column(
                      children: [
                        const sdk.TrafficWidget(),
                        const Spacer(),
                        const sdk.ZoomWidget(),
                        const Spacer(),
                        const sdk.CompassWidget(),
                        const SizedBox(height: 8),
                        if (_myLocationController != null)
                          sdk.MyLocationWidget(
                            controller: _myLocationController!,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (routeEditorController != null)
            ValueListenableBuilder(
              valueListenable: _isSelectingLocationNotifier,
              builder: (context, isSelectingLocation, child) {
                if (isSelectingLocation || child == null) {
                  return const SizedBox.shrink();
                }

                return child;
              },
              child: ValueListenableBuilder(
                valueListenable: _showRouteEditorNotifier,
                builder: (context, showRouteEditor, child) {
                  if (!showRouteEditor || child == null) {
                    return const SizedBox.shrink();
                  }

                  return child;
                },
                child: ValueListenableBuilder(
                  valueListenable: _showPointsEditorNotifier,
                  builder: (context, showPointsEditor, child) {
                    if (showPointsEditor || child == null) {
                      return const SizedBox.shrink();
                    }

                    return child;
                  },
                  child: sdk.RouteEditorWidget(
                    controller: routeEditorController!,
                    theme: theme,
                    navigationSettings: sdk.NavigationSettingsOptions(
                      repository: _navigationSettings,
                    ),
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
                    onInitLayout: (height) {
                      if (_hasRouteEditorInitializedNotifier.value) return;
                      _hasRouteEditorInitializedNotifier.value = true;

                      // It is necessary to adjust the camera to the route after
                      // initialization [sdk.RouteEditorWidget] only once
                      _editorInsetsNotifier.value = EdgeInsets.only(
                        bottom: height,
                      );
                    },
                    onReservedInsetsChanged: (insets) async {
                      _editorInsetsNotifier.value = insets;

                      final routesInfo = routeEditor?.routesInfoChannel.value;
                      if (routesInfo == null || routesInfo.routes.isEmpty) {
                        return;
                      }
                      await Future.delayed(
                        const Duration(milliseconds: 10),
                      );

                      unawaited(_fitCameraToActiveRoute(routesInfo));
                    },
                  ),
                ),
              ),
            ),
          if (routeEditorController != null)
            ValueListenableBuilder(
              valueListenable: _showPointsEditorNotifier,
              builder: (context, showPointsEditor, child) {
                if (!showPointsEditor || child == null) {
                  return const SizedBox.shrink();
                }

                return child;
              },
              child: Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: RoutePointsEditorWidget(
                  controller: routeEditorController!,
                  theme: isSystemThemeDark
                      ? RoutePointsEditorTheme.defaultDark
                      : RoutePointsEditorTheme.defaultLight,
                  routeDuration: _getRouteDuration(),
                  onCancel: _hidePointsEditor,
                  onPointTap: _onPointTap,
                  onAddStop: _onAddStop,
                  onPointDeleted: _updateMarkers,
                ),
              ),
            ),
          ValueListenableBuilder(
            valueListenable: _showCrosshairNotifier,
            builder: (context, showCrosshair, child) {
              if (!showCrosshair || child == null) {
                return const SizedBox.shrink();
              }

              return child;
            },
            child: ValueListenableBuilder(
              valueListenable: _isSelectingLocationNotifier,
              builder: (context, isSelectingLocation, child) {
                if (!isSelectingLocation || child == null) {
                  return const SizedBox.shrink();
                }

                return child;
              },
              child: const Center(
                child: Icon(Icons.add, color: Colors.red, size: 30),
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: _showCrosshairNotifier,
            builder: (context, showCrosshair, child) {
              if (!showCrosshair || child == null) {
                return const SizedBox.shrink();
              }

              return child;
            },

            child: ValueListenableBuilder(
              valueListenable: _isSelectingLocationNotifier,
              builder: (context, isSelectingLocation, child) {
                if (!isSelectingLocation || child == null) {
                  return const SizedBox.shrink();
                }

                return child;
              },
              child: Positioned(
                bottom: math.max(16, MediaQuery.of(context).padding.bottom),
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
    _isSelectingStartNotifier.value = isStart;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        final isSystemThemeDark =
            mediaQuery.platformBrightness == Brightness.dark;

        return ValueListenableBuilder(
          valueListenable: _isSelectingStartNotifier,
          builder: (context, isSelectingStart, child) {
            return LocationSelectorSheet(
              isSelectingStart: isSelectingStart,
              searchManager: searchManager,
              onDirectoryObjectSelected: _onSearchDirectoryObjectSelected,
              onMyLocationPressed: _useMyLocation,
              onChooseOnMapPressed: _chooseOnMap,
              theme: isSystemThemeDark
                  ? LocationSelectorTheme.defaultDark
                  : LocationSelectorTheme.defaultLight,
            );
          },
        );
      },
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

      final currentPoints = List<sdk.RoutePointUI>.from(
        routeEditorController!.routePoints.value,
      );
      if (_isSelectingStartNotifier.value && currentPoints.isNotEmpty) {
        currentPoints[0] = routePoint;
      } else if (!_isSelectingStartNotifier.value && currentPoints.length > 1) {
        currentPoints[currentPoints.length - 1] = routePoint;
      }

      routeEditorController!.setRoutePoints(currentPoints);
      _updateMarkers();
    }
  }

  Future<void> _useMyLocation() async {
    Navigator.pop(context);

    final locationService = sdk.LocationService(sdkContext);
    final lastLocation = locationService.lastLocation;

    if (lastLocation != null) {
      final newPoint = lastLocation.coordinates.value;

      final routePoint = sdk.RoutePointUI(
        point: sdk.RouteSearchPoint(coordinates: newPoint),
        label: 'My Location',
      );

      final currentPoints = List<sdk.RoutePointUI>.from(
        routeEditorController!.routePoints.value,
      );
      if (_isSelectingStartNotifier.value && currentPoints.isNotEmpty) {
        currentPoints[0] = routePoint;
      } else if (!_isSelectingStartNotifier.value && currentPoints.length > 1) {
        currentPoints[currentPoints.length - 1] = routePoint;
      }

      routeEditorController!.setRoutePoints(currentPoints);

      await _updateMarkers();
    }
  }

  void _chooseOnMap() {
    Navigator.pop(context);

    _isSelectingLocationNotifier.value = true;
    _showCrosshairNotifier.value = true;
    _editorInsetsNotifier.value = EdgeInsets.zero;
  }

  Future<void> _confirmLocationSelection() async {
    final map = await mapWidgetController.mapAsync;
    if (!mounted) {
      return;
    }

    final selectedPoint = map.camera.position.point;

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

    final renderedObjects = await map
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
          final directoryObjects = await searchManager!
              .searchByDirectoryObjectIds([objectId])
              .value;
          if (directoryObjects.isNotEmpty) {
            label = directoryObjects.first.title;
          }
        }
        break;
      }
    }

    final routePoint = sdk.RoutePointUI(
      point: sdk.RouteSearchPoint(coordinates: coordinates),
      label: label,
    );

    final currentPoints = List<sdk.RoutePointUI>.from(
      routeEditorController!.routePoints.value,
    );

    if (_editingPointIndexNotifier.value == -1) {
      currentPoints.insert(currentPoints.length - 1, routePoint);
    } else if (_isSelectingStartNotifier.value && currentPoints.isNotEmpty) {
      currentPoints[0] = routePoint;
    } else if (!_isSelectingStartNotifier.value && currentPoints.length > 1) {
      currentPoints[currentPoints.length - 1] = routePoint;
    }

    routeEditorController!.setRoutePoints(currentPoints);

    _isSelectingLocationNotifier.value = false;
    _showCrosshairNotifier.value = false;

    _editingPointIndexNotifier.value = null;

    await _updateMarkers();
  }

  void _cancelLocationSelection() {
    _isSelectingLocationNotifier.value = false;
    _showCrosshairNotifier.value = false;
    _editingPointIndexNotifier.value = null;
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
    if (!_showRouteEditorNotifier.value || routeEditorController == null) {
      return;
    }
    if (_isSelectingLocationNotifier.value || _showPointsEditorNotifier.value) {
      return;
    }

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
      final directoryObjects = await searchManager!.searchByDirectoryObjectIds([
        objectId,
      ]).value;
      final directoryObject = directoryObjects.firstOrNull;

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
    if (_useTrafficRouterProviderNotifier.value && trafficRouter != null) {
      return sdk.TrafficRouterBriefInfoProvider(trafficRouter: trafficRouter!);
    } else {
      return sdk.ActiveRouteBriefInfoProvider();
    }
  }

  void _onRoutesChanged(sdk.RouteEditorRoutesInfo routesInfo) {
    if (routesInfo.routes.isNotEmpty) {
      unawaited(_fitCameraToActiveRoute(routesInfo));
    }
  }

  void _onActiveRouteIndexChanged(sdk.RouteIndex? routeIndex) {
    if (routeIndex != null && routeEditor != null) {
      final routesInfo = routeEditor!.routesInfoChannel.value;
      if (routesInfo.routes.isNotEmpty) {
        unawaited(_fitCameraToActiveRoute(routesInfo));
      }
    }
  }

  Future<void> _fitCameraToActiveRoute(
    sdk.RouteEditorRoutesInfo routesInfo,
  ) async {
    if (routesInfo.routes.isEmpty) return;
    final map = await mapWidgetController.mapAsync;
    if (!mounted) {
      return;
    }

    final activeRouteIndex =
        routeEditor?.activeRouteIndexChannel.value?.value ?? 0;
    final activeRoute = routesInfo.routes[activeRouteIndex].route;
    final routeGeometry = activeRoute.geometry;
    final mapGeometry = sdk.toMapGeometry(routeGeometry);
    final editorInsets = _editorInsetsNotifier.value;
    final mediaQuery = MediaQuery.of(context);
    final dpi = mediaQuery.devicePixelRatio;
    final cameraPosition = sdk.calcPositionForGeometry(
      map.camera,
      mapGeometry,
      null,
      sdk.Padding(
        top: ((editorInsets.top + _cameraPadding) * dpi).ceil(),
        bottom: ((editorInsets.bottom + _cameraPadding) * dpi).ceil(),
        left: ((editorInsets.left + _cameraPadding) * dpi).ceil(),
        right: ((editorInsets.right + _cameraPadding) * dpi).ceil(),
      ),
      null,
      null,
      null,
    );

    await map.camera.moveToCameraPosition(cameraPosition).value;
  }

  Future<void> _switchBriefInfoProvider() async {
    _useTrafficRouterProviderNotifier.value =
        !_useTrafficRouterProviderNotifier.value;

    if (routeEditor != null) {
      final oldController = routeEditorController;
      final oldNavigationSettings = _navigationSettings;
      final oldRoutePoints = oldController?.routePoints.value ?? [];

      oldController?.dispose();
      oldNavigationSettings?.dispose();

      _navigationSettings = await sdk.NavigationSettingsRepository.defaults();
      _settingsProvider = sdk.SettingsTransportModeProvider(
        _navigationSettings!,
      );

      routeEditorController = sdk.RouteEditorController(
        routeEditor: routeEditor!,
        briefInfoProvider: _createBriefInfoProvider(),
        transportTypeOptionsProvider: _settingsProvider,
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
    _showPointsEditorNotifier.value = true;
  }

  void _hidePointsEditor() {
    _showPointsEditorNotifier.value = false;
    _editingPointIndexNotifier.value = null;

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
    _isSelectingStartNotifier.value = index == 0;
    _editingPointIndexNotifier.value = index;

    _hidePointsEditor();
    _showLocationSelector(index == 0);
  }

  void _onAddStop() {
    _hidePointsEditor();
    _isSelectingStartNotifier.value = false;
    _editingPointIndexNotifier.value =
        routeEditorController!.routePoints.value.length - 1;

    _showLocationSelectorForIntermediatePoint();
  }

  void _showLocationSelectorForIntermediatePoint() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        final isSystemThemeDark =
            mediaQuery.platformBrightness == Brightness.dark;

        return LocationSelectorSheet(
          isSelectingStart: false,
          searchManager: searchManager,
          onDirectoryObjectSelected: _onIntermediatePointSelected,
          onMyLocationPressed: _useMyLocationForIntermediatePoint,
          onChooseOnMapPressed: _chooseOnMapForIntermediatePoint,
          theme: isSystemThemeDark
              ? LocationSelectorTheme.defaultDark
              : LocationSelectorTheme.defaultLight,
        );
      },
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

      final currentPoints = List<sdk.RoutePointUI>.from(
        routeEditorController!.routePoints.value,
      );
      currentPoints.insert(currentPoints.length - 1, routePoint);

      routeEditorController!.setRoutePoints(currentPoints);
      _updateMarkers();
    }
  }

  Future<void> _useMyLocationForIntermediatePoint() async {
    Navigator.pop(context);

    final locationService = sdk.LocationService(sdkContext);
    final lastLocation = locationService.lastLocation;

    if (lastLocation != null) {
      final newPoint = lastLocation.coordinates.value;

      final routePoint = sdk.RoutePointUI(
        point: sdk.RouteSearchPoint(coordinates: newPoint),
        label: 'My Location',
      );

      final currentPoints = List<sdk.RoutePointUI>.from(
        routeEditorController!.routePoints.value,
      );

      currentPoints.insert(currentPoints.length - 1, routePoint);

      routeEditorController!.setRoutePoints(currentPoints);
      await _updateMarkers();
    }
  }

  void _chooseOnMapForIntermediatePoint() {
    Navigator.pop(context);

    _isSelectingLocationNotifier.value = true;
    _showCrosshairNotifier.value = true;
    _editingPointIndexNotifier.value = -1;
    _editorInsetsNotifier.value = EdgeInsets.zero;
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
