import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:flutter/material.dart';

class LocationSelectorTheme {
  const LocationSelectorTheme({
    required this.backgroundColor,
    required this.handleColor,
    required this.titleTextStyle,
    required this.buttonBackgroundColor,
    required this.buttonForegroundColor,
    required this.buttonTextStyle,
    required this.unavailableTextStyle,
    required this.searchColorScheme,
  });

  final Color backgroundColor;
  final Color handleColor;
  final TextStyle titleTextStyle;
  final Color buttonBackgroundColor;
  final Color buttonForegroundColor;
  final TextStyle buttonTextStyle;
  final TextStyle unavailableTextStyle;
  final sdk.SearchWidgetColorScheme searchColorScheme;

  static const defaultLight = LocationSelectorTheme(
    backgroundColor: Color(0xFFF1F1F1),
    handleColor: Color(0x4D5A5A5A),
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Color(0xFF141414),
    ),
    buttonBackgroundColor: Color(0xFF1BA136),
    buttonForegroundColor: Color(0xFFFFFFFF),
    buttonTextStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Color(0xFFFFFFFF),
    ),
    unavailableTextStyle: TextStyle(
      color: Color(0xFF898989),
    ),
    searchColorScheme: sdk.SearchWidgetColorScheme(
      searchBarBackgroundColor: Color(0xFFF1F1F1),
      searchBarTextFieldColor: Color(0xFFFFFFFF),
      searchBarTextStyle: TextStyle(color: Color(0xFF141414)),
      objectCardTileColor: Color(0xFFFFFFFF),
      objectCardHighlightedTextStyle:
          TextStyle(color: Color(0xFF141414), fontWeight: FontWeight.bold),
      objectCardNormalTextStyle: TextStyle(color: Color(0xFF141414)),
      objectListSeparatorColor: Color(0xFFE5E5EA),
      objectListBackgroundColor: Color(0xFFF1F1F1),
      searchResultItemPadding: 24,
    ),
  );

  static const defaultDark = LocationSelectorTheme(
    backgroundColor: Color(0xFF141414),
    handleColor: Color(0x4DB8B8B8),
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Color(0xFFFFFFFF),
    ),
    buttonBackgroundColor: Color(0xFF26C947),
    buttonForegroundColor: Color(0xFFFFFFFF),
    buttonTextStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Color(0xFFFFFFFF),
    ),
    unavailableTextStyle: TextStyle(
      color: Color(0xFF8E8E93),
    ),
    searchColorScheme: sdk.SearchWidgetColorScheme(
      searchBarBackgroundColor: Color(0xFF141414),
      searchBarTextFieldColor: Color(0xFF1C1C1E),
      searchBarTextStyle: TextStyle(color: Color(0xFFFFFFFF)),
      objectCardTileColor: Color(0xFF1C1C1E),
      objectCardHighlightedTextStyle:
          TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.bold),
      objectCardNormalTextStyle: TextStyle(color: Color(0xFFB8B8B8)),
      objectListSeparatorColor: Color(0xFF38383A),
      objectListBackgroundColor: Color(0xFF141414),
      searchResultItemPadding: 24,
    ),
  );
}

class LocationSelectorSheet extends StatelessWidget {
  final bool isSelectingStart;
  final sdk.SearchManager? searchManager;
  final void Function(sdk.DirectoryObject) onDirectoryObjectSelected;
  final VoidCallback onMyLocationPressed;
  final VoidCallback onChooseOnMapPressed;
  final LocationSelectorTheme theme;

  const LocationSelectorSheet({
    required this.isSelectingStart,
    required this.searchManager,
    required this.onDirectoryObjectSelected,
    required this.onMyLocationPressed,
    required this.onChooseOnMapPressed,
    required this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final title =
        isSelectingStart ? 'Select start location' : 'Select destination';
    const myLocationText = 'My Location';
    const chooseOnMapText = 'Choose on Map';
    const unavailableText = 'Search not available';

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.handleColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(title, style: theme.titleTextStyle),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onMyLocationPressed,
                        icon: const Icon(Icons.my_location),
                        label: const Text(myLocationText),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.buttonBackgroundColor,
                          foregroundColor: theme.buttonForegroundColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onChooseOnMapPressed,
                        icon: const Icon(Icons.map),
                        label: const Text(chooseOnMapText),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.buttonBackgroundColor,
                          foregroundColor: theme.buttonForegroundColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: searchManager != null
                ? sdk.DgisSearchWidget(
                    searchManager: searchManager!,
                    onObjectSelected: onDirectoryObjectSelected,
                    colorScheme: theme.searchColorScheme,
                  )
                : Center(
                    child: Text(
                      unavailableText,
                      style: theme.unavailableTextStyle,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
