import 'package:flutter/foundation.dart';
import '../../../generated/dart_bindings.dart' as sdk;

@immutable
class MyLocationModel {
  final bool isActive;
  final bool isHideable;
  final sdk.CameraBehaviour behaviour;
  final String iconAssetName;

  const MyLocationModel({
    required this.isActive,
    required this.behaviour,
    required this.isHideable,
    required this.iconAssetName,
  });

  MyLocationModel copyWith({
    bool? isActive,
    bool? isHideable,
    sdk.CameraBehaviour? behaviour,
    String? iconAssetName,
  }) {
    return MyLocationModel(
      isActive: isActive ?? this.isActive,
      isHideable: isHideable ?? this.isHideable,
      behaviour: behaviour ?? this.behaviour,
      iconAssetName: iconAssetName ?? this.iconAssetName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MyLocationModel &&
        other.isActive == isActive &&
        other.isHideable == isHideable &&
        other.behaviour == behaviour &&
        other.iconAssetName == iconAssetName;
  }

  @override
  int get hashCode => Object.hash(
        isActive,
        isHideable,
        behaviour,
        iconAssetName,
      );

  @override
  String toString() => 'MyLocationModel('
      'isActive: $isActive, '
      'isHideable: $isHideable, '
      'behaviour: $behaviour, '
      'iconAssetName: $iconAssetName'
      ')';
}
