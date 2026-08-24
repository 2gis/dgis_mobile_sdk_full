import 'dart:async';

import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'common.dart';

class MapGesturesPage extends StatefulWidget {
  const MapGesturesPage({required this.title, super.key});

  final String title;

  @override
  State<MapGesturesPage> createState() => _MapGesturesState();
}

class _MapGesturesState extends State<MapGesturesPage> {
  final sdkContext = AppContainer().initializeSdk();
  late final sdk.MapWidgetController mapWidgetController =
      createMapWidgetController(sdkContext);
  final formKey = GlobalKey<FormState>();
  final pinAssetsPath = 'assets/icons/pin.png';
  sdk.GestureManager? gestureManager;
  sdk.TouchEventsObserver? touchEventsObserver;
  sdk.MapObjectManager? mapObjectManager;
  sdk.MutableEnumSet<sdk.TransformGesture> enabledGestures =
      sdk.MutableTransformGestureEnumSet.all();
  late sdk.Image iconImage;

  @override
  void initState() {
    super.initState();
    unawaited(initContext());
  }

  @override
  void dispose() {
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
    final loader = sdk.ImageLoader(sdkContext);
    iconImage = await loader.loadPngFromAsset(pinAssetsPath, 160, 160);
    await _createMapController();
  }

  Future<void> _createMapController() async {
    final map = await mapWidgetController.mapAsync;
    if (!mounted) {
      return;
    }
    gestureManager = mapWidgetController.gestureManager;
    mapObjectManager = sdk.MapObjectManager(map);

    setState(() {
      mapWidgetController.copyrightAlignment = Alignment.bottomLeft;
    });
  }

  void _show() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Gesture settings'),
        actions: <Widget>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context, 'One');
              _showGestureSettings();
            },
            child: const Text('Disabling gestures'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context, 'Two');
              unawaited(
                _updateTouchEventsObserver(ScaffoldMessenger.of(context)),
              );
            },
            child: touchEventsObserver == null
                ? const Text('Enable custom TouchEventsObserver')
                : const Text('Disable custom TouchEventsObserver'),
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

  void _showGestureSettings() {
    if (gestureManager == null) {
      return;
    }
    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Gestures'),
              content: Form(
                key: formKey,
                child: SizedBox(
                  height: 300,
                  width: 50,
                  child: Column(
                    children: <Widget>[
                      _buildGestureCheckbox(
                        sdk.TransformGesture.shift,
                        'Shift',
                        setState,
                      ),
                      const Divider(height: 0),
                      _buildGestureCheckbox(
                        sdk.TransformGesture.scaling,
                        'Scaling',
                        setState,
                      ),
                      const Divider(height: 0),
                      _buildGestureCheckbox(
                        sdk.TransformGesture.rotation,
                        'Rotation',
                        setState,
                      ),
                      const Divider(height: 0),
                      _buildGestureCheckbox(
                        sdk.TransformGesture.multiTouchShift,
                        'MultiTouchShift',
                        setState,
                      ),
                      const Divider(height: 0),
                      _buildGestureCheckbox(
                        sdk.TransformGesture.tilt,
                        'Tilt',
                        setState,
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    if (gestureManager != null) {
                      enabledGestures =
                          gestureManager!.enabledGestures.toMutableEnumSet();
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      gestureManager?.enabledGestures =
                          enabledGestures.toEnumSet();
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  CheckboxListTile _buildGestureCheckbox(
    sdk.TransformGesture gesture,
    String gestureName,
    Function(void Function()) setState,
  ) {
    return CheckboxListTile(
      value: enabledGestures.contains(gesture),
      onChanged: (value) {
        setState(() {
          if (value ?? false) {
            enabledGestures.add(gesture);
          } else {
            enabledGestures.remove(gesture);
          }
        });
      },
      title: Text(gestureName),
    );
  }

  Future<void> _updateTouchEventsObserver(
    ScaffoldMessengerState messengerState,
  ) async {
    if (touchEventsObserver != null) {
      touchEventsObserver = null;
      mapWidgetController.setTouchEventsObserver(null);
      return;
    }

    final map = await mapWidgetController.mapAsync;
    touchEventsObserver =
        _TouchEventsObserverImpl(messengerState, (point, idx) {
      final geoPoint = map.camera.projection.screenToMap(point);
      if (geoPoint == null) {
        return;
      }
      final options = sdk.MarkerOptions(
        icon: iconImage,
        position: sdk.GeoPointWithElevation(
          latitude: geoPoint.latitude,
          longitude: geoPoint.longitude,
        ),
        anchor: const sdk.Anchor(y: 1),
        draggable: true,
        iconWidth: const sdk.LogicalPixel(5),
        userData: idx,
      );
      mapObjectManager?.addObject(sdk.Marker(options));
    }, () {
      mapObjectManager?.removeAll();
    }, (point) {
      final geoPoint = map.camera.projection.screenToMap(point);
      if (geoPoint == null) {
        return null;
      }
      return sdk.GeoPointWithElevation(
        latitude: geoPoint.latitude,
        longitude: geoPoint.longitude,
      );
    });
    mapWidgetController.setTouchEventsObserver(touchEventsObserver);
  }
}

class _TouchEventsObserverImpl extends sdk.TouchEventsObserver {
  final ScaffoldMessengerState _messengerState;
  final void Function(sdk.ScreenPoint point, int idx) _onTapFunction;
  final void Function() _onLongTouchFunction;
  final sdk.GeoPointWithElevation? Function(sdk.ScreenPoint point)
      _getGeoPointFunction;
  int tapIdx = 0;
  sdk.Marker? dragObject;

  _TouchEventsObserverImpl(
    this._messengerState,
    this._onTapFunction,
    this._onLongTouchFunction,
    this._getGeoPointFunction,
  );

  @override
  void onTap(sdk.ScreenPoint point) {
    _onTapFunction(point, tapIdx);
    tapIdx += 1;
    final snackBar = SnackBar(
      content: Text('User taped on screen (${point.x}, ${point.y})'),
      duration: const Duration(seconds: 2),
    );
    _messengerState.showSnackBar(snackBar);
  }

  @override
  void onLongTouch(sdk.ScreenPoint point) {
    _onLongTouchFunction();
    final snackBar = SnackBar(
      content: Text('User long touched on screen (${point.x}, ${point.y})'),
      duration: const Duration(seconds: 2),
    );
    _messengerState.showSnackBar(snackBar);
  }

  @override
  void onDragBegin(sdk.DragBeginData data) {
    final mapObject = data.item.item;
    if (mapObject.userData == null) {
      return;
    }
    final point = data.point;
    final simpleObject = mapObject as sdk.SimpleMapObject;
    dragObject = simpleObject as sdk.Marker;
    if (dragObject == null) {
      return;
    }
    final dragIdx = dragObject!.userData! as int;
    final snackBar = SnackBar(
      content: Text(
        'User drag begin on screen (${point.x}, ${point.y}) and object with id $dragIdx',
      ),
      duration: const Duration(seconds: 2),
    );
    _messengerState.showSnackBar(snackBar);
  }

  @override
  void onDragMove(sdk.ScreenPoint point) {
    if (dragObject == null) {
      return;
    }
    // ignore: avoid_print
    print(
      'User drag move on screen (${point.x}, ${point.y}) and object with id ${dragObject?.userData}',
    );
    final geoPoint = _getGeoPointFunction(point);
    if (geoPoint == null) {
      return;
    }
    dragObject?.position = geoPoint;
  }

  @override
  void onDragEnd() {
    if (dragObject == null) {
      return;
    }
    final snackBar = SnackBar(
      content: Text(
        'User drag end on screen object with id ${dragObject?.userData}',
      ),
      duration: const Duration(seconds: 2),
    );
    _messengerState.showSnackBar(snackBar);
  }
}
