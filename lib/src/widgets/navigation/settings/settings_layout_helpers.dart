import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'navigation_settings_repository.dart';
import 'navigation_settings_theme.dart';
import 'settings_key.dart';
import 'settings_toggle.dart';

/// Rebuilds when [key]'s value in [repository] changes.
@internal
Widget observeNavigationSetting<T>({
  required NavigationSettingsRepository repository,
  required SettingsKey<T> key,
  required ValueWidgetBuilder<T> builder,
  Widget? child,
}) =>
    ValueListenableBuilder<T>(
      valueListenable: repository.observe(key),
      builder: builder,
      child: child,
    );

/// Observes a boolean [key] and renders a labelled [NavigationSettingsToggle]
/// that persists changes through [setNavigationSetting].
@internal
Widget observeNavigationToggle({
  required NavigationSettingsRepository repository,
  required BoolSettingsKey key,
  required String label,
  required NavigationSettingsTheme theme,
}) =>
    observeNavigationSetting<bool>(
      repository: repository,
      key: key,
      builder: (context, value, child) => NavigationSettingsToggle(
        label: label,
        value: value,
        onChanged: (value) => setNavigationSetting(repository, key, value),
        theme: theme,
      ),
    );

/// Updates [key] without waiting for persistence.
@internal
void setNavigationSetting<T>(
  NavigationSettingsRepository repository,
  SettingsKey<T> key,
  T value,
) {
  unawaited(repository.set(key, value));
}

/// Returns [theme], or the default theme for the platform brightness.
@internal
NavigationSettingsTheme resolveNavigationSettingsTheme(
  BuildContext context,
  NavigationSettingsTheme? theme,
) {
  if (theme != null) {
    return theme;
  }

  return switch (MediaQuery.platformBrightnessOf(context)) {
    Brightness.dark => NavigationSettingsTheme.defaultDark,
    Brightness.light => NavigationSettingsTheme.defaultLight,
  };
}
