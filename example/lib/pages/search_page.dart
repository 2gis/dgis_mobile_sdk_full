import 'dart:async';

import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:dgis_mobile_sdk_full/l10n/generated/dgis_localizations.dart';
import 'package:dgis_mobile_sdk_full/l10n/generated/dgis_localizations_en.dart';
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
  late final sdk.MapWidgetController mapWidgetController =
      createMapWidgetController(sdkContext);

  final formKey = GlobalKey<FormState>();
  late sdk.SearchManager searchManager;
  late sdk.LocationService locationService;

  sdk.DirectoryObject? selectedDirectoryObject;
  String? formattedDistance;

  @override
  void initState() {
    super.initState();
    locationService = sdk.LocationService(sdkContext);
    searchManager = sdk.SearchManager.createOnlineManager(sdkContext);
    initialize();
    unawaited(_createMapController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Page')),
      body: Stack(
        children: [
          sdk.MapWidget(
            sdkContext: sdkContext,
            controller: mapWidgetController,
          ),
          sdk.DgisSearchWidget(
            searchManager: searchManager,
            locationService: locationService,
            onObjectSelected: _showObjectCard,
          ),
          if (selectedDirectoryObject != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildDirectoryObjectCard(),
            ),
        ],
      ),
    );
  }

  Future<void> initialize() async {
    await checkLocationPermissions(locationService);
  }

  Future<void> _createMapController() async {
    await mapWidgetController.mapAsync;
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  Widget _buildDirectoryObjectCard() {
    final localizations =
        DgisLocalizations.of(context) ?? DgisLocalizationsEn();
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final theme = isDarkMode
        ? sdk.SearchResultItemTheme.defaultDark
        : sdk.SearchResultItemTheme.defaultLight;

    final viewModel = sdk.SearchResultItemViewModel.fromDirectoryObject(
      object: selectedDirectoryObject!,
      localizations: localizations,
      onTap: (object) {
        _closeDirectoryObjectCard();
      },
      formattedDistance: formattedDistance,
    );

    final cardBackgroundColor =
        isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final closeButtonBackgroundColor =
        isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: closeButtonBackgroundColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _closeDirectoryObjectCard,
                icon: Icon(
                  Icons.close,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardBackgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: sdk.SearchResultItemWidget(
                  viewModel: viewModel,
                  theme: theme,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _closeDirectoryObjectCard() {
    setState(() {
      selectedDirectoryObject = null;
      formattedDistance = null;
    });
  }

  String _formatDistance(int meters, DgisLocalizations localizations) {
    if (meters >= 1000) {
      final km = meters / 1000;
      final kmValue = double.parse(km.toStringAsFixed(km % 1 == 0 ? 0 : 1));
      return localizations.dgis_km_format(kmValue);
    }
    return localizations.dgis_m__meters_format(meters);
  }

  void _showObjectCard(sdk.DirectoryObject objectInfo) {
    String? distance;
    final myLocation = locationService.lastLocation;
    final objectPosition = objectInfo.markerPosition;
    if (myLocation != null && objectPosition != null) {
      final localizations =
          DgisLocalizations.of(context) ?? DgisLocalizationsEn();
      final distanceMeters =
          objectPosition.distance(myLocation.coordinates.value);
      distance = _formatDistance(distanceMeters.value.toInt(), localizations);
    }

    setState(() {
      selectedDirectoryObject = objectInfo;
      formattedDistance = distance;
    });
  }
}
