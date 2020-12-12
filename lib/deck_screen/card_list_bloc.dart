import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ddi/di.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:tf_core/tf_core.dart';

class CardListState extends Equatable {
  final List<String> cardIds;
  final Map<String, ReviewCard> reviewCards;
  final bool isCardLoaded;
  final bool isFailure;
  final String error;

  CardListState(
      {@required this.cardIds,
      @required this.reviewCards,
      this.isCardLoaded = false,
      this.isFailure = false,
      this.error = ''})
      : props = [cardIds, reviewCards, isCardLoaded, isFailure, error];

  CardListState.init()
      : cardIds = <String>[],
        reviewCards = <String, ReviewCard>{},
        isCardLoaded = false,
        isFailure = false,
        error = null,
        props = const [];

  List<ReviewCard> getReviewCards({int firstIndex = 0}) {
    var data = cardIds
        .map<ReviewCard>((id) => reviewCards[id])
        .where((reviewCard) => reviewCard != null)
        .toList();

    if (firstIndex > 0 && firstIndex < data.length) {
      var item = data[firstIndex];
      data.removeAt(firstIndex);
      data.insert(0, item);
    }
    return data;
  }

  List<ReviewCard> getNotInReviewCards() {
    return cardIds
        .where((id) {
          final reviewCard = reviewCards[id];
          return reviewCard == null ||
              reviewCard.reviewInfo == null ||
              reviewCard.reviewInfo.isNotInReview();
        })
        .map<ReviewCard>((id) => reviewCards[id])
        .where((reviewCard) => reviewCard != null)
        .toList();
  }

  String getCardId(int index) {
    if (index >= 0 && index < cardIds.length) {
      return cardIds[index];
    } else {
      return null;
    }
  }

  Card getCard(int index) {
    String cardId = getCardId(index);
    return cardId != null ? reviewCards[cardId]?.card : null;
  }

  List<String> getNotInReviewCardIds() {
    return cardIds.where((id) {
      final reviewCard = reviewCards[id];
      return reviewCard == null ||
          reviewCard.reviewInfo == null ||
          reviewCard.reviewInfo.isNotInReview();
    }).toList();
  }

  bool get loadCardCompleted =>
      isCardLoaded && (reviewCards?.isNotEmpty ?? false);

  bool hasNotInReviewCards() {
    return getNotInReviewCardIds().isNotEmpty;
  }

  bool hasCards() {
    return reviewCards?.isNotEmpty ?? false;
  }

  CardListState copyWith(
      {List<String> cardIds,
      Map<String, ReviewCard> reviewCards,
      bool isSuccess,
      bool isFailure,
      String error}) {
    return CardListState(
      cardIds: cardIds ?? this.cardIds,
      reviewCards: reviewCards ?? this.reviewCards,
      isCardLoaded: isSuccess ?? this.isCardLoaded,
      isFailure: isFailure ?? this.isFailure,
      error: error ?? this.error,
    );
  }

  CardListState loading() {
    return CardListState(
      cardIds: this.cardIds,
      reviewCards: this.reviewCards,
      isCardLoaded: false,
      isFailure: false,
    );
  }

  CardListState success(
      List<String> cardIds, Map<String, ReviewCard> reviewCards) {
    return CardListState(
        cardIds: cardIds,
        reviewCards: reviewCards,
        isCardLoaded: true,
        isFailure: false,
        error: null);
  }

  CardListState failure(String error) {
    return CardListState(
        cardIds: this.cardIds,
        reviewCards: this.reviewCards,
        isCardLoaded: false,
        isFailure: true,
        error: error);
  }

  @override
  String toString() => 'CardListState';

  @override
  final List<Object> props;
}

abstract class CardListEvent extends Equatable {
  CardListEvent([this.props = const []]);

  @override
  final List<Object> props;
}

class LoadCardList extends CardListEvent {
  final List<String> cardIds;

  LoadCardList(this.cardIds);

  @override
  String toString() => 'LoadCardList $cardIds';
}

class CardListUpdated extends CardListEvent {
  final String cardId;
  final Card card;

  CardListUpdated(this.cardId, this.card);

  @override
  String toString() => 'CardUpdated';
}

class UpdateReviewInfo extends CardListEvent {
  final Map<String, ReviewInfo> reviewInfo;

  UpdateReviewInfo(this.reviewInfo);

  @override
  String toString() => 'UpdateReviewInfo';
}

class CardListBloc extends Bloc<CardListEvent, CardListState> {
  final DeckService deckService = DI.get(DeckService);
  final SRSService srsService = DI.get(SRSService);
  @override
  CardListState get initialState => CardListState.init();

  @override
  Stream<CardListState> mapEventToState(CardListEvent event) async* {
    switch (event.runtimeType) {
      case LoadCardList:
        yield* _loadCards(event);
        break;
      case CardListUpdated:
        yield* _updateCard(event);
        break;
      case UpdateReviewInfo:
        yield* _updateReviewInfo(event);
        break;
    }
  }

  Stream<CardListState> _loadCards(LoadCardList event) async* {
    try {
      yield CardListState.init();
      final cardIds = event.cardIds ?? <String>[];
      Log.debug("cardIds: ${cardIds.length}");
      List<ReviewCard> cards = await deckService.getReviewCardAsList(cardIds);
      var entries = cards.map<MapEntry<String, ReviewCard>>((reviewCard) {
        return MapEntry(reviewCard.cardId, reviewCard);
      });
      yield state.success(
          cardIds, Map<String, ReviewCard>.fromEntries(entries));
    } catch (e) {
      yield _handleError(e);
    }
  }

  Stream<CardListState> _updateCard(CardListUpdated event) async* {
    try {
      var reviewCards = Map<String, ReviewCard>.from(state.reviewCards);
      if (reviewCards.containsKey(event.cardId)) {
        reviewCards[event.cardId]..card = event.card;
        yield state.success(state.cardIds, reviewCards);
      }
    } catch (e) {
      yield _handleError(e);
    }
  }

  Stream<CardListState> _updateReviewInfo(UpdateReviewInfo event) async* {
    try {
      final reviewCards = <String, ReviewCard>{};
      state.reviewCards.forEach((cardId, reviewCard) {
        reviewCards[cardId] = reviewCard;
      });
      event.reviewInfo.forEach((cardId, reviewInfo) {
        if (reviewCards.containsKey(cardId)) {
          var reviewCard = reviewCards[cardId];
          reviewCard.reviewInfo = reviewInfo;
        }
      });
      yield state.copyWith(reviewCards: reviewCards, error: '');
    } catch (e, stackTrace) {
      yield _handleError(e, stackTrace: stackTrace);
    }
  }

  CardListState _handleError(e, {stackTrace}) {
    if (e is APIException) {
      switch (e.reason) {
        case ApiErrorReasons.NotAuthenticated:
          return state.failure(Config.getNotAuthenticatedMsg());
        default:
          return state.failure('${e.reason} - ${e.message}');
      }
    } else {
      return state.failure(e.toString());
    }
  }
}
