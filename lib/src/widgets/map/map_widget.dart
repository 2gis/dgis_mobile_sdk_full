import 'dart:async';
import 'dart:ui' as ui;

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../generated/dart_bindings.dart' as sdk;
import '../../generated/stateful_channel.dart';
import '../../platform/map/map.dart';
import '../../platform/map/map_appearance.dart';
import '../../platform/map/map_theme.dart';
import '../../platform/map/map_widget_options.dart';
import '../../platform/map/touch_events_observer.dart';
import 'copyright_widget.dart';

typedef OnMapThemeChangedCallback = void Function(MapTheme theme);
typedef MapObjectTappedCallback = void Function(
  sdk.RenderedObjectInfo objectInfo,
);

/// Контроллер для работы с картой.
class MapWidgetController {
  final sdk.MapController _mapController;
  final sdk.MapSurfaceProvider _provider;
  final sdk.MapRenderer _renderer;
  final sdk.MapGestureRecognizer _mapGestureRecognizer;
  final List<OnMapThemeChangedCallback> _mapThemeChangedCallbacks = [];
  final List<MapObjectTappedCallback> _objectTappedCallbacks = [];
  final List<MapObjectTappedCallback> _objectLongTouchCallbacks = [];
  final List<StreamSubscription<dynamic>?> _connections = [];
  final CopyrightWidgetController _copyrightWidgetController =
      CopyrightWidgetController();
  MapAppearance _appearance = const AutomaticAppearance(
    MapTheme.defaultDayTheme(),
    MapTheme.defaultNightTheme(),
  );
  TouchEventsObserver? _touchEventsObserver;

  MapWidgetController(sdk.MapController mapController)
      : _mapController = mapController,
        _provider = sdk.MapSurfaceProvider.create(mapController.map),
        _renderer = mapController.renderer,
        _mapGestureRecognizer = mapController.gestureRecognizer;

  /// Объект карты.
  sdk.Map get map => _mapController.map;

  /// Внешний вид карты в зависимости от окружения.
  MapAppearance get appearance => _appearance;
  set appearance(MapAppearance value) {
    if (_appearance != value) {
      _appearance = value;
      _updateMapTheme();
    }
  }

  /// Частота обновления карты.
  /// Для получения корректного значения необходимо держать подписку на канал.
  /// Перед вызовом метода карта должна быть подключена к [MapWidget].
  StatefulChannel<sdk.Fps> get fpsChannel => _renderer.fpsChannel;

  /// Максимальный FPS карты.
  sdk.Fps? get maxFps => _renderer.maxFps;
  set maxFps(sdk.Fps? value) {
    if (_renderer.maxFps != value) {
      _renderer.setMaxFps(value, _renderer.powerSavingMaxFps);
    }
  }

  /// Максимальный FPS карты в режиме энергосбережения.
  sdk.Fps? get powerSavingMaxFps => _renderer.powerSavingMaxFps;
  set powerSavingMaxFps(sdk.Fps? value) {
    if (_renderer.powerSavingMaxFps != value) {
      _renderer.setMaxFps(_renderer.maxFps, value);
    }
  }

  /// Отступы для позиционирования копирайта.
  EdgeInsets get copyrightEdgeInsets =>
      _copyrightWidgetController.copyrightAlignment.value.edgeInsets;
  set copyrightEdgeInsets(EdgeInsets insets) {
    _copyrightWidgetController.copyrightAlignment.value =
        _copyrightWidgetController.copyrightAlignment.value
            .copyWith(edgeInsets: insets);
  }

  /// Позиция копирайта на экране.
  Alignment get copyrightAlignment =>
      _copyrightWidgetController.copyrightAlignment.value.alignment;
  set copyrightAlignment(Alignment value) {
    _copyrightWidgetController.copyrightAlignment.value =
        _copyrightWidgetController.copyrightAlignment.value
            .copyWith(alignment: value);
  }

  /// Класс для управления обработкой жестов.
  sdk.GestureManager? get gestureManager =>
      _mapGestureRecognizer.gestureManager;

  /// Метод для установки функции обратного вызова при тапе в копирайт.
  void setUriOpener(UriOpener uriOpener) {
    _copyrightWidgetController.uriOpener = uriOpener;
  }

  void setTouchEventsObserver(TouchEventsObserver? observer) {
    if (_touchEventsObserver == observer) {
      return;
    }
    _touchEventsObserver = observer;
    _updateTouchEventObserver();
  }

  /// Метод для добавления подписки на тап в объект карты.
  void addObjectTappedCallback(MapObjectTappedCallback callback) {
    _objectTappedCallbacks.add(callback);
    _updateTouchEventObserver();
  }

  void removeObjectTappedCallback(MapObjectTappedCallback callback) {
    _objectTappedCallbacks.remove(callback);
    _updateTouchEventObserver();
  }

  /// Метод для добавления подписки на долгое нажатие на объект карты.
  void addObjectLongTouchCallback(MapObjectTappedCallback callback) {
    _objectLongTouchCallbacks.add(callback);
    _updateTouchEventObserver();
  }

  void removeObjectLongTouchCallback(MapObjectTappedCallback callback) {
    _objectLongTouchCallbacks.remove(callback);
    _updateTouchEventObserver();
  }

  /// Метод для получения снэпшота карты.
  CancelableOperation<ByteData?> takeSnapshot({
    sdk.Alignment copyrightPosition = sdk.Alignment.bottomRight,
  }) {
    final completer = Completer<ByteData>();
    _renderer.takeSnapshot(copyrightPosition).value.then(
      (imageData) {
        final buffer = imageData.data.buffer;
        final imageDataList = buffer.asUint8List(
          imageData.data.offsetInBytes,
          imageData.data.lengthInBytes,
        );
        final imageWidth = imageData.size.width;
        final imageHeight = imageData.size.height;
        ui.decodeImageFromPixels(
          imageDataList,
          imageWidth,
          imageHeight,
          ui.PixelFormat.rgba8888,
          (image) =>
              image.toByteData(format: ui.ImageByteFormat.png).then((value) {
            final buffer = value?.buffer;
            completer.complete(buffer == null ? null : ByteData.view(buffer));
          }),
        );
      },
    );
    return CancelableOperation.fromFuture(completer.future);
  }

  void dispose() {
    _cancelConnections();
  }

  void _updateMapTheme() {
    final theme = _appearance.mapTheme;
    _mapController.map.setTheme(theme);
    for (final cb in _mapThemeChangedCallbacks) {
      cb(theme);
    }
  }

  void _addMapThemeChangedCallback(OnMapThemeChangedCallback callback) {
    _mapThemeChangedCallbacks.add(callback);
  }

  void _removeMapThemeChangedCallback(OnMapThemeChangedCallback callback) {
    _mapThemeChangedCallbacks.remove(callback);
  }

  void _updateTouchEventObserver() {
    if (_touchEventsObserver == null &&
        _objectTappedCallbacks.isEmpty &&
        _objectLongTouchCallbacks.isEmpty) {
      _cancelConnections();
      return;
    }

    if (_connections.isNotEmpty) {
      return;
    }

    _connections
      ..add(
        _mapGestureRecognizer.tap.listen(
          (point) {
            _touchEventsObserver?.onTap(point);
            _callMapObjectCallbacks(point, _objectTappedCallbacks);
          },
        ),
      )
      ..add(
        _mapGestureRecognizer.longTouch.listen(
          (point) {
            _touchEventsObserver?.onLongTouch(point);
            _callMapObjectCallbacks(point, _objectLongTouchCallbacks);
          },
        ),
      )
      ..add(
        _mapGestureRecognizer.dragBegin.listen(
          (dragBeginData) {
            _touchEventsObserver?.onDragBegin(dragBeginData);
          },
        ),
      )
      ..add(
        _mapGestureRecognizer.dragMove.listen(
          (point) {
            _touchEventsObserver?.onDragMove(point);
          },
        ),
      )
      ..add(
        _mapGestureRecognizer.dragEnd.listen(
          (result) {
            _touchEventsObserver?.onDragEnd();
          },
        ),
      );
  }

  Future<void> _cancelConnections() async {
    final connections = List<StreamSubscription<dynamic>?>.from(_connections);
    _connections.clear();

    for (final connection in connections) {
      await connection?.cancel();
    }
  }

  Future<void> _callMapObjectCallbacks(
    sdk.ScreenPoint point,
    List<MapObjectTappedCallback> callbacks,
  ) async {
    if (callbacks.isEmpty) {
      return;
    }
    await map
        .getMapObject(point, const sdk.ScreenDistance(1))
        .value
        .then((objectInfo) {
      if (objectInfo != null) {
        for (final callback in callbacks) {
          callback(objectInfo);
        }
      }
    });
  }
}

class MapWidgetInternal extends StatefulWidget {
  final sdk.Context sdkContext;
  final MapWidgetController controller;
  final MapWidgetOptions viewOptions;
  final Widget? child;
  final bool showCopyright;

  // Не можем использовать const конструктор тут, т.к.
  // некоторые из параметров – обертки над нативными объектами,
  // и для них это неприменимо
  // ignore: prefer_const_constructors_in_immutables
  MapWidgetInternal({
    required this.sdkContext,
    required this.controller,
    this.viewOptions = const MapWidgetOptions(),
    this.child,
    this.showCopyright = true,
    super.key,
  });

  @override
  MapWidgetState createState() => MapWidgetState();
}

///  Виджет для работы с картой.
class MapWidget extends MapWidgetInternal {
  // Не можем использовать const конструктор тут, т.к.
  // некоторые из параметров – обертки над нативными объектами,
  // и для них это неприменимо
  // ignore: prefer_const_constructors_in_immutables
  MapWidget({
    required super.sdkContext,
    required super.controller,
    super.viewOptions,
    super.child,
    super.key,
  }) : super(
          showCopyright: true,
        );
}

class _TextureController {
  static const MethodChannel _channel =
      MethodChannel('flutter_map_surface_plugin');

  Future<int?> initialize(int mapSurfaceId) async {
    return _channel.invokeMethod('setSurface', {'mapSurfaceId': mapSurfaceId});
  }

  Future<void> update(int textureId, int width, int height) async {
    await _channel.invokeMethod('updateSurface', {
      'textureId': textureId,
      'width': width,
      'height': height,
    });
  }

  Future<int?> getScreenFps() async {
    return _channel.invokeMethod('getScreenFps');
  }

  void dispose(int textureId) {
    _channel.invokeMethod('dispose', {'textureId': textureId});
  }
}

class _MapRenderBox extends RenderBox {
  int? textureId;
  double deviceDensity;
  _TextureController textureController;
  MapWidgetController mapWidgetController;

  ClipRectLayer? _clipRectLayer;
  Size _currentTextureSize = Size.zero;

  _MapRenderBox(
    this.textureId,
    this.deviceDensity,
    this.textureController,
    this.mapWidgetController,
  );

  Future<void> _updateMapSize(Size newSize) async {
    if (newSize.width == 0.0 || newSize.height == 0.0) {
      return;
    }

    markNeedsPaint();

    final width = (newSize.width * deviceDensity).toInt();
    final height = (newSize.height * deviceDensity).toInt();
    await textureController.update(textureId!, width, height);
    final screenSize = sdk.ScreenSize(width: width, height: height);
    mapWidgetController._provider.resizeSurface(screenSize);
    mapWidgetController.map.camera.size = screenSize;

    mapWidgetController._renderer.waitForRendering().then((_) {
      _currentTextureSize = newSize;
      markNeedsPaint();
    });
  }

  @override
  bool get sizedByParent => true;

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  bool get isRepaintBoundary => true;

  @override
  void performResize() {
    size = constraints.biggest;
    _updateMapSize(size);
  }

  @override
  bool hitTestSelf(Offset position) {
    return true;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (textureId == null) {
      return;
    }
    if (size.width < _currentTextureSize.width ||
        size.height < _currentTextureSize.height) {
      _clipRectLayer = context.pushClipRect(
        true,
        offset,
        offset & size,
        _paintTexture,
        oldLayer: _clipRectLayer,
      );
      return;
    }
    _clipRectLayer = null;
    _paintTexture(context, offset);
  }

  void _paintTexture(PaintingContext context, Offset offset) {
    final dx = offset.dx + (size.width - _currentTextureSize.width) / 2;
    final dy = offset.dy + (size.height - _currentTextureSize.height) / 2;
    final centeredOffset = Offset(dx, dy);

    context.addLayer(
      TextureLayer(
        rect: centeredOffset & _currentTextureSize,
        textureId: textureId!,
      ),
    );
  }
}

class _MapTextureView extends LeafRenderObjectWidget {
  const _MapTextureView({
    required this.textureId,
    required this.deviceDensity,
    required this.textureController,
    required this.mapWidgetController,
  });

  final int? textureId;
  final double deviceDensity;
  final _TextureController textureController;
  final MapWidgetController mapWidgetController;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _MapRenderBox(
      textureId,
      deviceDensity,
      textureController,
      mapWidgetController,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    renderObject as _MapRenderBox
      ..textureId = textureId
      ..deviceDensity = deviceDensity
      ..textureController = textureController
      ..mapWidgetController = mapWidgetController;
  }
}

class _TouchPoint {
  final int _id;
  sdk.ScreenPoint _position;
  sdk.TouchPointState _state;

  _TouchPoint(this._id, this._position, this._state);
}

class _MapGestureController {
  final sdk.MapGestureRecognizer _mapGestureRecognizer;
  final double _deviceDensity;
  final _touchPoints = <_TouchPoint>[];

  _MapGestureController(this._mapGestureRecognizer, this._deviceDensity);

  void onPointerDownCallback(PointerDownEvent event) {
    _addTouchPoint(event, sdk.TouchPointState.pressed);
    _processPoints(event.timeStamp);
  }

  void onPointerMoveCallback(PointerMoveEvent event) {
    _addTouchPoint(event, sdk.TouchPointState.moved);
    _processPoints(event.timeStamp);
  }

  void onPointerUpCallback(PointerUpEvent event) {
    _addTouchPoint(event, sdk.TouchPointState.released);
    _processPoints(event.timeStamp);
  }

  void onPointerCancelCallback(PointerCancelEvent event) {
    _touchPoints.clear();
    _mapGestureRecognizer.cancel();
  }

  void _addTouchPoint(PointerEvent event, sdk.TouchPointState state) {
    final poisition = _getScreenPoint(event);
    final touchPoint =
        _touchPoints.where((element) => element._id == event.pointer);
    if (touchPoint.isEmpty) {
      _touchPoints.add(_TouchPoint(event.pointer, poisition, state));
    } else {
      touchPoint.first._position = poisition;
      touchPoint.first._state = state;
    }
  }

  void _processPoints(Duration timeStamp) {
    for (final point in _touchPoints) {
      _mapGestureRecognizer.addTouchPoint(
        point._position,
        point._state,
        point._id,
      );
      if (point._state == sdk.TouchPointState.pressed) {
        point._state = sdk.TouchPointState.moved;
      }
    }
    _mapGestureRecognizer.processTouchEvent(timeStamp);
    _touchPoints.removeWhere(
      (element) => element._state == sdk.TouchPointState.released,
    );
  }

  sdk.ScreenPoint _getScreenPoint(PointerEvent event) {
    return sdk.ScreenPoint(
      x: event.localPosition.dx * _deviceDensity,
      y: event.localPosition.dy * _deviceDensity,
    );
  }
}

class MapWidgetState extends State<MapWidgetInternal>
    with WidgetsBindingObserver {
  final _controller = _TextureController();
  late final MapWidgetController mapWidgetController;
  int? _textureId;
  AppLifecycleState? _appState;
  _MapGestureController? _mapGestureController;
  StreamSubscription<sdk.CameraChange>? _cameraChangeSubscription;
  double _deviceDensity = 1;
  double _devicePpi = 1;
  late final ValueNotifier<MapTheme> _mapTheme;
  bool isMapInitialized = false;

  @override
  void initState() {
    super.initState();
    mapWidgetController = widget.controller;
    mapWidgetController._appearance = widget.viewOptions.appearance;
    mapWidgetController._updateMapTheme();
    WidgetsBinding.instance.addObserver(this);
    _appState = WidgetsBinding.instance.lifecycleState;
    _mapTheme = ValueNotifier(mapWidgetController._appearance.mapTheme);
    if (widget.child != null) {
      mapWidgetController._addMapThemeChangedCallback(_onMapThemeChanged);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isMapInitialized) {
      _deviceDensity = widget.viewOptions.deviceDensity?.value ??
          MediaQuery.devicePixelRatioOf(context);
      _devicePpi =
          widget.viewOptions.devicePPI?.value ?? _deviceDensity * 160.0;
      _initialize();
    }
  }

  @override
  void dispose() {
    mapWidgetController._cancelConnections();
    if (_textureId != null) {
      _controller.dispose(_textureId!);
    }
    mapWidgetController._removeMapThemeChangedCallback(_onMapThemeChanged);
    WidgetsBinding.instance.removeObserver(this);
    _cameraChangeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_textureId == null) {
      return Container(
        color: widget.viewOptions.loadingBackground,
      );
    }

    return Stack(
      children: [
        Center(
          child: Listener(
            onPointerDown: (event) {
              _mapGestureController?.onPointerDownCallback(event);
            },
            onPointerMove: (event) {
              _mapGestureController?.onPointerMoveCallback(event);
            },
            onPointerUp: (event) {
              _mapGestureController?.onPointerUpCallback(event);
            },
            onPointerCancel: (event) {
              _mapGestureController?.onPointerCancelCallback(event);
            },
            child: _MapTextureView(
              textureId: _textureId,
              deviceDensity: _deviceDensity,
              textureController: _controller,
              mapWidgetController: mapWidgetController,
            ),
          ),
        ),
        if (widget.showCopyright)
          _MapProvider(
            map: mapWidgetController.map,
            mapTheme: _mapTheme.value,
            child: ValueListenableBuilder(
              valueListenable: mapWidgetController
                  ._copyrightWidgetController.copyrightAlignment,
              builder: (_, copyrightAlignment, __) => Align(
                alignment: copyrightAlignment.alignment,
                child: CopyrightWidget(
                  controller: mapWidgetController._copyrightWidgetController,
                ),
              ),
            ),
          ),
        if (widget.child != null)
          ValueListenableBuilder(
            valueListenable: _mapTheme,
            builder: (_, theme, __) => _MapProvider(
              map: mapWidgetController.map,
              mapTheme: theme,
              child: widget.child!,
            ),
          ),
      ],
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_appState != state) {
      _appState = state;
      _updateMapVisibility();
    }
  }

  @override
  void didChangePlatformBrightness() {
    mapWidgetController._updateMapTheme();
  }

  Future<void> _initialize() async {
    final map = mapWidgetController.map;
    map.camera.setDevicePpi(
      sdk.DevicePpi(_devicePpi),
      sdk.DeviceDensity(_deviceDensity),
    );

    final provider = mapWidgetController._provider;
    final id = await _controller.initialize(provider.id);

    final screenFps = await _controller.getScreenFps();
    final renderer = mapWidgetController._renderer;
    final maxFps = renderer.maxFps ?? sdk.Fps(screenFps ?? 60);
    final powerSavingMaxFps =
        renderer.powerSavingMaxFps ?? sdk.Fps(screenFps ?? 60);
    renderer.setMaxFps(maxFps, powerSavingMaxFps);

    _updateMapVisibility();

    final mapGestureRecognizer = mapWidgetController._mapGestureRecognizer;
    _mapGestureController = _MapGestureController(
      mapGestureRecognizer,
      _deviceDensity,
    );
    _cameraChangeSubscription = map.camera.changed.listen((changes) {
      if (changes.changeReasons.contains(sdk.CameraChangeReason.devicePPI)) {
        _mapGestureController?._mapGestureRecognizer
            .onDevicePpiChanged(map.camera.devicePpi);
      }
    });

    mapWidgetController._updateTouchEventObserver();

    renderer.waitForRendering().then((isRendered) {
      if (isRendered) {
        setState(() {
          _textureId = id;
        });
      }
    });
    isMapInitialized = true;
  }

  void _updateMapVisibility() {
    if (_appState == null) {
      return;
    }
    late sdk.MapVisibilityState mapVisibilityState;
    switch (_appState!) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        mapVisibilityState = sdk.MapVisibilityState.hidden;
      case AppLifecycleState.resumed:
      case AppLifecycleState.inactive:
        mapVisibilityState = sdk.MapVisibilityState.visible;
    }

    mapWidgetController.map.mapVisibilityState = mapVisibilityState;
  }

  void _onMapThemeChanged(MapTheme theme) {
    _mapTheme.value = theme;
  }
}

class _MapProvider extends InheritedWidget {
  final sdk.Map map;
  final MapTheme mapTheme;

  const _MapProvider({
    required this.map,
    required this.mapTheme,
    required super.child,
    // ignore: unused_element, unused_element_parameter
    super.key,
  });

  @override
  bool updateShouldNotify(_MapProvider oldWidget) {
    return map.id != oldWidget.map.id || mapTheme != oldWidget.mapTheme;
  }
}

/// Метод, позволяющий получить [sdk.Map] из виджета, находящегося
/// выше по дереву.
sdk.Map? mapOf(BuildContext context) {
  return context.dependOnInheritedWidgetOfExactType<_MapProvider>()?.map;
}

/// Метод, позволяющий получить [MapTheme] из виджета, находящегося
/// выше по дереву.
MapTheme? mapThemeOf(BuildContext context) {
  return context.dependOnInheritedWidgetOfExactType<_MapProvider>()?.mapTheme;
}
