import 'dart:async';
import 'dart:math';

import 'package:async/async.dart';
import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:flutter/material.dart';

import 'common.dart';

class FpsPage extends StatefulWidget {
  const FpsPage({required this.title, super.key});

  final String title;

  @override
  State<FpsPage> createState() => _FpsState();
}

class _FpsButtonState {
  final bool isPressed;
  final sdk.Fps currentFps;

  const _FpsButtonState({
    this.isPressed = false,
    this.currentFps = const sdk.Fps(),
  });

  _FpsButtonState copyWith({bool? isPressed, sdk.Fps? currentFps}) {
    return _FpsButtonState(
      isPressed: isPressed ?? this.isPressed,
      currentFps: currentFps ?? this.currentFps,
    );
  }
}

class _FpsState extends State<FpsPage> {
  final _sdkContext = AppContainer().initializeSdk();
  final _mapWidgetController = sdk.MapWidgetController();
  final _maxFps = TextEditingController();
  final _powerSavingMaxFps = TextEditingController();
  final _fpsButtonState = ValueNotifier(const _FpsButtonState());
  late final StreamSubscription<sdk.Fps> _fpsSubscription;
  sdk.Map? _sdkMap;
  CancelableOperation<sdk.CameraAnimatedMoveResult>? _moveCancelable;

  @override
  void initState() {
    super.initState();
    _initContext();
  }

  @override
  void dispose() {
    _fpsSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: <Widget>[
          sdk.MapWidget(
            sdkContext: _sdkContext,
            mapOptions: sdk.MapOptions(),
            controller: _mapWidgetController,
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints.tight(const Size(100, 50)),
                    child: TextFormField(
                      controller: _maxFps,
                      decoration: const InputDecoration(
                        labelText: 'Max fps',
                      ),
                      onFieldSubmitted: (value) {
                        _mapWidgetController.maxFps =
                            sdk.Fps(int.tryParse(value)!);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a value for max fps';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid integer';
                        }
                        return null;
                      },
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints.tight(const Size(100, 50)),
                    child: TextFormField(
                      controller: _powerSavingMaxFps,
                      decoration: const InputDecoration(
                        labelText: 'PS max fps',
                      ),
                      onFieldSubmitted: (value) {
                        _mapWidgetController.powerSavingMaxFps =
                            sdk.Fps(int.tryParse(value)!);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a value for power saving max fps';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid integer';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: ValueListenableBuilder<_FpsButtonState>(
              valueListenable: _fpsButtonState,
              builder: (_, state, __) => GestureDetector(
                onTap: () {
                  _onFpsButtonTap(state);
                },
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: state.isPressed
                        ? const Color(0xffffffff)
                        : const Color(0xffcccccc),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: Align(
                    child: Text(
                      'FPS: ${state.currentFps.value}',
                      style: const TextStyle(
                        color: Color(0xff121212),
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initContext() async {
    _mapWidgetController.getMapAsync((map) {
      _sdkMap = map;
      _fpsSubscription = _mapWidgetController.fpsChannel.listen((fps) {
        _fpsButtonState.value = _fpsButtonState.value.copyWith(currentFps: fps);
      });
    });
  }

  Future<void> _onFpsButtonTap(_FpsButtonState state) async {
    final newPressedState = !state.isPressed;
    if (newPressedState) {
      final currentPosition = _sdkMap!.camera.position;
      _moveCancelable = _sdkMap?.camera
          .moveWithController(_FpsMoveController(currentPosition));
    } else {
      await _moveCancelable?.cancel();
      _moveCancelable = null;
    }
    _fpsButtonState.value =
        _fpsButtonState.value.copyWith(isPressed: newPressedState);
  }
}

class _FpsMoveController extends sdk.CameraMoveController {
  final sdk.CameraPosition _initialPosition;

  _FpsMoveController(this._initialPosition);

  @override
  sdk.CameraPosition position(Duration time) {
    final offset = sin(time.inMilliseconds * 0.001);
    final res = _initialPosition.copyWith(
      zoom: sdk.Zoom(max(0, _initialPosition.zoom.value + offset)),
    );
    return res;
  }

  @override
  Duration animationTime() {
    return const Duration(seconds: 100);
  }
}
