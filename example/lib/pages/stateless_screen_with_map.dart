import 'dart:async';

import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:flutter/material.dart';

import 'common.dart';

class SimpleMapScreen extends StatelessWidget {
  final String title;
  const SimpleMapScreen({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    final sdkContext = AppContainer().initializeSdk();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: _SimpleMapWidget(sdkContext: sdkContext),
    );
  }
}

class _SimpleMapWidget extends StatefulWidget {
  final sdk.Context sdkContext;

  const _SimpleMapWidget({required this.sdkContext});

  @override
  State<_SimpleMapWidget> createState() => _SimpleMapWidgetState();
}

class _SimpleMapWidgetState extends State<_SimpleMapWidget> {
  late final sdk.MapWidgetController mapWidgetController =
      createMapWidgetController(widget.sdkContext);

  @override
  void initState() {
    super.initState();
    unawaited(_createMapController());
  }

  @override
  Widget build(BuildContext context) {
    return sdk.MapWidget(
      sdkContext: widget.sdkContext,
      controller: mapWidgetController,
    );
  }

  Future<void> _createMapController() async {
    await mapWidgetController.mapAsync;
  }
}
