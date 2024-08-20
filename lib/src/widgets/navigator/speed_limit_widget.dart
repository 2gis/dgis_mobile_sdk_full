import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../generated/dart_bindings.dart' as sdk;
import '../../generated/optional.dart';
import '../../util/plugin_name.dart';
import '../map/map_widget_theme.dart';
import '../map/themed_map_controlling_widget.dart';

class SpeedLimitWidget extends ThemedMapControllingWidget<SpeedLimitWidgetTheme> {
  final sdk.NavigationManager navigationManager;

  const SpeedLimitWidget({
    super.key,
    required this.navigationManager,
    SpeedLimitWidgetTheme? light,
    SpeedLimitWidgetTheme? dark,
  }) : super(
          light: light ?? SpeedLimitWidgetTheme.defaultLight,
          dark: dark ?? SpeedLimitWidgetTheme.defaultDark,
        );

  @override
  ThemedMapControllingWidgetState<SpeedLimitWidget, SpeedLimitWidgetTheme> createState() => _SpeedLimitWidgetState();
}

class _SpeedLimitWidgetState extends ThemedMapControllingWidgetState<SpeedLimitWidget, SpeedLimitWidgetTheme> {
  final ValueNotifier<SpeedLimitModel> _speedLimitModel = ValueNotifier(
    SpeedLimitModel(
      location: null,
      speedLimit: null,
      exceeding: false,
      cameraProgressInfo: null,
    ),
  );

  late sdk.CameraNotifier _cameraNotifier;
  sdk.FloatRouteLongAttribute? _speedLimits;

  late StreamSubscription<sdk.Location?> _locationSubscription;
  late StreamSubscription<sdk.RouteInfo> _routeSubscription;
  late StreamSubscription<sdk.RoutePoint?> _routePositionSubscription;
  late StreamSubscription<bool> _exceedingMaxSpeedLimitSubscription;
  late StreamSubscription<sdk.CameraProgressInfo?> _cameraProgressSubscription;

  @override
  void onAttachedToMap(sdk.Map map) {
    _locationSubscription = widget.navigationManager.uiModel.locationChannel.listen((location) {
      _speedLimitModel.value = _speedLimitModel.value.copyWith(
        location: Optional(location),
      );
    });
    _routeSubscription = widget.navigationManager.uiModel.routeChannel.listen((route) {
      _speedLimits = route.route.maxSpeedLimits;
    });
    _routePositionSubscription = widget.navigationManager.uiModel.routePositionChannel.listen((position) {
      if (position == null || _speedLimits == null) {
        return;
      }

      final entry = _speedLimits!.entry(position);
      _speedLimitModel.value = _speedLimitModel.value.copyWith(
        speedLimit: Optional(
          entry?.value,
        ),
      );
    });
    _exceedingMaxSpeedLimitSubscription =
        widget.navigationManager.uiModel.exceedingMaxSpeedLimitChannel.listen((exceeding) {
      _speedLimitModel.value = _speedLimitModel.value.copyWith(
        exceeding: exceeding,
      );
    });
    _cameraNotifier = sdk.CameraNotifier(widget.navigationManager.uiModel);
    _cameraProgressSubscription = _cameraNotifier.cameraProgressChannel.listen((cameraProgressInfo) {
      _speedLimitModel.value = _speedLimitModel.value.copyWith(
        cameraProgressInfo: Optional(cameraProgressInfo),
      );
    });
  }

  @override
  void onDetachedFromMap() {
    _locationSubscription.cancel();
    _routeSubscription.cancel();
    _routePositionSubscription.cancel();
    _exceedingMaxSpeedLimitSubscription.cancel();
    _cameraProgressSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _speedLimitModel,
      builder: (context, value, child) {
        final cameraIcon = value.cameraIcon();

        return Material(
          color: Colors.transparent,
          child: SizedBox(
            width: theme.size,
            height: theme.size,
            child: Stack(
              children: [
                /// speed
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: SizedBox(
                    width: theme.speedometerTheme.size,
                    height: theme.speedometerTheme.size,
                    child: OverflowBox(
                      alignment: Alignment.topCenter,
                      maxHeight: theme.speedometerTheme.size + theme.speedometerTheme.iconSize,
                      child: Stack(
                        children: [
                          SizedBox(
                            width: theme.speedometerTheme.size,
                            height: theme.speedometerTheme.size,
                            child: DecoratedBox(
                              decoration: ShapeDecoration(
                                shape: CircleBorder(
                                  side: value.cameraProgressInfo != null
                                      ? BorderSide(
                                          width: theme.cameraProgressTheme.thickness,
                                          color: theme.cameraProgressTheme.progressColor,
                                          strokeAlign: BorderSide.strokeAlignCenter,
                                        )
                                      : BorderSide.none,
                                ),
                                color: theme.speedometerTheme.surfaceColor,
                                shadows: theme.speedometerTheme.shadows,
                              ),
                              child: Center(
                                child: Baseline(
                                  baselineType: TextBaseline.alphabetic,
                                  baseline: theme.speedometerTheme.textStyle.fontSize!,
                                  child: Text(
                                    '${(value.location?.groundSpeed?.value ?? 0).floor()}',
                                    style: theme.speedometerTheme.textStyle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (value.cameraProgressInfo != null && cameraIcon != null)
                            SizedBox(
                              width: theme.speedometerTheme.size,
                              height: theme.speedometerTheme.size,
                              child: CircularProgressIndicator(
                                color: value.exceeding
                                    ? theme.cameraProgressTheme.progressExceededColor
                                    : theme.cameraProgressTheme.progressColor,
                                value: value.cameraProgressInfo!.progress,
                              ),
                            ),
                          if (cameraIcon != null)
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: SvgPicture.asset(
                                cameraIcon,
                                fit: BoxFit.none,
                                width: theme.speedometerTheme.iconSize,
                                height: theme.speedometerTheme.iconSize * 2,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 0,
                  right: 0,
                  child: SizedBox(
                    width: theme.speedLimitTheme.size,
                    height: theme.speedLimitTheme.size,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.speedLimitTheme.exceededSurfaceColor,
                          width: theme.speedLimitTheme.borderWidth,
                        ),
                        boxShadow: value.exceeding ? theme.speedLimitTheme.exceededShadows : null,
                        color: value.exceeding
                            ? theme.speedLimitTheme.exceededSurfaceColor
                            : theme.speedLimitTheme.surfaceColor,
                      ),
                      child: Center(
                        child: Text(
                          "${value.speedLimit != null ? (value.speedLimit! * 3.6).round() : '--'}",
                          style: theme.speedLimitTheme.textStyle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SpeedLimitModel {
  final sdk.Location? location;
  final double? speedLimit;
  final bool exceeding;
  final sdk.CameraProgressInfo? cameraProgressInfo;

  SpeedLimitModel({
    required this.location,
    required this.speedLimit,
    required this.exceeding,
    required this.cameraProgressInfo,
  });

  SpeedLimitModel copyWith({
    Optional<sdk.Location?>? location,
    Optional<double?>? speedLimit,
    Optional<sdk.CameraProgressInfo?>? cameraProgressInfo,
    bool? exceeding,
  }) {
    return SpeedLimitModel(
      location: location != null ? location.value : this.location,
      speedLimit: speedLimit != null ? speedLimit.value : this.speedLimit,
      exceeding: exceeding ?? this.exceeding,
      cameraProgressInfo: cameraProgressInfo != null ? cameraProgressInfo.value : this.cameraProgressInfo,
    );
  }

  String? cameraIcon() {
    if (this.cameraProgressInfo == null) {
      return null;
    }
    final purposes = this.cameraProgressInfo!.camera.purposes;

    if (purposes.contains(sdk.RouteCameraPurpose.noStoppingControl)) {
      return 'packages/$pluginName/assets/icons/dgis_camera_stop.svg';
    } else if (purposes.contains(sdk.RouteCameraPurpose.speedControl) ||
        purposes.contains(sdk.RouteCameraPurpose.averageSpeedControl)) {
      return switch (this.cameraProgressInfo!.camera.direction) {
        sdk.RouteCameraDirection.against => 'packages/$pluginName/assets/icons/dgis_camera_back.svg',
        sdk.RouteCameraDirection.along => 'packages/$pluginName/assets/icons/dgis_camera_front.svg',
        sdk.RouteCameraDirection.both => 'packages/$pluginName/assets/icons/dgis_camera_both.svg',
      };
    }

    return null;
  }
}

class CameraProgressTheme extends MapWidgetTheme {
  final Color surfaceColor;
  final Color progressColor;
  final Color progressExceededColor;
  final double thickness;

  const CameraProgressTheme({
    required this.surfaceColor,
    required this.progressColor,
    required this.progressExceededColor,
    required this.thickness,
  });

  /// Цветовая схема виджета для светлого режима по умолчанию.
  static const defaultLight = CameraProgressTheme(
    surfaceColor: Color(0xFFB8B8B8),
    progressColor: Color(0x80141414),
    progressExceededColor: Color(0xFFE91C21),
    thickness: 4,
  );

  /// Цветовая схема виджета для темного режима по умолчанию.
  static const defaultDark = CameraProgressTheme(
    surfaceColor: Color(0xff5A5A5A),
    progressColor: Color(0xffC4C4C4),
    progressExceededColor: Color(0xffE91C21),
    thickness: 4,
  );

  @override
  CameraProgressTheme copyWith({
    Color? surfaceColor,
    Color? progressColor,
    Color? progressExceededColor,
    double? thickness,
  }) {
    return CameraProgressTheme(
      surfaceColor: surfaceColor ?? this.surfaceColor,
      progressColor: progressColor ?? this.progressColor,
      progressExceededColor: progressExceededColor ?? this.progressExceededColor,
      thickness: thickness ?? this.thickness,
    );
  }
}

class SpeedometerTheme extends MapWidgetTheme {
  final double size;
  final double iconSize;

  final Color surfaceColor;
  final TextStyle textStyle;
  final List<BoxShadow> shadows;

  const SpeedometerTheme({
    required this.size,
    required this.iconSize,
    required this.textStyle,
    required this.shadows,
    required this.surfaceColor,
  });

  /// Цветовая схема виджета для светлого режима по умолчанию.
  static const defaultLight = SpeedometerTheme(
    surfaceColor: Color(0xffffffff),
    size: 64,
    iconSize: 28,
    textStyle: TextStyle(
      height: 1.14,
      color: Color(0xff141414),
      fontWeight: FontWeight.w600,
      fontSize: 28,
    ),
    shadows: [
      BoxShadow(
        color: Color(0x12000000),
        blurRadius: 1,
      ),
      BoxShadow(
        color: Color(0x0D000000),
        offset: Offset(0, 2),
        blurRadius: 4,
      ),
    ],
  );

  /// Цветовая схема виджета для темного режима по умолчанию.
  static const defaultDark = SpeedometerTheme(
    surfaceColor: Color(0xff121212),
    size: 64,
    iconSize: 28,
    textStyle: TextStyle(
      height: 1.14,
      color: Color(0xffffffff),
      fontWeight: FontWeight.w600,
      fontSize: 28,
    ),
    shadows: [
      BoxShadow(
        color: Color(0x14000000),
        offset: Offset(0, 1),
        blurRadius: 4,
      ),
      BoxShadow(
        color: Color(0x0A000000),
        spreadRadius: 0.5,
      ),
    ],
  );

  @override
  SpeedometerTheme copyWith({
    double? size,
    double? iconSize,
    Color? surfaceColor,
    TextStyle? textStyle,
    List<BoxShadow>? shadows,
  }) {
    return SpeedometerTheme(
      surfaceColor: surfaceColor ?? this.surfaceColor,
      size: size ?? this.size,
      iconSize: iconSize ?? this.iconSize,
      textStyle: textStyle ?? this.textStyle,
      shadows: shadows ?? this.shadows,
    );
  }
}

class SpeedLimitTheme extends MapWidgetTheme {
  final double size;
  final TextStyle textStyle;

  final Color surfaceColor;
  final Color exceededSurfaceColor;
  final TextStyle exceededTextStyle;
  final List<BoxShadow> exceededShadows;

  final double borderWidth;

  const SpeedLimitTheme({
    required this.size,
    required this.borderWidth,
    required this.surfaceColor,
    required this.textStyle,
    required this.exceededTextStyle,
    required this.exceededSurfaceColor,
    required this.exceededShadows,
  });

  /// Цветовая схема виджета для светлого режима по умолчанию.
  static const defaultLight = SpeedLimitTheme(
    size: 48,
    borderWidth: 4,
    surfaceColor: Color(0xffffffff),
    textStyle: TextStyle(
      height: 1.16,
      color: Color(0xff141414),
      fontWeight: FontWeight.w600,
      fontSize: 24,
    ),
    exceededTextStyle: TextStyle(
      height: 1.16,
      color: Color(0xffffffff),
      fontWeight: FontWeight.w600,
      fontSize: 24,
    ),
    exceededSurfaceColor: Color(0xffE91C21),
    exceededShadows: [
      BoxShadow(
        color: Color(0xffE91C21),
        blurRadius: 1,
      ),
      BoxShadow(
        color: Color(0xffE91C21),
        offset: Offset(0, 0),
        blurRadius: 4,
      ),
    ],
  );

  /// Цветовая схема виджета для темного режима по умолчанию.
  static const defaultDark = SpeedLimitTheme(
    surfaceColor: Color(0xff121212),
    exceededSurfaceColor: Color(0xffE91C21),
    borderWidth: 4,
    size: 48,
    exceededTextStyle: TextStyle(
      height: 1.16,
      color: Color(0xffffffff),
      fontWeight: FontWeight.w600,
      fontSize: 24,
    ),
    textStyle: TextStyle(
      height: 1.16,
      color: Color(0xffffffff),
      fontWeight: FontWeight.w600,
      fontSize: 24,
    ),
    exceededShadows: [
      BoxShadow(
        color: Color(0xffE91C21),
        blurRadius: 1,
      ),
      BoxShadow(
        color: Color(0xffE91C21),
        offset: Offset(0, 0),
        blurRadius: 4,
      ),
    ],
  );

  @override
  SpeedLimitTheme copyWith({
    double? size,
    double? borderWidth,
    Color? surfaceColor,
    TextStyle? textStyle,
    TextStyle? exceededTextStyle,
    Color? exceededSurfaceColor,
    List<BoxShadow>? exceededShadows,
  }) {
    return SpeedLimitTheme(
      size: size ?? this.size,
      textStyle: textStyle ?? this.textStyle,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      borderWidth: borderWidth ?? this.borderWidth,
      exceededTextStyle: exceededTextStyle ?? this.exceededTextStyle,
      exceededSurfaceColor: exceededSurfaceColor ?? this.exceededSurfaceColor,
      exceededShadows: exceededShadows ?? this.exceededShadows,
    );
  }
}

class SpeedLimitWidgetTheme extends MapWidgetTheme {
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

  /// Цветовая схема виджета для светлого режима по умолчанию.
  static const defaultLight = SpeedLimitWidgetTheme(
    size: 94,
    speedometerTheme: SpeedometerTheme.defaultLight,
    speedLimitTheme: SpeedLimitTheme.defaultLight,
    cameraProgressTheme: CameraProgressTheme.defaultLight,
  );

  /// Цветовая схема виджета для темного режима по умолчанию.
  static const defaultDark = SpeedLimitWidgetTheme(
    size: 94,
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
      size: widgetSize ?? this.size,
      speedometerTheme: speedometerTheme ?? this.speedometerTheme,
      speedLimitTheme: speedLimitTheme ?? this.speedLimitTheme,
      cameraProgressTheme: cameraProgressTheme ?? this.cameraProgressTheme,
    );
  }
}
