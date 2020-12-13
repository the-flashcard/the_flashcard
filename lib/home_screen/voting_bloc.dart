import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ddi/di.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:tf_core/tf_core.dart';
import 'package:the_flashcard/deck_screen/deck_list_bloc.dart';
import 'package:the_flashcard/deck_screen/deck_list_event.dart';
import 'package:the_flashcard/home_screen/trending_deck_bloc.dart';

abstract class VotingEvent extends Equatable {
  VotingEvent([this.props = const []]);

  @override
  final List<Object> props;
}

abstract class VotingState extends Equatable {
  VotingState([this.props = const []]);

  @override
  final List<Object> props;
}

class LikeEvent extends VotingEvent {
  final String objectType;
  final String objectId;
  final dynamic object;

  LikeEvent(this.objectType, this.objectId, {this.object});

  @override
  String toString() => 'LikeEvent';
}

class UnLikeEvent extends VotingEvent {
  String objectType;
  String objectId;
  dynamic object;

  UnLikeEvent(this.objectType, this.objectId, {this.object});

  @override
  String toString() => 'UnLikeEvent';
}

class VotingInit extends VotingState {
  @override
  String toString() => 'VotingInit';
}

class Liking extends VotingState {
  @override
  String toString() => 'Liking';
}

class Liked extends VotingState {
  @override
  String toString() => 'Liked';
}

class UnLiked extends VotingState {
  @override
  String toString() => 'UnLiked';
}

class VotingFailure extends VotingState {
  final String error;

  VotingFailure({@required this.error}) : super([error]);

  @override
  String toString() => 'VotingFailure { error: $error }';
}

class VotingBloc extends Bloc<VotingEvent, VotingState> {
  final VotingService deckService = DI.get(VotingService);

  final FavoriteDeckBloc favoriteDeckBloc;
  final TrendingDeckBloc trendingDeckBloc;

  VotingBloc(this.favoriteDeckBloc, this.trendingDeckBloc): super(VotingInit());

  @override
  Stream<VotingState> mapEventToState(VotingEvent event) async* {
    try {
      switch (event.runtimeType) {
        case LikeEvent:
          yield* _like(event);
          break;
        case UnLikeEvent:
          yield* _unlike(event);
          break;
      }
    } on APIException catch (e) {
      switch (e.reason) {
        case ApiErrorReasons.NotAuthenticated:
          yield VotingFailure(error: Config.getNotAuthenticatedMsg());
          break;
        default:
          yield VotingFailure(error: '${e.reason} - ${e.message}');
          break;
      }
    }
  }

  Stream<VotingState> _like(LikeEvent event) async* {
    try {
      var status = await deckService.like(event.objectType, event.objectId);
      if (status) {
        _onLiked(event);
        yield Liked();
      } else
        VotingFailure(error: 'Please try again later.');
    } on APIException catch (e) {
      switch (e.reason) {
        case ApiErrorReasons.NotAuthenticated:
          yield VotingFailure(error: Config.getNotAuthenticatedMsg());
          break;
        default:
          yield VotingFailure(error: '${e.reason} - ${e.message}');
          break;
      }
    }
  }

  Stream<VotingState> _unlike(UnLikeEvent event) async* {
    try {
      var status =
          await deckService.deleteVote(event.objectType, event.objectId);
      if (status) {
        _onUnliked(event);
        yield UnLiked();
      } else
        VotingFailure(error: 'Please try again later.');
    } on APIException catch (e) {
      switch (e.reason) {
        case ApiErrorReasons.NotAuthenticated:
          yield VotingFailure(error: Config.getNotAuthenticatedMsg());
          break;
        default:
          yield VotingFailure(error: '${e.reason} - ${e.message}');
          break;
      }
    }
  }

  void _onLiked(LikeEvent event) {
    addDeck(Deck deck) {
      if (deck != null)
        favoriteDeckBloc.add(AddOrUpdateListing(deck));
      else
        favoriteDeckBloc.add(Refresh());
    }

    switch (event.objectType) {
      case VotingService.ObjectDeck:
        addDeck(event.object as Deck);
        trendingDeckBloc.add(RefreshDeckListEvent());
        break;
    }
  }

  void _onUnliked(UnLikeEvent event) {
    removeDeck(Deck deck) {
      if (deck != null)
        favoriteDeckBloc.add(RemoveDeck(<String>{deck.id}));
      else
        favoriteDeckBloc.add(Refresh());
    }

    switch (event.objectType) {
      case VotingService.ObjectDeck:
        removeDeck(event.object as Deck);
        trendingDeckBloc.add(RefreshDeckListEvent());
        break;
    }
  }
}
