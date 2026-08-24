import '../../generated/dart_bindings.dart' as sdk;
import '../../platform/map/map_appearance.dart';
import 'base_map_state.dart';
import 'map_widget.dart';
import 'map_widget_color_scheme.dart';
import 'themed_map_controlling_widget.dart';

/// Базовый класс для реализации стейта виджетов управления картой, подверженным
/// изменениям цветовой схемы в течение жизненного цикла.
/// Помимо объекта [sdk.Map], предоставляет доступ к теме карты [sdk.MapTheme], а также реагирует на
/// ее изменения для того, чтобы синхронно обновлять цветовую схему.
/// Виджет, использующий этот класс как базовый для своего State, должен быть помещен
/// в child виджета [MapWidget]. В ином случае будет брошено исключение при использовании.
abstract class ThemedMapControllingWidgetState<
    T extends ThemedMapControllingWidget<S>,
    S extends MapWidgetColorScheme> extends BaseMapWidgetState<T> {
  late S colorScheme;
  sdk.MapTheme? _mapTheme;

  @override
  void didChangeDependencies() {
    final mapTheme = mapThemeOf(context);
    final map = mapOf(context);
    if (_mapTheme != mapTheme && map != null) {
      if (mapTheme != null) {
        _mapTheme = mapTheme;
      }
      setState(() {
        colorScheme = map.appearance.isDarkTheme ? widget.dark : widget.light;
      });
    }

    super.didChangeDependencies();
  }
}
