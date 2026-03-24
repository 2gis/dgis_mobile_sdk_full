import 'package:flutter/material.dart';

import '../../map/map_widget_color_scheme.dart';
import 'directory_object_widget.dart';

/// Theme configuration for [DirectoryObjectWidget].
///
/// This theme defines all visual properties for displaying directory object details,
/// including text styles, colors for various sections, and icons.
///
/// Two predefined themes are available:
/// * [defaultLight] - Light theme with dark text on light backgrounds
/// * [defaultDark] - Dark theme with light text on dark backgrounds
class DirectoryObjectWidgetTheme extends MapWidgetColorScheme {
  const DirectoryObjectWidgetTheme({
    required this.backgroundColor,
    required this.secondaryBackgroundColor,
    required this.tertiaryBackgroundColor,
    required this.capsuleColor,
    required this.closeButtonBackgroundColor,
    required this.closeButtonIconColor,
    required this.dividerColor,
    required this.titleTextStyle,
    required this.titleAdditionTextStyle,
    required this.subtitleTextStyle,
    required this.ratingTextStyle,
    required this.ratingCountTextStyle,
    required this.emptyStarColor,
    required this.filledStarColor,
    required this.distanceTextStyle,
    required this.shortAddressTextStyle,
    required this.fullAddressMainLineTextStyle,
    required this.fullAddressSecondaryLineTextStyle,
    required this.additionalInfoTextStyle,
    required this.lowAlertTextStyle,
    required this.highAlertTextStyle,
    required this.workingHoursIconColor,
    required this.workingHoursLowAlertColor,
    required this.workingHoursMediumAlertColor,
    required this.workingHoursHighAlertColor,
    required this.workingHoursScheduleTextStyle,
    required this.workingHoursBreakTextStyle,
    required this.porchesTitleTextStyle,
    required this.porchTitleTextStyle,
    required this.porchApartmentsTextStyle,
    required this.expandButtonColor,
    required this.contactsTitleTextStyle,
    required this.contactTitleTextStyle,
    required this.contactCommentTextStyle,
    required this.contactExpandButtonTextStyle,
    required this.contactIconColor,
    required this.socialMediaButtonBackgroundColor,
    required this.cardCornerRadius,
  });

  /// Background color for the main container.
  final Color backgroundColor;

  /// Secondary background color for scrollable content area.
  final Color secondaryBackgroundColor;

  /// Tertiary background color for buttons and nested elements.
  final Color tertiaryBackgroundColor;

  /// Color for the capsule handle at the top of the sheet.
  final Color capsuleColor;

  /// Background color for the close button.
  final Color closeButtonBackgroundColor;

  /// Icon color for the close button.
  final Color closeButtonIconColor;

  /// Divider color between sections.
  final Color dividerColor;

  /// Text style for the main title.
  final TextStyle titleTextStyle;

  /// Text style for the title addition (secondary part of title).
  final TextStyle titleAdditionTextStyle;

  /// Text style for the subtitle.
  final TextStyle subtitleTextStyle;

  /// Text style for the numeric rating value.
  final TextStyle ratingTextStyle;

  /// Text style for the reviews count text.
  final TextStyle ratingCountTextStyle;

  /// Color for empty (unfilled) rating stars.
  final Color emptyStarColor;

  /// Color for filled rating stars.
  final Color filledStarColor;

  /// Text style for distance information.
  final TextStyle distanceTextStyle;

  /// Text style for the short address.
  final TextStyle shortAddressTextStyle;

  /// Text style for the full address main line.
  final TextStyle fullAddressMainLineTextStyle;

  /// Text style for the full address secondary line.
  final TextStyle fullAddressSecondaryLineTextStyle;

  /// Text style for additional information (e.g., porches count).
  final TextStyle additionalInfoTextStyle;

  /// Text style for low alert (e.g., "opens soon").
  final TextStyle lowAlertTextStyle;

  /// Text style for high alert (e.g., "closed").
  final TextStyle highAlertTextStyle;

  /// Icon color for working hours section.
  final Color workingHoursIconColor;

  /// Color for low alert in working hours.
  final Color workingHoursLowAlertColor;

  /// Color for medium alert in working hours.
  final Color workingHoursMediumAlertColor;

  /// Color for high alert in working hours.
  final Color workingHoursHighAlertColor;

  /// Text style for working hours schedule.
  final TextStyle workingHoursScheduleTextStyle;

  /// Text style for break time in working hours.
  final TextStyle workingHoursBreakTextStyle;

  /// Text style for porches section title.
  final TextStyle porchesTitleTextStyle;

  /// Text style for individual porch title.
  final TextStyle porchTitleTextStyle;

  /// Text style for apartment ranges in porch.
  final TextStyle porchApartmentsTextStyle;

  /// Color for expand/collapse button icon.
  final Color expandButtonColor;

  /// Text style for contacts section title.
  final TextStyle contactsTitleTextStyle;

  /// Text style for individual contact title.
  final TextStyle contactTitleTextStyle;

  /// Text style for contact comment.
  final TextStyle contactCommentTextStyle;

  /// Text style for "more" button in contacts.
  final TextStyle contactExpandButtonTextStyle;

  /// Color for contact icons.
  final Color contactIconColor;

  /// Background color for social media buttons.
  final Color socialMediaButtonBackgroundColor;

  /// Corner radius for card elements.
  final double cardCornerRadius;

  /// Default light theme for directory object view.
  static const defaultLight = DirectoryObjectWidgetTheme(
    backgroundColor: Color(0xFFFFFFFF),
    secondaryBackgroundColor: Color(0xFFF5F5F5),
    tertiaryBackgroundColor: Color(0xFFEEEEEE),
    capsuleColor: Color(0xFFBDBDBD),
    closeButtonBackgroundColor: Color(0xFFF5F5F5),
    closeButtonIconColor: Color(0xFF757575),
    dividerColor: Color(0xFFE0E0E0),
    titleTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w500,
      color: Color(0xFF141414),
      fontSize: 17,
      height: 1.3,
    ),
    titleAdditionTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w500,
      color: Color(0xFF898989),
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
    emptyStarColor: Color(0xFFE0E0E0),
    filledStarColor: Color(0xFFFFA726),
    distanceTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFF898989),
      fontSize: 13,
      height: 1.3,
    ),
    shortAddressTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFF141414),
      fontSize: 15,
      height: 1.3,
    ),
    fullAddressMainLineTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFF141414),
      fontSize: 15,
      height: 1.3,
    ),
    fullAddressSecondaryLineTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFF898989),
      fontSize: 13,
      height: 1.3,
    ),
    additionalInfoTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFF898989),
      fontSize: 13,
      height: 1.3,
    ),
    lowAlertTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFFFFA726),
      fontSize: 13,
      height: 1.3,
    ),
    highAlertTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFFE53935),
      fontSize: 13,
      height: 1.3,
    ),
    workingHoursIconColor: Color(0xFF757575),
    workingHoursLowAlertColor: Color(0xFF4CAF50),
    workingHoursMediumAlertColor: Color(0xFFFFA726),
    workingHoursHighAlertColor: Color(0xFFE53935),
    workingHoursScheduleTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFF141414),
      fontSize: 15,
      height: 1.3,
    ),
    workingHoursBreakTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFF898989),
      fontSize: 13,
      height: 1.3,
    ),
    porchesTitleTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w500,
      color: Color(0xFF141414),
      fontSize: 15,
      height: 1.3,
    ),
    porchTitleTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFF141414),
      fontSize: 15,
      height: 1.3,
    ),
    porchApartmentsTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFF898989),
      fontSize: 15,
      height: 1.3,
    ),
    expandButtonColor: Color(0xFF757575),
    contactsTitleTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w500,
      color: Color(0xFF141414),
      fontSize: 15,
      height: 1.3,
    ),
    contactTitleTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFF141414),
      fontSize: 15,
      height: 1.3,
    ),
    contactCommentTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFF898989),
      fontSize: 13,
      height: 1.3,
    ),
    contactExpandButtonTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFF2196F3),
      fontSize: 13,
      height: 1.3,
    ),
    contactIconColor: Color(0xFF757575),
    socialMediaButtonBackgroundColor: Color(0xFFF5F5F5),
    cardCornerRadius: 10,
  );

  /// Default dark theme for directory object view.
  static const defaultDark = DirectoryObjectWidgetTheme(
    backgroundColor: Color(0xFF1E1E1E),
    secondaryBackgroundColor: Color(0xFF141414),
    tertiaryBackgroundColor: Color(0xFF3D3D3D),
    capsuleColor: Color(0xFF757575),
    closeButtonBackgroundColor: Color(0xFF3D3D3D),
    closeButtonIconColor: Color(0xFFBDBDBD),
    dividerColor: Color(0xFF424242),
    titleTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w500,
      color: Color(0xFFFFFFFF),
      fontSize: 17,
      height: 1.3,
    ),
    titleAdditionTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w500,
      color: Color(0xFF898989),
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
    emptyStarColor: Color(0xFF424242),
    filledStarColor: Color(0xFFFFB74D),
    distanceTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFF898989),
      fontSize: 13,
      height: 1.3,
    ),
    shortAddressTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFFFFFFFF),
      fontSize: 15,
      height: 1.3,
    ),
    fullAddressMainLineTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFFFFFFFF),
      fontSize: 15,
      height: 1.3,
    ),
    fullAddressSecondaryLineTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFF898989),
      fontSize: 13,
      height: 1.3,
    ),
    additionalInfoTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFF898989),
      fontSize: 13,
      height: 1.3,
    ),
    lowAlertTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFFFFB74D),
      fontSize: 13,
      height: 1.3,
    ),
    highAlertTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFFEF5350),
      fontSize: 13,
      height: 1.3,
    ),
    workingHoursIconColor: Color(0xFFBDBDBD),
    workingHoursLowAlertColor: Color(0xFF66BB6A),
    workingHoursMediumAlertColor: Color(0xFFFFB74D),
    workingHoursHighAlertColor: Color(0xFFEF5350),
    workingHoursScheduleTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFFFFFFFF),
      fontSize: 15,
      height: 1.3,
    ),
    workingHoursBreakTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFF898989),
      fontSize: 13,
      height: 1.3,
    ),
    porchesTitleTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w500,
      color: Color(0xFFFFFFFF),
      fontSize: 15,
      height: 1.3,
    ),
    porchTitleTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFFFFFFFF),
      fontSize: 15,
      height: 1.3,
    ),
    porchApartmentsTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFF898989),
      fontSize: 15,
      height: 1.3,
    ),
    expandButtonColor: Color(0xFFBDBDBD),
    contactsTitleTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w500,
      color: Color(0xFFFFFFFF),
      fontSize: 15,
      height: 1.3,
    ),
    contactTitleTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFFFFFFFF),
      fontSize: 15,
      height: 1.3,
    ),
    contactCommentTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFF898989),
      fontSize: 13,
      height: 1.3,
    ),
    contactExpandButtonTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFF64B5F6),
      fontSize: 13,
      height: 1.3,
    ),
    contactIconColor: Color(0xFFBDBDBD),
    socialMediaButtonBackgroundColor: Color(0xFF3D3D3D),
    cardCornerRadius: 10,
  );

  @override
  DirectoryObjectWidgetTheme copyWith({
    Color? backgroundColor,
    Color? secondaryBackgroundColor,
    Color? tertiaryBackgroundColor,
    Color? capsuleColor,
    Color? closeButtonBackgroundColor,
    Color? closeButtonIconColor,
    Color? dividerColor,
    TextStyle? titleTextStyle,
    TextStyle? titleAdditionTextStyle,
    TextStyle? subtitleTextStyle,
    TextStyle? ratingTextStyle,
    TextStyle? ratingCountTextStyle,
    Color? emptyStarColor,
    Color? filledStarColor,
    TextStyle? distanceTextStyle,
    TextStyle? shortAddressTextStyle,
    TextStyle? fullAddressMainLineTextStyle,
    TextStyle? fullAddressSecondaryLineTextStyle,
    TextStyle? additionalInfoTextStyle,
    TextStyle? lowAlertTextStyle,
    TextStyle? highAlertTextStyle,
    Color? workingHoursIconColor,
    Color? workingHoursLowAlertColor,
    Color? workingHoursMediumAlertColor,
    Color? workingHoursHighAlertColor,
    TextStyle? workingHoursScheduleTextStyle,
    TextStyle? workingHoursBreakTextStyle,
    TextStyle? porchesTitleTextStyle,
    TextStyle? porchTitleTextStyle,
    TextStyle? porchApartmentsTextStyle,
    Color? expandButtonColor,
    TextStyle? contactsTitleTextStyle,
    TextStyle? contactTitleTextStyle,
    TextStyle? contactCommentTextStyle,
    TextStyle? contactExpandButtonTextStyle,
    Color? contactIconColor,
    Color? socialMediaButtonBackgroundColor,
    double? cardCornerRadius,
  }) {
    return DirectoryObjectWidgetTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      secondaryBackgroundColor:
          secondaryBackgroundColor ?? this.secondaryBackgroundColor,
      tertiaryBackgroundColor:
          tertiaryBackgroundColor ?? this.tertiaryBackgroundColor,
      capsuleColor: capsuleColor ?? this.capsuleColor,
      closeButtonBackgroundColor:
          closeButtonBackgroundColor ?? this.closeButtonBackgroundColor,
      closeButtonIconColor: closeButtonIconColor ?? this.closeButtonIconColor,
      dividerColor: dividerColor ?? this.dividerColor,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      titleAdditionTextStyle:
          titleAdditionTextStyle ?? this.titleAdditionTextStyle,
      subtitleTextStyle: subtitleTextStyle ?? this.subtitleTextStyle,
      ratingTextStyle: ratingTextStyle ?? this.ratingTextStyle,
      ratingCountTextStyle: ratingCountTextStyle ?? this.ratingCountTextStyle,
      emptyStarColor: emptyStarColor ?? this.emptyStarColor,
      filledStarColor: filledStarColor ?? this.filledStarColor,
      distanceTextStyle: distanceTextStyle ?? this.distanceTextStyle,
      shortAddressTextStyle:
          shortAddressTextStyle ?? this.shortAddressTextStyle,
      fullAddressMainLineTextStyle:
          fullAddressMainLineTextStyle ?? this.fullAddressMainLineTextStyle,
      fullAddressSecondaryLineTextStyle: fullAddressSecondaryLineTextStyle ??
          this.fullAddressSecondaryLineTextStyle,
      additionalInfoTextStyle:
          additionalInfoTextStyle ?? this.additionalInfoTextStyle,
      lowAlertTextStyle: lowAlertTextStyle ?? this.lowAlertTextStyle,
      highAlertTextStyle: highAlertTextStyle ?? this.highAlertTextStyle,
      workingHoursIconColor:
          workingHoursIconColor ?? this.workingHoursIconColor,
      workingHoursLowAlertColor:
          workingHoursLowAlertColor ?? this.workingHoursLowAlertColor,
      workingHoursMediumAlertColor:
          workingHoursMediumAlertColor ?? this.workingHoursMediumAlertColor,
      workingHoursHighAlertColor:
          workingHoursHighAlertColor ?? this.workingHoursHighAlertColor,
      workingHoursScheduleTextStyle:
          workingHoursScheduleTextStyle ?? this.workingHoursScheduleTextStyle,
      workingHoursBreakTextStyle:
          workingHoursBreakTextStyle ?? this.workingHoursBreakTextStyle,
      porchesTitleTextStyle:
          porchesTitleTextStyle ?? this.porchesTitleTextStyle,
      porchTitleTextStyle: porchTitleTextStyle ?? this.porchTitleTextStyle,
      porchApartmentsTextStyle:
          porchApartmentsTextStyle ?? this.porchApartmentsTextStyle,
      expandButtonColor: expandButtonColor ?? this.expandButtonColor,
      contactsTitleTextStyle:
          contactsTitleTextStyle ?? this.contactsTitleTextStyle,
      contactTitleTextStyle:
          contactTitleTextStyle ?? this.contactTitleTextStyle,
      contactCommentTextStyle:
          contactCommentTextStyle ?? this.contactCommentTextStyle,
      contactExpandButtonTextStyle:
          contactExpandButtonTextStyle ?? this.contactExpandButtonTextStyle,
      contactIconColor: contactIconColor ?? this.contactIconColor,
      socialMediaButtonBackgroundColor: socialMediaButtonBackgroundColor ??
          this.socialMediaButtonBackgroundColor,
      cardCornerRadius: cardCornerRadius ?? this.cardCornerRadius,
    );
  }
}
