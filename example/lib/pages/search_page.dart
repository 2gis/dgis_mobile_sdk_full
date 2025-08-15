import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:flutter/material.dart';

import 'common.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    required this.title,
    super.key,
  });

  final String title;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final sdkContext = AppContainer().initializeSdk();

  final formKey = GlobalKey<FormState>();
  late sdk.SearchManager searchManager;
  late sdk.LocationService locationService;

  @override
  void initState() {
    super.initState();
    locationService = sdk.LocationService(sdkContext);
    searchManager = sdk.SearchManager.createOnlineManager(sdkContext);
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Page')),
      body: Stack(
        children: [
          sdk.MapWidget(sdkContext: sdkContext, mapOptions: sdk.MapOptions()),
          sdk.DgisSearchWidget(
            searchManager: searchManager,
            onObjectSelected: _showObjectCard,
          ),
        ],
      ),
    );
  }

  Future<void> initialize() async {
    await checkLocationPermissions(locationService);
  }

  void _showObjectCard(sdk.DirectoryObject objectInfo) {
    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(objectInfo.title),
          content: Form(
            key: formKey,
            child: SizedBox(
              height: 250,
              width: 50,
              child: ListView(
                shrinkWrap: true,
                children: _buildObjectInfoWidget(objectInfo),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildObjectInfoWidget(sdk.DirectoryObject objectInfo) {
    /// Main info.
    final infoWidgets = <Widget>[
      Text(objectInfo.subtitle),
      Text('ID: ${objectInfo.id?.objectId}'),
    ];
    if (objectInfo.description.isNotEmpty) {
      infoWidgets.add(Text(objectInfo.description));
    }
    infoWidgets.add(() {
      String rating;
      final ratingValue = objectInfo.reviews?.rating;
      if (ratingValue != null) {
        rating = 'Rating: ${ratingValue.toStringAsFixed(2)}';
      } else {
        rating = 'There is no rating for this organization';
      }
      return Text(rating);
    }());
    final fiasCode = objectInfo.address?.fiasCode;
    if (fiasCode != null) {
      infoWidgets.add(Text(fiasCode));
    }

    /// Address
    infoWidgets.addAll([const SizedBox(height: 10), const Text('Location:')]);
    final formattedAddress =
        objectInfo.formattedAddress(sdk.FormattingType.full);
    if (formattedAddress != null) {
      infoWidgets.add(
        Text(
          '${formattedAddress.drilldownAddress}, ${formattedAddress.streetAddress}, ${formattedAddress.addressComment}, ${formattedAddress.postCode}',
        ),
      );
    }
    final position = objectInfo.markerPosition?.point;
    if (position != null) {
      infoWidgets.add(
        Text(
          'Latitude: ${position.latitude.value.toStringAsFixed(6)}, Longitude: ${position.longitude.value.toStringAsFixed(6)}',
        ),
      );
      final lastLocation = locationService.lastLocation().value;
      if (lastLocation != null) {
        final distance = position.distance(lastLocation.coordinates.value);
        var distanceValue = 0.0;
        String distanceUnit;
        if (distance.value > 1000) {
          distanceValue = distance.value / 1000;
          distanceUnit = 'km';
        } else {
          distanceValue = distance.value;
          distanceUnit = 'm';
        }
        infoWidgets.add(
          Text(
            'Distance: ${distanceValue.toStringAsFixed(2)} $distanceUnit',
          ),
        );
      }
    }

    return infoWidgets;
  }
}
