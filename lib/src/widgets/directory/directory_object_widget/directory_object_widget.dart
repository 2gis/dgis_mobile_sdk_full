import 'package:flutter/material.dart';

import './directory_object_view_model.dart';
import './directory_object_widget_builder.dart';
import './directory_object_widget_theme.dart';

/// Widget for displaying detailed information about a directory object
/// in a bottom sheet format.
///
/// This widget displays comprehensive information about a place or organization,
/// including:
/// * Title, subtitle, and close button
/// * Star rating with review count
/// * Distance from current location
/// * Short address
/// * Additional information (e.g., porches count)
/// * Work status alerts
/// * Expandable sections for:
///   - Full address with entrances button
///   - Porches/entrances information
///   - Working hours
///   - Contacts (phones, messengers)
///   - Websites and social networks
///
/// The widget supports two states:
/// * Collapsed: Shows header information only
/// * Expanded: Shows all sections in a scrollable view
///
/// These map to **peek** vs **expanded** heights of the host
/// [DraggableScrollableSheet] (use [showAsBottomSheet] or pass [scrollController]
/// and the sheet callbacks yourself). The header stays fixed; the block below
/// scrolls in a [SingleChildScrollView].
///
/// Usage example:
///
/// ```dart
/// final viewModel = DirectoryObjectViewModel.fromDirectoryObject(
///   object: directoryObject,
///   localizations: localizations,
///   onDismiss: () => Navigator.of(context).pop(),
///   formattedDistance: '1.2 km',
/// );
///
/// DirectoryObjectWidget(
///   viewModel: viewModel,
///   theme: DirectoryObjectWidgetTheme.defaultLight,
/// )
/// ```
///
/// For a [DraggableScrollableSheet] host you must also pass [scrollController]
/// and the sheet callbacks ([onHeaderHeightChanged], [onExpandRequest],
/// [onHeaderDragUpdate], [onHeaderDragEnd], [onMinimizeRequest]); or use
/// [showAsBottomSheet] below.
///
/// Usage example ([showAsBottomSheet] — recommended):
///
/// ```dart
/// final viewModel = DirectoryObjectViewModel.fromDirectoryObject(
///   object: directoryObject,
///   localizations: localizations,
///   onDismiss: () => Navigator.of(context).pop(),
///   formattedDistance: '1.2 km',
/// );
///
/// await DirectoryObjectWidget.showAsBottomSheet<void>(
///   context: context,
///   viewModel: viewModel,
///   theme: DirectoryObjectWidgetTheme.defaultLight,
///   startExpanded: false,
/// );
/// ```
///
/// See also: `map_objects_identification.dart` in the SDK example app
/// (`_showFullDirectoryObjectCard`).
class DirectoryObjectWidget extends StatefulWidget {
  /// View model containing all display data for the directory object.
  final DirectoryObjectViewModel viewModel;

  /// Theme configuration for visual styling.
  final DirectoryObjectWidgetTheme theme;

  /// Builder for customizing individual sections of the widget.
  final DirectoryObjectWidgetBuilder builder;

  /// Peek fraction fallback for the host sheet before the header height is known.
  final double initialSnapFraction;

  /// Whether the host sheet should start fully expanded (`true`) or at peek (`false`).
  final bool startExpanded;

  /// Optional scroll controller (typically from [DraggableScrollableSheet]).
  final ScrollController? scrollController;

  /// Reports the measured height of the header (capsule + title block), in logical pixels.
  final ValueChanged<double>? onHeaderHeightChanged;

  /// Header tap — expand the host sheet (e.g. animate to `maxChildSize`).
  final VoidCallback? onExpandRequest;

  /// Header vertical drag update.
  final GestureDragUpdateCallback? onHeaderDragUpdate;

  /// Header vertical drag end.
  final GestureDragEndCallback? onHeaderDragEnd;

  /// Collapse the host sheet to peek (e.g. before showing entrances on the map).
  final VoidCallback? onMinimizeRequest;

  const DirectoryObjectWidget({
    required this.viewModel,
    required this.theme,
    DirectoryObjectWidgetBuilder? builder,
    this.initialSnapFraction = 0.25,
    this.startExpanded = false,
    this.scrollController,
    this.onHeaderHeightChanged,
    this.onExpandRequest,
    this.onHeaderDragUpdate,
    this.onHeaderDragEnd,
    this.onMinimizeRequest,
    super.key,
  }) : builder = builder ?? const DefaultDirectoryObjectWidgetBuilder();

  /// Opens a **transparent** modal bottom sheet containing a
  /// [DraggableScrollableSheet] pre-wired to [DirectoryObjectWidget].
  ///
  /// Snap positions: **peek** (from measured header height, with
  /// [initialSnapFraction] as fallback before the first layout) and
  /// **[maxChildSize]** (fraction of screen height, default `0.9`).
  ///
  /// Parameters correspond to the widget constructor where applicable:
  /// [viewModel], [theme], [builder], [startExpanded], [initialSnapFraction].
  ///
  /// Returns the same [Future] as [showModalBottomSheet] (result when the route
  /// is popped). Example usage: SDK **example** `map_objects_identification.dart`
  /// → `_showFullDirectoryObjectCard`.
  static Future<T?> showAsBottomSheet<T>({
    required BuildContext context,
    required DirectoryObjectViewModel viewModel,
    required DirectoryObjectWidgetTheme theme,
    DirectoryObjectWidgetBuilder? builder,
    bool startExpanded = false,
    double initialSnapFraction = 0.25,
    double maxChildSize = 0.9,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DirectoryObjectDraggableSheet(
        viewModel: viewModel,
        theme: theme,
        builder: builder,
        startExpanded: startExpanded,
        initialSnapFraction: initialSnapFraction,
        maxChildSize: maxChildSize,
      ),
    );
  }

  @override
  State<DirectoryObjectWidget> createState() => _DirectoryObjectWidgetState();
}

class _DirectoryObjectWidgetState extends State<DirectoryObjectWidget> {
  final GlobalKey _headerKey = GlobalKey();
  double? _lastReportedHeaderHeight;

  @override
  void initState() {
    super.initState();
    _scheduleHeaderHeightMeasure();
  }

  @override
  void didUpdateWidget(DirectoryObjectWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.onHeaderHeightChanged == null) return;

    if (_headerLayoutInputsChanged(oldWidget)) {
      _scheduleHeaderHeightMeasure();
    }
  }

  bool _headerLayoutInputsChanged(DirectoryObjectWidget oldWidget) {
    return !identical(oldWidget.viewModel, widget.viewModel) ||
        oldWidget.theme != widget.theme ||
        oldWidget.builder != widget.builder ||
        !identical(
          oldWidget.onHeaderHeightChanged,
          widget.onHeaderHeightChanged,
        );
  }

  void _scheduleHeaderHeightMeasure() {
    if (widget.onHeaderHeightChanged == null) {
      return;
    }
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _measureAndReportHeaderHeight());
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: widget.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            key: widget.onHeaderHeightChanged != null ? _headerKey : null,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: widget.theme.capsuleColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              GestureDetector(
                onTap: widget.onExpandRequest,
                onVerticalDragUpdate: widget.onHeaderDragUpdate,
                onVerticalDragEnd: widget.onHeaderDragEnd,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildHeaderContent(),
                ),
              ),
              Divider(color: widget.theme.dividerColor, height: 1),
            ],
          ),
          Expanded(
            child: ColoredBox(
              color: widget.theme.secondaryBackgroundColor,
              child: SingleChildScrollView(
                controller: widget.scrollController,
                padding: const EdgeInsets.only(
                  top: 10,
                  left: 15,
                  right: 15,
                  bottom: 80,
                ),
                child: _SpacedColumn(
                  spacing: 16,
                  children: [
                    widget.builder.buildFullAddressWidget(
                      widget.viewModel,
                      widget.theme,
                      _minimizeFromContent,
                    ),
                    widget.builder.buildPorchesWidget(
                      widget.viewModel,
                      widget.theme,
                    ),
                    widget.builder.buildWorkingHoursWidget(
                      widget.viewModel,
                      widget.theme,
                    ),
                    widget.builder.buildContactsWidget(
                      widget.viewModel,
                      widget.theme,
                    ),
                    widget.builder.buildSitesAndSocialNetworksWidget(
                      widget.viewModel,
                      widget.theme,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _measureAndReportHeaderHeight() {
    if (!mounted || widget.onHeaderHeightChanged == null) {
      return;
    }
    final ctx = _headerKey.currentContext;
    if (ctx == null) {
      return;
    }
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return;
    }
    final h = box.size.height;
    if (_lastReportedHeaderHeight != h) {
      _lastReportedHeaderHeight = h;
      widget.onHeaderHeightChanged!(h);
    }
  }

  void _minimizeFromContent() {
    widget.onMinimizeRequest?.call();
  }

  Widget _buildHeaderContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.builder.buildTitleWidget(
                    widget.viewModel,
                    widget.theme,
                  ),
                  widget.builder.buildSubtitleWidget(
                    widget.viewModel,
                    widget.theme,
                  ),
                ],
              ),
            ),
            widget.builder.buildCloseButton(
              widget.viewModel,
              widget.theme,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Row(
            children: [
              Expanded(
                child: widget.builder.buildRatingWidget(
                  widget.viewModel,
                  widget.theme,
                ),
              ),
              widget.builder.buildDistanceWidget(
                widget.viewModel,
                widget.theme,
              ),
            ],
          ),
        ),
        widget.builder.buildShortAddressWidget(
          widget.viewModel,
          widget.theme,
        ),
        widget.builder.buildAdditionalInfoWidget(
          widget.viewModel,
          widget.theme,
        ),
        widget.builder.buildAlertWidget(
          widget.viewModel,
          widget.theme,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

/// Hosts [DraggableScrollableSheet] + [DirectoryObjectWidget] with coordinated
/// peek size and expand/minimize.
class _DirectoryObjectDraggableSheet extends StatefulWidget {
  const _DirectoryObjectDraggableSheet({
    required this.viewModel,
    required this.theme,
    required this.startExpanded,
    required this.initialSnapFraction,
    required this.maxChildSize,
    this.builder,
  });

  final DirectoryObjectViewModel viewModel;
  final DirectoryObjectWidgetTheme theme;
  final DirectoryObjectWidgetBuilder? builder;
  final bool startExpanded;
  final double initialSnapFraction;
  final double maxChildSize;

  @override
  State<_DirectoryObjectDraggableSheet> createState() =>
      _DirectoryObjectDraggableSheetState();
}

class _DirectoryObjectDraggableSheetState
    extends State<_DirectoryObjectDraggableSheet> {
  static const Duration _sheetExtentAnimationDuration =
      Duration(milliseconds: 250);
  static const double _sheetSnapVelocityThreshold = 250;

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  double _minFraction = 0.25;
  bool _headerMeasured = false;

  @override
  void initState() {
    super.initState();
    _minFraction = widget.initialSnapFraction;
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  void _onHeaderHeightChanged(double headerHeight) {
    if (!mounted) return;

    final screenH = MediaQuery.sizeOf(context).height;
    final fraction = (headerHeight / screenH).clamp(0.0, widget.maxChildSize);
    if (!_headerMeasured || (_minFraction - fraction).abs() > 0.0001) {
      setState(() {
        _headerMeasured = true;
        _minFraction = fraction;
      });
    }
  }

  void _expand() {
    if (!_sheetController.isAttached) {
      return;
    }
    _sheetController.animateTo(
      widget.maxChildSize,
      duration: _sheetExtentAnimationDuration,
      curve: Curves.easeOutCubic,
    );
  }

  void _minimize() {
    if (!_sheetController.isAttached) {
      return;
    }
    _sheetController.animateTo(
      _minFraction,
      duration: _sheetExtentAnimationDuration,
      curve: Curves.easeOutCubic,
    );
  }

  void _onHeaderDragUpdate(DragUpdateDetails details) {
    if (!_sheetController.isAttached) {
      return;
    }
    final screenH = MediaQuery.sizeOf(context).height;
    final delta = details.primaryDelta ?? 0;
    final next = (_sheetController.size - delta / screenH).clamp(
      _minFraction,
      widget.maxChildSize,
    );
    _sheetController.jumpTo(next);
  }

  void _onHeaderDragEnd(DragEndDetails details) {
    if (!_sheetController.isAttached) {
      return;
    }

    final velocity = details.primaryVelocity ?? 0;
    final current = _sheetController.size;
    final mid = (_minFraction + widget.maxChildSize) / 2;
    final target = velocity.abs() > _sheetSnapVelocityThreshold
        ? (velocity < 0 ? widget.maxChildSize : _minFraction)
        : (current >= mid ? widget.maxChildSize : _minFraction);

    _sheetController.animateTo(
      target,
      duration: _sheetExtentAnimationDuration,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final max = widget.maxChildSize;
    final min = _minFraction.clamp(0.0, max);
    final initial = (widget.startExpanded ? max : min).clamp(min, max);

    return DraggableScrollableSheet(
      controller: _sheetController,
      maxChildSize: max,
      minChildSize: min,
      initialChildSize: initial,
      snap: true,
      snapSizes: [min, max],
      expand: false,
      shouldCloseOnMinExtent: false,
      builder: (context, scrollController) {
        return DirectoryObjectWidget(
          viewModel: widget.viewModel,
          theme: widget.theme,
          builder: widget.builder,
          initialSnapFraction: widget.initialSnapFraction,
          startExpanded: widget.startExpanded,
          scrollController: scrollController,
          onHeaderHeightChanged: _onHeaderHeightChanged,
          onExpandRequest: _expand,
          onHeaderDragUpdate: _onHeaderDragUpdate,
          onHeaderDragEnd: _onHeaderDragEnd,
          onMinimizeRequest: _minimize,
        );
      },
    );
  }
}

/// Helper widget that arranges sections with spacing,
/// filtering out null children.
class _SpacedColumn extends StatelessWidget {
  final List<Widget?> children;
  final double spacing;

  const _SpacedColumn({
    required this.children,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    final nonNullChildren = children.whereType<Widget>().toList();

    if (nonNullChildren.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < nonNullChildren.length; i++) ...[
          nonNullChildren[i],
          if (i < nonNullChildren.length - 1) SizedBox(height: spacing),
        ],
      ],
    );
  }
}
