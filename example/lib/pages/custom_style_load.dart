import 'dart:async';

import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:flutter/material.dart';

import 'common.dart';

class CustomStyleLoadPage extends StatefulWidget {
  final String title;

  const CustomStyleLoadPage({required this.title, super.key});

  @override
  State<CustomStyleLoadPage> createState() => _CustomStyleLoadPageState();
}

class _CustomStyleLoadPageState extends State<CustomStyleLoadPage> {
  sdk.MapWidgetController? mapWidgetController;
  final sdkContext = AppContainer().initializeSdk();

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
      controllerOptions: sdk.MapControllerOptions(
        styleFile: sdk.File.fromAsset(sdkContext, 'custom_styles.2gis'),
      ),
    );
    if (!mounted) {
      return;
    }

    final map = createdMapWidgetController.map;
    map.camera.position = const sdk.CameraPosition(
      point: sdk.GeoPoint(
        latitude: sdk.Latitude(55.752474),
        longitude: sdk.Longitude(37.668906),
      ),
      zoom: sdk.Zoom(11),
    );

    setState(() {
      mapWidgetController = createdMapWidgetController;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentMapWidgetController = mapWidgetController;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: currentMapWidgetController == null
          ? const SizedBox.shrink()
          : sdk.MapWidget(
              sdkContext: sdkContext,
              controller: currentMapWidgetController,
            ),
    );
  }
}
