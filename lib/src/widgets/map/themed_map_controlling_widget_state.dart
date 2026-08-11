import '../../platform/map/map_theme.dart';
import 'base_map_state.dart';
import 'map_widget.dart';
import 'map_widget_color_scheme.dart';
import 'themed_map_controlling_widget.dart';

/// Базовый класс для реализации стейта виджетов управления картой, подверженным
/// изменениям цветовой схемы в течение жизненного цикла.
/// Помимо объекта sdk.Map, предоставляет доступ к теме карты [MapTheme], а также реагирует на
/// ее изменения для того, чтобы синхронно обновлять цветовую схему.
/// Виджет, использующий этот класс как базовый для своего State, должен быть помещен
/// в child виджета [MapWidget]. В ином случае будет брошено исключение при использовании.
abstract class ThemedMapControllingWidgetState<
    T extends ThemedMapControllingWidget<S>,
    S extends MapWidgetColorScheme> extends BaseMapWidgetState<T> {
  late S colorScheme;
  MapThemeColorMode? _colorMode;

  @override
  void didChangeDependencies() {
    final mapTheme = mapThemeOf(context);
    if (_colorMode != mapTheme?.colorMode) {
      if (mapTheme != null) {
        _colorMode = mapTheme.colorMode;
      }
      switch (_colorMode) {
        case MapThemeColorMode.light:
          setState(() {
            colorScheme = widget.light;
          });
        case MapThemeColorMode.dark:
          setState(() {
            colorScheme = widget.dark;
          });
        default:
          setState(() {
            colorScheme = widget.light;
          });
      }
    }

    super.didChangeDependencies();
  }
}
