import 'package:flutter/widgets.dart';

import '../../generated/dart_bindings.dart' as sdk;

sdk.MapAppearance defaultMapAppearance() {
  return sdk.MapAppearance.bySystem(
    sdk.BySystem(
      light: sdk.MapTheme.defaultTheme,
      dark: sdk.MapTheme.defaultDarkTheme,
    ),
  );
}

extension MakeMapTheme on sdk.MapAppearance {
  sdk.MapTheme get mapTheme {
    return match(
      fixed: (value) => value.theme,
      bySystem: (value) {
        return isDarkTheme ? value.dark : value.light;
      },
    );
  }

  bool get isDarkTheme {
    return match(
      fixed: (value) => false,
      bySystem: (value) {
        final brightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        return brightness == Brightness.dark;
      },
    );
  }
}
