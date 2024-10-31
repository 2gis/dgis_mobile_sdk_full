import 'dart:async';
import 'dart:math';

import 'package:dgis_mobile_sdk_full/src/util/format_duration.dart';
import 'package:dgis_mobile_sdk_full/src/util/fromat_distance.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../generated/dart_bindings.dart' as sdk;
import '../../util/measure_size.dart';
import '../../util/no_overscroll_behavior.dart';
import '../../util/plugin_name.dart';
import '../map/map_widget_theme.dart';
import '../map/themed_map_controlling_widget.dart';

class DashboardWidget extends ThemedMapControllingWidget<DashboardWidgetTheme> {
  final sdk.NavigationManager navigationManager;

  const DashboardWidget({
    super.key,
    required this.navigationManager,
    DashboardWidgetTheme? light,
    DashboardWidgetTheme? dark,
  }) : super(
          light: light ?? DashboardWidgetTheme.defaultLight,
          dark: dark ?? DashboardWidgetTheme.defaultDark,
        );

  @override
  ThemedMapControllingWidgetState<DashboardWidget, DashboardWidgetTheme> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends ThemedMapControllingWidgetState<DashboardWidget, DashboardWidgetTheme>
    with SingleTickerProviderStateMixin {
  late StreamSubscription<sdk.RoutePoint?> _routePositionSubscription;

  late final DraggableScrollableController _sheetController;
  final ValueNotifier<double> _headerScaleSize = ValueNotifier(0);

  final _dateFormat = DateFormat("HH:mm");

  double _maxExtent = .36;
  int _dashboardSize = 0;
  double _headerSize = 60;
  final double _minExtent = .1;

  sdk.Map? map;

  final ValueNotifier<DashboardModel> _dashboardModel = ValueNotifier(
    DashboardModel(
      distance: 0,
      duration: Duration.zero,
      soundsEnabled: true,
    ),
  );

  @override
  void initState() {
    _sheetController = DraggableScrollableController();
    _sheetController.addListener(() {
      _headerScaleSize.value = (_sheetController.size - _minExtent) * (1 / (_maxExtent - _minExtent));
    });

    super.initState();
  }

  @override
  void onAttachedToMap(sdk.Map map) {
    _routePositionSubscription = widget.navigationManager.uiModel.routePositionChannel.listen((position) {
      final duration = widget.navigationManager.uiModel.duration();
      final distance = widget.navigationManager.uiModel.distance();

      _dashboardModel.value = _dashboardModel.value.copyWith(
        distance: distance,
        duration: duration,
      );
    });
    this.map = map;
  }

  @override
  void onDetachedFromMap() {
    _routePositionSubscription.cancel();
    map = null;
  }

  bool _soundsEnabled() {
    final categories = widget.navigationManager.soundNotificationSettings.enabledSoundCategories;

    return categories.contains(sdk.SoundCategory.instructions);
  }

  void _toggleSounds() {
    final categories = widget.navigationManager.soundNotificationSettings.enabledSoundCategories;
    print(categories);

    if (_soundsEnabled()) {
      categories.remove(sdk.SoundCategory.instructions);
    } else {
      categories.add(sdk.SoundCategory.instructions);
    }
    widget.navigationManager.soundNotificationSettings.enabledSoundCategories = categories;

    _dashboardModel.value = _dashboardModel.value.copyWith(
      soundsEnabled: _soundsEnabled(),
    );
  }

  Future<void> _showRoute() async {
    if (map == null) {
      return;
    }

    final geometries = widget.navigationManager.uiModel.route.route.geometry.entries.map((entry) {
      return sdk.PointGeometry(entry.value);
    }).toList();
    final geometry = sdk.ComplexGeometry(geometries);

    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    final cameraPosition = sdk.calcPositionForGeometry(
      map!.camera,
      geometry,
      null,
      sdk.Padding(
        top: (32 * devicePixelRatio).round(),
        bottom: ((_dashboardSize + 32) * devicePixelRatio).round(),
        left: (32 * devicePixelRatio).round(),
        right: (32 * devicePixelRatio).round(),
      ),
      null,
      null,
      null,
    );

    await map!.camera.moveToCameraPosition(cameraPosition).value;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return DraggableScrollableSheet(
          controller: _sheetController,
          snap: true,
          initialChildSize: _minExtent,
          minChildSize: _minExtent,
          maxChildSize: _maxExtent,
          snapSizes: [_minExtent, _maxExtent],
          builder: (context, scrollController) {
            return ScrollConfiguration(
              behavior: NoOverscrollBehavior(),
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const ClampingScrollPhysics(),
                controller: scrollController,
                shrinkWrap: true,
                children: [
                  MeasureSize(
                    onChange: (size) {
                      setState(() {
                        _headerSize = size.height;
                      });
                    },
                    child: Center(
                      child: ValueListenableBuilder(
                        valueListenable: _headerScaleSize,
                        builder: (context, headerScaleSize, child) {
                          return Container(
                            width: min(
                              MediaQuery.of(context).size.width,
                              MediaQuery.of(context).size.width * (.8 + headerScaleSize),
                            ),
                            decoration: BoxDecoration(
                              color: theme.surfaceColor,
                              boxShadow: theme.shadows,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(theme.borderRadius),
                                bottom: Radius.circular(theme.borderRadius * (1 - headerScaleSize)),
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 10,
                            ),
                            child: ValueListenableBuilder(
                              valueListenable: _dashboardModel,
                              builder: (context, value, child) {
                                final distance = formatMeters(value.distance);
                                final arrivalTime = DateTime.now().add(value.duration);

                                return Row(
                                  children: [
                                    SizedBox(
                                      width: theme.buttonSize,
                                      height: theme.buttonSize,
                                    ),
                                    Spacer(),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          formatDuration(value.duration),
                                          style: theme.durationTextStyle,
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "${distance.value}${distance.unit}",
                                              style: theme.distanceArrivalTextStyle,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Container(
                                                width: 4,
                                                height: 4,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: theme.distanceArrivalTextStyle.color!,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              _dateFormat.format(arrivalTime),
                                              style: theme.distanceArrivalTextStyle,
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    Spacer(),
                                    GestureDetector(
                                      onTap: () {
                                        if (_sheetController.size >= _maxExtent) {
                                          _sheetController.animateTo(
                                            _minExtent,
                                            duration: Durations.short3,
                                            curve: Curves.linear,
                                          );
                                        } else {
                                          _sheetController.animateTo(
                                            _maxExtent,
                                            duration: Durations.short3,
                                            curve: Curves.linear,
                                          );
                                        }
                                      },
                                      child: Container(
                                        width: theme.buttonSize,
                                        height: theme.buttonSize,
                                        decoration: BoxDecoration(
                                          color: theme.buttonSurfaceColor,
                                          borderRadius: BorderRadius.circular(theme.buttonBorderRadius),
                                        ),
                                        child: SvgPicture.asset(
                                          'packages/$pluginName/assets/icons/dgis_menu.svg',
                                          fit: BoxFit.none,
                                          width: 24,
                                          height: 24,
                                          colorFilter: ColorFilter.mode(
                                            theme.iconColor,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  MeasureSize(
                    onChange: (size) {
                      setState(() {
                        _dashboardSize = size.height.round();
                        _maxExtent = (size.height + _headerSize) / constraints.maxHeight;
                      });
                    },
                    child: ValueListenableBuilder(
                      valueListenable: _headerScaleSize,
                      builder: (context, headerScaleSize, child) {
                        return Opacity(
                          opacity: headerScaleSize,
                          child: Container(
                            color: theme.surfaceColor,
                            child: Column(
                              children: [
                                Divider(
                                  color: theme.buttonSurfaceColor,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: ValueListenableBuilder(
                                      valueListenable: _dashboardModel,
                                      builder: (context, value, child) {
                                        return GestureDetector(
                                          onTap: _toggleSounds,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: theme.buttonSurfaceColor,
                                              borderRadius: BorderRadius.circular(
                                                theme.buttonBorderRadius,
                                              ),
                                            ),
                                            padding: const EdgeInsets.all(12),
                                            child: Row(
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Настройки звука',
                                                      style: theme.menuButtonTextStyle,
                                                    ),
                                                    Text(
                                                      value.soundsEnabled ? 'Маневры включены' : 'Маневры выключены',
                                                      style: theme.menuButtonSubTextStyle,
                                                    ),
                                                  ],
                                                ),
                                                const Spacer(),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: value.soundsEnabled
                                                        ? theme.buttonPositiveSurfaceColor
                                                        : theme.buttonNegativeSurfaceColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  padding: EdgeInsets.all(6),
                                                  child: SvgPicture.asset(
                                                    'packages/$pluginName/assets/icons/dgis_sound.svg',
                                                    fit: BoxFit.none,
                                                    width: 24,
                                                    height: 24,
                                                    colorFilter: ColorFilter.mode(
                                                      Color(0xffffffff),
                                                      BlendMode.srcIn,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: GestureDetector(
                                    onTap: _showRoute,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: theme.buttonSurfaceColor,
                                        borderRadius: BorderRadius.circular(theme.buttonBorderRadius),
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            'packages/$pluginName/assets/icons/dgis_route.svg',
                                            fit: BoxFit.none,
                                            width: 24,
                                            height: 24,
                                            colorFilter: ColorFilter.mode(
                                              theme.iconColor,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 12,
                                          ),
                                          Text(
                                            'Просмотр Маршрута',
                                            style: theme.menuButtonTextStyle,
                                          ),
                                          Spacer(),
                                          SvgPicture.asset(
                                            'packages/$pluginName/assets/icons/dgis_chevron.svg',
                                            fit: BoxFit.none,
                                            width: 24,
                                            height: 24,
                                            colorFilter: ColorFilter.mode(
                                              theme.iconColor,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: widget.navigationManager.stop,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: theme.buttonNegativeSurfaceColor,
                                        borderRadius: BorderRadius.circular(theme.buttonBorderRadius),
                                      ),
                                      padding: const EdgeInsets.all(14.0),
                                      child: Center(
                                        child: Text(
                                          'Завершить поездку',
                                          style: theme.finishButtonTextStyle,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 40,
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class DashboardModel {
  final int distance;
  final Duration duration;
  final bool soundsEnabled;

  DashboardModel({
    required this.distance,
    required this.duration,
    required this.soundsEnabled,
  });

  DashboardModel copyWith({
    int? distance,
    Duration? duration,
    bool? soundsEnabled,
  }) {
    return DashboardModel(
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      soundsEnabled: soundsEnabled ?? this.soundsEnabled,
    );
  }
}

class DashboardWidgetTheme extends MapWidgetTheme {
  final TextStyle durationTextStyle;
  final TextStyle distanceArrivalTextStyle;

  final Color surfaceColor;
  final List<BoxShadow> shadows;
  final double borderRadius;

  final Color buttonSurfaceColor;
  final Color buttonNegativeSurfaceColor;
  final Color buttonPositiveSurfaceColor;
  final double buttonBorderRadius;
  final double buttonSize;
  final Color iconColor;
  final double iconSize;

  final TextStyle menuButtonTextStyle;
  final TextStyle menuButtonSubTextStyle;
  final TextStyle finishButtonTextStyle;

  const DashboardWidgetTheme({
    required this.shadows,
    required this.surfaceColor,
    required this.borderRadius,
    required this.durationTextStyle,
    required this.distanceArrivalTextStyle,
    required this.buttonSurfaceColor,
    required this.buttonNegativeSurfaceColor,
    required this.buttonPositiveSurfaceColor,
    required this.buttonBorderRadius,
    required this.buttonSize,
    required this.iconColor,
    required this.iconSize,
    required this.menuButtonTextStyle,
    required this.menuButtonSubTextStyle,
    required this.finishButtonTextStyle,
  });

  /// Цветовая схема виджета для светлого режима по умолчанию.
  static const defaultLight = DashboardWidgetTheme(
    borderRadius: 16,
    surfaceColor: Color(0xffffffff),
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
    durationTextStyle: TextStyle(
      color: Color(0xff141414),
      fontWeight: FontWeight.w600,
      fontSize: 18,
      height: 1.22,
    ),
    distanceArrivalTextStyle: TextStyle(
      color: Color(0xff141414),
      fontWeight: FontWeight.w500,
      fontSize: 16,
      height: 1.25,
    ),
    buttonSurfaceColor: Color(0x0F141414),
    buttonNegativeSurfaceColor: Color(0xFFE81C21),
    buttonPositiveSurfaceColor: Color(0xFF1DB93C),
    buttonBorderRadius: 8,
    buttonSize: 36,
    iconColor: Color(0xFF3C3C3C),
    iconSize: 24,
    menuButtonTextStyle: TextStyle(
      color: Color(0xff141414),
      fontWeight: FontWeight.w500,
      fontSize: 16,
      height: 1.25,
    ),
    menuButtonSubTextStyle: TextStyle(
      color: Color(0xff898989),
      fontWeight: FontWeight.w500,
      fontSize: 14,
      height: 1.3,
    ),
    finishButtonTextStyle: TextStyle(
      color: Color(0xffffffff),
      fontWeight: FontWeight.w600,
      fontSize: 16,
      height: 1.25,
    ),
  );

  /// Цветовая схема виджета для темного режима по умолчанию.
  static const defaultDark = DashboardWidgetTheme(
    borderRadius: 16,
    surfaceColor: Color(0xff121212),
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
    durationTextStyle: TextStyle(
      color: Color(0xFFFFFFFF),
      fontWeight: FontWeight.w600,
      fontSize: 18,
      height: 1.22,
    ),
    distanceArrivalTextStyle: TextStyle(
      color: Color(0xFFFFFFFF),
      fontWeight: FontWeight.w500,
      fontSize: 16,
      height: 1.25,
    ),
    buttonSurfaceColor: Color(0x0FFFFFFF),
    buttonNegativeSurfaceColor: Color(0xFFE81C21),
    buttonPositiveSurfaceColor: Color(0xFF1DB93C),
    buttonBorderRadius: 8,
    buttonSize: 36,
    iconColor: Color(0xFFB8B8B8),
    iconSize: 24,
    menuButtonTextStyle: TextStyle(
      color: Color(0xffffffff),
      fontWeight: FontWeight.w500,
      fontSize: 16,
      height: 1.25,
    ),
    menuButtonSubTextStyle: TextStyle(
      color: Color(0xff898989),
      fontWeight: FontWeight.w500,
      fontSize: 14,
      height: 1.3,
    ),
    finishButtonTextStyle: TextStyle(
      color: Color(0xffffffff),
      fontWeight: FontWeight.w600,
      fontSize: 16,
      height: 1.25,
    ),
  );

  @override
  DashboardWidgetTheme copyWith({
    double? borderRadius,
    Color? surfaceColor,
    List<BoxShadow>? shadows,
    TextStyle? durationTextStyle,
    TextStyle? distanceArrivalTextStyle,
    Color? buttonSurfaceColor,
    Color? buttonNegativeSurfaceColor,
    Color? buttonPositiveSurfaceColor,
    double? buttonBorderRadius,
    double? buttonSize,
    Color? iconColor,
    double? iconSize,
    TextStyle? menuButtonTextStyle,
    TextStyle? menuButtonSubTextStyle,
    TextStyle? finishButtonTextStyle,
  }) {
    return DashboardWidgetTheme(
      borderRadius: borderRadius ?? this.borderRadius,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      shadows: shadows ?? this.shadows,
      durationTextStyle: durationTextStyle ?? this.durationTextStyle,
      distanceArrivalTextStyle: distanceArrivalTextStyle ?? this.distanceArrivalTextStyle,
      buttonSurfaceColor: buttonSurfaceColor ?? this.buttonSurfaceColor,
      buttonNegativeSurfaceColor: buttonNegativeSurfaceColor ?? this.buttonNegativeSurfaceColor,
      buttonPositiveSurfaceColor: buttonPositiveSurfaceColor ?? this.buttonPositiveSurfaceColor,
      buttonBorderRadius: buttonBorderRadius ?? this.buttonBorderRadius,
      buttonSize: buttonSize ?? this.buttonSize,
      iconColor: iconColor ?? this.iconColor,
      iconSize: iconSize ?? this.iconSize,
      menuButtonTextStyle: menuButtonTextStyle ?? this.menuButtonTextStyle,
      menuButtonSubTextStyle: menuButtonSubTextStyle ?? this.menuButtonSubTextStyle,
      finishButtonTextStyle: finishButtonTextStyle ?? this.finishButtonTextStyle,
    );
  }
}

/// TODO: Удалить после фикса SDK
extension ModelDistanceDuration on sdk.Model {
  int? distance() {
    final routeDistance = this.route.route.geometry.length.millimeters;
    final currentDistance = this.routePosition?.distance.millimeters;

    if (currentDistance == null) {
      return null;
    }

    return routeDistance - currentDistance;
  }

  Duration? duration() {
    final routePosition = this.routePosition;
    final endPosition = this.route.route.geometry.last?.point;

    if (routePosition == null || endPosition == null) {
      return null;
    }

    final duration = this.dynamicRouteInfo.traffic.durations.calculateDuration(routePosition, endPosition);

    return duration;
  }
}
