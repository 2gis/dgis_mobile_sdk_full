import 'package:flutter/material.dart';

import '../../map/map_widget_color_scheme.dart';
import 'search_result_item_widget.dart';

/// Theme configuration for [SearchResultItemWidget].
///
/// This theme defines all visual properties for displaying search result items,
/// including text styles, colors for ratings, and charging station status colors.
///
/// Two predefined themes are available:
/// * [defaultLight] - Light theme with dark text on light backgrounds
/// * [defaultDark] - Dark theme with light text on dark backgrounds
///
/// Usage example:
/// ```dart
/// SearchResultItemWidget(
///   viewModel: viewModel,
///   theme: SearchResultItemTheme.defaultLight,
/// )
/// ```
///
/// Custom themes can be created by using the constructor or [copyWith] method:
/// ```dart
/// final customTheme = SearchResultItemTheme.defaultLight.copyWith(
///   titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
///   filledStarColor: Colors.amber,
/// );
/// ```
class SearchResultItemTheme extends MapWidgetColorScheme {
  const SearchResultItemTheme({
    required this.titleTextStyle,
    required this.subtitleTextStyle,
    required this.ratingTextStyle,
    required this.ratingCountTextStyle,
    required this.distanceTextStyle,
    required this.addressTextStyle,
    required this.attributesTextStyle,
    required this.workStatusTextStyle,
    required this.closedTextStyle,
    required this.soonOpenTextStyle,
    required this.chargingAvailabilityTextStyle,
    required this.emptyStarColor,
    required this.filledStarColor,
    required this.highChargingAvailabilityColor,
    required this.mediumChargingAvailabilityColor,
    required this.lowChargingAvailabilityColor,
    required this.chargingIconColor,
  });

  /// Text style for the main title of the search result item.
  final TextStyle titleTextStyle;

  /// Text style for the subtitle (category or type) of the search result item.
  final TextStyle subtitleTextStyle;

  /// Text style for the numeric rating value.
  final TextStyle ratingTextStyle;

  /// Text style for the reviews count text.
  final TextStyle ratingCountTextStyle;

  /// Text style for the distance information.
  final TextStyle distanceTextStyle;

  /// Text style for the address line.
  final TextStyle addressTextStyle;

  /// Text style for object attributes (e.g., "Wi-Fi • Parking").
  final TextStyle attributesTextStyle;

  /// Text style for general work status information.
  final TextStyle workStatusTextStyle;

  /// Text style for "closed" status indicator.
  final TextStyle closedTextStyle;

  /// Text style for "opening soon" status indicator.
  final TextStyle soonOpenTextStyle;

  /// Text style for charging station availability status.
  final TextStyle chargingAvailabilityTextStyle;

  /// Color for empty (unfilled) rating stars.
  final Color emptyStarColor;

  /// Color for filled rating stars.
  final Color filledStarColor;

  /// Color indicating high charging availability (many free spots).
  final Color highChargingAvailabilityColor;

  /// Color indicating medium charging availability (some spots busy).
  final Color mediumChargingAvailabilityColor;

  /// Color indicating low charging availability (no free spots or inactive).
  final Color lowChargingAvailabilityColor;

  /// Color for the charging station icon.
  final Color chargingIconColor;

  /// Default light theme for search result items.
  static const defaultLight = SearchResultItemTheme(
    titleTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w600,
      color: Color(0xFF141414),
      fontSize: 17,
      height: 1.3,
    ),
    subtitleTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFF898989),
      fontSize: 15,
      height: 1.3,
    ),
    ratingTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w500,
      color: Color(0xFF141414),
      fontSize: 13,
      height: 1.3,
    ),
    ratingCountTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFF898989),
      fontSize: 13,
      height: 1.3,
    ),
    distanceTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFF898989),
      fontSize: 13,
      height: 1.3,
    ),
    addressTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFF141414),
      fontSize: 15,
      height: 1.3,
    ),
    attributesTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFF898989),
      fontSize: 13,
      height: 1.3,
    ),
    workStatusTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFF898989),
      fontSize: 13,
      height: 1.3,
    ),
    closedTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFFE53935),
      fontSize: 13,
      height: 1.3,
    ),
    soonOpenTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFFFFA726),
      fontSize: 13,
      height: 1.3,
    ),
    chargingAvailabilityTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      fontSize: 13,
      height: 1.3,
    ),
    emptyStarColor: Color(0xFFE0E0E0),
    filledStarColor: Color(0xFFFFA726),
    highChargingAvailabilityColor: Color(0xFF1DB93C),
    mediumChargingAvailabilityColor: Color(0xFFFFA726),
    lowChargingAvailabilityColor: Color(0xFFE53935),
    chargingIconColor: Color(0xFF898989),
  );

  /// Default dark theme for search result items.
  static const defaultDark = SearchResultItemTheme(
    titleTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w600,
      color: Color(0xFFFFFFFF),
      fontSize: 17,
      height: 1.3,
    ),
    subtitleTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFF898989),
      fontSize: 15,
      height: 1.3,
    ),
    ratingTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w500,
      color: Color(0xFFFFFFFF),
      fontSize: 13,
      height: 1.3,
    ),
    ratingCountTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFF898989),
      fontSize: 13,
      height: 1.3,
    ),
    distanceTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFF898989),
      fontSize: 13,
      height: 1.3,
    ),
    addressTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFFFFFFFF),
      fontSize: 15,
      height: 1.3,
    ),
    attributesTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFF898989),
      fontSize: 13,
      height: 1.3,
    ),
    workStatusTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFF898989),
      fontSize: 13,
      height: 1.3,
    ),
    closedTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFFEF5350),
      fontSize: 13,
      height: 1.3,
    ),
    soonOpenTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFFFFB74D),
      fontSize: 13,
      height: 1.3,
    ),
    chargingAvailabilityTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      fontSize: 13,
      height: 1.3,
    ),
    emptyStarColor: Color(0xFF424242),
    filledStarColor: Color(0xFFFFB74D),
    highChargingAvailabilityColor: Color(0xFF26C947),
    mediumChargingAvailabilityColor: Color(0xFFFFB74D),
    lowChargingAvailabilityColor: Color(0xFFEF5350),
    chargingIconColor: Color(0xFF898989),
  );

  @override
  SearchResultItemTheme copyWith({
    TextStyle? titleTextStyle,
    TextStyle? subtitleTextStyle,
    TextStyle? ratingTextStyle,
    TextStyle? ratingCountTextStyle,
    TextStyle? distanceTextStyle,
    TextStyle? addressTextStyle,
    TextStyle? attributesTextStyle,
    TextStyle? workStatusTextStyle,
    TextStyle? closedTextStyle,
    TextStyle? soonOpenTextStyle,
    TextStyle? chargingAvailabilityTextStyle,
    Color? emptyStarColor,
    Color? filledStarColor,
    Color? highChargingAvailabilityColor,
    Color? mediumChargingAvailabilityColor,
    Color? lowChargingAvailabilityColor,
    Color? chargingIconColor,
  }) {
    return SearchResultItemTheme(
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      subtitleTextStyle: subtitleTextStyle ?? this.subtitleTextStyle,
      ratingTextStyle: ratingTextStyle ?? this.ratingTextStyle,
      ratingCountTextStyle: ratingCountTextStyle ?? this.ratingCountTextStyle,
      distanceTextStyle: distanceTextStyle ?? this.distanceTextStyle,
      addressTextStyle: addressTextStyle ?? this.addressTextStyle,
      attributesTextStyle: attributesTextStyle ?? this.attributesTextStyle,
      workStatusTextStyle: workStatusTextStyle ?? this.workStatusTextStyle,
      closedTextStyle: closedTextStyle ?? this.closedTextStyle,
      soonOpenTextStyle: soonOpenTextStyle ?? this.soonOpenTextStyle,
      chargingAvailabilityTextStyle:
          chargingAvailabilityTextStyle ?? this.chargingAvailabilityTextStyle,
      emptyStarColor: emptyStarColor ?? this.emptyStarColor,
      filledStarColor: filledStarColor ?? this.filledStarColor,
      highChargingAvailabilityColor:
          highChargingAvailabilityColor ?? this.highChargingAvailabilityColor,
      mediumChargingAvailabilityColor: mediumChargingAvailabilityColor ??
          this.mediumChargingAvailabilityColor,
      lowChargingAvailabilityColor:
          lowChargingAvailabilityColor ?? this.lowChargingAvailabilityColor,
      chargingIconColor: chargingIconColor ?? this.chargingIconColor,
    );
  }
}
