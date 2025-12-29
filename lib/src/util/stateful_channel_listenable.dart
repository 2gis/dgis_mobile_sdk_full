import 'dart:async';
import 'package:flutter/foundation.dart';
import '../generated/stateful_channel.dart';

class StatefulChannelValueListenable<Value> extends ValueListenable<Value> {
  final StatefulChannel<Value> _channel;
  final Map<VoidCallback, StreamSubscription<Value>> _listeners = {};

  StatefulChannelValueListenable._(this._channel);

  @override
  Value get value => _channel.value;

  @override
  void addListener(VoidCallback listener) {
    _listeners[listener] = this._channel.listen((_) {
      listener();
    });
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners[listener]?.cancel();
    _listeners.remove(listener);
  }
}

extension StatefulChannelValueListenableExtension<Value>
    on StatefulChannel<Value> {
  StatefulChannelValueListenable<Value> asValueListenable() =>
      StatefulChannelValueListenable._(this);
}
