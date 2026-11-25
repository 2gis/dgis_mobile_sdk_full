import 'package:flutter/foundation.dart';

@immutable
class ManeuverModel {
  final String? roadName;
  final ManeuverIcon? maneuverIcon;
  final int? maneuverDistance;
  final AdditionalManeuverModel? additionalManeuver;

  const ManeuverModel({
    required this.maneuverDistance,
    required this.maneuverIcon,
    required this.roadName,
    required this.additionalManeuver,
  });

  ManeuverModel copyWith({
    int? Function()? maneuverDistance,
    ManeuverIcon? Function()? maneuverIcon,
    String? Function()? roadName,
    AdditionalManeuverModel? Function()? additionalManeuver,
  }) {
    return ManeuverModel(
      maneuverDistance: maneuverDistance != null
          ? maneuverDistance()
          : this.maneuverDistance,
      maneuverIcon: maneuverIcon != null ? maneuverIcon() : this.maneuverIcon,
      roadName: roadName != null ? roadName() : this.roadName,
      additionalManeuver: additionalManeuver != null
          ? additionalManeuver()
          : this.additionalManeuver,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ManeuverModel &&
        other.roadName == roadName &&
        other.maneuverIcon == maneuverIcon &&
        other.maneuverDistance == maneuverDistance &&
        other.additionalManeuver == additionalManeuver;
  }

  @override
  int get hashCode => Object.hash(
    roadName,
    maneuverIcon,
    maneuverDistance,
    additionalManeuver,
  );

  @override
  String toString() =>
      'ManeuverModel('
      'roadName: $roadName, '
      'maneuverIcon: $maneuverIcon, '
      'maneuverDistance: $maneuverDistance, '
      'additionalManeuver: $additionalManeuver'
      ')';
}

typedef ManeuverIcon = (String iconPath, bool shouldBeMirrored);

sealed class AdditionalManeuverModel {}

class ManeuverWithIcon extends AdditionalManeuverModel {
  ManeuverIcon? icon;

  ManeuverWithIcon({required this.icon});
}

class ExitName extends AdditionalManeuverModel {
  String exitName;

  ExitName({required this.exitName});
}

class ExitNumber extends AdditionalManeuverModel {
  int exitNumber;

  ExitNumber({required this.exitNumber});
}
