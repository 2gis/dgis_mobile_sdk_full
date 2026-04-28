import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../generated/dart_bindings.dart' as sdk;
import '../../../../platform/bss_events_source.dart';
import '../../../../util/plugin_name.dart';
import '../../../widget_shadows.dart';
import '../../map_widget_color_scheme.dart';
import '../../themed_map_controlling_widget.dart';
import '../../themed_map_controlling_widget_state.dart';
import 'modern_zoom_button_widget.dart';

/// Виджет карты, предоставлящий элементы для управления зумом (modern-версия).
/// Может использоваться только как child в MapWidget на любом уровне вложенности.
class ModernZoomWidget
    extends ThemedMapControllingWidget<ModernZoomWidgetColorScheme> {
  const ModernZoomWidget({
    super.key,
    ModernZoomWidgetColorScheme? light,
    ModernZoomWidgetColorScheme? dark,
  }) : super(
          light: light ?? defaultLightColorScheme,
          dark: dark ?? defaultDarkColorScheme,
        );

  @override
  ThemedMapControllingWidgetState<ModernZoomWidget, ModernZoomWidgetColorScheme>
      createState() => _ModernZoomWidgetState();

  /// Default color scheme of the UI element for light mode.
  static const ModernZoomWidgetColorScheme defaultLightColorScheme =
      ModernZoomWidgetColorScheme(
    backgroundColor: Color(0xFFFFFFFF),
    pressedBackgroundColor: Color(0xFFEEEEEE),
    activeIconColor: Color(0xFF141414),
    inactiveIconColor: Color(0xFFB8B8B8),
  );

  /// Default color scheme of the UI element for dark mode.
  static const ModernZoomWidgetColorScheme defaultDarkColorScheme =
      ModernZoomWidgetColorScheme(
    backgroundColor: Color(0xFF141414),
    pressedBackgroundColor: Color(0xFF3C3C3C),
    activeIconColor: Color(0xFFFFFFFF),
    inactiveIconColor: Color(0xFF5A5A5A),
  );
}

class _ModernZoomWidgetState extends ThemedMapControllingWidgetState<
    ModernZoomWidget, ModernZoomWidgetColorScheme> {
  final ValueNotifier<bool> isZoomInEnabled = ValueNotifier(false);
  final ValueNotifier<bool> isZoomOutEnabled = ValueNotifier(false);

  StreamSubscription<bool>? zoomInSubscription;
  StreamSubscription<bool>? zoomOutSubscription;
  late sdk.ZoomControlModel model;

  @override
  void onAttachedToMap(sdk.Map map) {
    model = withBssEventsSourceFromSdk(() => sdk.ZoomControlModel(map));

    zoomInSubscription = model.isEnabled(sdk.ZoomControlButton.zoomIn).listen(
          (isEnabled) => isZoomInEnabled.value = isEnabled,
        );
    zoomOutSubscription = model.isEnabled(sdk.ZoomControlButton.zoomOut).listen(
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
            builder: (_, isEnabled, __) => ModernZoomButton(
              activeIconColor: colorScheme.activeIconColor,
              inactiveIconColor: colorScheme.inactiveIconColor,
              backgroundColor: colorScheme.backgroundColor,
              pressedBackgroundColor: colorScheme.pressedBackgroundColor,
              isEnabled: isEnabled,
              onClick: () =>
                  model.setPressed(sdk.ZoomControlButton.zoomIn, true),
              onRelease: () =>
                  model.setPressed(sdk.ZoomControlButton.zoomIn, false),
              iconResource:
                  'packages/$pluginName/assets/icons/dgis_zoom_in.svg',
              position: ModernZoomButtonPosition.top,
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: isZoomOutEnabled,
            builder: (_, isEnabled, __) => ModernZoomButton(
              activeIconColor: colorScheme.activeIconColor,
              inactiveIconColor: colorScheme.inactiveIconColor,
              backgroundColor: colorScheme.backgroundColor,
              pressedBackgroundColor: colorScheme.pressedBackgroundColor,
              isEnabled: isEnabled,
              onClick: () =>
                  model.setPressed(sdk.ZoomControlButton.zoomOut, true),
              onRelease: () =>
                  model.setPressed(sdk.ZoomControlButton.zoomOut, false),
              iconResource:
                  'packages/$pluginName/assets/icons/dgis_zoom_out.svg',
              position: ModernZoomButtonPosition.bottom,
            ),
          ),
        ],
      ),
    );
  }
}

/// Color scheme for [ModernZoomWidget].
class ModernZoomWidgetColorScheme extends MapWidgetColorScheme {
  final Color backgroundColor;
  final Color pressedBackgroundColor;
  final Color activeIconColor;
  final Color inactiveIconColor;

  const ModernZoomWidgetColorScheme({
    required this.backgroundColor,
    required this.pressedBackgroundColor,
    required this.activeIconColor,
    required this.inactiveIconColor,
  });

  @override
  ModernZoomWidgetColorScheme copyWith({
    Color? activeIconColor,
    Color? inactiveIconColor,
    Color? backgroundColor,
    Color? pressedBackgroundColor,
  }) {
    return ModernZoomWidgetColorScheme(
      activeIconColor: activeIconColor ?? this.activeIconColor,
      inactiveIconColor: inactiveIconColor ?? this.inactiveIconColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      pressedBackgroundColor:
          pressedBackgroundColor ?? this.pressedBackgroundColor,
    );
  }
}
