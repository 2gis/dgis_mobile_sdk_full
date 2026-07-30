import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:flutter/material.dart';

import 'common.dart';

class AllMapWidgetsPage extends StatefulWidget {
  final String title;

  const AllMapWidgetsPage({required this.title, super.key});

  @override
  State<AllMapWidgetsPage> createState() => _AllMapWidgetsPageState();
}

class _AllMapWidgetsPageState extends State<AllMapWidgetsPage> {
  final mapWidgetController = sdk.MapWidgetController();
  final sdkContext = AppContainer().initializeSdk();

  @override
  void initState() {
    super.initState();
    final locationService = sdk.LocationService(sdkContext);
    checkLocationPermissions(locationService).then((_) {
      mapWidgetController.getMapAsync((map) {
        final locationSource = sdk.MyLocationMapObjectSource(sdkContext);
        map.addSource(locationSource);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: sdk.MapWidget(
        sdkContext: sdkContext,
        mapOptions: sdk.MapOptions(),
        controller: mapWidgetController,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Stack(
            children: [
              Column(
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
                    child: Column(
                      children: [
                        sdk.ZoomWidget(),
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: sdk.CompassWidget(),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: sdk.MyLocationWidget(),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                ],
              ),
              Align(
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
