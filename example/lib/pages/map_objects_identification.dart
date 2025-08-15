import 'dart:async';

import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
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
        ],
      ),
    );
  }

  Future<void> initContext() async {
    searchManager = sdk.SearchManager.createOnlineManager(sdkContext);
    loader = sdk.ImageLoader(sdkContext);
    final locationService = sdk.LocationService(sdkContext);
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

  void _showDirectoryObjectCard(sdk.DirectoryObject? objectInfo) {
    if (objectInfo == null) {
      return;
    }

    _setHighlighted(objectInfo);
    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(objectInfo.title),
          content: Form(
            key: formKey,
            child: SizedBox(
              height: 250,
              width: 50,
              child: ListView(
                shrinkWrap: true,
                children: _buildObjectInfoWidget(objectInfo),
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

  List<Widget> _buildObjectInfoWidget(sdk.DirectoryObject objectInfo) {
    /// Main info.
    final infoWidgets = <Widget>[
      Text(objectInfo.subtitle),
      Text('ID: ${objectInfo.id?.objectId}'),
    ];
    if (objectInfo.description.isNotEmpty) {
      infoWidgets.add(Text(objectInfo.description));
    }
    infoWidgets.add(() {
      String rating;
      final ratingValue = objectInfo.reviews?.rating;
      if (ratingValue != null) {
        rating = 'Rating: ${ratingValue.toStringAsFixed(2)}';
      } else {
        rating = 'There is no rating for this organization';
      }
      return Text(rating);
    }());
    final fiasCode = objectInfo.address?.fiasCode;
    if (fiasCode != null) {
      infoWidgets.add(Text(fiasCode));
    }

    /// Address
    infoWidgets.addAll([const SizedBox(height: 10), const Text('Location:')]);
    final formattedAddress =
        objectInfo.formattedAddress(sdk.FormattingType.full);
    if (formattedAddress != null) {
      infoWidgets.add(
        Text(
          '${formattedAddress.drilldownAddress}, ${formattedAddress.streetAddress}, ${formattedAddress.addressComment}, ${formattedAddress.postCode}',
        ),
      );
    }
    final position = objectInfo.markerPosition?.point;
    if (position != null) {
      infoWidgets.add(
        Text(
          'Latitude: ${position.latitude.value.toStringAsFixed(
            6,
          )}, Longitude: ${position.longitude.value.toStringAsFixed(6)}',
        ),
      );
    }

    return infoWidgets;
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
