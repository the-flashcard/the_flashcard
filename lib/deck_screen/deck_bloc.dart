import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ddi/di.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:tf_core/tf_core.dart';
import 'package:the_flashcard/deck_screen/deck_list_bloc.dart';
import 'package:the_flashcard/home_screen/trending_deck_bloc.dart';

import 'card_list_bloc.dart';
import 'deck_list_event.dart';

class DeckState extends Equatable {
  final Deck deck;
  final bool isLoading;
  final bool isSuccess;
  final bool isFailure;
  final String error;

  @override
  final List<Object> props;

  DeckState(
      {@required this.deck,
      this.isLoading = false,
      this.isSuccess = false,
      this.isFailure = false,
      this.error = ''})
      : props = [deck, isLoading, isSuccess, isFailure, error];

  DeckState.init()
      : deck = null,
        isLoading = false,
        isSuccess = false,
        isFailure = false,
        error = null,
        props = const [];

  DeckState.created(this.deck)
      : isLoading = false,
        isSuccess = true,
        isFailure = false,
        error = null,
        props = const [];

  DeckState copyWith(
      {bool isLoading, bool isSuccess, bool isFailure, String error}) {
    return DeckState(
      deck: deck,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
      error: error ?? this.error,
    );
  }

  DeckState created(Deck deck) {
    return DeckState(
      deck: deck,
      isLoading: false,
      isSuccess: true,
      isFailure: false,
      error: error,
    );
  }

  DeckState loading() {
    return DeckState(
      deck: this.deck,
      isLoading: true,
      isSuccess: false,
      isFailure: false,
    );
  }

  DeckState success(Deck deck) {
    return DeckState(
        deck: deck,
        isLoading: false,
        isSuccess: true,
        isFailure: false,
        error: error);
  }

  DeckState failure(String error) {
    return DeckState(
        deck: this.deck,
        isLoading: false,
        isSuccess: false,
        isFailure: true,
        error: error);
  }

  @override
  String toString() => 'DeckState';
}

abstract class DeckEvent extends Equatable {
  DeckEvent([this.props = const []]);

  @override
  final List<Object> props;
}

class InfoChanged extends DeckEvent {
  final String name;
  final String description;
  final String thumbnailUrl;
  final DeckStatus deckStatus;
  final Container design;
  final String categoryId;

  InfoChanged({
    this.name,
    this.description,
    this.deckStatus,
    this.thumbnailUrl,
    this.design,
    this.categoryId,
  });

  @override
  String toString() => 'InfoChanged';
}

class CardAdded extends DeckEvent {
  final String cardId;
  final Card card;

  CardAdded({this.cardId, this.card});

  @override
  String toString() => 'CardAdded';
}

class DeleteCard extends DeckEvent {
  final List<String> cardIds;
  final String deckId;

  DeleteCard({this.cardIds, this.deckId});

  @override
  String toString() => 'CardDeleted ${this.cardIds} ${this.deckId}';
}

class CardUpdated extends DeckEvent {
  final String cardId;
  final Card card;

  CardUpdated({this.cardId, this.card});

  @override
  String toString() => 'CardUpdated';
}

class CardGenerated extends DeckEvent {
  final List<String> words;

  CardGenerated(this.words);

  @override
  String toString() => 'CardGenerated $words';
}

class ErrorDeckEvent extends DeckEvent {
  final ex;

  ErrorDeckEvent(this.ex);

  @override
  String toString() => 'ErrorDeckEvent';
}

class ListCardAdded extends DeckEvent {
  final List<String> cardIds;

  ListCardAdded(this.cardIds);

  @override
  String toString() => 'ListCardAdded';
}

class DeckBloc extends Bloc<DeckEvent, DeckState> {
  final CardListBloc cardListBloc;
  final GlobalDeckBloc globalDeckBloc;
  final MyDeckBloc myDeckBloc;
  final TrendingDeckBloc trendingDeckBloc;
  final NewDeckBloc newDeckBloc;

  final AuthService authService = DI.get(AuthService);
  final DeckService deckService = DI.get(DeckService);
  Deck deck;

  DeckBloc.create(this.cardListBloc, this.myDeckBloc, this.globalDeckBloc,
      this.trendingDeckBloc, this.newDeckBloc);

  DeckBloc.edit(
    this.cardListBloc,
    this.myDeckBloc,
    this.globalDeckBloc,
    this.trendingDeckBloc,
    this.newDeckBloc,
    this.deck,
  );

  @override
  DeckState get initialState =>
      deck == null ? DeckState.init() : DeckState.created(deck);
  @override
  Stream<DeckState> mapEventToState(DeckEvent event) async* {
    switch (event.runtimeType) {
      case InfoChanged:
        if (state.deck == null)
          yield* _createDeck(event);
        else
          yield* _editDeck(event);
        break;
      case CardAdded:
        yield* _addCard(event);
        break;
      case ListCardAdded:
        yield* _addListCard(event);
        break;
      case DeleteCard:
        yield* _deleteCard(event);
        break;
      case CardUpdated:
        yield* _updateCard(event);
        break;
      case CardGenerated:
        yield* _generateCard(event);
        break;
      case ErrorDeckEvent:
        yield _handleError((event as ErrorDeckEvent).ex);
        break;
    }
  }

  Stream<DeckState> _createDeck(InfoChanged event) async* {
    yield state.loading();
    try {
      var loggedInProfile =
          await authService.getLoginData().then((data) => data.userProfile);
      Deck createdDeck = await deckService.createDeck(
          event.name ?? 'Untitled deck',
          event.description,
          event.design,
          event.thumbnailUrl,
          event.deckStatus ?? DeckStatus.Protected,
          categoryId: event.categoryId);
      createdDeck..ownerDetail = ShortUserProfile.from(loggedInProfile);
      _addOrUpdateToDeckListing(createdDeck);
      cardListBloc.add(LoadCardList(createdDeck.cardIds));

      yield state.created(createdDeck);
    } catch (e) {
      yield _handleError(e);
    }
  }

  Stream<DeckState> _editDeck(InfoChanged event) async* {
    yield state.loading();
    if (event.deckStatus == DeckStatus.Published) {
      if (isNotEnoughCard()) {
        yield state
            .failure('You must have at least 5 cards to the public deck.');
        return;
      }
      if (haveNotThumbnailAndDescription()) {
        yield state.failure('Thumbnail and description are required.');
        return;
      }
    }
    try {
      bool success = await deckService.editDeck(
        state.deck.id,
        name: event.name,
        desc: event.description,
        design: event.design,
        thumbnailUrl: event.thumbnailUrl,
        deckStatus: event.deckStatus,
        categoryId: event.categoryId ?? "",
      );

      if (success) {
        state.deck.updateWith(
          thumbnail: event.thumbnailUrl,
          name: event.name,
          design: event.design,
          description: event.description,
          deckStatus: event.deckStatus,
          categoryId: event.categoryId ?? "",
        );
        final updatedDeck = Deck.from(state.deck);
        _addOrUpdateToDeckListing(updatedDeck);
        yield state.created(updatedDeck);
      } else {
        yield state.failure('Can\'t edit at the moment!');
      }
    } catch (e) {
      yield _handleError(e);
    }
  }

  void _addOrUpdateToDeckListing(Deck deck) {
    myDeckBloc.add(AddOrUpdateListing(deck));
    switch (deck.deckStatus) {
      case DeckStatus.Published:
        globalDeckBloc.add(AddOrUpdateListing(deck));
        Future.delayed(Duration(seconds: 2), () {
          trendingDeckBloc.add(LoadDeckListEvent());
          newDeckBloc.add(LoadDeckListEvent());
        });
        break;
      default:
        globalDeckBloc.add(RemoveDeck(<String>{deck.id}));
        Future.delayed(Duration(seconds: 2), () {
          trendingDeckBloc.add(LoadDeckListEvent());
          newDeckBloc.add(LoadDeckListEvent());
        });
        break;
    }
  }

  // bool _canNotPusblish() {
  //   final deck = state.deck;
  //   return deck == null ||
  //       deck.thumbnail == null ||
  //       deck.deckStatus == null ||
  //       deck.cardIds == null ||
  //       deck.cardIds.length < 5;
  // }

  bool haveNotThumbnailAndDescription() {
    final deck = state.deck;

    return deck.thumbnail?.isEmpty == true || deck.description?.isEmpty == true;
  }

  bool isNotEnoughCard() {
    final deck = state.deck;
    return deck == null || deck.cardIds == null || deck.cardIds.length < 5;
  }

  Stream<DeckState> _addCard(CardAdded event) async* {
    try {
      state.deck.cardIds.add(event.cardId);
      cardListBloc.add(LoadCardList(state.deck.cardIds));
      Deck newDeck = Deck.from(state.deck);

      _addOrUpdateToDeckListing(newDeck);
      yield state.created(newDeck);
    } catch (e) {
      yield _handleError(e);
    }
  }

  Stream<DeckState> _addListCard(ListCardAdded event) async* {
    try {
      state.deck?.cardIds?.addAll(event.cardIds);
      cardListBloc.add(LoadCardList(state.deck.cardIds));
      Deck newDeck = Deck.from(state.deck);
      _addOrUpdateToDeckListing(newDeck);
      yield state.success(newDeck);
    } catch (ex) {
      yield _handleError(ex);
    }
  }

  Stream<DeckState> _updateCard(CardUpdated event) async* {
    try {
      if (!state.deck.cardIds.contains(event.cardId))
        state.deck.cardIds.add(event.cardId);
      cardListBloc.add(CardListUpdated(event.cardId, event.card));
      Deck newDeck = Deck.from(state.deck);

      _addOrUpdateToDeckListing(newDeck);
      yield state.created(newDeck);
    } catch (e) {
      yield _handleError(e);
    }
  }

  DeckState _handleError(e) {
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

  Stream<DeckState> _deleteCard(DeleteCard event) async* {
    try {
      yield this.state.loading();
      Deck deck = await deckService.removeCards(event.deckId, event.cardIds);
      cardListBloc.add(LoadCardList(deck.cardIds));
      this.deck = deck;
      _addOrUpdateToDeckListing(deck);
      yield this.state.success(deck);
    } catch (ex) {
      yield _handleError(ex);
    }
  }

  Stream<DeckState> _generateCard(CardGenerated event) async* {
    yield this.state.loading();
    deckService
        .generateCards(100, 'en', 'en', event.words)
        .then<void>(_genereted)
        .catchError(_onError);
  }

  Future<void> _genereted(List<GenerateWordInfo> generateWords) async {
    final List<CardDesign> cardDesigns = <CardDesign>[];
    final String cardId = this.state.deck.id;
    if (generateWords != null) {
      generateWords.forEach((generateWord) {
        if (generateWord?.data != null) {
          final CardDesign cardDesign = CardDesign.fromDesign(
            generateWord.data.fronts,
            generateWord.data.back,
          );
          cardDesigns.add(cardDesign);
        }
      });

      deckService
          .addCards(cardId, CardVersion.V1000, cardDesigns)
          .then((cardIds) => add(ListCardAdded(cardIds)))
          .catchError(_onError);
    }
  }

  void _onError(dynamic ex) {
    add(ErrorDeckEvent(ex));
  }
}
