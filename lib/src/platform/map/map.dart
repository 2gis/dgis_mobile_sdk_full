import '../../generated/dart_bindings.dart' as sdk;
import 'map_theme.dart';

extension SetAttributesTheme on sdk.Map {
  void setTheme(MapTheme? theme) {
    const themeAttributeName = 'theme';
    if (theme != null) {
      attributes.setAttributeValue(
        themeAttributeName,
        sdk.AttributeValue.string(theme.name),
      );
    } else {
      attributes.removeAttribute(themeAttributeName);
    }
  }
}

extension SetAttributesNavigationParking on sdk.Map {
  static const parkingOnAttributeName = 'parkingOn';

  void setNavigation({required bool isOn}) {
    const attributeName = 'navigatorOn';
    final attributeValue = attributes.getAttributeValue(attributeName);
    final oldValue = attributeValue.asBoolean;
    if (oldValue != isOn) {
      attributes.setAttributeValue(
        attributeName,
        sdk.AttributeValue.boolean(isOn),
      );
    }
  }

  bool isParkingOn() {
    return attributes.getAttributeValue(parkingOnAttributeName).asBoolean ?? false;
  }

  void setParkingOn({required bool isOn}) {
    final attributeValue = attributes.getAttributeValue(parkingOnAttributeName);
    final oldValue = attributeValue.asBoolean;
    if (oldValue != isOn) {
      attributes.setAttributeValue(
        parkingOnAttributeName,
        sdk.AttributeValue.boolean(isOn),
      );
    }
  }
}
