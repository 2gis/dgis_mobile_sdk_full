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
  final sdkContext = AppContainer().initializeSdk();
  late final sdk.MapWidgetController mapWidgetController =
      createMapWidgetController(
    sdkContext,
    controllerOptions: sdk.MapControllerOptions(
      styleFile: sdk.File.fromAsset(sdkContext, 'custom_styles.2gis'),
    ),
  );

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
    final map = await mapWidgetController.mapAsync;
    if (!mounted) {
      return;
    }
    map.camera.position = const sdk.CameraPosition(
      point: sdk.GeoPoint(
        latitude: sdk.Latitude(55.752474),
        longitude: sdk.Longitude(37.668906),
      ),
      zoom: sdk.Zoom(11),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: sdk.MapWidget(
        sdkContext: sdkContext,
        controller: mapWidgetController,
      ),
    );
  }
}
