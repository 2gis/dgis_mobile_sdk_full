import 'package:flutter/material.dart';

class SearchWidgetColorScheme {
  final Color searchBarBackgroundColor;
  final Color searchBarTextFieldColor;
  final TextStyle? searchBarTextStyle;
  final Color objectCardTileColor;
  final TextStyle objectCardHighlightedTextStyle;
  final TextStyle objectCardNormalTextStyle;
  final Color objectListSeparatorColor;
  final Color objectListBackgroundColor;

  const SearchWidgetColorScheme({
    required this.searchBarBackgroundColor,
    required this.searchBarTextFieldColor,
    required this.objectCardTileColor,
    required this.objectCardHighlightedTextStyle,
    required this.objectCardNormalTextStyle,
    required this.objectListSeparatorColor,
    required this.objectListBackgroundColor,
    this.searchBarTextStyle,
  });

  SearchWidgetColorScheme copyWith({
    Color? searchBarBackgroundColor,
    Color? searchBarTextFieldColor,
    TextStyle? searchBarTextStyle,
    Color? objectCardTileColor,
    TextStyle? objectCardHighlightedTextStyle,
    TextStyle? objectCardNormalTextStyle,
    Color? objectListSeparatorColor,
    Color? objectListBackgroundColor,
  }) {
    return SearchWidgetColorScheme(
      searchBarBackgroundColor:
          searchBarBackgroundColor ?? this.searchBarBackgroundColor,
      searchBarTextFieldColor:
          searchBarTextFieldColor ?? this.searchBarTextFieldColor,
      searchBarTextStyle: searchBarTextStyle ?? this.searchBarTextStyle,
      objectCardTileColor: objectCardTileColor ?? this.objectCardTileColor,
      objectCardHighlightedTextStyle:
          objectCardHighlightedTextStyle ?? this.objectCardHighlightedTextStyle,
      objectCardNormalTextStyle:
          objectCardNormalTextStyle ?? this.objectCardNormalTextStyle,
      objectListSeparatorColor:
          objectListSeparatorColor ?? this.objectListSeparatorColor,
      objectListBackgroundColor:
          objectListBackgroundColor ?? this.objectListBackgroundColor,
    );
  }
}
