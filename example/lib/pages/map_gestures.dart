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
  final mapWidgetController = sdk.MapWidgetController();
  final formKey = GlobalKey<FormState>();
  sdk.GestureManager? gestureManager;
  sdk.TouchEventsObserver? touchEventsObserver;
  sdk.GestureEnumSet enabledGestures = sdk.GestureEnumSet.all();

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
    mapWidgetController
      ..getMapAsync((map) {
        gestureManager = mapWidgetController.gestureManager;
      })
      ..copyrightAlignment = Alignment.bottomLeft;
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
              _updateTouchEventsObserver(context);
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
                        sdk.Gesture.shift,
                        'Shift',
                        setState,
                      ),
                      const Divider(height: 0),
                      _buildGestureCheckbox(
                        sdk.Gesture.scaling,
                        'Scaling',
                        setState,
                      ),
                      const Divider(height: 0),
                      _buildGestureCheckbox(
                        sdk.Gesture.rotation,
                        'Rotation',
                        setState,
                      ),
                      const Divider(height: 0),
                      _buildGestureCheckbox(
                        sdk.Gesture.multiTouchShift,
                        'MultiTouchShift',
                        setState,
                      ),
                      const Divider(height: 0),
                      _buildGestureCheckbox(
                        sdk.Gesture.tilt,
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
                      enabledGestures = gestureManager!.enabledGestures;
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      gestureManager?.enabledGestures = enabledGestures;
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
    sdk.Gesture gesture,
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

  void _updateTouchEventsObserver(BuildContext context) {
    if (touchEventsObserver != null) {
      touchEventsObserver = null;
      mapWidgetController.setTouchEventsObserver(null);
      return;
    }

    touchEventsObserver =
        _TouchEventsObserverImpl(ScaffoldMessenger.of(context));
    mapWidgetController.setTouchEventsObserver(touchEventsObserver);
  }
}

class _TouchEventsObserverImpl extends sdk.TouchEventsObserver {
  final ScaffoldMessengerState _messengerState;

  _TouchEventsObserverImpl(this._messengerState);

  @override
  void onTap(sdk.ScreenPoint point) {
    final snackBar = SnackBar(
      content: Text('User taped on screen (${point.x}, ${point.y})'),
      duration: const Duration(seconds: 2),
    );
    _messengerState.showSnackBar(snackBar);
  }

  @override
  void onLongTouch(sdk.ScreenPoint point) {
    final snackBar = SnackBar(
      content: Text('User long touched on screen (${point.x}, ${point.y})'),
      duration: const Duration(seconds: 2),
    );
    _messengerState.showSnackBar(snackBar);
  }
}
