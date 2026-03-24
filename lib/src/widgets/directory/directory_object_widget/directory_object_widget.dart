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
/// Usage example:
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
class DirectoryObjectWidget extends StatefulWidget {
  /// View model containing all display data for the directory object.
  final DirectoryObjectViewModel viewModel;

  /// Theme configuration for visual styling.
  final DirectoryObjectWidgetTheme theme;

  /// Builder for customizing individual sections of the widget.
  final DirectoryObjectWidgetBuilder builder;

  /// Initial snap position (0.0 to 1.0).
  final double initialSnapFraction;

  /// Whether to start in expanded state.
  final bool startExpanded;

  /// Optional scroll controller for use with DraggableScrollableSheet.
  final ScrollController? scrollController;

  const DirectoryObjectWidget({
    required this.viewModel,
    required this.theme,
    DirectoryObjectWidgetBuilder? builder,
    this.initialSnapFraction = 0.25,
    this.startExpanded = false,
    this.scrollController,
    super.key,
  }) : builder = builder ?? const DefaultDirectoryObjectWidgetBuilder();

  @override
  State<DirectoryObjectWidget> createState() => _DirectoryObjectWidgetState();
}

class _DirectoryObjectWidgetState extends State<DirectoryObjectWidget> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.startExpanded;
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _minimizeCard() {
    setState(() {
      _isExpanded = false;
    });
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
        mainAxisSize: MainAxisSize.min,
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
            onTap: _toggleExpanded,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildHeaderContent(),
            ),
          ),
          if (_isExpanded) ...[
            Divider(color: widget.theme.dividerColor, height: 1),
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
                        _minimizeCard,
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
        ],
      ),
    );
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
