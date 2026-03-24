import 'package:flutter/foundation.dart';

/// Data model for a porch/entrance item.
@immutable
class PorchItem {
  final String title;
  final String apartments;
  final bool hasNumber;
  final int? number;

  const PorchItem({
    required this.title,
    required this.apartments,
    required this.hasNumber,
    this.number,
  });

  PorchItem copyWith({
    String? title,
    String? apartments,
    bool? hasNumber,
    int? number,
  }) {
    return PorchItem(
      title: title ?? this.title,
      apartments: apartments ?? this.apartments,
      hasNumber: hasNumber ?? this.hasNumber,
      number: number ?? this.number,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PorchItem &&
        other.title == title &&
        other.apartments == apartments &&
        other.hasNumber == hasNumber &&
        other.number == number;
  }

  @override
  int get hashCode => Object.hash(title, apartments, hasNumber, number);

  @override
  String toString() {
    return 'PorchItem(title: $title, apartments: $apartments, '
        'hasNumber: $hasNumber, number: $number)';
  }
}

/// Contact type enumeration for different contact methods.
enum ContactType {
  phone,
  email,
  website,
  vkontakte,
  twitter,
  odnoklassniki,
  youtube,
  linkedin,
  googleplus,
  whatsapp,
  telegram,
  telegramChannel,
  viber,
  pinterest,
  unknown;

  factory ContactType.fromString(String value) {
    switch (value.toLowerCase()) {
      case 'phone':
        return ContactType.phone;
      case 'email':
        return ContactType.email;
      case 'website':
        return ContactType.website;
      case 'vkontakte':
        return ContactType.vkontakte;
      case 'twitter':
        return ContactType.twitter;
      case 'odnoklassniki':
        return ContactType.odnoklassniki;
      case 'youtube':
        return ContactType.youtube;
      case 'linkedin':
        return ContactType.linkedin;
      case 'googleplus':
        return ContactType.googleplus;
      case 'whatsapp':
        return ContactType.whatsapp;
      case 'telegram':
        return ContactType.telegram;
      case 'telegramchannel':
        return ContactType.telegramChannel;
      case 'viber':
        return ContactType.viber;
      case 'pinterest':
        return ContactType.pinterest;
      default:
        return ContactType.unknown;
    }
  }

  String? get displayName {
    switch (this) {
      case ContactType.whatsapp:
        return 'WhatsApp';
      case ContactType.telegram:
        return 'Telegram';
      case ContactType.viber:
        return 'Viber';
      default:
        return null;
    }
  }

  bool get isPhone => this == ContactType.phone;

  bool get isMessenger =>
      this == ContactType.viber ||
      this == ContactType.whatsapp ||
      this == ContactType.telegram;

  bool get isSocialMedia =>
      this == ContactType.googleplus ||
      this == ContactType.twitter ||
      this == ContactType.linkedin ||
      this == ContactType.odnoklassniki ||
      this == ContactType.vkontakte ||
      this == ContactType.youtube ||
      this == ContactType.pinterest ||
      this == ContactType.telegramChannel;

  bool get isWebsite =>
      this == ContactType.website || this == ContactType.email;
}

/// Data model for contact information.
@immutable
class ContactData {
  final ContactType type;
  final String title;
  final String? comment;
  final String value;

  const ContactData({
    required this.type,
    required this.title,
    required this.value,
    this.comment,
  });

  ContactData copyWith({
    ContactType? type,
    String? title,
    String? comment,
    String? value,
  }) {
    return ContactData(
      type: type ?? this.type,
      title: title ?? this.title,
      value: value ?? this.value,
      comment: comment ?? this.comment,
    );
  }

  Uri? get launchUri {
    final normalizedValue = value.trim();
    if (normalizedValue.isEmpty) return null;

    switch (type) {
      case ContactType.phone:
        return Uri(scheme: 'tel', path: normalizedValue);
      case ContactType.email:
        return Uri(scheme: 'mailto', path: normalizedValue);
      default:
        return Uri.tryParse(normalizedValue);
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContactData &&
        other.type == type &&
        other.title == title &&
        other.comment == comment &&
        other.value == value;
  }

  @override
  int get hashCode => Object.hash(type, title, comment, value);

  @override
  String toString() {
    return 'ContactData(type: $type, title: $title, '
        'comment: $comment, value: $value)';
  }
}

/// Alert level for working hours status.
enum WorkingHoursAlertLevel {
  low,
  medium,
  high,
}

/// Data model for a single row in full working hours display.
@immutable
class WorkingHoursFullRow {
  final String days;
  final String title;
  final String? subtitle;

  const WorkingHoursFullRow({
    required this.days,
    required this.title,
    this.subtitle,
  });

  WorkingHoursFullRow copyWith({
    String? days,
    String? title,
    String? subtitle,
  }) {
    return WorkingHoursFullRow(
      days: days ?? this.days,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkingHoursFullRow &&
        other.days == days &&
        other.title == title &&
        other.subtitle == subtitle;
  }

  @override
  int get hashCode => Object.hash(days, title, subtitle);

  @override
  String toString() {
    return 'WorkingHoursFullRow(days: $days, title: $title, '
        'subtitle: $subtitle)';
  }
}

/// Data model for working hours information.
@immutable
class WorkingHoursData {
  final String shortTitle;
  final WorkingHoursAlertLevel alertLevel;
  final String mediumTitle;
  final String? mediumSubtitle;
  final List<WorkingHoursFullRow> full;
  final String scheduleLabel;
  final bool isUniformDaily;
  final bool isOpenSoon;
  final bool isOpen24x7;

  const WorkingHoursData({
    required this.shortTitle,
    required this.alertLevel,
    required this.mediumTitle,
    required this.full,
    required this.scheduleLabel,
    required this.isUniformDaily,
    required this.isOpenSoon,
    required this.isOpen24x7,
    this.mediumSubtitle,
  });

  WorkingHoursData copyWith({
    String? shortTitle,
    WorkingHoursAlertLevel? alertLevel,
    String? mediumTitle,
    String? mediumSubtitle,
    List<WorkingHoursFullRow>? full,
    String? scheduleLabel,
    bool? isUniformDaily,
    bool? isOpenSoon,
    bool? isOpen24x7,
  }) {
    return WorkingHoursData(
      shortTitle: shortTitle ?? this.shortTitle,
      alertLevel: alertLevel ?? this.alertLevel,
      mediumTitle: mediumTitle ?? this.mediumTitle,
      mediumSubtitle: mediumSubtitle ?? this.mediumSubtitle,
      full: full ?? this.full,
      scheduleLabel: scheduleLabel ?? this.scheduleLabel,
      isUniformDaily: isUniformDaily ?? this.isUniformDaily,
      isOpenSoon: isOpenSoon ?? this.isOpenSoon,
      isOpen24x7: isOpen24x7 ?? this.isOpen24x7,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkingHoursData &&
        other.shortTitle == shortTitle &&
        other.alertLevel == alertLevel &&
        other.mediumTitle == mediumTitle &&
        other.mediumSubtitle == mediumSubtitle &&
        listEquals(other.full, full) &&
        other.scheduleLabel == scheduleLabel &&
        other.isUniformDaily == isUniformDaily &&
        other.isOpenSoon == isOpenSoon &&
        other.isOpen24x7 == isOpen24x7;
  }

  @override
  int get hashCode => Object.hash(
        shortTitle,
        alertLevel,
        mediumTitle,
        mediumSubtitle,
        Object.hashAll(full),
        scheduleLabel,
        isUniformDaily,
        isOpenSoon,
        isOpen24x7,
      );

  @override
  String toString() {
    return 'WorkingHoursData(shortTitle: $shortTitle, alertLevel: $alertLevel, '
        'mediumTitle: $mediumTitle, mediumSubtitle: $mediumSubtitle, '
        'full: $full, scheduleLabel: $scheduleLabel, '
        'isUniformDaily: $isUniformDaily, isOpenSoon: $isOpenSoon, '
        'isOpen24x7: $isOpen24x7)';
  }
}
