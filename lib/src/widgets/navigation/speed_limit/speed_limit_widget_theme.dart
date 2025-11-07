import '../../map/map_widget_color_scheme.dart';
import './camera_progress_theme.dart';
import './speed_limit_theme.dart';
import './speedometer_theme.dart';

class SpeedLimitWidgetTheme extends MapWidgetColorScheme {
  final double size;

  final SpeedometerTheme speedometerTheme;
  final SpeedLimitTheme speedLimitTheme;
  final CameraProgressTheme cameraProgressTheme;

  const SpeedLimitWidgetTheme({
    required this.size,
    required this.speedometerTheme,
    required this.speedLimitTheme,
    required this.cameraProgressTheme,
  });

  /// Widget color scheme for default light mode.
  static const defaultLight = SpeedLimitWidgetTheme(
    size: 92,
    speedometerTheme: SpeedometerTheme.defaultLight,
    speedLimitTheme: SpeedLimitTheme.defaultLight,
    cameraProgressTheme: CameraProgressTheme.defaultLight,
  );

  /// Widget color scheme for default dark mode.
  static const defaultDark = SpeedLimitWidgetTheme(
    size: 92,
    speedometerTheme: SpeedometerTheme.defaultDark,
    speedLimitTheme: SpeedLimitTheme.defaultDark,
    cameraProgressTheme: CameraProgressTheme.defaultDark,
  );

  @override
  SpeedLimitWidgetTheme copyWith({
    double? widgetSize,
    SpeedometerTheme? speedometerTheme,
    SpeedLimitTheme? speedLimitTheme,
    CameraProgressTheme? cameraProgressTheme,
  }) {
    return SpeedLimitWidgetTheme(
      size: widgetSize ?? size,
      speedometerTheme: speedometerTheme ?? this.speedometerTheme,
      speedLimitTheme: speedLimitTheme ?? this.speedLimitTheme,
      cameraProgressTheme: cameraProgressTheme ?? this.cameraProgressTheme,
    );
  }
}
