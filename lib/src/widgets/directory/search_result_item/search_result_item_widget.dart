import 'package:flutter/material.dart';

import '../../../../../l10n/generated/dgis_localizations.dart';
import '../../../../../l10n/generated/dgis_localizations_en.dart';
import './search_result_item_builder.dart';
import './search_result_item_theme.dart';
import './search_result_item_view_model.dart';

/// Widget for displaying a search result item from the directory.
///
/// This widget displays detailed information about a place or organization,
/// including:
/// * Title and subtitle
/// * Star rating with review count
/// * Distance from current location
/// * Address
/// * Attributes (e.g., "Wi-Fi • Parking")
/// * Charging station availability (for EV stations)
/// * Work status alerts
///
/// Usage example:
/// ```dart
/// final viewModel = SearchResultItemViewModel.fromDirectoryObject(
///   object: directoryObject,
///   localizations: localizations,
///   onTap: (object) => print('Selected: ${object.title}'),
/// );
///
/// SearchResultItemWidget(
///   viewModel: viewModel,
///   theme: SearchResultItemTheme.defaultLight,
/// )
/// ```
///
/// Customization is available through:
/// * [theme] - Visual styling configuration
/// * [builder] - Custom widget builders for each section
///
/// The widget automatically handles tap gestures and invokes
/// [SearchResultItemViewModel.onTap] when tapped.
class SearchResultItemWidget extends StatelessWidget {
  /// View model containing all display data for the search result.
  final SearchResultItemViewModel viewModel;

  /// Theme configuration for visual styling.
  final SearchResultItemTheme theme;

  /// Builder for customizing individual sections of the widget.
  ///
  /// Defaults to [DefaultSearchResultItemBuilder] if not provided.
  final SearchResultItemBuilder builder;

  const SearchResultItemWidget({
    required this.viewModel,
    required this.theme,
    SearchResultItemBuilder? builder,
    super.key,
  }) : builder = builder ?? const DefaultSearchResultItemBuilder();

  @override
  Widget build(BuildContext context) {
    final localizations =
        DgisLocalizations.of(context) ?? DgisLocalizationsEn();

    return GestureDetector(
      onTap: () => viewModel.onTap(viewModel.object),
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          builder.buildTitleWidget(viewModel, theme),
          builder.buildSubtitleWidget(viewModel, theme),
          Row(
            children: [
              Expanded(
                child: builder.buildRatingWidget(viewModel, theme),
              ),
              builder.buildDistanceWidget(viewModel, theme),
            ],
          ),
          builder.buildAddressWidget(viewModel, theme),
          builder.buildAttributesWidget(viewModel, theme),
          builder.buildChargingStationWidget(viewModel, theme, localizations),
          builder.buildAlertWidget(viewModel, theme),
        ],
      ),
    );
  }
}
