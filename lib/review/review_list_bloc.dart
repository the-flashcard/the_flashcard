import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ddi/di.dart';
import 'package:equatable/equatable.dart';
import 'package:tf_core/tf_core.dart';
import 'package:the_flashcard/review/review_list_event.dart';

class ReviewListState extends Equatable {
  final int total;
  final List<Deck> records;

  @override
  final List<Object> props;

  ReviewListState(this.total, this.records) : props = ([total, records]);

  ReviewListState.empty()
      : total = 0,
        records = <Deck>[],
        props = [];

  bool get canLoadMore => records.length < total;

  @override
  String toString() => 'ReviewListState';
}

class ReviewListLoading extends ReviewListState {
  ReviewListLoading.from(ReviewListState state)
      : super(state.total, state.records);

  @override
  String toString() => 'ReviewListLoading';
}

abstract class ReviewListBloc extends Bloc<ReviewListEvent, ReviewListState> {
  final int pageSize;

  ReviewListBloc(this.pageSize): super(ReviewListState.empty());

  @override
  Stream<ReviewListState> mapEventToState(ReviewListEvent event) async* {
    switch (event.runtimeType) {
      case RefreshReview:
        yield* _refreshSearch();
        break;
      case LoadMore:
        yield* loadMore(event);
        break;
      case RemoveDeck:
        yield* _removeDeck(event);
        break;
      case AddCards:
        yield* _addCards(event);
        break;
    }
  }

  SearchRequest _buildSearchRequest(int from) {
    var request = SearchRequest(from, pageSize);
    return request;
  }

  Stream<ReviewListState> _refreshSearch() async* {
    yield ReviewListLoading.from(state);

    try {
      var r = await _search(_buildSearchRequest(0));
      yield ReviewListState(
        r.total,
        r.records,
      );
    } catch (ex) {
      yield ReviewListState(0, []);
    }
  }

  Stream<ReviewListState> _removeDeck(RemoveDeck event) async* {
    var data = <Deck>[];
    state.records.forEach((deck) {
      if (deck.id != event.deckId) {
        data.add(deck);
      }
    });
    var total = (state.records?.length == data.length)
        ? state.total
        : (state.total - 1);

    yield ReviewListState(
      total,
      data,
    );
  }

  Stream<ReviewListState> _addCards(AddCards event) async* {
    int total = state.total;
    var data = <Deck>[];
    var deck = state.records.firstWhere(
      (deck) => deck.id == event.deck.id,
      orElse: () => null,
    );
    if (deck == null) {
      deck = Deck.from(event.deck);
      deck.setCardIds(event.cardIds);
      data.add(deck);
      total++;
    } else {
      deck.addCardIds(event.cardIds);
    }

    data.addAll(state.records);
    yield ReviewListState(
      total,
      data,
    );
  }

  Stream<ReviewListState> loadMore(LoadMore event) async* {
    yield ReviewListLoading.from(state);
    var r = await _search(_buildSearchRequest(state.records.length));
    var data = <Deck>[];
    data.addAll(state.records);
    data.addAll(r.records);
    yield ReviewListState(
      r.total,
      data,
    );
  }

  Future<PageResult<Deck>> _search(SearchRequest event);
}

class DueReviewBloc extends ReviewListBloc {
  DueReviewBloc(int pageSize) : super(pageSize);

  @override
  Future<PageResult<Deck>> _search(SearchRequest request) {
    final SRSService srsService = DI.get(SRSService);
    return srsService.searchDue(request);
  }
}

class DoneReviewBloc extends ReviewListBloc {
  DoneReviewBloc(int pageSize) : super(pageSize);

  @override
  Future<PageResult<Deck>> _search(SearchRequest request) {
    final SRSService srsService = DI.get(SRSService);
    return srsService.searchDone(request);
  }
}

class LearningReviewBloc extends ReviewListBloc {
  LearningReviewBloc(int pageSize) : super(pageSize);

  @override
  Future<PageResult<Deck>> _search(SearchRequest request) {
    final SRSService srsService = DI.get(SRSService);
    return srsService.searchLearning(request);
  }
}
