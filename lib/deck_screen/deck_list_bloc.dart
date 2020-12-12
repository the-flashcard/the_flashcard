import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ddi/di.dart';
import 'package:tf_core/tf_core.dart';
import 'package:the_flashcard/deck_screen/deck_list_event.dart';

class DeckListState {
  String query;
  String categoryId;

  int total;
  final List<Deck> records;

  DeckListState(this.total, this.records, {this.query, this.categoryId});

  DeckListState.empty()
      : total = 0,
        records = <Deck>[],
        categoryId = null;

  bool get canLoadMore => records.length < total;

  bool get hasQueryFilter => query != null && query.trim().isNotEmpty;

  bool get hasCategoryFilter =>
      categoryId != null && categoryId.trim().isNotEmpty;

  bool get hasNoData =>
      records.isEmpty && !hasQueryFilter && !hasCategoryFilter;

  @override
  String toString() => 'DeckListState: $query, $categoryId';
}

class DeckListLoading extends DeckListState {
  DeckListLoading.from(DeckListState state)
      : super(state.total, state.records,
            query: state.query, categoryId: state.categoryId);

  @override
  String toString() => 'DeckLoading';
}

abstract class DeckListBloc extends Bloc<DeckListEvent, DeckListState> {
  final Map<String, Deck> selectedDeckMap = <String, Deck>{};
  final List<Deck> selectedDecks = <Deck>[];

  final int pageSize;

  DeckListBloc(this.pageSize);

  @override
  DeckListState get initialState => DeckListState.empty();

  bool get isAllSelected {
    var total = state.records.length;
    var totalSelected = state.records
        .where((deck) => selectedDeckMap.containsKey(deck.id))
        .length;

    return total == totalSelected;
  }

  bool get hasSelected => selectedDeckMap.isNotEmpty;

  bool isSelected(String deckId) => selectedDeckMap.containsKey(deckId);

  @override
  Stream<DeckListState> mapEventToState(DeckListEvent event) async* {
    switch (event.runtimeType) {
      case CategoryChanged:
        yield* _updateCategory(event);
        break;
      case QueryChanged:
        yield* _updateQuery(event);
        break;
      case Refresh:
        yield* _refreshSearch();
        break;
      case LoadMore:
        yield* _loadMore(event);
        break;
      case AddOrUpdateListing:
        yield* _addDeck(event);
        break;
      case SelectDeck:
        yield* _selectDeck(event);
        break;

      case SelectAllDeck:
        yield* _selectAllDeck(event);
        break;
      case DeSelectAllDeck:
        yield* _deSelectAllDeck(event);
        break;

      case DeleteSelectedDecks:
        yield* _deleteAndRemoveSelectedDecks(event);
        break;
      case RemoveDeck:
        yield* _removeDeck(event);
        break;
    }
  }

  void refresh() {
    add(Refresh());
  }

  Stream<DeckListState> _updateCategory(CategoryChanged event) async* {
    state.categoryId = event.isRemoved ? null : event.categoryId;
    yield* _refreshSearch();
  }

  Stream<DeckListState> _updateQuery(QueryChanged event) async* {
    state.query = event.query;
    state.categoryId = null;
    yield* _refreshSearch();
  }

  SearchRequest _buildSearchRequest(int from) {
    var request = SearchRequest(from, pageSize);

    if (state.hasQueryFilter) {
      request.addMatchQuery(
        MatchQuery(
          "name",
          state.query,
        ),
      );
    }

    if (state.hasCategoryFilter) {
      request.addTermsQuery(
        TermsQuery.from(
          "category",
          [state.categoryId],
        ),
      );
    }
    return request;
  }

  Stream<DeckListState> _refreshSearch() async* {
    yield DeckListLoading.from(state);
    try {
      var r = await _search(_buildSearchRequest(0));
      selectedDeckMap.clear();
      selectedDecks.clear();

      yield DeckListState(
        r.total,
        r.records,
        query: state.query,
        categoryId: state.categoryId,
      );
    } catch (e) {
      Log.error("Error when search deck: ${this.runtimeType} - $e");
    }
  }

  Stream<DeckListState> _loadMore(LoadMore event) async* {
    yield DeckListLoading.from(state);
    var r = await _search(_buildSearchRequest(state.records.length));
    var data = state.records;
    data.addAll(r.records);
    yield DeckListState(
      r.total,
      data,
      query: state.query,
      categoryId: state.categoryId,
    );
  }

  Stream<DeckListState> _addDeck(AddOrUpdateListing event) async* {
    bool isFound = false;
    var data = <Deck>[];

    state.records.forEach((deck) {
      if (event.deck != null && deck.id == event.deck.id) {
        isFound = true;
      } else {
        data.add(deck);
      }
    });
    data.insert(0, event.deck);
    yield DeckListState(isFound ? state.total : (state.total + 1), data,
        query: state.query, categoryId: state.categoryId);
  }

  Stream<DeckListState> _selectDeck(SelectDeck event) async* {
    if (selectedDeckMap.containsKey(event.deckId)) {
      selectedDeckMap.remove(event.deckId);
      selectedDecks.removeWhere((x) => x.id == event.deckId);
    } else {
      var deck = state.records
          .where((deck) => deck.id == event.deckId)
          .firstWhere((_) => true, orElse: () => null);
      if (deck != null) {
        selectedDeckMap[event.deckId] = deck;
        selectedDecks.add(deck);
      }
    }
    yield DeckListState(
      state.total,
      state.records,
      query: state.query,
      categoryId: state.categoryId,
    );
  }

  Stream<DeckListState> _selectAllDeck(SelectAllDeck event) async* {
    selectedDeckMap.clear();
    selectedDecks.clear();
    state.records.forEach((deck) {
      selectedDeckMap[deck.id] = deck;
      selectedDecks.add(deck);
    });
    yield DeckListState(
      state.total,
      state.records,
      query: state.query,
      categoryId: state.categoryId,
    );
  }

  Stream<DeckListState> _deSelectAllDeck(DeSelectAllDeck event) async* {
    selectedDeckMap.clear();
    selectedDecks.clear();
    yield DeckListState(
      state.total,
      state.records,
      query: state.query,
      categoryId: state.categoryId,
    );
  }

  Stream<DeckListState> _deleteAndRemoveSelectedDecks(
      DeleteSelectedDecks event) async* {
    var data = <Deck>[];

    var deckService = DI.get<DeckService>(DeckService);
    var deckIds = selectedDecks.map((deck) => deck.id).toList();
    var deletedIds = await deckService.deleteDecks(deckIds);

    state.records.forEach((deck) {
      if (!deletedIds.contains(deck.id)) {
        data.add(deck);
      }
    });
    yield DeckListState(
      (state.total - deckIds.length),
      data,
      query: state.query,
      categoryId: state.categoryId,
    );
  }

  Stream<DeckListState> _removeDeck(RemoveDeck event) async* {
    int foundCount = 0;
    var data = <Deck>[];
    if (event.deckIds != null) {
      selectedDecks.removeWhere((deck) => event.deckIds.contains(deck.id));
      event.deckIds.forEach((id) => selectedDeckMap.remove(id));

      state.records.forEach((deck) {
        if (!event.deckIds.contains(deck.id)) {
          data.add(deck);
        } else {
          foundCount++;
        }
      });
    }
    yield DeckListState(
      (state.total - foundCount),
      data,
      query: state.query,
      categoryId: state.categoryId,
    );
  }

  Future<PageResult<Deck>> _search(SearchRequest event);
}

class MyDeckBloc extends DeckListBloc {
  MyDeckBloc(int pageSize) : super(pageSize);
  @override
  Future<PageResult<Deck>> _search(SearchRequest request) {
    final DeckService deckService = DI.get(DeckService);
    return deckService.searchMyDeck(request);
  }
}

class GlobalDeckBloc extends DeckListBloc {
  GlobalDeckBloc(int pageSize) : super(pageSize);

  DeckListState get iniState => DeckListState.empty();

  @override
  Future<PageResult<Deck>> _search(SearchRequest request) {
    final DeckService deckService = DI.get(DeckService);
    return deckService.searchGlobalDeck(request);
  }
}

class FavoriteDeckBloc extends DeckListBloc {
  FavoriteDeckBloc(int pageSize) : super(pageSize);

  @override
  Future<PageResult<Deck>> _search(SearchRequest request) {
    final DeckService deckService = DI.get(DeckService);
    return deckService.searchFavoriteDeck(request.from, request.size);
  }
}

class SearchDeckBloc extends DeckListBloc {
  SearchDeckBloc(int pageSize) : super(pageSize);

  @override
  Future<PageResult<Deck>> _search(SearchRequest request) {
    final DeckService deckService = DI.get(DeckService);
    return deckService.searchGlobalDeck(request, query: state.query);
  }

  @override
  SearchRequest _buildSearchRequest(int from) {
    var request = SearchRequest(from, pageSize);

    if (state.hasCategoryFilter) {
      request.addTermsQuery(
        TermsQuery.from(
          "category",
          [state.categoryId],
        ),
      );
    }
    return request;
  }
}
