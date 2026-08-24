import '../../generated/dart_bindings.dart' as sdk;

extension SetAttributesNavigationParking on sdk.Map {
  static const parkingOnAttributeName = 'parkingOn';

  void setNavigation({required bool isOn}) {
    const attributeName = 'navigatorOn';
    final attributeValue = attributes.getAttributeValue(attributeName);
    final oldValue = attributeValue.asBoolean;
    if (oldValue != null && oldValue != isOn) {
      attributes.setAttributeValue(
        attributeName,
        sdk.AttributeValue.boolean(isOn),
      );
    }
  }

  bool isParkingOn() {
    return attributes.getAttributeValue(parkingOnAttributeName).asBoolean ??
        false;
  }

  void setParkingOn({required bool isOn}) {
    final attributeValue = attributes.getAttributeValue(parkingOnAttributeName);
    final oldValue = attributeValue.asBoolean;
    if (oldValue != null && oldValue != isOn) {
      attributes.setAttributeValue(
        parkingOnAttributeName,
        sdk.AttributeValue.boolean(isOn),
      );
    }
  }
}
