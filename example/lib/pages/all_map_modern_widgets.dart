import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'common.dart';

class AllMapModernWidgetsPage extends StatefulWidget {
  final String title;

  const AllMapModernWidgetsPage({required this.title, super.key});

  @override
  State<AllMapModernWidgetsPage> createState() =>
      _AllMapModernWidgetsPageState();
}

class _AllMapModernWidgetsPageState extends State<AllMapModernWidgetsPage> {
  final mapWidgetController = sdk.MapWidgetController();
  final sdkContext = AppContainer().initializeSdk();

  sdk.ModernMyLocationController? _myLocationController;
  sdk.ModernMyLocationController? _defaultMyLocationController;

  @override
  void initState() {
    super.initState();
    mapWidgetController.getMapAsync((map) {
      final locationSource = sdk.MyLocationMapObjectSource(sdkContext);
      map.addSource(locationSource);
      setState(() {
        _myLocationController = sdk.ModernMyLocationController(
          map: map,
          onPermissionRequest: _requestLocationPermission,
          onTapFeedback: HapticFeedback.mediumImpact,
        );
        _defaultMyLocationController = sdk.ModernMyLocationController(
          map: map,
          onTapFeedback: HapticFeedback.mediumImpact,
        );
      });
    });
  }

  @override
  void dispose() {
    _myLocationController?.dispose();
    _defaultMyLocationController?.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (!status.isGranted) return;
    final serviceStatus = await Permission.location.serviceStatus;
    if (serviceStatus != ServiceStatus.enabled) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Location services disabled'),
          content: const Text(
            'Location services are turned off on '
            'your device. Please enable them in '
            'settings to use this feature.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final myLocationController = _myLocationController;
    final defaultMyLocationController = _defaultMyLocationController;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: sdk.MapWidget(
        sdkContext: sdkContext,
        mapOptions: sdk.MapOptions(),
        controller: mapWidgetController,
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
                    child: sdk.ModernTrafficWidget(),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      children: [
                        const sdk.ModernZoomWidget(),
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: sdk.ModernCompassWidget(),
                        ),
                        if (myLocationController != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: sdk.ModernMyLocationWidget(
                              controller: myLocationController,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        sdk.ModernIndoorWidget(),
                        SizedBox(width: 8),
                        sdk.ModernIndoorWidget(showRoof: false),
                      ],
                    ),
                    if (defaultMyLocationController != null) ...[
                      const SizedBox(height: 8),
                      sdk.ModernMyLocationWidget(
                        controller: defaultMyLocationController,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
