import 'dart:async';
import 'dart:ui' as ui;

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../generated/dart_bindings.dart' as sdk;
import '../../generated/native_exception.dart';
import '../../generated/stateful_channel.dart';
import '../../platform/map/map_appearance.dart';
import '../../platform/map/map_widget_options.dart';
import '../../platform/map/touch_events_observer.dart';
import 'copyright_widget.dart';

typedef OnMapThemeChangedCallback = void Function(
  sdk.MapTheme appearance,
);
typedef MapObjectTappedCallback = void Function(
  sdk.RenderedObjectInfo objectInfo,
);

/// Контроллер для работы с картой.
class MapWidgetController {
  final List<OnMapThemeChangedCallback> _mapThemeChangedCallbacks = [];
  final List<MapObjectTappedCallback> _objectTappedCallbacks = [];
  final List<MapObjectTappedCallback> _objectLongTouchCallbacks = [];
  final List<StreamSubscription<dynamic>?> _connections = [];
  final CopyrightWidgetController _copyrightWidgetController =
      CopyrightWidgetController();
  sdk.MapAppearance _appearance;
  late sdk.Color _backgroundColor;
  late CancelableOperation<sdk.MapController> _mapControllerOperation;
  sdk.MapController? _mapController;
  sdk.MapSurfaceProvider? _provider;
  sdk.MapRenderer? _renderer;
  sdk.MapGestureRecognizer? _mapGestureRecognizer;
  sdk.Fps? _maxFps;
  sdk.Fps? _powerSavingMaxFps;
  TouchEventsObserver? _touchEventsObserver;
  bool _isDisposed = false;

  MapWidgetController(
    sdk.Context sdkContext, {
    sdk.MapControllerOptions controllerOptions =
        const sdk.MapControllerOptions(),
  })  : _appearance = controllerOptions.mapAppearance ?? defaultMapAppearance(),
        _maxFps = controllerOptions.maxFps,
        _powerSavingMaxFps = controllerOptions.powerSavingMaxFps {
    _backgroundColor = _appearance.mapTheme.loadingBackground;
    _mapControllerOperation = sdk.MapController.create(
      sdkContext,
      controllerOptions,
    );
    _observeMapControllerOperation();
  }

  MapWidgetController.fromMapController(
    sdk.MapController mapController,
  )   : _appearance = defaultMapAppearance(),
        _mapControllerOperation = CancelableOperation.fromFuture(
          Future.value(mapController),
        ) {
    _backgroundColor = _appearance.mapTheme.loadingBackground;
    _bindMapController(mapController);
  }

  /// Объект карты. Возвращает null, если [sdk.MapController] еще не создан.
  sdk.Map? get map => _mapController?.map;

  /// Завершается true, когда карта создана и [map] возвращает не null.
  Future<bool> get isReady async {
    if (_mapController != null) {
      return true;
    }

    try {
      await _ensureMapController();
      return true;
    } on Object {
      return false;
    }
  }

  /// Асинхронно возвращает карту, дожидаясь создания [sdk.MapController].
  Future<sdk.Map> get mapAsync async {
    final mapController = await _ensureMapController();
    return mapController.map;
  }

  /// Внешний вид карты в зависимости от окружения.
  sdk.MapAppearance get appearance => _appearance;
  set appearance(sdk.MapAppearance value) {
    if (_appearance != value) {
      _appearance = value;
      _updateMapTheme();
    }
  }

  /// Цвет фона, который должен использоваться до первого отрисованного кадра.
  Color get loadingBackground => Color(_backgroundColor.argb);

  /// Частота обновления карты.
  /// Для получения корректного значения необходимо держать подписку на канал.
  /// Перед вызовом метода карта должна быть подключена к [MapWidget].
  StatefulChannel<sdk.Fps> get fpsChannel {
    final renderer = _renderer;
    if (renderer == null) {
      throw NativeException(
        'MapController is not initialized yet. Await mapAsync first.',
      );
    }

    return renderer.fpsChannel;
  }

  /// Максимальный FPS карты.
  sdk.Fps? get maxFps => _renderer?.maxFps ?? _maxFps;
  set maxFps(sdk.Fps? value) {
    if (maxFps != value) {
      _maxFps = value;
      _updateRendererFps();
    }
  }

  /// Максимальный FPS карты в режиме энергосбережения.
  sdk.Fps? get powerSavingMaxFps =>
      _renderer?.powerSavingMaxFps ?? _powerSavingMaxFps;
  set powerSavingMaxFps(sdk.Fps? value) {
    if (powerSavingMaxFps != value) {
      _powerSavingMaxFps = value;
      _updateRendererFps();
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
      _mapGestureRecognizer?.gestureManager;

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
    return CancelableOperation.fromFuture(_takeSnapshot(copyrightPosition));
  }

  void dispose() {
    _isDisposed = true;
    unawaited(_cancelConnections());
    _mapController = null;
    _provider = null;
    _renderer = null;
    _mapGestureRecognizer = null;
    unawaited(_mapControllerOperation.cancel());
  }

  void _observeMapControllerOperation() {
    unawaited(
      _mapControllerOperation.value
          .then<void>(_bindMapController)
          .catchError((Object _) {}),
    );
  }

  void _bindMapController(sdk.MapController mapController) {
    if (_isDisposed || _mapController == mapController) {
      return;
    }

    _mapController = mapController;
    _provider = sdk.MapSurfaceProvider.create(mapController.map);
    _renderer = mapController.renderer;
    _mapGestureRecognizer = mapController.gestureRecognizer;
    _maxFps ??= _renderer?.maxFps;
    _powerSavingMaxFps ??= _renderer?.powerSavingMaxFps;
    _updateMapTheme();
    _updateRendererFps();
    _updateTouchEventObserver();
  }

  Future<sdk.MapController> _ensureMapController() async {
    final mapController = _mapController;
    if (mapController != null) {
      return mapController;
    }

    final createdMapController = await _mapControllerOperation.value;
    _bindMapController(createdMapController);
    return createdMapController;
  }

  Future<ByteData?> _takeSnapshot(sdk.Alignment copyrightPosition) async {
    await _ensureMapController();
    final renderer = _renderer!;
    final imageData = await renderer.takeSnapshot(copyrightPosition).value;
    final completer = Completer<ByteData?>();
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
      (image) {
        unawaited(
          image.toByteData(format: ui.ImageByteFormat.png).then((value) {
            final buffer = value?.buffer;
            completer.complete(buffer == null ? null : ByteData.view(buffer));
          }),
        );
      },
    );
    return completer.future;
  }

  void _updateMapTheme() {
    final mapController = _mapController;
    if (mapController == null) {
      return;
    }

    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    mapController.map.setIsPlatformDarkMode(brightness == Brightness.dark);
    mapController.map.appearance = _appearance;
    for (final cb in _mapThemeChangedCallbacks) {
      cb(_appearance.mapTheme);
    }
  }

  void _updateRendererFps() {
    _renderer?.setMaxFps(_maxFps, _powerSavingMaxFps);
  }

  void _updateTouchEventObserver() {
    final mapGestureRecognizer = _mapGestureRecognizer;
    if (mapGestureRecognizer == null) {
      return;
    }

    if (_touchEventsObserver == null &&
        _objectTappedCallbacks.isEmpty &&
        _objectLongTouchCallbacks.isEmpty) {
      unawaited(_cancelConnections());
      return;
    }

    if (_connections.isNotEmpty) {
      return;
    }

    _connections
      ..add(
        mapGestureRecognizer.tap.listen(
          (point) {
            _touchEventsObserver?.onTap(point);
            _callMapObjectCallbacks(point, _objectTappedCallbacks);
          },
        ),
      )
      ..add(
        mapGestureRecognizer.longTouch.listen(
          (point) {
            _touchEventsObserver?.onLongTouch(point);
            _callMapObjectCallbacks(point, _objectLongTouchCallbacks);
          },
        ),
      )
      ..add(
        mapGestureRecognizer.dragBegin.listen(
          (dragBeginData) {
            _touchEventsObserver?.onDragBegin(dragBeginData);
          },
        ),
      )
      ..add(
        mapGestureRecognizer.dragMove.listen(
          (point) {
            _touchEventsObserver?.onDragMove(point);
          },
        ),
      )
      ..add(
        mapGestureRecognizer.dragEnd.listen(
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
    final map = _mapController?.map;
    if (map == null || callbacks.isEmpty) {
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
  final MapWidgetController? controller;
  final sdk.MapControllerOptions controllerOptions;
  final MapWidgetOptions viewOptions;
  final Widget? child;
  final bool showCopyright;

  // Не можем использовать const конструктор тут, т.к.
  // некоторые из параметров – обертки над нативными объектами,
  // и для них это неприменимо
  // ignore: prefer_const_constructors_in_immutables
  MapWidgetInternal({
    required this.sdkContext,
    this.controller,
    this.controllerOptions = const sdk.MapControllerOptions(),
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
    super.controller,
    super.controllerOptions,
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

  final LayerHandle<ClipRectLayer> _clipRectLayer =
      LayerHandle<ClipRectLayer>();
  Size _currentTextureSize = Size.zero;
  bool _isDisposed = false;
  CancelableOperation<bool>? _renderingWait;

  _MapRenderBox(
    this.textureId,
    this.deviceDensity,
    this.textureController,
    this.mapWidgetController,
  );

  Future<void> _updateMapSize(Size newSize) async {
    final textureId = this.textureId;
    if (_isDisposed ||
        textureId == null ||
        newSize.width == 0.0 ||
        newSize.height == 0.0) {
      return;
    }

    markNeedsPaint();

    final width = (newSize.width * deviceDensity).toInt();
    final height = (newSize.height * deviceDensity).toInt();
    await textureController.update(textureId, width, height);
    if (_isDisposed || this.textureId != textureId) {
      return;
    }

    final screenSize = sdk.ScreenSize(width: width, height: height);
    mapWidgetController._provider?.resizeSurface(screenSize);
    final map = mapWidgetController._mapController?.map;
    map?.camera.size = screenSize;

    final renderer = mapWidgetController._renderer;
    if (renderer == null) {
      return;
    }

    unawaited(_renderingWait?.cancel());
    final renderingWait = renderer.waitForRendering();
    _renderingWait = renderingWait;
    unawaited(
      renderingWait.valueOrCancellation(false).then((isRendered) {
        if (_renderingWait != renderingWait) {
          return;
        }
        _renderingWait = null;

        if (isRendered != true || _isDisposed || this.textureId != textureId) {
          return;
        }
        _currentTextureSize = newSize;
        markNeedsPaint();
      }),
    );
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
      _clipRectLayer.layer = context.pushClipRect(
        true,
        offset,
        offset & size,
        _paintTexture,
        oldLayer: _clipRectLayer.layer,
      );
      return;
    }
    _clipRectLayer.layer = null;
    _paintTexture(context, offset);
  }

  @override
  void dispose() {
    _isDisposed = true;
    unawaited(_renderingWait?.cancel());
    _renderingWait = null;
    _clipRectLayer.layer = null;
    super.dispose();
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
  late final bool _ownsMapWidgetController;
  int? _textureId;
  int? _createdTextureId;
  AppLifecycleState? _appState;
  _MapGestureController? _mapGestureController;
  StreamSubscription<sdk.CameraChange>? _cameraChangeSubscription;
  CancelableOperation<bool>? _renderingWait;
  double _deviceDensity = 1;
  double _devicePpi = 1;
  late final ValueNotifier<sdk.MapTheme> _mapTheme;
  bool isMapInitialized = false;

  @override
  void initState() {
    super.initState();
    _ownsMapWidgetController = widget.controller == null;
    mapWidgetController = widget.controller ??
        MapWidgetController(
          widget.sdkContext,
          controllerOptions: widget.controllerOptions,
        );
    mapWidgetController._updateMapTheme();
    WidgetsBinding.instance.addObserver(this);
    _appState = WidgetsBinding.instance.lifecycleState;
    _mapTheme = ValueNotifier(mapWidgetController._appearance.mapTheme);
    if (widget.child != null) {
      mapWidgetController._mapThemeChangedCallbacks.add(_onMapThemeChanged);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isMapInitialized) {
      isMapInitialized = true;
      _deviceDensity = widget.viewOptions.deviceDensity?.value ??
          MediaQuery.devicePixelRatioOf(context);
      _devicePpi =
          widget.viewOptions.devicePPI?.value ?? _deviceDensity * 160.0;
      unawaited(_initialize());
    }
  }

  @override
  void dispose() {
    unawaited(_renderingWait?.cancel());
    _renderingWait = null;
    if (_ownsMapWidgetController) {
      mapWidgetController.dispose();
    } else {
      unawaited(mapWidgetController._cancelConnections());
    }
    _disposeTexture();
    mapWidgetController._mapThemeChangedCallbacks.remove(_onMapThemeChanged);
    WidgetsBinding.instance.removeObserver(this);
    _cameraChangeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final map = mapWidgetController._mapController?.map;
    if (_textureId == null || map == null) {
      return Container(
        color: mapWidgetController.loadingBackground,
      );
    }

    return ColoredBox(
      color: mapWidgetController.loadingBackground,
      child: Stack(
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
              map: map,
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
                map: map,
                mapTheme: theme,
                child: widget.child!,
              ),
            ),
        ],
      ),
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
    try {
      final mapController = await mapWidgetController._ensureMapController();
      if (!mounted) {
        return;
      }

      final map = mapController.map;
      map.camera.setDevicePpi(
        sdk.DevicePpi(_devicePpi),
        sdk.DeviceDensity(_deviceDensity),
      );

      final provider = mapWidgetController._provider!;
      final id = await _controller.initialize(provider.id);
      if (id == null) {
        return;
      }

      _createdTextureId = id;
      if (!mounted) {
        _disposeTexture();
        return;
      }

      final screenFps = await _controller.getScreenFps();
      if (!mounted) {
        return;
      }

      mapWidgetController
        ..maxFps = mapWidgetController.maxFps ?? sdk.Fps(screenFps ?? 60)
        ..powerSavingMaxFps =
            mapWidgetController.powerSavingMaxFps ?? sdk.Fps(screenFps ?? 60);

      _updateMapVisibility();

      final mapGestureRecognizer = mapWidgetController._mapGestureRecognizer!;
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

      final renderer = mapWidgetController._renderer!;
      unawaited(_renderingWait?.cancel());
      final renderingWait = renderer.waitForRendering();
      _renderingWait = renderingWait;
      unawaited(
        renderingWait.valueOrCancellation(false).then((isRendered) {
          if (_renderingWait != renderingWait) {
            return;
          }
          _renderingWait = null;

          if (isRendered != true || !mounted || _createdTextureId != id) {
            return;
          }
          setState(() {
            _textureId = id;
          });
        }),
      );
    } catch (error, stackTrace) {
      _disposeTexture();
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'dgis_mobile_sdk',
          context: ErrorDescription('while initializing MapWidget'),
        ),
      );
    }
  }

  void _disposeTexture() {
    final textureId = _createdTextureId ?? _textureId;
    _createdTextureId = null;
    _textureId = null;
    if (textureId != null) {
      _controller.dispose(textureId);
    }
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

    final map = mapWidgetController._mapController?.map;
    map?.mapVisibilityState = mapVisibilityState;
  }

  void _onMapThemeChanged(sdk.MapTheme theme) {
    _mapTheme.value = theme;
  }
}

class _MapProvider extends InheritedWidget {
  final sdk.Map map;
  final sdk.MapTheme mapTheme;

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

/// Метод, позволяющий получить [sdk.MapTheme] из виджета, находящегося
/// выше по дереву.
sdk.MapTheme? mapThemeOf(BuildContext context) {
  return context.dependOnInheritedWidgetOfExactType<_MapProvider>()?.mapTheme;
}
