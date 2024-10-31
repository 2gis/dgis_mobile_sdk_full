import 'package:flutter/widgets.dart';

import 'map_widget_theme.dart';

import '../../platform/map/map_theme.dart';
import 'base_map_state.dart';
import 'map_widget.dart';

/// Базовый класс для реализации стейта виджетов управления картой, подверженным
/// изменениям цветовой схемы в течение жизненного цикла.
/// Помимо объекта sdk.Map, предоставляет доступ к теме карты [MapTheme], а также реагирует на
/// ее изменения для того, чтобы синхронно обновлять цветовую схему.
/// Виджет, использующий этот класс как базовый для своего State, должен быть помещен
/// в child виджета [MapWidget]. В ином случае будет брошено исключение при использовании.
abstract class ThemedMapControllingWidgetState<T extends ThemedMapControllingWidget<S>, S extends MapWidgetTheme>
    extends BaseMapWidgetState<T> {
  late S theme;
  MapThemeColorMode? _colorMode;

  @override
  void didChangeDependencies() {
    final mapTheme = mapThemeOf(context);
    if (_colorMode == mapTheme?.colorMode) {
      return;
    }
    if (mapTheme != null) {
      _colorMode = mapTheme.colorMode;
    }
    switch (_colorMode) {
      case MapThemeColorMode.light:
        setState(() {
          theme = widget.light;
        });
      case MapThemeColorMode.dark:
        setState(() {
          theme = widget.dark;
        });
      default:
        setState(() {
          theme = widget.light;
        });
    }

    super.didChangeDependencies();
  }
}

/// Базовый класс для реализации виджетов карты, способных изменять цветовую схему
/// в зависимости от признака colorMode темы карты MapTheme.
/// Должен использоваться совместно с ThemedMapControllingWidgetState.
abstract class ThemedMapControllingWidget<T extends MapWidgetTheme> extends StatefulWidget {
  final T light;
  final T dark;

  const ThemedMapControllingWidget({
    required this.light,
    required this.dark,
    super.key,
  });
}
