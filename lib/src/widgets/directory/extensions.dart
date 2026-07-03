import '../../generated/dart_bindings.dart' as sdk;

extension OpenStatusExtension on sdk.OpenStatus {
  bool get isOpen => isOpened || isClosingSoon;
}
