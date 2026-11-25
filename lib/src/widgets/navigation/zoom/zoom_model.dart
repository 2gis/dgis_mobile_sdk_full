import 'package:flutter/foundation.dart';

@immutable
class ZoomModel {
  final bool zoomInEnabled;
  final bool zoomOutEnabled;

  const ZoomModel({required this.zoomInEnabled, required this.zoomOutEnabled});

  ZoomModel copyWith({
    bool? zoomInEnabled,
    bool? zoomOutEnabled,
  }) {
    return ZoomModel(
      zoomInEnabled: zoomInEnabled ?? this.zoomInEnabled,
      zoomOutEnabled: zoomOutEnabled ?? this.zoomOutEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ZoomModel &&
        other.zoomInEnabled == zoomInEnabled &&
        other.zoomOutEnabled == zoomOutEnabled;
  }

  @override
  int get hashCode => Object.hash(zoomInEnabled, zoomOutEnabled);

  @override
  String toString() =>
      'ZoomModel('
      'zoomInEnabled: $zoomInEnabled, '
      'zoomOutEnabled: $zoomOutEnabled'
      ')';
}
