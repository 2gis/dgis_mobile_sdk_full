import 'package:flutter/material.dart';

import '../../../../../l10n/generated/dgis_localizations.dart';
import './search_result_item_theme.dart';
import './search_result_item_view_model.dart';
import './star_rating_widget.dart';

/// Abstract builder for customizing search result item appearance.
///
/// Implement this interface to provide custom widgets for each section
/// of the search result item. Each method builds a specific part of the UI.
///
/// Usage example:
/// ```dart
/// class CustomSearchResultItemBuilder implements SearchResultItemBuilder {
///   @override
///   Widget buildTitleWidget(
///     SearchResultItemViewModel viewModel,
///     SearchResultItemTheme theme,
///   ) {
///     return Text(
///       viewModel.title.toUpperCase(),
///       style: theme.titleTextStyle.copyWith(letterSpacing: 2),
///     );
///   }
///   // ... implement other methods
/// }
/// ```
///
/// See [DefaultSearchResultItemBuilder] for the default implementation.
abstract class SearchResultItemBuilder {
  /// Builds the title section displaying the object name.
  Widget buildTitleWidget(
    SearchResultItemViewModel viewModel,
    SearchResultItemTheme theme,
  );

  /// Builds the subtitle section displaying category or type.
  Widget buildSubtitleWidget(
    SearchResultItemViewModel viewModel,
    SearchResultItemTheme theme,
  );

  /// Builds the rating section with star rating and review count.
  Widget buildRatingWidget(
    SearchResultItemViewModel viewModel,
    SearchResultItemTheme theme,
  );

  /// Builds the distance indicator.
  Widget buildDistanceWidget(
    SearchResultItemViewModel viewModel,
    SearchResultItemTheme theme,
  );

  /// Builds the address section.
  Widget buildAddressWidget(
    SearchResultItemViewModel viewModel,
    SearchResultItemTheme theme,
  );

  /// Builds the attributes section (e.g., "Wi-Fi • Parking").
  Widget buildAttributesWidget(
    SearchResultItemViewModel viewModel,
    SearchResultItemTheme theme,
  );

  /// Builds the charging station availability section.
  Widget buildChargingStationWidget(
    SearchResultItemViewModel viewModel,
    SearchResultItemTheme theme,
    DgisLocalizations localizations,
  );

  /// Builds the work status alert section (e.g., "Closed" or "Opens at 9:00").
  Widget buildAlertWidget(
    SearchResultItemViewModel viewModel,
    SearchResultItemTheme theme,
  );
}

/// Default implementation of [SearchResultItemBuilder].
///
/// This builder provides a standard layout for search result items with:
/// * Title text with ellipsis overflow (max 2 lines)
/// * Subtitle text with ellipsis overflow (max 2 lines)
/// * Star rating widget with numeric value and review count
/// * Distance text aligned to the right
/// * Address text
/// * Attributes in a single line with ellipsis
/// * Charging station status with colored icon
/// * Work status alerts with appropriate colors
class DefaultSearchResultItemBuilder implements SearchResultItemBuilder {
  const DefaultSearchResultItemBuilder();

  @override
  Widget buildTitleWidget(
    SearchResultItemViewModel viewModel,
    SearchResultItemTheme theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        viewModel.title,
        style: theme.titleTextStyle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  @override
  Widget buildSubtitleWidget(
    SearchResultItemViewModel viewModel,
    SearchResultItemTheme theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 6),
      child: Text(
        viewModel.subtitle,
        style: theme.subtitleTextStyle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  @override
  Widget buildRatingWidget(
    SearchResultItemViewModel viewModel,
    SearchResultItemTheme theme,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StarRatingWidget(
          rating: viewModel.rating ?? 0,
          emptyStarColor: theme.emptyStarColor,
          filledStarColor: theme.filledStarColor,
        ),
        if (viewModel.rating != null) ...[
          const SizedBox(width: 4),
          Text(
            viewModel.rating!.toStringAsFixed(1),
            style: theme.ratingTextStyle,
          ),
        ],
        const SizedBox(width: 4),
        Text(
          viewModel.reviewsCount,
          style: theme.ratingCountTextStyle,
        ),
      ],
    );
  }

  @override
  Widget buildDistanceWidget(
    SearchResultItemViewModel viewModel,
    SearchResultItemTheme theme,
  ) {
    final distance = viewModel.distance;
    if (distance == null || distance.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      distance,
      style: theme.distanceTextStyle,
    );
  }

  @override
  Widget buildAddressWidget(
    SearchResultItemViewModel viewModel,
    SearchResultItemTheme theme,
  ) {
    final address = viewModel.address;
    if (address == null || address.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        address,
        style: theme.addressTextStyle,
      ),
    );
  }

  @override
  Widget buildAttributesWidget(
    SearchResultItemViewModel viewModel,
    SearchResultItemTheme theme,
  ) {
    if (viewModel.attributes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        viewModel.attributes,
        style: theme.attributesTextStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  @override
  Widget buildChargingStationWidget(
    SearchResultItemViewModel viewModel,
    SearchResultItemTheme theme,
    DgisLocalizations localizations,
  ) {
    final status = viewModel.chargingStatus;
    if (status == null) {
      return const SizedBox.shrink();
    }

    Color chargingStatusColor;
    if (!(viewModel.chargingIsActive ?? false)) {
      chargingStatusColor = theme.lowChargingAvailabilityColor;
    } else if (viewModel.chargingIsBusy ?? false) {
      chargingStatusColor = theme.mediumChargingAvailabilityColor;
    } else {
      chargingStatusColor = theme.highChargingAvailabilityColor;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.ev_station,
            size: 16,
            color: chargingStatusColor,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: theme.chargingAvailabilityTextStyle.copyWith(
              color: chargingStatusColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildAlertWidget(
    SearchResultItemViewModel viewModel,
    SearchResultItemTheme theme,
  ) {
    final alertDescription = viewModel.alertDescription;
    if (alertDescription == null || alertDescription.isEmpty) {
      return const SizedBox.shrink();
    }

    final isOpenSoon = viewModel.isOpenSoon;
    if (isOpenSoon == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 2),
      child: Text(
        alertDescription,
        style: isOpenSoon ? theme.soonOpenTextStyle : theme.closedTextStyle,
      ),
    );
  }
}
