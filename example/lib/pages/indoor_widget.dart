import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'common.dart';

class IndoorWidgetPage extends StatefulWidget {
  final String title;

  const IndoorWidgetPage({required this.title, super.key});

  @override
  State<IndoorWidgetPage> createState() => _IndoorWidgetPageState();
}

class _IndoorWidgetPageState extends State<IndoorWidgetPage> {
  final mapWidgetController = sdk.MapWidgetController();
  final sdkContext = AppContainer().initializeSdk();

  @override
  void initState() {
    super.initState();
    mapWidgetController.copyrightAlignment = Alignment.bottomLeft;
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
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: sdk.IndoorWidget(),
              ),
            ),
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

  void _show() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Buildings'),
        actions: <Widget>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              mapWidgetController.getMapAsync((map) {
                map.camera.changePosition(
                  const sdk.CameraPositionChange(
                    zoom: sdk.Zoom(17),
                    point: sdk.GeoPoint(
                      latitude: sdk.Latitude(54.980661),
                      longitude: sdk.Longitude(82.897799),
                    ),
                  ),
                );
              });
            },
            child: const Text('Sun City Mall Novosibirsk (6 floors, scroll)'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              mapWidgetController.getMapAsync((map) {
                map.camera.changePosition(
                  const sdk.CameraPositionChange(
                    zoom: sdk.Zoom(17),
                    point: sdk.GeoPoint(
                      latitude: sdk.Latitude(54.965676),
                      longitude: sdk.Longitude(82.93565),
                    ),
                  ),
                );
              });
            },
            child: const Text('MEGA Mall Novosibirsk (2 floors, no scroll)'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              mapWidgetController.getMapAsync((map) {
                map.camera.changePosition(
                  const sdk.CameraPositionChange(
                    zoom: sdk.Zoom(17),
                    point: sdk.GeoPoint(
                      latitude: sdk.Latitude(55.028917),
                      longitude: sdk.Longitude(82.936734),
                    ),
                  ),
                );
              });
            },
            child: const Text(
              'Aura Mall Novosibirsk (6 floors, scroll, -1 -2 etc.)',
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              mapWidgetController.getMapAsync((map) {
                map.camera.changePosition(
                  const sdk.CameraPositionChange(
                    zoom: sdk.Zoom(17),
                    point: sdk.GeoPoint(
                      latitude: sdk.Latitude(54.987016),
                      longitude: sdk.Longitude(82.905888),
                    ),
                  ),
                );
              });
            },
            child: const Text('NSTU (12 floors, scroll, double-digit)'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              mapWidgetController.getMapAsync((map) {
                map.camera.changePosition(
                  const sdk.CameraPositionChange(
                    zoom: sdk.Zoom(17),
                    point: sdk.GeoPoint(
                      latitude: sdk.Latitude(25.212477),
                      longitude: sdk.Longitude(55.280235),
                    ),
                  ),
                );
              });
            },
            child: const Text(
              'Gate Avenue Dubai (Letters in floors, no scroll)',
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              mapWidgetController.getMapAsync((map) {
                map.camera.changePosition(
                  const sdk.CameraPositionChange(
                    zoom: sdk.Zoom(17),
                    point: sdk.GeoPoint(
                      latitude: sdk.Latitude(25.19742),
                      longitude: sdk.Longitude(55.27982),
                    ),
                  ),
                );
              });
            },
            child: const Text('Dubai Mall (Letters in floors, scroll)'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              mapWidgetController.getMapAsync((map) {
                map.camera.changePosition(
                  const sdk.CameraPositionChange(
                    zoom: sdk.Zoom(17),
                    point: sdk.GeoPoint(
                      latitude: sdk.Latitude(25.076247),
                      longitude: sdk.Longitude(55.14074),
                    ),
                  ),
                );
              });
            },
            child: const Text('Marina Mall Dubai (Letters in floors, scroll)'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}
