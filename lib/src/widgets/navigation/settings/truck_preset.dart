import 'package:meta/meta.dart';

/// Size class of the truck a route is built for.
///
/// Selecting a preset fills every truck dimension with the values typical for
/// that class. The class is named after its maximum permitted mass, so
/// [TruckPreset.small] covers vehicles up to 3,5 t, [TruckPreset.medium] up to
/// 10 t and [TruckPreset.large] up to 20 t.
enum TruckPreset {
  small,
  medium,
  large,
}

/// A numeric truck parameter of the route-search settings.
@internal
enum TruckDimension {
  length(maxValue: 30000, step: 100, small: 3800, medium: 6000, large: 9000),
  height(maxValue: 10000, step: 100, small: 2000, medium: 2400, large: 2700),
  width(maxValue: 10000, step: 100, small: 2100, medium: 2400, large: 2500),
  actualMass(
    maxValue: 50000,
    step: 500,
    small: 3500,
    medium: 10000,
    large: 20000,
  ),
  maxPermittedMass(
    maxValue: 50000,
    step: 500,
    small: 3500,
    medium: 10000,
    large: 20000,
  ),
  axleLoad(maxValue: 30000, step: 500, small: 1500, medium: 6000, large: 8000);

  const TruckDimension({
    required this.maxValue,
    required this.step,
    required int small,
    required int medium,
    required int large,
  })  : _small = small,
        _medium = medium,
        _large = large;

  /// Largest accepted value, in thousandths of the displayed unit.
  final int maxValue;

  /// Increment of a single stepper press, in thousandths of the displayed unit.
  final int step;

  final int _small;
  final int _medium;
  final int _large;

  /// Smallest accepted value. Core exposes no minimum, so zero it is.
  static const int minValue = 0;

  /// Value this parameter takes while [preset] is selected and the user has
  /// not overridden it.
  int defaultFor(TruckPreset preset) => switch (preset) {
        TruckPreset.small => _small,
        TruckPreset.medium => _medium,
        TruckPreset.large => _large,
      };

  /// Value to display for [preset], where [override] is the stored user value
  /// or null when the parameter still follows the preset.
  int resolve(TruckPreset preset, int? override) =>
      override ?? defaultFor(preset);

  /// [value] moved by [steps] increments, clamped to the accepted range.
  int stepped(int value, int steps) =>
      (value + steps * step).clamp(minValue, maxValue);
}

/// Mass class a preset stands for, in thousandths of a tonne.
///
/// Drives the captions under the preset selector, so they cannot drift away
/// from the values the presets actually apply.
@internal
int truckPresetMass(TruckPreset preset) =>
    TruckDimension.maxPermittedMass.defaultFor(preset);
