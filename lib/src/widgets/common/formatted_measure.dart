import 'dart:math';
import 'package:flutter/widgets.dart';
import '../../../l10n/generated/dgis_localizations.dart';

/// Value with units of measurement, for example ("1.5", "km")
@immutable
class FormattedMeasure {
  const FormattedMeasure(this.value, this.unit);

  final String value;
  final String unit;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FormattedMeasure &&
        other.value == value &&
        other.unit == unit;
  }

  @override
  int get hashCode => Object.hash(value, unit);

  @override
  String toString() => 'FormattedMeasure($value $unit)';
}

FormattedMeasure metersToFormattedMeasure(
  int millis,
  DgisLocalizations localizations,
) {
  final meters = millis / 1000;
  if (meters > 3000) {
    // Show in kilometers with precision to whole numbers
    final kilometers = meters ~/ 1000;
    return FormattedMeasure(kilometers.toString(), localizations.dgis_km);
  }

  if (meters > 1000) {
    // Show in kilometers with precision to one decimal place
    final hundredsOfMeters = meters ~/ 100;
    final distanceKm = hundredsOfMeters / 10;
    return FormattedMeasure(
      distanceKm.toStringAsFixed(1),
      localizations.dgis_km,
    );
  }

  if (meters > 500) {
    // Show with precision to 100 m
    final hundredsOfMeters = meters ~/ 100;
    final distanceM = hundredsOfMeters * 100;
    return FormattedMeasure(distanceM.toString(), localizations.dgis_m__meters);
  }

  if (meters > 250) {
    // Show with precision to 50 m
    final fiftiesOfMeters = meters ~/ 50;
    final distanceM = fiftiesOfMeters * 50;
    return FormattedMeasure(distanceM.toString(), localizations.dgis_m__meters);
  }

  if (meters == 0) {
    return FormattedMeasure('0', localizations.dgis_m__meters);
  }

  // Show with precision to 10 m
  final tensOfMeters = max(1, meters ~/ 10);
  final distanceM = tensOfMeters * 10;
  return FormattedMeasure(distanceM.toString(), localizations.dgis_m__meters);
}

FormattedMeasure durationToFormattedMeasure(
  Duration duration,
  DgisLocalizations localizations,
) {
  if (duration.inHours > 0) {
    final remainingHours = duration.inHours;
    final remainingMinutes = (duration.inMinutes - duration.inHours * 60)
        .toString()
        .padLeft(2, '0');
    return FormattedMeasure(
      '$remainingHours:$remainingMinutes',
      localizations.dgis_h__hours,
    );
  }
  if (duration.inMinutes >= 1) {
    return FormattedMeasure(
      duration.inMinutes.toString(),
      localizations.dgis_min__minutes,
    );
  }
  return FormattedMeasure('<1', localizations.dgis_min__minutes);
}
