import 'dart:async';

import 'package:async/async.dart';
import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'common.dart';

class CameraMovesPage extends StatefulWidget {
  const CameraMovesPage({required this.title, super.key});

  final String title;

  @override
  State<CameraMovesPage> createState() => _CameraMovesState();
}

class _CameraMovesState extends State<CameraMovesPage> {
  final sdkContext = AppContainer().initializeSdk();
  final mapWidgetController = sdk.MapWidgetController();
  sdk.Map? sdkMap;
  sdk.LocationService? locationService;
  CancelableOperation<sdk.CameraAnimatedMoveResult>? moveCameraCancellable;
  StreamSubscription<sdk.Location?>? locationSubscription;

  final testPoints = [
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(55.759909),
          longitude: sdk.Longitude(37.618806),
        ),
        zoom: sdk.Zoom(15),
        tilt: sdk.Tilt(15),
        bearing: sdk.Bearing(115),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(55.759909),
          longitude: sdk.Longitude(37.618806),
        ),
        zoom: sdk.Zoom(16),
        tilt: sdk.Tilt(15),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.default_
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(55.746962),
          longitude: sdk.Longitude(37.643073),
        ),
        zoom: sdk.Zoom(16),
        tilt: sdk.Tilt(55),
      ),
      const Duration(seconds: 9),
      sdk.CameraAnimationType.showBothPositions
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(55.746962),
          longitude: sdk.Longitude(37.643073),
        ),
        zoom: sdk.Zoom(16.5),
        tilt: sdk.Tilt(45),
        bearing: sdk.Bearing(40),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(55.752425),
          longitude: sdk.Longitude(37.613983),
        ),
        zoom: sdk.Zoom(16),
        tilt: sdk.Tilt(25),
        bearing: sdk.Bearing(85),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.default_
    ),
  ];

  @override
  void initState() {
    super.initState();
    initContext();
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    moveCameraCancellable?.cancel();
    super.dispose();
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
            child: CupertinoButton(
              onPressed: _show,
              child: const Icon(Icons.format_list_bulleted),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> initContext() async {
    locationService = sdk.LocationService(sdkContext);
    mapWidgetController
      ..getMapAsync((map) {
        sdkMap = map;

        const locationController = sdk.MyLocationControllerSettings(
          bearingSource: sdk.BearingSource.satellite,
        );
        final locationSource =
            sdk.MyLocationMapObjectSource(sdkContext, locationController);
        map.addSource(locationSource);
      })
      ..copyrightAlignment = Alignment.bottomLeft;
    await checkLocationPermissions(locationService!);
  }

  void _show() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Map scenarios'),
        actions: <Widget>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context, 'One');
              _testCamera();
            },
            child: const Text('Move camera around Moscow'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context, 'Two');
              _startFollowingPosition();
            },
            child: locationSubscription == null
                ? const Text('Start following for current position')
                : const Text('Stop following for current position'),
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

  void _testCamera() {
    locationSubscription?.cancel();
    locationSubscription = null;
    if (sdkMap == null) {
      return;
    }
    _move(0);
  }

  Future<void> _move(int index) async {
    if (index >= testPoints.length) {
      return;
    }
    final tuple = testPoints[index];
    moveCameraCancellable =
        sdkMap?.camera.moveToCameraPosition(tuple.$1, tuple.$2, tuple.$3);
    await moveCameraCancellable?.value.then((value) {
      _move(index + 1);
    });
  }

  Future<void> _startFollowingPosition() async {
    if (locationSubscription != null) {
      await locationSubscription?.cancel();
      locationSubscription = null;
      return;
    }
    locationSubscription =
        locationService?.lastLocation().listen((currentLocation) async {
      if (currentLocation == null) {
        return;
      }

      final position = sdk.CameraPosition(
        point: currentLocation.coordinates.value,
        zoom: const sdk.Zoom(14),
        tilt: const sdk.Tilt(15),
      );
      moveCameraCancellable = sdkMap?.camera.moveToCameraPosition(
        position,
        const Duration(seconds: 3),
        sdk.CameraAnimationType.linear,
      );
      await moveCameraCancellable?.value;
    });
  }
}
