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
      body: sdk.MapWidget(
        sdkContext: sdkContext,
        mapOptions: sdk.MapOptions(),
      ),
    );
  }
}
