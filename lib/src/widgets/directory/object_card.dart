import 'package:flutter/material.dart';

import '../../generated/dart_bindings.dart' as sdk;
import '../either.dart';

class SuggestionCard extends StatelessWidget {
  final VoidCallback onTap;
  final EitherDirectoryObjOrSuggest suggestion;
  final TextStyle objectCardHighlightedTextStyle;
  final TextStyle objectCardNormalTextStyle;
  final Color objectCardTileColor;

  const SuggestionCard({
    required this.suggestion,
    required this.onTap,
    required this.objectCardHighlightedTextStyle,
    required this.objectCardNormalTextStyle,
    required this.objectCardTileColor,
    super.key,
  });

  TextSpan _createHighlightedString(sdk.MarkedUpText text) {
    final normalStyle = objectCardNormalTextStyle;
    final highlightStyle = objectCardHighlightedTextStyle;

    if (text.matchedParts.isEmpty || text.text.isEmpty) {
      return TextSpan(text: text.text, style: normalStyle);
    }

    if (text.matchedParts.any(
      (element) => element.offset + element.length > text.text.length,
    )) {
      return TextSpan(text: text.text, style: normalStyle);
    }

    final spans = <TextSpan>[];
    var lastMatchEnd = 0;

    for (final part in text.matchedParts) {
      if (part.offset > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: text.text.substring(lastMatchEnd, part.offset),
            style: normalStyle,
          ),
        );
      }

      spans.add(
        TextSpan(
          text: text.text.substring(part.offset, part.offset + part.length),
          style: highlightStyle,
        ),
      );

      lastMatchEnd = part.offset + part.length;
    }

    if (lastMatchEnd < text.text.length) {
      spans.add(
        TextSpan(
          text: text.text.substring(lastMatchEnd),
          style: normalStyle,
        ),
      );
    }

    return TextSpan(children: spans);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.search, color: Colors.black),
        title: suggestion.fold(
          (left) => Text(
            left.title,
            style: objectCardNormalTextStyle,
          ),
          (right) => RichText(text: _createHighlightedString(right.title)),
        ),
        subtitle: suggestion.fold(
          (left) => Text(
            left.subtitle,
            style: objectCardNormalTextStyle,
          ),
          (right) => RichText(text: _createHighlightedString(right.subtitle)),
        ),
        tileColor: objectCardTileColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
