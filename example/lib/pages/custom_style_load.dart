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
  final mapWidgetController = sdk.MapWidgetController();
  final sdkContext = AppContainer().initializeSdk();
  final ValueNotifier<bool> isReady = ValueNotifier(false);
  late final sdk.MapOptions mapOptions;

  @override
  void initState() {
    super.initState();
    unawaited(initializeMapOptions());
    mapWidgetController.getMapAsync(
      (map) {
        map.camera.position = const sdk.CameraPosition(
          point: sdk.GeoPoint(
            latitude: sdk.Latitude(55.752474),
            longitude: sdk.Longitude(37.668906),
          ),
          zoom: sdk.Zoom(11),
        );
      },
    );
  }

  Future<void> initializeMapOptions() async {
    final style = await sdk.StyleBuilder(sdkContext)
        .loadStyle(
          sdk.File.fromAsset(sdkContext, 'custom_styles.2gis'),
        )
        .value;
    mapOptions = sdk.MapOptions(style: style);
    isReady.value = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ValueListenableBuilder(
        valueListenable: isReady,
        builder: (context, ready, _) {
          if (ready) {
            return sdk.MapWidget(
              sdkContext: sdkContext,
              mapOptions: mapOptions,
              controller: mapWidgetController,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
