import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'navigation_settings_theme.dart';

/// Caption above a group of settings rows.
///
/// Its bottom hairline marks the top edge of the section that follows.
@internal
class NavigationSettingsSectionHeader extends StatelessWidget {
  /// Text of the header, in sentence case.
  final String label;

  /// Color and typography tokens.
  final NavigationSettingsTheme theme;

  const NavigationSettingsSectionHeader({
    required this.label,
    required this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Semantics(
        header: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: theme.colors.divider),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              label.toUpperCase(),
              style: theme.typography.sectionHeader.copyWith(
                color: theme.colors.sectionHeader,
              ),
            ),
          ),
        ),
      );
}
