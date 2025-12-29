import '../../../generated/dart_bindings.dart' as sdk;
import '../../../platform/dgis.dart';

/// Controller for the navigation mini-map.
///
/// Creates  an instance of `sdk.MiniMapControlModel`,
/// subscribes to the mini-map lifecycle and ensures its correct
/// connection to the `NavigationManager`.
class NavigationMiniMapController {
  final sdk.NavigationManager navigationManager;

  sdk.Map? _miniMap;
  // ignore: unused_field
  sdk.MiniMapControlModel? _controlModel;

  NavigationMiniMapController({
    required this.navigationManager,
  });

  /// Should be called when the internal map of the mini-map is ready.
  /// If the map has changed, creates a new `MiniMapControlModel`
  /// and registers the map in `mapManager`.
  void onMapReady(sdk.Map? map) {
    if (identical(_miniMap, map)) {
      return;
    }

    _deinitializeInternal();

    if (map == null) {
      return;
    }

    _miniMap = map;

    _controlModel = sdk.MiniMapControlModel(
      DGis().context,
      navigationManager.uiModel,
      map,
    );

    navigationManager.mapManager.addMap(map);
  }

  void _deinitializeInternal() {
    final map = _miniMap;
    if (map != null) {
      try {
        navigationManager.mapManager.removeMap(map);
      } on Exception catch (_) {}
    }
    _controlModel = null;
    _miniMap = null;
  }

  void dispose() {
    _deinitializeInternal();
  }
}
