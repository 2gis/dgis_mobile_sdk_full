import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../generated/dart_bindings.dart' as sdk;
import '../../../platform/bss_events_source.dart';
import './traffic_model.dart';

// Controller for managing traffic visualization and traffic intensity monitoring on the map.
///
/// This controller handles:
/// * Traffic layer visibility toggling
/// * Traffic intensity score tracking
/// * Traffic status monitoring
///
/// The controller provides real-time traffic information through [TrafficModel],
/// allowing users to monitor traffic conditions and control traffic visualization.
///
/// Usage example:
/// ```dart
/// final controller = TrafficController(
///   map: mapInstance,
/// );
///
/// // Toggle traffic visualization
/// controller.toggleTraffic();
///
/// // Access current traffic information
/// print('Traffic score: ${controller.state.value.score}');
/// print('Traffic status: ${controller.state.value.status}');
///
/// // Listen to traffic condition changes
/// controller.state.addListener(() {
///   final model = controller.state.value;
///   print('Traffic intensity updated:');
///   print('Score: ${model.score}');
///   print('Status: ${model.status}');
/// });
/// ```
///
/// The controller maintains a single subscription to traffic state changes
/// and provides a simple mechanism to toggle traffic visualization on the map.
///
/// Traffic score typically ranges from 0 to 10, where:
/// * 0-3: Light traffic
/// * 4-7: Moderate traffic
/// * 8-10: Heavy traffic
///
/// Remember to dispose of the controller when it's no longer needed:
/// ```dart
/// controller.dispose();
/// ```
class TrafficController {
  final sdk.Map map;

  late sdk.TrafficControlModel _trafficModel;
  late StreamSubscription<sdk.TrafficControlState> _stateSubscription;
  late ValueNotifier<TrafficModel> _model;

  ValueNotifier<TrafficModel> get state => _model;

  TrafficController({required this.map}) {
    _init();
  }

  void _init() {
    _trafficModel =
        withBssEventsSourceFromSdk(() => sdk.TrafficControlModel(map));
    _model = ValueNotifier(
      TrafficModel(
        score: _trafficModel.state.score,
        status: _trafficModel.state.status,
      ),
    );
    _stateSubscription = _trafficModel.stateChannel.listen((newState) {
      _model.value = _model.value
          .copyWith(status: newState.status, score: () => newState.score);
    });
  }

  void toggleTraffic() {
    withBssEventsSourceFromSdk(_trafficModel.onClicked);
  }

  void dispose() {
    _stateSubscription.cancel();
  }
}
