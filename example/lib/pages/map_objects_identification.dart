import 'dart:async';

import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:dgis_mobile_sdk_full/l10n/generated/dgis_localizations.dart';
import 'package:dgis_mobile_sdk_full/l10n/generated/dgis_localizations_en.dart';
import 'package:flutter/material.dart';

import 'common.dart';

class MapObjectsIdentificationFullPage extends StatefulWidget {
  const MapObjectsIdentificationFullPage({required this.title, super.key});

  final String title;

  @override
  State<MapObjectsIdentificationFullPage> createState() =>
      _MapObjectsIdentificationFullState();
}

class _MapObjectsIdentificationFullState
    extends State<MapObjectsIdentificationFullPage> {
  final sdkContext = AppContainer().initializeSdk();
  final mapWidgetController = sdk.MapWidgetController();
  final formKey = GlobalKey<FormState>();
  bool isParkingEnabled = false;
  bool isTUGCEnabled = false;
  bool isRouteEnabled = false;
  bool isCircleEnabled = false;

  sdk.DirectoryObject? selectedDirectoryObject;
  String? formattedDistance;

  List<sdk.DgisObjectId> highlightedObjectIds = [];
  sdk.MapObjectManager? mapObjectManager;
  sdk.Marker? selectedObject;
  sdk.DgisSource? dgisSource;
  sdk.Map? sdkMap;

  late sdk.SearchManager searchManager;
  late sdk.ImageLoader loader;
  late sdk.RoadEventSource roadEventSource;
  late sdk.RouteEditor routeEditor;
  late sdk.RouteEditorSource routeEditorSource;
  late sdk.MyLocationMapObjectSource locationSource;
  late sdk.LocationService locationService;
  late sdk.Circle circle;

  @override
  void initState() {
    super.initState();
    initContext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: <Widget>[
          sdk.MapWidget(
            sdkContext: sdkContext,
            mapOptions: sdk.MapOptions(),
            controller: mapWidgetController,
          ),
          if (selectedDirectoryObject == null)
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      title: const Text('TUGC enable'),
                      value: isTUGCEnabled,
                      onChanged: (value) {
                        setState(() {
                          isTUGCEnabled = value;
                          if (isTUGCEnabled) {
                            sdkMap?.addSource(roadEventSource);
                          } else {
                            sdkMap?.removeSource(roadEventSource);
                          }
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Show parking'),
                      value: isParkingEnabled,
                      onChanged: (value) {
                        setState(() {
                          isParkingEnabled = value;
                          sdkMap?.attributes.setAttributeValue(
                            'parkingOn',
                            sdk.AttributeValue.boolean(value),
                          );
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Show route'),
                      value: isRouteEnabled,
                      onChanged: (value) {
                        setState(() {
                          isRouteEnabled = value;
                          if (isRouteEnabled) {
                            routeEditorSource.setRoutesVisible(true);
                            _findRoute();
                          } else {
                            routeEditorSource.setRoutesVisible(false);
                          }
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Show circle'),
                      value: isCircleEnabled,
                      onChanged: (value) {
                        setState(() {
                          isCircleEnabled = value;
                          if (isCircleEnabled) {
                            _addCircle();
                          } else {
                            mapObjectManager?.removeAll();
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          if (selectedDirectoryObject != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildDirectoryObjectCard(),
            ),
        ],
      ),
    );
  }

  Widget _buildDirectoryObjectCard() {
    final localizations =
        DgisLocalizations.of(context) ?? DgisLocalizationsEn();
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final theme = isDarkMode
        ? sdk.SearchResultItemTheme.defaultDark
        : sdk.SearchResultItemTheme.defaultLight;

    final viewModel = sdk.SearchResultItemViewModel.fromDirectoryObject(
      object: selectedDirectoryObject!,
      localizations: localizations,
      onTap: (object) {
        _showFullDirectoryObjectCard(object, localizations, isDarkMode);
      },
      formattedDistance: formattedDistance,
    );

    final cardBackgroundColor =
        isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final closeButtonBackgroundColor =
        isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: closeButtonBackgroundColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _closeDirectoryObjectCard,
                icon: Icon(
                  Icons.close,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardBackgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: sdk.SearchResultItemWidget(
                  viewModel: viewModel,
                  theme: theme,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _closeDirectoryObjectCard() {
    setState(() {
      selectedDirectoryObject = null;
      formattedDistance = null;
    });
    dgisSource?.setHighlighted(highlightedObjectIds, false);
    highlightedObjectIds = [];
  }

  void _showFullDirectoryObjectCard(
    sdk.DirectoryObject object,
    DgisLocalizations localizations,
    bool isDarkMode,
  ) {
    final theme = isDarkMode
        ? sdk.DirectoryObjectWidgetTheme.defaultDark
        : sdk.DirectoryObjectWidgetTheme.defaultLight;

    final viewModel = sdk.DirectoryObjectViewModel.fromDirectoryObject(
      object: object,
      localizations: localizations,
      onDismiss: () => Navigator.of(context).pop(),
      onShowEntrances: (entrances) {
        // Handle show entrances on map
        Navigator.of(context).pop();
      },
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          maxChildSize: 0.9,
          snap: true,
          snapSizes: const [0.25, 0.5, 0.9],
          expand: false,
          builder: (context, scrollController) {
            return sdk.DirectoryObjectWidget(
              viewModel: viewModel,
              theme: theme,
              startExpanded: true,
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }

  Future<void> initContext() async {
    searchManager = sdk.SearchManager.createOnlineManager(sdkContext);
    loader = sdk.ImageLoader(sdkContext);
    locationService = sdk.LocationService(sdkContext);
    roadEventSource = sdk.RoadEventSource(sdkContext);

    await checkLocationPermissions(locationService);
    mapWidgetController
      ..getMapAsync((map) {
        sdkMap = map;
        mapObjectManager = sdk.MapObjectManager(map);
        const locationController = sdk.MyLocationControllerSettings(
          bearingSource: sdk.BearingSource.satellite,
        );
        locationSource =
            sdk.MyLocationMapObjectSource(sdkContext, locationController);
        routeEditor = sdk.RouteEditor(sdkContext);
        routeEditorSource = sdk.RouteEditorSource(sdkContext, routeEditor);

        map
          ..addSource(locationSource)
          ..addSource(routeEditorSource);

        map.camera.position = const sdk.CameraPosition(
          point: sdk.GeoPoint(
            latitude: sdk.Latitude(55.75),
            longitude: sdk.Longitude(37.62),
          ),
          zoom: sdk.Zoom(12),
        );
      })
      ..addObjectLongTouchCallback(_showObjectCard)
      ..addObjectTappedCallback(_handleObjectTapped);
  }

  Future<void> _handleObjectTapped(sdk.RenderedObjectInfo objectInfo) async {
    final object = objectInfo.item.item;

    if (object is sdk.RoadEventMapObject) {
      _showRoadEventDialog(object);
      return;
    }
    if (object is sdk.MyLocationMapObject) {
      _showMyLocationDialog(object);
      return;
    }
    if (object is sdk.RouteMapObject) {
      _showRouteMapObjectDialog(object);
      return;
    }
    if (object is sdk.SimpleMapObject) {
      _showSimpleMapObjectDialog(object);
      return;
    }

    if (object is sdk.DgisMapObject) {
      final objectId = _getObjectId(objectInfo);
      if (objectId == null) {
        return;
      }
      await _setSelectedObject(objectInfo);
      dgisSource = objectInfo.item.source as sdk.DgisSource;
      final directoryObject =
          await searchManager.searchByDirectoryObjectId(objectId).value;
      _showDirectoryObjectCard(directoryObject);
      return;
    }
  }

  void _showObjectCard(sdk.RenderedObjectInfo objectInfo) {
    final object = objectInfo.item.item;

    if (object is sdk.DgisMapObject) {
      _setSelectedObject(objectInfo);
    }

    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('RenderedObjectInfo'),
          content: Form(
            key: formKey,
            child: SizedBox(
              height: 250,
              width: 50,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Text(
                    'ClosestViewportPoint: (${objectInfo.closestViewportPoint.x}, ${objectInfo.closestViewportPoint.y})',
                  ),
                  Text(
                    'ClosestMapPoint: (${objectInfo.closestMapPoint.latitude.value}, ${objectInfo.closestMapPoint.longitude.value})',
                  ),
                  Text(
                    'LevelId: ${objectInfo.item.levelId?.value}',
                  ),
                  Text(
                    'Class: ${objectInfo.item.item.runtimeType}',
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showRoadEventDialog(sdk.RoadEventMapObject object) {
    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('RoadEventMapObject'),
          content: Form(
            key: formKey,
            child: SizedBox(
              height: 250,
              width: 50,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Text(
                    'Class: ${object.runtimeType}',
                  ),
                  Text(
                    'Event: ${object.event.description}',
                  ),
                  Text(
                    'ID: ${object.id.objectId}',
                  ),
                  Text(
                    'UserData: ${object.userData}',
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showMyLocationDialog(sdk.MyLocationMapObject object) {
    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('MyLocationMapObject'),
          content: Form(
            key: formKey,
            child: SizedBox(
              height: 250,
              width: 50,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Text(
                    'Class: ${object.runtimeType}',
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showRouteMapObjectDialog(sdk.RouteMapObject object) {
    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('RouteMapObject'),
          content: Form(
            key: formKey,
            child: SizedBox(
              height: 250,
              width: 50,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Text(
                    'IsActive: ${object.isActive}',
                  ),
                  Text(
                    'routeIndex: ${object.routeIndex.value}',
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showSimpleMapObjectDialog(sdk.SimpleMapObject object) {
    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('SimpleMapObject'),
          content: Form(
            key: formKey,
            child: SizedBox(
              height: 250,
              width: 50,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Text(
                    'Class: ${object.runtimeType}',
                  ),
                  Text(
                    'UserData: ${object.userData}',
                  ),
                  Text(
                    'zIndex: ${object.zIndex.value}',
                  ),
                  Text(
                    'NorthEastPoint latitude: ${object.bounds.northEastPoint.latitude.value}, NorthEastPoint longitude: ${object.bounds.northEastPoint.longitude.value}',
                  ),
                  Text(
                    'SouthWestPoint latitude: ${object.bounds.southWestPoint.latitude.value}, SouthWestPoint longitude: ${object.bounds.southWestPoint.longitude.value}',
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  String _formatDistance(int meters, DgisLocalizations localizations) {
    if (meters >= 1000) {
      final km = meters / 1000;
      final kmValue = double.parse(km.toStringAsFixed(km % 1 == 0 ? 0 : 1));
      return localizations.dgis_km_format(kmValue);
    }
    return localizations.dgis_m__meters_format(meters);
  }

  void _showDirectoryObjectCard(sdk.DirectoryObject? objectInfo) {
    if (objectInfo == null) {
      return;
    }

    _setHighlighted(objectInfo);

    String? distance;
    final myLocation = locationService.lastLocation().value;
    final objectPosition = objectInfo.markerPosition;
    if (myLocation != null && objectPosition != null) {
      final localizations =
          DgisLocalizations.of(context) ?? DgisLocalizationsEn();
      final distanceMeters =
          objectPosition.distance(myLocation.coordinates.value);
      distance = _formatDistance(distanceMeters.value.toInt(), localizations);
    }

    setState(() {
      selectedDirectoryObject = objectInfo;
      formattedDistance = distance;
    });
  }

  sdk.DgisObjectId? _getObjectId(sdk.RenderedObjectInfo objectInfo) {
    if (objectInfo.item.item is! sdk.DgisMapObject) {
      return null;
    }
    return (objectInfo.item.item as sdk.DgisMapObject).id;
  }

  Future<void> _setSelectedObject(sdk.RenderedObjectInfo objectInfo) async {
    if (selectedObject == null) {
      final iconImage =
          await loader.loadPngFromAsset('assets/icons/pin.png', 160, 160);
      final options = sdk.MarkerOptions(
        icon: iconImage,
        position: objectInfo.closestMapPoint,
        anchor: const sdk.Anchor(y: 1),
        iconWidth: const sdk.LogicalPixel(5),
      );
      selectedObject = sdk.Marker(options);
      mapObjectManager?.addObject(selectedObject!);
    } else {
      selectedObject?.position = objectInfo.closestMapPoint;
    }
  }

  void _setHighlighted(sdk.DirectoryObject objectInfo) {
    if (objectInfo.id == null) {
      return;
    }
    dgisSource?.setHighlighted(highlightedObjectIds, false);
    highlightedObjectIds = <sdk.DgisObjectId>[objectInfo.id!];
    for (final entrance in objectInfo.entrances) {
      highlightedObjectIds.add(entrance.id);
    }
    dgisSource?.setHighlighted(highlightedObjectIds, true);
  }

  void _addCircle() {
    final circlePosition = sdk.GeoPoint(
      latitude: sdk.Latitude(sdkMap!.camera.position.point.latitude.value),
      longitude: sdk.Longitude(sdkMap!.camera.position.point.longitude.value),
    );
    circle = sdk.Circle(
      sdk.CircleOptions(
        position: circlePosition,
        radius: const sdk.Meter(5000),
        // ignore: deprecated_member_use
        color: sdk.Color(Colors.red.value),
        // ignore: deprecated_member_use
        strokeColor: sdk.Color(Colors.blue.value),
        strokeWidth: const sdk.LogicalPixel(1),
        userData: 'Userdata',
        zIndex: const sdk.ZIndex(12),
      ),
    );
    mapObjectManager?.addObject(circle);
  }

  void _findRoute() {
    routeEditor.setRouteParams(
      sdk.RouteEditorRouteParams(
        startPoint: const sdk.RouteSearchPoint(
          coordinates: sdk.GeoPoint(
            latitude: sdk.Latitude(55.74),
            longitude: sdk.Longitude(37.61),
          ),
        ),
        finishPoint: const sdk.RouteSearchPoint(
          coordinates: sdk.GeoPoint(
            latitude: sdk.Latitude(55.76),
            longitude: sdk.Longitude(37.631),
          ),
        ),
        intermediatePoints: [],
        routeSearchOptions: sdk.RouteSearchOptions.car(
          const sdk.CarRouteSearchOptions(),
        ),
      ),
    );
  }
}
