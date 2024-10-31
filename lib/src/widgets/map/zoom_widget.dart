import 'dart:async';
import 'package:dgis_mobile_sdk_full/src/util/rounded_corners.dart';
import 'package:dgis_mobile_sdk_full/src/widgets/map/base_map_control.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import '../../generated/dart_bindings.dart' as sdk;
import '../../util/plugin_name.dart';
import 'themed_map_controlling_widget.dart';

/// Виджет карты, предоставлящий элементы для управления зумом.
/// Может использоваться только как child в MapWidget на любом уровне вложенности.
class ZoomWidget extends ThemedMapControllingWidget<MapControlTheme> {
  const ZoomWidget({
    super.key,
    MapControlTheme? light,
    MapControlTheme? dark,
  }) : super(
          light: light ?? MapControlTheme.defaultLight,
          dark: dark ?? MapControlTheme.defaultDark,
        );

  @override
  ThemedMapControllingWidgetState<ZoomWidget, MapControlTheme> createState() => _ZoomWidgetState();
}

class _ZoomWidgetState extends ThemedMapControllingWidgetState<ZoomWidget, MapControlTheme> {
  final ValueNotifier<bool> isZoomInEnabled = ValueNotifier(false);
  final ValueNotifier<bool> isZoomOutEnabled = ValueNotifier(false);

  StreamSubscription<bool>? zoomInSubscription;
  StreamSubscription<bool>? zoomOutSubscription;
  late sdk.ZoomControlModel model;

  @override
  void onAttachedToMap(sdk.Map map) {
    model = sdk.ZoomControlModel(map);

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
          builder: (_, isEnabled, __) => BaseMapControl(
            theme: theme,
            isEnabled: isEnabled,
            onPress: () => model.setPressed(sdk.ZoomControlButton.zoomIn, true),
            onRelease: () => model.setPressed(sdk.ZoomControlButton.zoomIn, false),
            roundedCorners: RoundedCorners.top(),
            child: Center(
              child: SvgPicture.asset(
                'packages/$pluginName/assets/icons/dgis_zoom_in.svg',
                width: theme.iconSize,
                height: theme.iconSize,
                fit: BoxFit.none,
                colorFilter: ColorFilter.mode(
                  isEnabled ? theme.iconInactiveColor : theme.iconDisabledColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: isZoomOutEnabled,
          builder: (_, isEnabled, __) => BaseMapControl(
            theme: theme,
            isEnabled: isEnabled,
            onPress: () => model.setPressed(sdk.ZoomControlButton.zoomOut, true),
            onRelease: () => model.setPressed(sdk.ZoomControlButton.zoomOut, false),
            roundedCorners: RoundedCorners.bottom(),
            child: Center(
              child: SvgPicture.asset(
                'packages/$pluginName/assets/icons/dgis_zoom_out.svg',
                width: theme.iconSize,
                height: theme.iconSize,
                fit: BoxFit.none,
                colorFilter: ColorFilter.mode(
                  isEnabled ? theme.iconInactiveColor : theme.iconDisabledColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
