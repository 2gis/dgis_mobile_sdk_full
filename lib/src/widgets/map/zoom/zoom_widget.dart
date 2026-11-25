import 'dart:async';
import 'package:flutter/material.dart';
import '../../../generated/dart_bindings.dart' as sdk;
import '../../../platform/bss_events_source.dart';
import '../../../util/plugin_name.dart';
import '../../widget_shadows.dart';
import '../map_widget_color_scheme.dart';
import '../themed_map_controlling_widget.dart';
import '../themed_map_controlling_widget_state.dart';
import 'zoom_button_widget.dart';

/// Виджет карты, предоставляющий элементы для управления зумом (modern-версия).
/// Может использоваться только как child в MapWidget на любом уровне вложенности.
class ZoomWidget extends ThemedMapControllingWidget<ZoomWidgetColorScheme> {
  const ZoomWidget({
    super.key,
    ZoomWidgetColorScheme? light,
    ZoomWidgetColorScheme? dark,
  }) : super(
         light: light ?? defaultLightColorScheme,
         dark: dark ?? defaultDarkColorScheme,
       );

  @override
  ThemedMapControllingWidgetState<ZoomWidget, ZoomWidgetColorScheme>
  createState() => _ZoomWidgetState();

  /// Default color scheme of the UI element for light mode.
  static const ZoomWidgetColorScheme defaultLightColorScheme =
      ZoomWidgetColorScheme(
        backgroundColor: Color(0xFFFFFFFF),
        pressedBackgroundColor: Color(0xFFEEEEEE),
        activeIconColor: Color(0xFF141414),
        inactiveIconColor: Color(0xFFB8B8B8),
      );

  /// Default color scheme of the UI element for dark mode.
  static const ZoomWidgetColorScheme defaultDarkColorScheme =
      ZoomWidgetColorScheme(
        backgroundColor: Color(0xFF141414),
        pressedBackgroundColor: Color(0xFF3C3C3C),
        activeIconColor: Color(0xFFFFFFFF),
        inactiveIconColor: Color(0xFF5A5A5A),
      );
}

class _ZoomWidgetState
    extends ThemedMapControllingWidgetState<ZoomWidget, ZoomWidgetColorScheme> {
  final ValueNotifier<bool> isZoomInEnabled = ValueNotifier(false);
  final ValueNotifier<bool> isZoomOutEnabled = ValueNotifier(false);

  StreamSubscription<bool>? zoomInSubscription;
  StreamSubscription<bool>? zoomOutSubscription;
  late sdk.ZoomControlModel model;

  @override
  void onAttachedToMap(sdk.Map map) {
    model = withBssEventsSourceFromSdk(() => sdk.ZoomControlModel(map));

    zoomInSubscription = model
        .isEnabled(sdk.ZoomControlButton.zoomIn)
        .listen(
          (isEnabled) => isZoomInEnabled.value = isEnabled,
        );
    zoomOutSubscription = model
        .isEnabled(sdk.ZoomControlButton.zoomOut)
        .listen(
          (isEnabled) => isZoomOutEnabled.value = isEnabled,
        );
  }

  @override
  void onDetachedFromMap() {
    zoomInSubscription?.cancel();
    zoomOutSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 88,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: WidgetShadows.modernMapWidgetBoxShadows,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: isZoomInEnabled,
            builder: (_, isEnabled, _) => ZoomButton(
              colorScheme: colorScheme,
              isEnabled: isEnabled,
              onClick: () =>
                  model.setPressed(sdk.ZoomControlButton.zoomIn, true),
              onRelease: () =>
                  model.setPressed(sdk.ZoomControlButton.zoomIn, false),
              iconResource:
                  'packages/$pluginName/assets/icons/dgis_zoom_in.svg',
              position: ZoomButtonPosition.top,
            ),
          ),
          Divider(color: colorScheme.dividerColor, height: 0),
          ValueListenableBuilder<bool>(
            valueListenable: isZoomOutEnabled,
            builder: (_, isEnabled, _) => ZoomButton(
              colorScheme: colorScheme,
              isEnabled: isEnabled,
              onClick: () =>
                  model.setPressed(sdk.ZoomControlButton.zoomOut, true),
              onRelease: () =>
                  model.setPressed(sdk.ZoomControlButton.zoomOut, false),
              iconResource:
                  'packages/$pluginName/assets/icons/dgis_zoom_out.svg',
              position: ZoomButtonPosition.bottom,
            ),
          ),
        ],
      ),
    );
  }
}

/// Color scheme for [ZoomWidget].
class ZoomWidgetColorScheme extends MapWidgetColorScheme {
  final Color backgroundColor;
  final Color pressedBackgroundColor;
  final Color activeIconColor;
  final Color inactiveIconColor;
  final Color dividerColor;

  final List<BoxShadow> shadows;

  const ZoomWidgetColorScheme({
    required this.backgroundColor,
    required this.pressedBackgroundColor,
    required this.activeIconColor,
    required this.inactiveIconColor,
    this.dividerColor = const Color(0x4D898989),
    this.shadows = const [
      BoxShadow(
        offset: Offset(0, 1),
        color: Color(0x14000000),
        blurRadius: 4,
      ),
      BoxShadow(
        color: Color(0x0a000000),
        spreadRadius: 0.5,
      ),
    ],
  });

  @override
  ZoomWidgetColorScheme copyWith({
    Color? activeIconColor,
    Color? inactiveIconColor,
    Color? backgroundColor,
    Color? pressedBackgroundColor,
    Color? dividerColor,
    List<BoxShadow>? shadows,
  }) {
    return ZoomWidgetColorScheme(
      activeIconColor: activeIconColor ?? this.activeIconColor,
      inactiveIconColor: inactiveIconColor ?? this.inactiveIconColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      pressedBackgroundColor:
          pressedBackgroundColor ?? this.pressedBackgroundColor,
      dividerColor: dividerColor ?? this.dividerColor,
      shadows: shadows ?? this.shadows,
    );
  }
}
