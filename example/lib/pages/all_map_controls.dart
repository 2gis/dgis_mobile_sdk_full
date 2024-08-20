import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:flutter/material.dart';

import 'common.dart';

class AllMapControlsPage extends StatefulWidget {
  final String title;

  const AllMapControlsPage({required this.title, super.key});

  @override
  State<AllMapControlsPage> createState() => _AllMapControlsPageState();
}

class _AllMapControlsPageState extends State<AllMapControlsPage> {
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
        // TODO: пофиксить краш при const sdk.MapOptions()
        // ignore: prefer_const_constructors
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
                    child: Column(
                      children: [
                        sdk.TrafficWidget(
                          roundedCorners: sdk.RoundedCorners.top(),
                        ),
                        sdk.ParkingWidget(
                          roundedCorners: sdk.RoundedCorners.bottom(),
                        ),
                      ],
                    ),
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
