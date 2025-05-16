import 'package:flutter/material.dart';

import '../../generated/dart_bindings.dart' as sdk;
import '../either.dart';
import 'object_card.dart';
import 'search_bar.dart';
import 'search_widget_color_scheme.dart';

/// Виджет, представляющий собой поисковую строку и лист выдачи объектов
/// или подсказок.
///
/// Пример кастомного билдера для результатов:
/// ```dart
/// DgisSearchWidget(
///   searchManager: searchManager,
///   resultBuilder: (context, objects) {
///     return SliverList(
///       delegate: SliverChildBuilderDelegate(
///         (context, index) {
///           final item = objects[index];
///
///           return item.fold(
///             // Handle DirectoryObject
///             (directoryObject) {
///               return ListTile(
///                 title: Text(directoryObject.title),
///                 subtitle: Text(directoryObject.subtitle),
///                 onTap: () {
///                   // Handle directory object selection
///                   print('Selected: ${directoryObject.title}');
///                 },
///               );
///             },
///             // Handle Suggest
///             (suggest) {
///               return ListTile(
///                 title: Text(suggest.title.text),
///                 subtitle: Text(suggest.subtitle.text),
///                 onTap: () {
///                   if (suggest.handler.isObjectHandler) {
///                     final item = suggest.handler.asObjectHandler!.item;
///                     print('Selected object: ${item.title}');
///                   } else if (suggest.handler.isIncompleteTextHandler) {
///                     final queryText = suggest.handler.asIncompleteTextHandler!.queryText;
///                     print('Complete search with: $queryText');
///                   } else if (suggest.handler.isPerformSearchHandler) {
///                     final searchQuery = suggest.handler.asPerformSearchHandler!.searchQuery;
///                     print('Perform search query');
///                   }
///                 },
///               );
///             },
///           );
///         },
///         childCount: objects.length,
///       ),
///     );
///   },
/// )
/// ```
///
/// Важно при создании своего билдера:
/// 1. Билдер должен возвращать Sliver-виджет (SliverList, SliverGrid, etc.)
/// 2. Используйте fold чтобы обработать все возможные объекты DirectoryObject и Suggest
class DgisSearchWidget extends StatefulWidget {
  final sdk.SearchManager _searchManager;
  final void Function(sdk.DirectoryObject)? _onObjectSelected;
  final SearchResultBuilder? resultBuilder;
  final SearchWidgetColorScheme colorScheme;
  final SearchQueryProvider _searchQueryProvider;
  final SuggestQueryProvider _suggestQueryProvider;

  const DgisSearchWidget({
    required sdk.SearchManager searchManager,
    void Function(sdk.DirectoryObject)? onObjectSelected,
    this.resultBuilder,
    this.colorScheme = defaultSearchWidgetColorScheme,
    SearchQueryProvider? searchQueryProvider,
    SuggestQueryProvider? suggestQueryProvider,
    super.key,
  })  : _onObjectSelected = onObjectSelected,
        _searchManager = searchManager,
        _searchQueryProvider =
            searchQueryProvider ?? _defaultSearchQueryProvider,
        _suggestQueryProvider =
            suggestQueryProvider ?? _defaultSuggestQueryProvider,
        assert(
          onObjectSelected == null || resultBuilder == null,
          'You can only provide either onObjectSelected or resultBuilder, not both.',
        );

  // Цветовая схема виджета по-умолчанию.
  static const defaultSearchWidgetColorScheme = SearchWidgetColorScheme(
    searchBarBackgroundColor: Colors.white,
    searchBarTextFieldColor: Colors.grey,
    objectCardTileColor: Colors.white,
    objectCardHighlightedTextStyle:
        TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    objectCardNormalTextStyle: TextStyle(color: Colors.black),
    objectListSeparatorColor: Colors.grey,
    objectListBackgroundColor: Colors.white,
  );

  static sdk.SearchQuery _defaultSearchQueryProvider(
    Either<sdk.SearchQuery, String> someQuery,
  ) {
    return someQuery.fold(
      (query) => sdk.SearchQueryBuilder.fromQuery(query).build(),
      (queryText) => sdk.SearchQueryBuilder.fromQueryText(queryText).build(),
    );
  }

  static sdk.SuggestQuery _defaultSuggestQueryProvider(
    Either<sdk.SuggestQuery, String> someQuery,
  ) {
    return someQuery.fold(
      (query) => sdk.SuggestQueryBuilder.fromQuery(query).build(),
      (queryText) => sdk.SuggestQueryBuilder.fromQueryText(queryText).build(),
    );
  }

  @override
  State<DgisSearchWidget> createState() => _DgisSearchWidgetState();
}

class _DgisSearchWidgetState extends State<DgisSearchWidget> {
  final _scrollController = ScrollController();
  final _controller = TextEditingController();
  final ValueNotifier<List<EitherDirectoryObjOrSuggest>> _objects =
      ValueNotifier([]);
  sdk.Page? searchPage;

  void onPerformSearchSuggestSelected(sdk.PerformSearchHandler handler) {
    _performSearch(handler.searchQuery);
  }

  void onIncompleteTextSuggestSelected(String additionalQueryText) {
    _controller.text = additionalQueryText;
  }

  Future<void> _getSuggetions(String query) async {
    if (query.isNotEmpty) {
      final suggestions = await widget._searchManager
          .suggest(widget._suggestQueryProvider(Right(query)))
          .value;
      _objects.value = suggestions.suggests.map(SuggestUIObj.new).toList();
    } else {
      _objects.value = [];
    }
  }

  void _performSearchFromText(String query) {
    _performSearch(
      sdk.SearchQueryBuilder.fromQueryText(query).build(),
    );
  }

  Future<void> _performSearch(sdk.SearchQuery query) async {
    final result = await widget._searchManager
        .search(widget._searchQueryProvider(Left(query)))
        .value;
    searchPage = result.firstPage;
    _objects.value = searchPage?.items.map(DirectoryUIObj.new).toList() ?? [];
  }

  void _onScroll() {
    if (_scrollController.position.atEdge) {
      _objects.value.last.fold(
        (left) async {
          final nextPage = await searchPage?.fetchNextPage().value;
          if (nextPage != null) {
            searchPage = nextPage;
            _objects.value = [
              ..._objects.value,
              ...nextPage.items.map(DirectoryUIObj.new),
            ];
          }
        },
        (right) => null,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _handleSuggestionTap(EitherDirectoryObjOrSuggest suggestion) {
    suggestion.fold(
      (left) => {widget._onObjectSelected!(left)},
      (right) => {
        if (right.handler.isObjectHandler)
          {
            widget._onObjectSelected!(
              right.handler.asObjectHandler!.item,
            ),
            _controller.text = right.title.text,
          }
        else if (right.handler.isIncompleteTextHandler)
          {
            onIncompleteTextSuggestSelected(
              right.handler.asIncompleteTextHandler!.queryText,
            ),
          }
        else if (right.handler.isPerformSearchHandler)
          {
            onPerformSearchSuggestSelected(
              right.handler.asPerformSearchHandler!,
            ),
            _controller.text = right.title.text,
          }
        else
          {
            throw Exception(
              'Unknown SuggestHandler type: ${right.handler.runtimeType}',
            ),
          },
      },
    );
    _objects.value = [];
  }

  Widget _defaultSearchResultListBuilder(
    BuildContext context,
    List<EitherDirectoryObjOrSuggest> objects,
  ) {
    return DecoratedSliver(
      decoration:
          BoxDecoration(color: widget.colorScheme.objectListBackgroundColor),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index.isEven) {
              final itemIndex = index ~/ 2;
              if (itemIndex >= objects.length) return null;
              final suggestion = objects[itemIndex];
              return SuggestionCard(
                objectCardHighlightedTextStyle:
                    widget.colorScheme.objectCardHighlightedTextStyle,
                objectCardNormalTextStyle:
                    widget.colorScheme.objectCardNormalTextStyle,
                objectCardTileColor: widget.colorScheme.objectCardTileColor,
                suggestion: suggestion,
                onTap: () => _handleSuggestionTap(suggestion),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.only(left: 54),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: widget.colorScheme.objectListSeparatorColor,
                ),
              );
            }
          },
          childCount: objects.isEmpty ? 0 : objects.length * 2 - 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: DgisSearchBar(
            onSearchSubmitted: _performSearchFromText,
            onSearchChanged: _getSuggetions,
            controller: _controller,
            searchBarBackgroundColor:
                widget.colorScheme.searchBarBackgroundColor,
            searchBarTextFieldColor: widget.colorScheme.searchBarTextFieldColor,
            searchBarTextStyle: widget.colorScheme.searchBarTextStyle,
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.zero,
          sliver: ValueListenableBuilder<List<EitherDirectoryObjOrSuggest>>(
            valueListenable: _objects,
            builder: (context, objects, _) {
              if (widget.resultBuilder != null) {
                return widget.resultBuilder!(context, objects);
              }
              return _defaultSearchResultListBuilder(context, objects);
            },
          ),
        ),
      ],
    );
  }
}

typedef SearchResultBuilder = Widget Function(
  BuildContext context,
  List<EitherDirectoryObjOrSuggest> objects,
);

/// Билдер для SearchQuery, передаваемый в DgisSearchWidget.
/// Стандартная реализация:
/// ```dart
///   static sdk.SearchQuery _defaultSearchQueryProvider(
///    Either<sdk.SearchQuery, String> someQuery,
///  ) {
///   return someQuery.fold(
///      (query) => sdk.SearchQueryBuilder.fromQuery(query).build(),
///      (queryText) => sdk.SearchQueryBuilder.fromQueryText(queryText).build(),
///    );
///  }
typedef SearchQueryProvider = sdk.SearchQuery Function(
  Either<sdk.SearchQuery, String>,
);

/// Билдер для SuggestQuery, передаваемый в DgisSearchWidget.
/// Стандартная реализация:
/// ```dart
///   static sdk.SearchQuery _defaultSuggestQueryProvider(
///    Either<sdk.SuggestQuery, String> someQuery,
///  ) {
///   return someQuery.fold(
///      (query) => sdk.SuggestQueryBuilder.fromQuery(query).build(),
///      (queryText) => sdk.SuggestQueryBuilder.fromQueryText(queryText).build(),
///    );
///  }
typedef SuggestQueryProvider = sdk.SuggestQuery Function(
  Either<sdk.SuggestQuery, String>,
);
