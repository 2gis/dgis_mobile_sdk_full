import 'dart:ffi' as ffi;

typedef NativeReleaseFn = void Function(ffi.Pointer<ffi.Void>);

class ClassMessage<T> {
  final int address;
  final NativeReleaseFn _release;

  const ClassMessage(
    this.address,
    this._release,
  );

  void dispose() {
    final ptr = ffi.Pointer<ffi.Void>.fromAddress(address);
    _release(ptr);
  }
}