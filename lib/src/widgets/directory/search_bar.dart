import 'package:flutter/material.dart';

class DgisSearchBar extends StatelessWidget {
  final void Function(String) onSearchChanged;
  final void Function(String) onSearchSubmitted;
  final TextEditingController controller;
  final Color searchBarBackgroundColor;
  final Color searchBarTextFieldColor;
  final TextStyle? searchBarTextStyle;

  const DgisSearchBar({
    required this.onSearchChanged,
    required this.controller,
    required this.onSearchSubmitted,
    required this.searchBarBackgroundColor,
    required this.searchBarTextFieldColor,
    required this.searchBarTextStyle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: ColoredBox(
        color: searchBarBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: TextField(
            textInputAction: TextInputAction.search,
            controller: controller,
            onChanged: onSearchChanged,
            onSubmitted: onSearchSubmitted,
            style: searchBarTextStyle,
            decoration: InputDecoration(
              hintText: 'Search Query',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      controller.clear();
                      onSearchChanged('');
                    },
                  ),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: searchBarTextFieldColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 6),
            ),
          ),
        ),
      ),
    );
  }
}
