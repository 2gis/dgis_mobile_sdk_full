import 'package:flutter/foundation.dart';

import '../../../../../l10n/generated/dgis_localizations.dart';
import '../../../generated/dart_bindings.dart' as sdk;
import './directory_object_models.dart';
import './working_hours_factory.dart';

/// View model for displaying directory object details.
///
/// This class encapsulates all the display data for a directory object,
/// extracted from a [sdk.DirectoryObject]. It provides a clean separation
/// between the SDK data model and the UI representation.
@immutable
class DirectoryObjectViewModel {
  /// The original directory object from the SDK.
  final sdk.DirectoryObject object;

  /// Display title of the object.
  final String? title;

  /// Additional title text (e.g., building number).
  final String? titleAddition;

  /// Display subtitle (e.g., category or type).
  final String? subtitle;

  /// Rating value from 0 to 5, or null if no rating available.
  final double? rating;

  /// Localized text showing the number of reviews.
  final String? reviewsCount;

  /// Formatted distance string, or null if unavailable.
  final String? distance;

  /// Short street address.
  final String? shortAddress;

  /// Full address main line.
  final String? fullAddressMainLine;

  /// Full address secondary line (postal code, etc.).
  final String? fullAddressSecondaryLine;

  /// Combined attributes string (e.g., "Wi-Fi • Parking").
  final String? attributes;

  /// Alert description for work status.
  final String? alertDescription;

  /// Whether the alert is for "opening soon" vs "closed".
  final bool isOpenSoon;

  /// Porches prefix label (e.g., "Entrances").
  final String? porchesPrefix;

  /// Localized porches count text.
  final String? porchesCount;

  /// List of porch items.
  final List<PorchItem>? porches;

  /// Working hours data.
  final WorkingHoursData? workingHours;

  /// List of contacts.
  final List<ContactData>? contacts;

  /// Entrances button label.
  final String? entrancesButtonLabel;

  /// Callback invoked when the close button is tapped.
  final VoidCallback onDismiss;

  /// Callback invoked when the entrances button is tapped.
  final void Function(List<sdk.EntranceInfo>)? onShowEntrances;

  /// List of entrances for the show entrances callback.
  final List<sdk.EntranceInfo>? entrances;

  /// Label for the copy button.
  final String copyButtonLabel;

  /// Title for the contacts section.
  final String contactsTitle;

  /// Title for the websites/social networks section.
  final String websitesSocialNetworksTitle;

  /// Label for the "more" button in contacts.
  final String? expandButtonLabel;

  const DirectoryObjectViewModel({
    required this.object,
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.reviewsCount,
    required this.distance,
    required this.shortAddress,
    required this.fullAddressMainLine,
    required this.fullAddressSecondaryLine,
    required this.attributes,
    required this.alertDescription,
    required this.isOpenSoon,
    required this.porchesPrefix,
    required this.porchesCount,
    required this.porches,
    required this.workingHours,
    required this.contacts,
    required this.entrancesButtonLabel,
    required this.onDismiss,
    required this.copyButtonLabel,
    required this.contactsTitle,
    required this.websitesSocialNetworksTitle,
    this.titleAddition,
    this.onShowEntrances,
    this.entrances,
    this.expandButtonLabel,
  });

  /// Creates a view model from a [sdk.DirectoryObject].
  factory DirectoryObjectViewModel.fromDirectoryObject({
    required sdk.DirectoryObject object,
    required DgisLocalizations localizations,
    required VoidCallback onDismiss,
    void Function(List<sdk.EntranceInfo>)? onShowEntrances,
    String? formattedDistance,
  }) {
    final title = object.title;
    final titleAddition = object.titleAddition;
    final subtitle = object.subtitle;

    double? rating;
    final reviews = object.reviews;
    if (reviews != null) {
      rating = reviews.rating;
    }
    final reviewCount = reviews?.count ?? 0;
    final reviewsCountText = localizations.dgis_reviews_count(reviewCount);

    final shortFormattedAddress =
        object.formattedAddress(sdk.FormattingType.short);
    final shortAddress = shortFormattedAddress?.streetAddress;

    final fullFormattedAddress =
        object.formattedAddress(sdk.FormattingType.full);
    final fullAddressMainLine = fullFormattedAddress?.streetAddress;

    String? fullAddressSecondaryLine;
    final postCode = fullFormattedAddress?.postCode;
    final drilldownAddress = fullFormattedAddress?.drilldownAddress;
    final postalAndDrilldown = [
      if (postCode != null && postCode.isNotEmpty) postCode,
      if (drilldownAddress != null && drilldownAddress.isNotEmpty)
        drilldownAddress,
    ].join(', ');

    if (postalAndDrilldown.isNotEmpty) {
      fullAddressSecondaryLine = postalAndDrilldown;
    } else {
      final markerPosition = object.markerPosition;
      if (markerPosition != null) {
        fullAddressSecondaryLine =
            '${markerPosition.latitude.value.toStringAsFixed(6)}, '
            '${markerPosition.longitude.value.toStringAsFixed(6)}';
      }
    }

    final attributesList = object.attributes.map((attr) => attr.value).toList();
    final attributesText =
        attributesList.isNotEmpty ? attributesList.join(' \u2022 ') : null;

    final objectEntrances = object.entrances
        .where((e) => e.porchName != null || e.porchNumber != null)
        .toList();

    String? porchesPrefix;
    String? porchesCount;
    List<PorchItem>? porches;

    if (objectEntrances.isNotEmpty) {
      porchesCount = localizations.dgis_entrances_count(objectEntrances.length);
      porchesPrefix = localizations.dgis_building_porches_prefix;

      final items = <PorchItem>[];
      for (final entrance in objectEntrances) {
        final rawPorchName = entrance.porchName ?? entrance.porchNumber ?? '';
        final numericPorch = int.tryParse(entrance.porchNumber ?? '');
        final hasInvalidNumber =
            numericPorch == null || rawPorchName.contains(':');

        var porchTitle = rawPorchName;
        String? apartments;

        if (hasInvalidNumber) {
          final parts = rawPorchName.split(':');
          if (parts.length == 2) {
            final left = parts[0].trim();
            final right = parts[1].trim();
            porchTitle = '$left:';
            apartments = right.isEmpty ? null : right;
          }
        }

        if (apartments == null) {
          final ranges = entrance.apartmentRanges.map((range) {
            final end = range.end;
            if (end != null) {
              return '${range.start}-$end';
            } else {
              return range.start;
            }
          }).toList();
          if (ranges.isNotEmpty) {
            apartments =
                '${ranges.join(', ')} ${localizations.dgis_apartments_suffix}';
          }
        }

        if (apartments != null && apartments.isNotEmpty) {
          items.add(
            PorchItem(
              title: porchTitle,
              apartments: apartments,
              hasNumber: !hasInvalidNumber,
              number: numericPorch,
            ),
          );
        }
      }

      items.sort((a, b) {
        final aNum = a.hasNumber ? (a.number ?? 0) : 0;
        final bNum = b.hasNumber ? (b.number ?? 0) : 0;
        return aNum.compareTo(bNum);
      });

      porches = items.isNotEmpty ? items : null;
    }

    String? entrancesButtonLabel;
    List<sdk.EntranceInfo>? entrances;
    final buildingInfo = object.buildingInfo;
    if (buildingInfo != null && object.entrances.isNotEmpty) {
      final purposeCode = buildingInfo.purposeCode;
      final isPorchesObject = purposeCode != null && purposeCode.value == 42;
      if (isPorchesObject) {
        entrances = object.entrances
            .where((e) => e.porchName != null || e.porchNumber != null)
            .toList();
        entrancesButtonLabel = localizations.dgis_porches;
      } else {
        entrances = object.entrances;
        entrancesButtonLabel = localizations.dgis_entrances;
      }
    }

    List<ContactData>? contacts;
    String? expandButtonLabel;
    final contactInfos = object.contactInfos;
    if (contactInfos.isNotEmpty) {
      expandButtonLabel = localizations.dgis_contacts_more;

      final mappedContacts = contactInfos.map((info) {
        final type = ContactType.fromString(info.type);
        String contactTitle;
        var value = info.value;

        final displayName = type.displayName;
        if (displayName != null) {
          contactTitle = '${localizations.dgis_write_to} $displayName';
        } else {
          contactTitle = info.displayText;
        }

        if (type == ContactType.whatsapp) {
          final uri = Uri.tryParse(value);
          if (uri != null) {
            final queryParams = Map<String, String>.from(uri.queryParameters)
              ..remove('text');
            value = uri.replace(queryParameters: queryParams).toString();
          }
        }

        return ContactData(
          type: type,
          title: contactTitle,
          comment: info.comment,
          value: value,
        );
      }).toList();

      contacts = mappedContacts.map((contact) {
        final lowercasedValue = contact.value.toLowerCase();
        if (contact.type == ContactType.website &&
            (lowercasedValue.startsWith('http://t.me/') ||
                lowercasedValue.startsWith('https://t.me/'))) {
          return ContactData(
            type: ContactType.telegramChannel,
            title: contact.title,
            comment: contact.comment,
            value: contact.value,
          );
        }
        return contact;
      }).toList();
    }

    final factory = WorkingHoursFactory(localizations);
    final workingHours = factory.make(object.openingHours, object.workStatus);

    String? alertDescription;
    var isOpenSoon = false;
    if (workingHours != null && workingHours.shortTitle.isNotEmpty) {
      alertDescription = workingHours.shortTitle;
      isOpenSoon = workingHours.isOpenSoon;
    }

    return DirectoryObjectViewModel(
      object: object,
      title: title,
      titleAddition: titleAddition,
      subtitle: subtitle,
      rating: rating,
      reviewsCount: reviewsCountText,
      distance: formattedDistance,
      shortAddress: shortAddress,
      fullAddressMainLine: fullAddressMainLine,
      fullAddressSecondaryLine: fullAddressSecondaryLine,
      attributes: attributesText,
      alertDescription: alertDescription,
      isOpenSoon: isOpenSoon,
      porchesPrefix: porchesPrefix,
      porchesCount: porchesCount,
      porches: porches,
      workingHours: workingHours,
      contacts: contacts,
      entrancesButtonLabel: entrancesButtonLabel,
      onDismiss: onDismiss,
      onShowEntrances: onShowEntrances,
      entrances: entrances,
      copyButtonLabel: localizations.dgis_copy,
      contactsTitle: localizations.dgis_contacts_title,
      websitesSocialNetworksTitle:
          localizations.dgis_websites_social_networks_title,
      expandButtonLabel: expandButtonLabel,
    );
  }

  DirectoryObjectViewModel copyWith({
    sdk.DirectoryObject? object,
    String? title,
    String? titleAddition,
    String? subtitle,
    double? rating,
    String? reviewsCount,
    String? distance,
    String? shortAddress,
    String? fullAddressMainLine,
    String? fullAddressSecondaryLine,
    String? attributes,
    String? alertDescription,
    bool? isOpenSoon,
    String? porchesPrefix,
    String? porchesCount,
    List<PorchItem>? porches,
    WorkingHoursData? workingHours,
    List<ContactData>? contacts,
    String? entrancesButtonLabel,
    VoidCallback? onDismiss,
    void Function(List<sdk.EntranceInfo>)? onShowEntrances,
    List<sdk.EntranceInfo>? entrances,
    String? copyButtonLabel,
    String? contactsTitle,
    String? websitesSocialNetworksTitle,
    String? expandButtonLabel,
  }) {
    return DirectoryObjectViewModel(
      object: object ?? this.object,
      title: title ?? this.title,
      titleAddition: titleAddition ?? this.titleAddition,
      subtitle: subtitle ?? this.subtitle,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      distance: distance ?? this.distance,
      shortAddress: shortAddress ?? this.shortAddress,
      fullAddressMainLine: fullAddressMainLine ?? this.fullAddressMainLine,
      fullAddressSecondaryLine:
          fullAddressSecondaryLine ?? this.fullAddressSecondaryLine,
      attributes: attributes ?? this.attributes,
      alertDescription: alertDescription ?? this.alertDescription,
      isOpenSoon: isOpenSoon ?? this.isOpenSoon,
      porchesPrefix: porchesPrefix ?? this.porchesPrefix,
      porchesCount: porchesCount ?? this.porchesCount,
      porches: porches ?? this.porches,
      workingHours: workingHours ?? this.workingHours,
      contacts: contacts ?? this.contacts,
      entrancesButtonLabel: entrancesButtonLabel ?? this.entrancesButtonLabel,
      onDismiss: onDismiss ?? this.onDismiss,
      onShowEntrances: onShowEntrances ?? this.onShowEntrances,
      entrances: entrances ?? this.entrances,
      copyButtonLabel: copyButtonLabel ?? this.copyButtonLabel,
      contactsTitle: contactsTitle ?? this.contactsTitle,
      websitesSocialNetworksTitle:
          websitesSocialNetworksTitle ?? this.websitesSocialNetworksTitle,
      expandButtonLabel: expandButtonLabel ?? this.expandButtonLabel,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DirectoryObjectViewModel &&
        other.object == object &&
        other.title == title &&
        other.titleAddition == titleAddition &&
        other.subtitle == subtitle &&
        other.rating == rating &&
        other.reviewsCount == reviewsCount &&
        other.distance == distance &&
        other.shortAddress == shortAddress &&
        other.fullAddressMainLine == fullAddressMainLine &&
        other.fullAddressSecondaryLine == fullAddressSecondaryLine &&
        other.attributes == attributes &&
        other.alertDescription == alertDescription &&
        other.isOpenSoon == isOpenSoon &&
        other.porchesPrefix == porchesPrefix &&
        other.porchesCount == porchesCount &&
        listEquals(other.porches, porches) &&
        other.workingHours == workingHours &&
        listEquals(other.contacts, contacts) &&
        listEquals(other.entrances, entrances) &&
        other.entrancesButtonLabel == entrancesButtonLabel &&
        other.copyButtonLabel == copyButtonLabel &&
        other.contactsTitle == contactsTitle &&
        other.websitesSocialNetworksTitle == websitesSocialNetworksTitle &&
        other.expandButtonLabel == expandButtonLabel;
  }

  @override
  int get hashCode => Object.hash(
        object,
        title,
        titleAddition,
        subtitle,
        rating,
        reviewsCount,
        distance,
        shortAddress,
        fullAddressMainLine,
        fullAddressSecondaryLine,
        attributes,
        alertDescription,
        isOpenSoon,
        porchesPrefix,
        porchesCount,
        porches != null ? Object.hashAll(porches!) : null,
        workingHours,
        contacts != null ? Object.hashAll(contacts!) : null,
        entrances != null ? Object.hashAll(entrances!) : null,
        Object.hash(
          entrancesButtonLabel,
          copyButtonLabel,
          contactsTitle,
          websitesSocialNetworksTitle,
          expandButtonLabel,
        ),
      );

  @override
  String toString() {
    return 'DirectoryObjectViewModel('
        'object: $object, '
        'title: $title, '
        'titleAddition: $titleAddition, '
        'subtitle: $subtitle, '
        'rating: $rating, '
        'reviewsCount: $reviewsCount, '
        'distance: $distance, '
        'shortAddress: $shortAddress, '
        'fullAddressMainLine: $fullAddressMainLine, '
        'fullAddressSecondaryLine: $fullAddressSecondaryLine, '
        'attributes: $attributes, '
        'alertDescription: $alertDescription, '
        'isOpenSoon: $isOpenSoon, '
        'porchesPrefix: $porchesPrefix, '
        'porchesCount: $porchesCount, '
        'porches: $porches, '
        'workingHours: $workingHours, '
        'contacts: $contacts, '
        'entrancesButtonLabel: $entrancesButtonLabel, '
        'entrances: $entrances, '
        'copyButtonLabel: $copyButtonLabel, '
        'contactsTitle: $contactsTitle, '
        'websitesSocialNetworksTitle: $websitesSocialNetworksTitle, '
        'expandButtonLabel: $expandButtonLabel)';
  }
}
