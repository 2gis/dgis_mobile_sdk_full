import 'dart:async';
import 'dart:math';

import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'add_objects_widgets/circle_options_widget.dart';
import 'add_objects_widgets/marker_options_widget.dart';
import 'add_objects_widgets/model_options_widget.dart';
import 'add_objects_widgets/polygon_options_widget.dart';
import 'add_objects_widgets/polyline_options_widget.dart';
import 'common.dart';

class AddObjectsPage extends StatefulWidget {
  const AddObjectsPage({required this.title, super.key});

  final String title;

  @override
  State<AddObjectsPage> createState() => _SamplePageState();
}

enum MarkerType { scooterPng, bridgeSvg, batLottie }

class _SamplePageState extends State<AddObjectsPage> {
  final _sdkContext = AppContainer().initializeSdk();
  final _mapWidgetController = sdk.MapWidgetController();
  final _formKey = GlobalKey<FormState>();
  final _scooterAssetsPath = 'assets/icons/scooter_model.png';
  final _bridgeAssetsPath = 'assets/icons/bridge.svg';
  final _batAssetsPath = 'assets/icons/bat.json';
  final _pinAssetsPath = 'assets/icons/topGoMarker.png';
  final _airplaneAssetsPath = 'assets/models/airplane.glb';
  final _imageCache = <String, sdk.Image>{};
  MarkerType _markerType = MarkerType.scooterPng;

  sdk.Map? _sdkMap;
  sdk.MapObjectManager? _mapObjectManager;
  late sdk.ImageLoader _loader;
  late sdk.ModelLoader _modelLoader;

  String _circleRadius = '100';
  String _circleUserData = '';
  String _circleZIndex = '1';
  // ignore: deprecated_member_use
  int _circleSelectedColor = Colors.black.value;
  double _circleStrokeWidth = 0;
  // ignore: deprecated_member_use
  int _circleSelectedStrokeColor = Colors.black.value;

  String _polylinePointCount = '2';
  String _polylineUserData = '';
  String _polylineZIndex = '1';
  double _polylineWidth = 5;
  // ignore: deprecated_member_use
  int _polylineSelectedColor = Colors.black.value;

  String _polygonPointCount = '3';
  String _polygonUserData = '';
  String _polygonZIndex = '1';
  double _polygonStrokeWidth = 5;
  // ignore: deprecated_member_use
  int _polygonSelectedColor = Colors.black.value;
  // ignore: deprecated_member_use
  int _polygonSelectedStrokeColor = Colors.black.value;

  String _markerUserData = '';
  String _markerZIndex = '1';
  String _markerText = 'Marker';
  double _markerWidth = 45;
  String _markerElevation = '0';

  String _modelUserData = '';
  String _modelSize = '50';
  bool _modelScaleEnabled = false;
  sdk.ModelData? _modelData;

  @override
  void initState() {
    super.initState();
    initContext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: <Widget>[
          sdk.MapWidget(
            sdkContext: _sdkContext,
            mapOptions: sdk.MapOptions(),
            controller: _mapWidgetController,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoButton(
                  onPressed: _removeObjects,
                  child: const Icon(Icons.highlight_remove),
                ),
                CupertinoButton(
                  onPressed: _show,
                  child: const Icon(Icons.format_list_bulleted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void initContext() {
    _loader = sdk.ImageLoader(_sdkContext);
    _modelLoader = sdk.ModelLoader(_sdkContext);
    _mapWidgetController
      ..getMapAsync((map) {
        _sdkMap = map;
        _mapObjectManager = sdk.MapObjectManager(map);
      })
      ..copyrightAlignment = Alignment.bottomLeft;
  }

  void _show() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Select object'),
        actions: <Widget>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showCircleOptions();
            },
            child: const Text('Circle'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showMarkerOptions();
            },
            child: const Text('Marker'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showModelOptions();
            },
            child: const Text('Model'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showPolylineOptions();
            },
            child: const Text('Polyline'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(
                context,
              );
              _showPolygonOptions();
            },
            child: const Text('Polygon'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _addTopGoMarker(
                _sdkMap!.camera.position.point.latitude.value,
                _sdkMap!.camera.position.point.longitude.value,
                _pinAssetsPath,
                'Marker from topGo',
              );
            },
            child: const Text('Marker from TopGo'),
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

  void _showCircleOptions() {
    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return CircleOptionsDialog(
          initialRadius: _circleRadius,
          initialUserData: _circleUserData,
          initialZIndex: _circleZIndex,
          initialSelectedColor: _circleSelectedColor,
          initialStrokeWidth: _circleStrokeWidth,
          initialSelectedStrokeColor: _circleSelectedStrokeColor,
          formKey: _formKey,
          onAddCircle:
              (radius, userData, zIndex, color, strokeWidth, strokeColor) {
            setState(() {
              _circleRadius = radius;
              _circleUserData = userData;
              _circleZIndex = zIndex;
              _circleSelectedColor = color;
              _circleStrokeWidth = strokeWidth;
              _circleSelectedStrokeColor = strokeColor;
            });
            _addCircle();
          },
        );
      },
    );
  }

  Future<void> _addCircle() async {
    final circle = sdk.Circle(
      sdk.CircleOptions(
        position: _sdkMap!.camera.position.point,
        radius: sdk.Meter(double.tryParse(_circleRadius)!),
        userData: _circleUserData,
        color: sdk.Color(_circleSelectedColor),
        strokeColor: sdk.Color(_circleSelectedStrokeColor),
        strokeWidth: sdk.LogicalPixel(_circleStrokeWidth),
        zIndex: sdk.ZIndex(int.tryParse(_circleZIndex)!),
      ),
    );
    _mapObjectManager?.addObject(circle);
  }

  void _showPolylineOptions() {
    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return PolylineOptionsDialog(
          initialPointCount: _polylinePointCount,
          initialUserData: _polylineUserData,
          initialZIndex: _polylineZIndex,
          initialWidth: _polylineWidth,
          initialSelectedColor: _polylineSelectedColor,
          formKey: _formKey,
          onAddPolyline: (pointCount, userData, zIndex, width, color) {
            setState(() {
              _polylinePointCount = pointCount;
              _polylineUserData = userData;
              _polylineZIndex = zIndex;
              _polylineWidth = width;
              _polylineSelectedColor = color;
            });
            _addPolyline();
          },
        );
      },
    );
  }

  Future<void> _addPolyline() async {
    final points = <sdk.GeoPoint>[];
    for (var i = 0; i < (int.tryParse(_polylinePointCount)!); i++) {
      points.add(_makePoint()!);
    }
    final polyline = sdk.Polyline(
      sdk.PolylineOptions(
        points: points,
        width: sdk.LogicalPixel(_polylineWidth),
        userData: _polylineUserData,
        color: sdk.Color(_polylineSelectedColor),
        zIndex: sdk.ZIndex(int.tryParse(_polylineZIndex)!),
      ),
    );
    _mapObjectManager?.addObject(polyline);
  }

  void _showPolygonOptions() {
    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return PolygonOptionsDialog(
          initialPointCount: _polygonPointCount,
          initialUserData: _polygonUserData,
          initialZIndex: _polygonZIndex,
          initialSelectedColor: _polygonSelectedColor,
          initialSelectedStrokeColor: _polygonSelectedStrokeColor,
          initialStrokeWidth: _polygonStrokeWidth,
          formKey: _formKey,
          onAddPolygon:
              (pointCount, userData, zIndex, color, strokeColor, strokeWidth) {
            setState(() {
              _polygonPointCount = pointCount;
              _polygonUserData = userData;
              _polygonZIndex = zIndex;
              _polygonSelectedColor = color;
              _polygonSelectedStrokeColor = strokeColor;
              _polygonStrokeWidth = strokeWidth;
            });
            _addPolygon();
          },
        );
      },
    );
  }

  Future<void> _addPolygon() async {
    final points = <sdk.GeoPoint>[];
    for (var i = 0; i < (int.tryParse(_polygonPointCount)!); i++) {
      points.add(_makePoint()!);
    }
    final polygon = sdk.Polygon(
      sdk.PolygonOptions(
        contours: [points],
        strokeWidth: sdk.LogicalPixel(_polygonStrokeWidth),
        userData: _polygonUserData,
        color: sdk.Color(_polygonSelectedColor),
        strokeColor: sdk.Color(_polygonSelectedStrokeColor),
        zIndex: sdk.ZIndex(int.tryParse(_polygonZIndex)!),
      ),
    );
    _mapObjectManager?.addObject(polygon);
  }

  void _showMarkerOptions() {
    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return MarkerOptionsDialog(
          initialUserData: _markerUserData,
          initialZIndex: _markerZIndex,
          initialText: _markerText,
          initialMarkerType: _markerType,
          initialMarkerWidth: _markerWidth,
          initialMarkerElevation: _markerElevation,
          formKey: _formKey,
          onAddMarker: (
            userData,
            zIndex,
            text,
            markerType,
            markerWidth,
            markerElevation,
          ) {
            setState(() {
              _markerUserData = userData;
              _markerZIndex = zIndex;
              _markerText = text;
              _markerType = markerType;
              _markerWidth = markerWidth;
              _markerElevation = markerElevation;
            });
            _addMarker();
          },
        );
      },
    );
  }

  Future<void> _addMarker() async {
    final marker = sdk.Marker(
      sdk.MarkerOptions(
        position: sdk.GeoPointWithElevation(
          latitude: _sdkMap!.camera.position.point.latitude,
          longitude: _sdkMap!.camera.position.point.longitude,
          elevation: sdk.Elevation(double.tryParse(_markerElevation)!),
        ),
        icon: await _getMarkerImage(_markerType),
        iconWidth: sdk.LogicalPixel(_markerWidth),
        userData: _markerUserData,
        text: _markerText,
        zIndex: sdk.ZIndex(int.tryParse(_markerZIndex)!),
      ),
    );
    _mapObjectManager?.addObject(marker);
  }

  Future<sdk.Image> _getMarkerImage(MarkerType type) async {
    switch (type) {
      case MarkerType.scooterPng:
        _imageCache[_scooterAssetsPath] ??=
            await _loader.loadPngFromAsset(_scooterAssetsPath, 170, 170);
        return _imageCache[_scooterAssetsPath]!;
      case MarkerType.bridgeSvg:
        _imageCache[_bridgeAssetsPath] ??=
            await _loader.loadSVGFromAsset(_bridgeAssetsPath);
        return _imageCache[_bridgeAssetsPath]!;
      case MarkerType.batLottie:
        _imageCache[_batAssetsPath] ??=
            await _loader.loadLottieFromAsset(_batAssetsPath);
        return _imageCache[_batAssetsPath]!;
    }
  }

  void _showModelOptions() {
    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return ModelOptionsDialog(
          initialUserData: _modelUserData,
          initialSize: _modelSize,
          initialScaleEnable: _modelScaleEnabled,
          formKey: _formKey,
          onAddModel: (
            userData,
            size, {
            required initialScaleEnable,
          }) {
            setState(() {
              _modelUserData = userData;
              _modelSize = size;
              _modelScaleEnabled = initialScaleEnable;
            });
            _addModel();
          },
        );
      },
    );
  }

  Future<void> _addModel() async {
    final model = sdk.ModelMapObject(
      sdk.ModelMapObjectOptions(
        position: sdk.GeoPointWithElevation(
          latitude: _sdkMap!.camera.position.point.latitude,
          longitude: _sdkMap!.camera.position.point.longitude,
        ),
        data: await _getModelData(),
        size: _getModelSize(),
        userData: _markerUserData,
      ),
    );
    _mapObjectManager?.addObject(model);
  }

  Future<sdk.ModelData> _getModelData() async {
    _modelData ??= await _modelLoader.loadFromAsset(_airplaneAssetsPath);
    return _modelData!;
  }

  sdk.ModelSize _getModelSize() {
    final modelSizeValue = double.tryParse(_modelSize)!;
    if (_modelScaleEnabled) {
      return sdk.ModelSize.scale(sdk.ModelScale(modelSizeValue));
    } else {
      return sdk.ModelSize.logicalPixel(sdk.LogicalPixel(modelSizeValue));
    }
  }

  void _removeObjects() {
    _mapObjectManager?.removeAll();
  }

  sdk.GeoPoint? _makePoint() {
    final random = Random();
    final minHeight = _sdkMap!.camera.size.height / 3;
    final maxHeight =
        _sdkMap!.camera.size.height - (_sdkMap!.camera.size.height / 3);
    final randomHeight =
        minHeight + (random.nextDouble() * (maxHeight - minHeight));

    return _sdkMap?.camera.projection.screenToMap(
      sdk.ScreenPoint(
        x: random.nextDouble() * _sdkMap!.camera.size.width,
        y: randomHeight,
      ),
    );
  }

  Future<void> _addTopGoMarker(
    double lat,
    double lon,
    String img,
    String text, {
    int size = 30,
    double iconWidth = 30,
    double strokeWidth = 10,
    double textOffset = 5,
  }) async {
    final point = sdk.GeoPointWithElevation(
      latitude: sdk.Latitude(lat),
      longitude: sdk.Longitude(lon),
    );
    final icon = await _loader.loadPngFromAsset(img, size, size);
    final markerTopGo = sdk.Marker(
      sdk.MarkerOptions(
        position: point,
        icon: icon,
        iconWidth: sdk.LogicalPixel(iconWidth),
        text: text,
        textStyle: sdk.TextStyle(
          textPlacement: sdk.TextPlacement.topCenter,
          strokeWidth: sdk.LogicalPixel(strokeWidth),
          textOffset: sdk.LogicalPixel(textOffset),
          // ignore: deprecated_member_use
          strokeColor: sdk.Color(Colors.black.value),
          // ignore: deprecated_member_use
          color: sdk.Color(Colors.white.value),
        ),
      ),
    );
    _mapObjectManager?.addObject(markerTopGo);
  }
}
