import 'package:flutter/material.dart';

import './route_editor_controller.dart';
import './route_editor_theme.dart';
import './route_point_ui.dart';

/// Factory interface for creating route search point views.
///
/// This interface allows customization of how start and finish points
/// are displayed in the route editor header.
///
/// Example usage:
/// ```dart
/// class CustomRouteSearchPointBuilder implements RouteSearchPointBuilder {
///   @override
///   Widget buildStartPointView(
///     RoutePointUI point,
///     RouteEditorController controller,
///     RouteEditorViewTheme theme,
///   ) {
///     return Container(
///       padding: EdgeInsets.all(8),
///       child: Text('From: ${point.label}', style: TextStyle(color: Colors.green)),
///     );
///   }
///
///   @override
///   Widget buildFinishPointView(
///     RoutePointUI point,
///     RouteEditorController controller,
///     RouteEditorViewTheme theme,
///   ) {
///     return Container(
///       padding: EdgeInsets.all(8),
///       child: Text('To: ${point.label}', style: TextStyle(color: Colors.red)),
///     );
///   }
/// }
/// ```
abstract class RouteSearchPointBuilder {
  /// Creates a widget for displaying the start point.
  ///
  /// [point] - The route point UI data
  /// [controller] - The route editor controller for accessing state and actions
  /// [theme] - The current route editor theme for styling
  Widget buildStartPointView(
    RoutePointUI point,
    RouteEditorController controller,
    RouteEditorViewTheme theme,
  );

  /// Creates a widget for displaying the finish point.
  ///
  /// [point] - The route point UI data
  /// [controller] - The route editor controller for accessing state and actions
  /// [theme] - The current route editor theme for styling
  Widget buildFinishPointView(
    RoutePointUI point,
    RouteEditorController controller,
    RouteEditorViewTheme theme,
  );
}

/// Default implementation of [RouteSearchPointBuilder].
///
/// Provides the standard route point display with theme-appropriate styling,
/// text overflow handling, and proper text styles for start and finish points.
class DefaultRouteSearchPointBuilder implements RouteSearchPointBuilder {
  const DefaultRouteSearchPointBuilder();

  @override
  Widget buildStartPointView(
    RoutePointUI point,
    RouteEditorController controller,
    RouteEditorViewTheme theme,
  ) {
    return Text(
      point.label,
      style: theme.startLabelTextStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget buildFinishPointView(
    RoutePointUI point,
    RouteEditorController controller,
    RouteEditorViewTheme theme,
  ) {
    return Text(
      point.label,
      style: theme.finishLabelTextStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
