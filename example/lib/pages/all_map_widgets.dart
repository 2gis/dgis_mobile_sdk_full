import 'dart:async';

import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'common.dart';

class AllMapWidgetsPage extends StatefulWidget {
  final String title;

  const AllMapWidgetsPage({required this.title, super.key});

  @override
  State<AllMapWidgetsPage> createState() => _AllMapWidgetsPageState();
}

class _AllMapWidgetsPageState extends State<AllMapWidgetsPage> {
  sdk.MapWidgetController? mapWidgetController;
  final sdkContext = AppContainer().initializeSdk();

  sdk.MyLocationController? _myLocationController;

  @override
  void initState() {
    super.initState();
    final locationService = sdk.LocationService(sdkContext);
    checkLocationPermissions(locationService).then((_) {
      unawaited(_createMapController());
    });
  }

  @override
  void dispose() {
    _myLocationController?.dispose();
    super.dispose();
  }

  Future<void> _createMapController() async {
    final createdMapWidgetController = await createMapWidgetController(
      sdkContext,
    );
    if (!mounted) {
      return;
    }

    final map = createdMapWidgetController.map;
    final locationSource = sdk.MyLocationMapObjectSource(sdkContext);
    map.addSource(locationSource);

    setState(() {
      mapWidgetController = createdMapWidgetController;
      _myLocationController = sdk.MyLocationController(
        map: map,
        onPermissionRequest: () async {
          await Permission.location.request();
        },
        onTapFeedback: HapticFeedback.mediumImpact,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentMapWidgetController = mapWidgetController;
    final myLocationController = _myLocationController;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: currentMapWidgetController == null
          ? const SizedBox.shrink()
          : sdk.MapWidget(
              sdkContext: sdkContext,
              controller: currentMapWidgetController,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Align(
                          alignment: Alignment.topRight,
                          child: sdk.TrafficWidget(),
                        ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Column(
                            children: [
                              const sdk.ZoomWidget(),
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: sdk.CompassWidget(),
                              ),
                              if (myLocationController != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: sdk.MyLocationWidget(
                                    controller: myLocationController,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: sdk.IndoorWidget(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
