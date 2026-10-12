import 'package:flutter/widgets.dart';

import 'navigation_settings_divider.dart';
import 'navigation_settings_theme.dart';

/// Groups navigation settings rows on a shared background.
///
/// A [NavigationSettingsDivider] is inserted between each pair of direct
/// [children]. When [bottomDivider] is true, a full-width hairline marks the
/// bottom edge. The top edge is marked by whatever sits above — a section
/// header hairline or the navigation bar border — so a section right under
/// the bar does not get a doubled line.
class NavigationSettingsSection extends StatelessWidget {
  /// Theme that supplies the section and divider colors.
  final NavigationSettingsTheme theme;

  /// Rows displayed in this section.
  final List<Widget> children;

  /// Whether the bottom edge carries a full-width hairline.
  ///
  /// Turn off for sections drawn as rounded cards.
  final bool bottomDivider;

  const NavigationSettingsSection({
    required this.theme,
    required this.children,
    this.bottomDivider = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final sectionChildren = <Widget>[];
    for (var index = 0; index < children.length; index++) {
      if (index > 0) {
        sectionChildren.add(NavigationSettingsDivider(theme: theme));
      }
      sectionChildren.add(children[index]);
    }

    final edge = BorderSide(color: theme.colors.divider);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.sectionBackground,
        border: bottomDivider ? Border(bottom: edge) : null,
      ),
      child: Padding(
        // The hairline is painted over the box; keep the rows clear of it.
        padding: EdgeInsets.only(bottom: bottomDivider ? edge.width : 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: sectionChildren,
        ),
      ),
    );
  }
}
