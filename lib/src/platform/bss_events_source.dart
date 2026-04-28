import '../generated/dart_bindings.dart';
import 'dgis.dart';

/// Switches the BSS statistics source to SDK for the duration of [block],
/// after which the guard is released and the source reverts to its original User state.
T withBssEventsSourceFromSdk<T>(T Function() block) {
  // ignore: unused_local_variable
  final guard = setupBssEventsSourceFromSdk(DGis().context);
  return block();
}
