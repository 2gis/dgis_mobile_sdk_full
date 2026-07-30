import 'dart:async';

import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'common.dart';

class CalcPositionPage extends StatefulWidget {
  const CalcPositionPage({required this.title, super.key});

  final String title;

  @override
  State<CalcPositionPage> createState() => _SamplePageState();
}

class _SamplePageState extends State<CalcPositionPage> {
  final _sdkContext = AppContainer().initializeSdk();
  final _mapWidgetController = sdk.MapWidgetController();
  final _circleAssetsPath = 'assets/icons/circle.png';
  final ValueNotifier<double?> _deviceDensity = ValueNotifier<double?>(null);

  sdk.StyleZoomToTiltRelation? _styleZoomToTiltRelation;
  sdk.Padding? _padding;
  sdk.Tilt? _tilt;
  sdk.ScreenSize? _screenSize;
  sdk.MapObjectManager? _mapObjectManager;
  bool _switchValue = false;
  sdk.Map? _sdkMap;

  late sdk.Bearing _bearing;
  late sdk.SimpleMapObject _marker;
  late sdk.ImageLoader _loader;
  late List<sdk.SimpleMapObject> _markers;
  late List<sdk.SimpleMapObject> _rectMarkersOn180;
  late List<sdk.SimpleMapObject> _markersOn180;
  late List<sdk.SimpleMapObject> _rectMarkersOn0;
  late List<sdk.SimpleMapObject> _markersOn0;
  late sdk.SimpleMapObject _circle;
  late sdk.SimpleMapObject _polygon;
  late sdk.Camera _sdkCamera;

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
          _buildPositionedOverlay(),
          Align(
            alignment: Alignment.bottomRight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoButton(
                  onPressed: _showSettings,
                  child: const Icon(Icons.settings),
                ),
                CupertinoButton(
                  onPressed: _show,
                  child: const Icon(Icons.arrow_circle_right_outlined),
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
    _mapWidgetController
      ..getMapAsync((map) {
        _sdkMap = map;
        _sdkCamera = map.camera;
        _mapObjectManager = sdk.MapObjectManager(map);
        _initMarkers();
        _initMarkersOn0();
        _initMarkersOn180Meridian();
        _initRectMarkersOn0();
        _initRectMarkersOn180Meridian();
        _initCircle();
        _initPolygon();
        _deviceDensity.value = map.camera.deviceDensity.value;
      })
      ..copyrightAlignment = Alignment.bottomLeft;
  }

  Widget _buildPositionedOverlay() {
    return ValueListenableBuilder<double?>(
      valueListenable: _deviceDensity,
      builder: (context, deviceDensity, child) {
        if (deviceDensity == null) return const SizedBox.shrink();
        return Positioned(
          top: _sdkMap?.camera.padding.top.toDouble() ?? 0 / deviceDensity,
          bottom:
              _sdkMap?.camera.padding.bottom.toDouble() ?? 0 / deviceDensity,
          left: _sdkMap?.camera.padding.left.toDouble() ?? 0 / deviceDensity,
          right: _sdkMap?.camera.padding.right.toDouble() ?? 0 / deviceDensity,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2),
              ),
            ),
          ),
        );
      },
    );
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
              _calcPosition([_marker]);
            },
            child: const Text('Marker'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _calcPosition(_markers);
            },
            child: const Text('Markers'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _calcPosition(_rectMarkersOn180);
            },
            child: const Text('Rectangle markers on 180 meridian'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _calcPosition(_markersOn180);
            },
            child: const Text('Markers on 180 meridian'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _calcPosition(_rectMarkersOn0);
            },
            child: const Text('Rectangle markers on 0'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _calcPosition(_markersOn0);
            },
            child: const Text('Markers on 0'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _calcPosition([_polygon]);
            },
            child: const Text('Polygon'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _calcPosition([_circle]);
            },
            child: const Text('Circle'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _calcPosition([_circle] + _markers);
            },
            child: const Text('Markers and Circle'),
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

  void _showSettings() {
    final paddingTopText = TextEditingController();
    final paddingBottomText = TextEditingController();
    final paddingLeftText = TextEditingController();
    final paddingRightText = TextEditingController();
    final tiltText = TextEditingController();
    final bearingText = TextEditingController();

    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return CupertinoAlertDialog(
              title: const Text('Settings'),
              content: Column(
                children: [
                  CupertinoTextField(
                    controller: paddingTopText,
                    placeholder: 'Top: ${_sdkCamera.padding.top}',
                  ),
                  const SizedBox(height: 16),
                  CupertinoTextField(
                    controller: paddingBottomText,
                    placeholder: 'Bottom: ${_sdkCamera.padding.bottom}',
                  ),
                  const SizedBox(height: 16),
                  CupertinoTextField(
                    controller: paddingLeftText,
                    placeholder: 'Left: ${_sdkCamera.padding.left}',
                  ),
                  const SizedBox(height: 16),
                  CupertinoTextField(
                    controller: paddingRightText,
                    placeholder: 'Right: ${_sdkCamera.padding.right}',
                  ),
                  const SizedBox(height: 16),
                  CupertinoTextField(
                    controller: tiltText,
                    placeholder: 'Tilt: ${_sdkCamera.position.tilt.value}',
                  ),
                  const SizedBox(height: 16),
                  CupertinoTextField(
                    controller: bearingText,
                    placeholder:
                        'Bearing: ${_sdkCamera.position.bearing.value}',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Use Standalone calcPosition'),
                      CupertinoSwitch(
                        value: _switchValue,
                        onChanged: (value) {
                          setState(() {
                            _switchValue = value;
                            if (_switchValue) {
                              _sdkCamera.position =
                                  _sdkCamera.position.copyWith(
                                bearing: const sdk.Bearing(),
                                tilt: const sdk.Tilt(),
                              );
                              _updateMapPadding(const sdk.Padding());
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: <CupertinoDialogAction>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: _switchValue
                      ? null
                      : () {
                          _padding = sdk.Padding(
                            left: int.tryParse(paddingLeftText.text) ?? 0,
                            right: int.tryParse(paddingRightText.text) ?? 0,
                            top: int.tryParse(paddingTopText.text) ?? 0,
                            bottom: int.tryParse(paddingBottomText.text) ?? 0,
                          );
                          _updateMapPadding(_padding!);
                          _tilt =
                              sdk.Tilt(double.tryParse(tiltText.text) ?? 0.0);
                          _updateMapTilt(_tilt!);
                          _bearing = sdk.Bearing(
                            double.tryParse(bearingText.text) ?? 0.0,
                          );
                          _updateMapBearing(_bearing);
                          Navigator.pop(context);
                        },
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      color: _switchValue
                          ? CupertinoColors.inactiveGray
                          : CupertinoColors.activeBlue,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showStandaloneSettings(List<sdk.SimpleMapObject> objects) {
    final paddingTopText = TextEditingController();
    final paddingBottomText = TextEditingController();
    final paddingLeftText = TextEditingController();
    final paddingRightText = TextEditingController();
    final tiltText = TextEditingController();
    final bearingText = TextEditingController();

    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return CupertinoAlertDialog(
              title: const Text('Settings'),
              content: Column(
                children: [
                  CupertinoTextField(
                    controller: paddingTopText,
                    placeholder: 'Top:',
                  ),
                  const SizedBox(height: 16),
                  CupertinoTextField(
                    controller: paddingBottomText,
                    placeholder: 'Bottom:',
                  ),
                  const SizedBox(height: 16),
                  CupertinoTextField(
                    controller: paddingLeftText,
                    placeholder: 'Left:',
                  ),
                  const SizedBox(height: 16),
                  CupertinoTextField(
                    controller: paddingRightText,
                    placeholder: 'Right:',
                  ),
                  const SizedBox(height: 16),
                  CupertinoTextField(
                    controller: tiltText,
                    placeholder: 'Tilt:',
                  ),
                  const SizedBox(height: 16),
                  CupertinoTextField(
                    controller: bearingText,
                    placeholder: 'Bearing:',
                  ),
                  const SizedBox(height: 16),
                ],
              ),
              actions: <CupertinoDialogAction>[
                CupertinoDialogAction(
                  onPressed: () {
                    final padding = sdk.Padding(
                      left: int.tryParse(paddingLeftText.text) ?? 0,
                      right: int.tryParse(paddingRightText.text) ?? 0,
                      top: int.tryParse(paddingTopText.text) ?? 0,
                      bottom: int.tryParse(paddingBottomText.text) ?? 0,
                    );
                    final tilt =
                        sdk.Tilt(double.tryParse(tiltText.text) ?? 0.0);
                    final bearing =
                        sdk.Bearing(double.tryParse(bearingText.text) ?? 0.0);
                    _sdkCamera.moveToCameraPosition(
                      sdk.calcPositionForObjects(
                        _sdkCamera,
                        objects,
                        _styleZoomToTiltRelation,
                        padding,
                        tilt,
                        bearing,
                        _screenSize,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _updateMapTilt(sdk.Tilt tilt) {
    _sdkCamera.position = _sdkMap!.camera.position.copyWith(tilt: tilt);
  }

  void _updateMapBearing(sdk.Bearing bearing) {
    _sdkCamera.position = _sdkCamera.position.copyWith(bearing: bearing);
  }

  void _updateMapPadding(sdk.Padding padding) {
    setState(() {
      _sdkCamera.padding = padding;
    });
  }

  Future<void> _initMarkers() async {
    _marker = sdk.Marker(
      sdk.MarkerOptions(
        icon: await _loader.loadPngFromAsset(_circleAssetsPath, 160, 160),
        position: const sdk.GeoPointWithElevation(
          latitude: sdk.Latitude(55.744213),
          longitude: sdk.Longitude(37.624631),
        ),
        text: 'text',
      ),
    );

    _markers = [
      _marker,
      sdk.Marker(
        sdk.MarkerOptions(
          icon: await _loader.loadPngFromAsset(_circleAssetsPath, 160, 160),
          position: const sdk.GeoPointWithElevation(
            latitude: sdk.Latitude(55.744213),
            longitude: sdk.Longitude(37.627422),
          ),
          text: 'text',
        ),
      ),
      sdk.Marker(
        sdk.MarkerOptions(
          icon: await _loader.loadPngFromAsset(_circleAssetsPath, 160, 160),
          position: const sdk.GeoPointWithElevation(
            latitude: sdk.Latitude(55.740861),
            longitude: sdk.Longitude(37.627422),
          ),
          text: 'text',
        ),
      ),
      sdk.Marker(
        sdk.MarkerOptions(
          icon: await _loader.loadPngFromAsset(_circleAssetsPath, 160, 160),
          position: const sdk.GeoPointWithElevation(
            latitude: sdk.Latitude(55.740861),
            longitude: sdk.Longitude(37.62463),
          ),
          text: 'text',
        ),
      ),
    ];

    _mapObjectManager?.addObjects(_markers);
  }

  Future<void> _initRectMarkersOn180Meridian() async {
    _rectMarkersOn180 = [
      sdk.Marker(
        sdk.MarkerOptions(
          icon: await _loader.loadPngFromAsset(_circleAssetsPath, 160, 160),
          position: const sdk.GeoPointWithElevation(
            latitude: sdk.Latitude(-53.744213),
            longitude: sdk.Longitude(175.624631),
          ),
          text: 'text',
        ),
      ),
      sdk.Marker(
        sdk.MarkerOptions(
          icon: await _loader.loadPngFromAsset(_circleAssetsPath, 160, 160),
          position: const sdk.GeoPointWithElevation(
            latitude: sdk.Latitude(-53.744213),
            longitude: sdk.Longitude(-177.627422),
          ),
          text: 'text',
        ),
      ),
      sdk.Marker(
        sdk.MarkerOptions(
          icon: await _loader.loadPngFromAsset(_circleAssetsPath, 160, 160),
          position: const sdk.GeoPointWithElevation(
            latitude: sdk.Latitude(-57.740861),
            longitude: sdk.Longitude(-177.627422),
          ),
          text: 'text',
        ),
      ),
      sdk.Marker(
        sdk.MarkerOptions(
          icon: await _loader.loadPngFromAsset(_circleAssetsPath, 160, 160),
          position: const sdk.GeoPointWithElevation(
            latitude: sdk.Latitude(-57.740861),
            longitude: sdk.Longitude(175.624631),
          ),
          text: 'text',
        ),
      ),
    ];

    _mapObjectManager?.addObjects(_rectMarkersOn180);
  }

  Future<void> _initMarkersOn180Meridian() async {
    _markersOn180 = [
      sdk.Marker(
        sdk.MarkerOptions(
          icon: await _loader.loadPngFromAsset(_circleAssetsPath, 160, 160),
          position: const sdk.GeoPointWithElevation(
            latitude: sdk.Latitude(63.744213),
            longitude: sdk.Longitude(170.624631),
          ),
          text: 'text',
        ),
      ),
      sdk.Marker(
        sdk.MarkerOptions(
          icon: await _loader.loadPngFromAsset(_circleAssetsPath, 160, 160),
          position: const sdk.GeoPointWithElevation(
            latitude: sdk.Latitude(63.744213),
            longitude: sdk.Longitude(-170.627422),
          ),
          text: 'text',
        ),
      ),
      sdk.Marker(
        sdk.MarkerOptions(
          icon: await _loader.loadPngFromAsset(_circleAssetsPath, 160, 160),
          position: const sdk.GeoPointWithElevation(
            latitude: sdk.Latitude(67.740861),
            longitude: sdk.Longitude(-177.627422),
          ),
          text: 'text',
        ),
      ),
      sdk.Marker(
        sdk.MarkerOptions(
          icon: await _loader.loadPngFromAsset(_circleAssetsPath, 160, 160),
          position: const sdk.GeoPointWithElevation(
            latitude: sdk.Latitude(67.740861),
            longitude: sdk.Longitude(175.624631),
          ),
          text: 'text',
        ),
      ),
    ];
    _mapObjectManager?.addObjects(_markersOn180);
  }

  Future<void> _initRectMarkersOn0() async {
    _rectMarkersOn0 = [
      sdk.Marker(
        sdk.MarkerOptions(
          icon: await _loader.loadPngFromAsset(_circleAssetsPath, 160, 160),
          position: const sdk.GeoPointWithElevation(
            latitude: sdk.Latitude(-53.744213),
            longitude: sdk.Longitude(25.624631),
          ),
          text: 'text',
        ),
      ),
      sdk.Marker(
        sdk.MarkerOptions(
          icon: await _loader.loadPngFromAsset(_circleAssetsPath, 160, 160),
          position: const sdk.GeoPointWithElevation(
            latitude: sdk.Latitude(-53.744213),
            longitude: sdk.Longitude(-27.627422),
          ),
          text: 'text',
        ),
      ),
      sdk.Marker(
        sdk.MarkerOptions(
          icon: await _loader.loadPngFromAsset(_circleAssetsPath, 160, 160),
          position: const sdk.GeoPointWithElevation(
            latitude: sdk.Latitude(-57.740861),
            longitude: sdk.Longitude(-27.627422),
          ),
          text: 'text',
        ),
      ),
      sdk.Marker(
        sdk.MarkerOptions(
          icon: await _loader.loadPngFromAsset(_circleAssetsPath, 160, 160),
          position: const sdk.GeoPointWithElevation(
            latitude: sdk.Latitude(-57.740861),
            longitude: sdk.Longitude(25.624631),
          ),
          text: 'text',
        ),
      ),
    ];
    _mapObjectManager?.addObjects(_rectMarkersOn0);
  }

  Future<void> _initMarkersOn0() async {
    _markersOn0 = [
      sdk.Marker(
        sdk.MarkerOptions(
          icon: await _loader.loadPngFromAsset(_circleAssetsPath, 160, 160),
          position: const sdk.GeoPointWithElevation(
            latitude: sdk.Latitude(63.744213),
            longitude: sdk.Longitude(20.624631),
          ),
          text: 'text',
        ),
      ),
      sdk.Marker(
        sdk.MarkerOptions(
          icon: await _loader.loadPngFromAsset(_circleAssetsPath, 160, 160),
          position: const sdk.GeoPointWithElevation(
            latitude: sdk.Latitude(63.744213),
            longitude: sdk.Longitude(-20.627422),
          ),
          text: 'text',
        ),
      ),
      sdk.Marker(
        sdk.MarkerOptions(
          icon: await _loader.loadPngFromAsset(_circleAssetsPath, 160, 160),
          position: const sdk.GeoPointWithElevation(
            latitude: sdk.Latitude(67.740861),
            longitude: sdk.Longitude(-27.627422),
          ),
          text: 'text',
        ),
      ),
      sdk.Marker(
        sdk.MarkerOptions(
          icon: await _loader.loadPngFromAsset(_circleAssetsPath, 160, 160),
          position: const sdk.GeoPointWithElevation(
            latitude: sdk.Latitude(67.740861),
            longitude: sdk.Longitude(25.624631),
          ),
          text: 'text',
        ),
      ),
    ];

    _mapObjectManager?.addObjects(_markersOn0);
  }

  void _initCircle() {
    const circlePosition = sdk.GeoPoint(
      latitude: sdk.Latitude(55.840861),
      longitude: sdk.Longitude(37.72463),
    );
    _circle = sdk.Circle(
      sdk.CircleOptions(
        position: circlePosition,
        radius: const sdk.Meter(1000),
        // ignore: deprecated_member_use
        color: sdk.Color(Colors.red.value),
        // ignore: deprecated_member_use
        strokeColor: sdk.Color(Colors.blue.value),
        strokeWidth: const sdk.LogicalPixel(1),
      ),
    );
    _mapObjectManager?.addObject(_circle);
  }

  void _initPolygon() {
    final points = <sdk.GeoPoint>[
      const sdk.GeoPoint(
        latitude: sdk.Latitude(55.656843),
        longitude: sdk.Longitude(37.520876),
      ),
      const sdk.GeoPoint(
        latitude: sdk.Latitude(55.636271),
        longitude: sdk.Longitude(37.558983),
      ),
      const sdk.GeoPoint(
        latitude: sdk.Latitude(55.624607),
        longitude: sdk.Longitude(37.560663),
      ),
      const sdk.GeoPoint(
        latitude: sdk.Latitude(55.617338),
        longitude: sdk.Longitude(37.527384),
      ),
      const sdk.GeoPoint(
        latitude: sdk.Latitude(55.62257),
        longitude: sdk.Longitude(37.494438),
      ),
      const sdk.GeoPoint(
        latitude: sdk.Latitude(55.635209),
        longitude: sdk.Longitude(37.481369),
      ),
    ];

    _polygon = sdk.Polygon(
      sdk.PolygonOptions(
        contours: [points],
        strokeWidth: const sdk.LogicalPixel(10),
        // ignore: deprecated_member_use
        color: sdk.Color(Colors.red.value),
        // ignore: deprecated_member_use
        strokeColor: sdk.Color(Colors.blue.value),
      ),
    );
    _mapObjectManager?.addObject(_polygon);
  }

  void _calcPosition(List<sdk.SimpleMapObject> objects) {
    if (_switchValue) {
      _showStandaloneSettings(objects);
    } else {
      _sdkCamera.moveToCameraPosition(
        sdk.calcPositionForObjects(
          _sdkCamera,
          objects,
          _styleZoomToTiltRelation,
          _sdkCamera.padding,
          _sdkCamera.position.tilt,
          _sdkCamera.position.bearing,
          _screenSize,
        ),
      );
    }
  }
}
