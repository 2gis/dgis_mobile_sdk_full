import 'dart:async';

import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'common.dart';

class TrafficWidgetPage extends StatefulWidget {
  const TrafficWidgetPage({required this.title, super.key});

  final String title;

  @override
  State<TrafficWidgetPage> createState() => _TrafficWidgetPageState();
}

class _TrafficWidgetPageState extends State<TrafficWidgetPage> {
  sdk.MapWidgetController? mapWidgetController;
  final sdkContext = AppContainer().initializeSdk();
  sdk.Map? _map;

  @override
  void initState() {
    super.initState();
    unawaited(_createMapController());
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _createMapController() async {
    final createdMapWidgetController = await createMapWidgetController(
      sdkContext,
    );
    if (!mounted) {
      return;
    }

    _map = createdMapWidgetController.map;
    setState(() {
      mapWidgetController = createdMapWidgetController
        ..copyrightAlignment = Alignment.bottomLeft;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentMapWidgetController = mapWidgetController;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: <Widget>[
          if (currentMapWidgetController == null)
            const SizedBox.shrink()
          else
            sdk.MapWidget(
              sdkContext: sdkContext,
              controller: currentMapWidgetController,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: sdk.TrafficWidget(),
                    ),
                    Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: sdk.ZoomWidget(),
                    ),
                    Spacer(),
                  ],
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

  void _moveToCityWithTrafficScore() {
    _map?.camera.position = const sdk.CameraPosition(
      point: sdk.GeoPoint(
        latitude: sdk.Latitude(51.121764),
        longitude: sdk.Longitude(71.451362),
      ),
      zoom: sdk.Zoom(13),
    );
  }

  void _moveToCityWithoutTrafficScore() {
    _map?.camera.position = const sdk.CameraPosition(
      point: sdk.GeoPoint(
        latitude: sdk.Latitude(52.342013),
        longitude: sdk.Longitude(71.912038),
      ),
      zoom: sdk.Zoom(12),
    );
  }

  void _show() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Variants'),
        actions: <Widget>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _moveToCityWithTrafficScore();
            },
            child: const Text('City with traffic score'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _moveToCityWithoutTrafficScore();
            },
            child: const Text('City without traffic score'),
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
