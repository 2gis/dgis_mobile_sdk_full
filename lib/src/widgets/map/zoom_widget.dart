import 'dart:async';
import 'package:flutter/cupertino.dart';
import '../../generated/dart_bindings.dart' as sdk;
import '../../platform/bss_events_source.dart';
import '../../util/plugin_name.dart';
import 'map_widget_color_scheme.dart';
import 'themed_map_controlling_widget.dart';
import 'themed_map_controlling_widget_state.dart';
import 'zoom_button_widget.dart';

/// Виджет карты, предоставлящий элементы для управления зумом.
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

  /// Цветовая схема UI–элемента для светлого режима по умолчанию.
  static const ZoomWidgetColorScheme defaultLightColorScheme =
      ZoomWidgetColorScheme(
    backgroundColor: Color(0xffffffff),
    pressedBackgroundColor: Color(0xffeeeeee),
    activeIconColor: Color(0xff4d4d4d),
    inactiveIconColor: Color(0xffcccccc),
  );

  /// Цветовая схема UI–элемента для темного режима по умолчанию.
  static const ZoomWidgetColorScheme defaultDarkColorScheme =
      ZoomWidgetColorScheme(
    backgroundColor: Color(0xff121212),
    pressedBackgroundColor: Color(0xff3C3C3C),
    activeIconColor: Color(0xffCCCCCC),
    inactiveIconColor: Color(0xff808080),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: isZoomInEnabled,
          builder: (_, isEnabled, __) => ZoomButton(
            activeIconColor: colorScheme.activeIconColor,
            inactiveIconColor: colorScheme.inactiveIconColor,
            backgroundColor: colorScheme.backgroundColor,
            pressedBackgroundColor: colorScheme.pressedBackgroundColor,
            isEnabled: isEnabled,
            onClick: () => model.setPressed(sdk.ZoomControlButton.zoomIn, true),
            onRelease: () =>
                model.setPressed(sdk.ZoomControlButton.zoomIn, false),
            iconResource: 'packages/$pluginName/assets/icons/dgis_zoom_in.svg',
          ),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<bool>(
          valueListenable: isZoomOutEnabled,
          builder: (_, isEnabled, __) => ZoomButton(
            activeIconColor: colorScheme.activeIconColor,
            inactiveIconColor: colorScheme.inactiveIconColor,
            backgroundColor: colorScheme.backgroundColor,
            pressedBackgroundColor: colorScheme.pressedBackgroundColor,
            isEnabled: isEnabled,
            onClick: () =>
                model.setPressed(sdk.ZoomControlButton.zoomOut, true),
            onRelease: () =>
                model.setPressed(sdk.ZoomControlButton.zoomOut, false),
            iconResource: 'packages/$pluginName/assets/icons/dgis_zoom_out.svg',
          ),
        ),
      ],
    );
  }
}

/// Цветовая схема для [ZoomWidget].
class ZoomWidgetColorScheme extends MapWidgetColorScheme {
  final Color backgroundColor;
  final Color pressedBackgroundColor;
  final Color activeIconColor;
  final Color inactiveIconColor;

  const ZoomWidgetColorScheme({
    required this.backgroundColor,
    required this.pressedBackgroundColor,
    required this.activeIconColor,
    required this.inactiveIconColor,
  });

  @override
  ZoomWidgetColorScheme copyWith({
    Color? activeIconColor,
    Color? inactiveIconColor,
    Color? backgroundColor,
    Color? pressedBackgroundColor,
  }) {
    return ZoomWidgetColorScheme(
      activeIconColor: activeIconColor ?? this.activeIconColor,
      inactiveIconColor: inactiveIconColor ?? this.inactiveIconColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      pressedBackgroundColor:
          pressedBackgroundColor ?? this.pressedBackgroundColor,
    );
  }
}
