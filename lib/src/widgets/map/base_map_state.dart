import 'package:flutter/widgets.dart';

import '../../generated/dart_bindings.dart' as sdk;
import 'map_widget.dart';

/// Базовый класс для реализации стейта виджетов управления картой.
/// Предоставляет доступ к объекту карты [sdk.Map].
/// Виджет, использующий этот класс как базовый для своего [State], должен быть помещен
/// в child виджета [MapWidget], в ином случае будет брошено исключение при использовании.
///
abstract class BaseMapWidgetState<T extends StatefulWidget> extends State<T> {
  sdk.Map? _map;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _map = mapOf(context);
    if (_map == null) {
      throw Exception('Any MapControl should be added as child of MapWidget');
    }
    onAttachedToMap(_map!);
  }

  @override
  void dispose() {
    onDetachedFromMap();
    _map = null;
    super.dispose();
  }

  /// Вызывается при появлении доступа к объекту [sdk.Map].
  /// В этом методе необходимо инициализировать необходимые виджету модели,
  /// подписки и другие объекты, которым необходима карта.
  void onAttachedToMap(sdk.Map map);

  /// Вызывается перед вызовом [dispose].
  /// В этом методе необходимо отменить все подписки и освободить все объекты,
  /// зависящие от [sdk.Map]
  void onDetachedFromMap();
}
