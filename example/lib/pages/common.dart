import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:permission_handler/permission_handler.dart';

Text buildPageTitle(String content) {
  return Text(
    content,
    style: const TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 20,
    ),
  );
}

ListTile buildListTile(BuildContext context, String title, String subtitle) {
  return ListTile(
    title: buildPageTitle(title),
    subtitle: Text(subtitle),
  );
}

// SDK is initialized here. If you need to modify parameters of initialization,
// do it in initializeSdk() method.
class AppContainer {
  static sdk.Context? _sdkContext;

  sdk.Context initializeSdk() {
    _sdkContext ??= sdk.DGis.initialize(
      logOptions: const sdk.LogOptions(
        systemLevel: sdk.LogLevel.verbose,
        customLevel: sdk.LogLevel.verbose,
      ),
    );
    return _sdkContext!;
  }
}

Future<sdk.MapWidgetController> createMapWidgetController(
  sdk.Context sdkContext, {
  sdk.MapControllerOptions controllerOptions = const sdk.MapControllerOptions(),
}) async {
  final mapController = await sdk.MapController.create(
    sdkContext,
    controllerOptions,
  ).value;
  return sdk.MapWidgetController(mapController);
}

Future<void> checkLocationPermissions(
  sdk.LocationService locationService,
) async {
  final permission = await Permission.location.status;

  if (permission.isGranted) {
    locationService.onPermissionGranted();
  } else {
    final result = await Permission.location.request();
    if (result.isGranted) {
      locationService.onPermissionGranted();
    }
  }
}
