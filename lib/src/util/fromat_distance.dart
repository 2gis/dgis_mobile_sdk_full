import 'dart:math';

FormattedMeasure formatMeters(int millis) {
  final meters = millis / 1000;
  if (meters > 3000) {
    // Показываем в километрах с точностью до целых
    final kilometers = (meters / 1000).floor();
    return FormattedMeasure(kilometers.toString(), "км");
  }

  if (meters > 1000) {
    // Показываем в километрах с точностью до одного десятичного знака
    final hundredsOfMeters = (meters / 100).floor();
    final distanceKm = (hundredsOfMeters / 10).floor();
    return FormattedMeasure(distanceKm.floor().toString(), "км");
  }

  if (meters > 500) {
    // Показываем с точностью до 100 м
    final hundredsOfMeters = (meters / 100).floor();
    final distanceM = hundredsOfMeters * 100;
    return FormattedMeasure(distanceM.floor().toString(), "м");
  }

  if (meters > 250) {
    // Показываем с точностью до 50 м
    final fiftiesOfMeters = (meters / 50).floor();
    final distanceM = fiftiesOfMeters * 50;
    return FormattedMeasure(distanceM.floor().toString(), "м");
  }

  if (meters == 0) {
    return FormattedMeasure("0", "м");
  }

  // Показываем с точностью до 10 м
  final tensOfMeters = max(1, meters / 10).floor();
  final distanceM = tensOfMeters * 10;
  return FormattedMeasure(distanceM.floor().toString(), "м");
}

class FormattedMeasure {
  FormattedMeasure(this.value, this.unit);

  final String value;
  final String unit;
}
