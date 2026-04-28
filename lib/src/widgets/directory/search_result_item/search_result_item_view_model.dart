import '../../../../../l10n/generated/dgis_localizations.dart';
import '../../../generated/dart_bindings.dart' as sdk;
import '../../../platform/dgis.dart';

/// View model for displaying search result item data.
///
/// This class encapsulates all the display data for a search result item,
/// extracted from a [sdk.DirectoryObject]. It provides a clean separation
/// between the SDK data model and the UI representation.
///
/// The view model includes:
/// * Basic information (title, subtitle, address)
/// * Rating and reviews data
/// * Distance from user's location
/// * Work status (open/closed/opening soon)
/// * Charging station availability (for EV charging stations)
/// * Object attributes
///
/// Usage example:
/// ```dart
/// final viewModel = SearchResultItemViewModel.fromDirectoryObject(
///   object: directoryObject,
///   localizations: DgisLocalizations.of(context)!,
///   onTap: (object) {
///     print('Tapped on: ${object.title}');
///   },
///   formattedDistance: '1.2 km',
/// );
/// ```
class SearchResultItemViewModel {
  /// The original directory object from the SDK.
  final sdk.DirectoryObject object;

  /// Display title of the object (e.g., organization name).
  final String title;

  /// Display subtitle (e.g., category or type).
  final String subtitle;

  /// Rating value from 0 to 5, or null if no rating available.
  final double? rating;

  /// Localized text showing the number of reviews.
  final String reviewsCount;

  /// Formatted distance string (e.g., "1.2 km"), or null if unavailable.
  final String? distance;

  /// Street address, or null if unavailable.
  final String? address;

  /// Combined attributes string (e.g., "Wi-Fi • Parking • 24/7").
  final String attributes;

  /// Whether the place is currently open, or null if unknown.
  final bool? isOpen;

  /// Whether the place is opening soon, or null if not applicable.
  final bool? isOpenSoon;

  /// Alert description for work status (e.g., "Opens at 9:00").
  final String? alertDescription;

  /// Whether the charging station is active, or null if not a charging station.
  final bool? chargingIsActive;

  /// Whether the charging station is busy, or null if not a charging station.
  final bool? chargingIsBusy;

  /// Localized charging status text (e.g., "3 of 5 available").
  final String? chargingStatus;

  /// Callback invoked when the item is tapped.
  final void Function(sdk.DirectoryObject) onTap;

  SearchResultItemViewModel({
    required this.object,
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.reviewsCount,
    required this.distance,
    required this.address,
    required this.attributes,
    required this.isOpen,
    required this.isOpenSoon,
    required this.alertDescription,
    required this.chargingIsActive,
    required this.chargingIsBusy,
    required this.chargingStatus,
    required this.onTap,
  });

  /// Creates a view model from a [sdk.DirectoryObject].
  ///
  /// This factory extracts and formats all relevant data from the directory
  /// object, including rating, address, attributes, and charging station info.
  ///
  /// Parameters:
  /// * [object] - The directory object to extract data from
  /// * [localizations] - Localization provider for formatting text
  /// * [onTap] - Callback when the item is tapped
  /// * [formattedDistance] - Optional pre-formatted distance string
  factory SearchResultItemViewModel.fromDirectoryObject({
    required sdk.DirectoryObject object,
    required DgisLocalizations localizations,
    required void Function(sdk.DirectoryObject) onTap,
    String? formattedDistance,
  }) {
    // ignore: unused_local_variable
    final guard = sdk.setupBssEventsSourceFromSdk(DGis().context);

    final title = object.title;
    final subtitle = object.subtitle;

    double? rating;
    final reviews = object.reviews;
    if (reviews != null) {
      rating = reviews.rating;
    }

    final reviewCount = reviews?.count ?? 0;
    final reviewsCountText = localizations.dgis_reviews_count(reviewCount);

    final formattedAddress = object.formattedAddress(sdk.FormattingType.short);
    final address = formattedAddress?.streetAddress;

    final isOpen = object.workStatus?.isOpen;

    String? alertDescription;
    bool? isOpenSoon;

    bool? chargingIsActive;
    bool? chargingIsBusy;
    String? chargingStatus;

    final chargingStation = object.chargingStation;
    if (chargingStation != null) {
      final aggregate = chargingStation.aggregate;
      chargingIsActive = aggregate.isActive;
      chargingIsBusy = aggregate.isBusy;

      if (!aggregate.isActive) {
        chargingStatus = localizations.dgis_charging_not_active;
      } else if (aggregate.connectorsFree == 0) {
        chargingStatus = localizations.dgis_no_places_available;
      } else if (aggregate.connectorsTotal == aggregate.connectorsFree) {
        chargingStatus = localizations.dgis_charging_available_places_all(
          aggregate.connectorsTotal,
        );
      } else {
        chargingStatus = localizations.dgis_charging_available_places_count(
          aggregate.connectorsFree,
          aggregate.connectorsTotal,
        );
      }
    }

    final attributesList = object.attributes.map((attr) => attr.value).toList();
    final attributesText = attributesList.join(' • ');

    return SearchResultItemViewModel(
      object: object,
      title: title,
      subtitle: subtitle,
      rating: rating,
      reviewsCount: reviewsCountText,
      distance: formattedDistance,
      address: address,
      attributes: attributesText,
      isOpen: isOpen,
      isOpenSoon: isOpenSoon,
      alertDescription: alertDescription,
      chargingIsActive: chargingIsActive,
      chargingIsBusy: chargingIsBusy,
      chargingStatus: chargingStatus,
      onTap: onTap,
    );
  }
}
