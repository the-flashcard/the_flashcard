import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ddi/di.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:tf_core/tf_core.dart';
import 'package:the_flashcard/common/common.dart';

abstract class DeckListEvent extends Equatable {
  DeckListEvent([this.props = const []]);

  @override
  final List<Object> props;
}

abstract class TrendingDeckState extends Equatable {
  TrendingDeckState([this.props = const []]);

  @override
  final List<Object> props;
}

class LoadDeckListEvent extends DeckListEvent {
  @override
  String toString() => 'LoadTrendingDeckEvent';
}

class RefreshDeckListEvent extends DeckListEvent {
  @override
  String toString() => 'RefreshDeckListEvent';
}

class DeckListUnload extends TrendingDeckState {
  @override
  String toString() => 'TrendingDeckUnloaded';
}

class DeckListLoading extends TrendingDeckState {
  @override
  String toString() => 'TrendingDeckLoading';
}

class DeckListLoaded extends TrendingDeckState {
  final List<Deck> decks;

  DeckListLoaded(this.decks) : super(decks);

  DeckListLoaded copyWith({List<Deck> posts}) {
    return DeckListLoaded(
      decks ?? this.decks,
    );
  }

  @override
  String toString() => 'TrendingDeckLoaded';
}

class DeckListFailure extends TrendingDeckState {
  final String error;

  DeckListFailure({@required this.error}) : super([error]);

  @override
  String toString() => 'TrendingDeckFailure { error: $error }';
}

class TrendingDeckBloc extends Bloc<DeckListEvent, TrendingDeckState> {
  static const TRENDING_DECK_SIZE = 20;

  TrendingDeckBloc() : super(DeckListUnload());

  @override
  Stream<TrendingDeckState> mapEventToState(DeckListEvent event) async* {
    try {
      final DeckService deckService = DI.get(DeckService);
      if (event is LoadDeckListEvent) {
        yield DeckListLoading();
        var decks = await deckService.getTrendingDecks(TRENDING_DECK_SIZE);
        yield DeckListLoaded(decks);
      } else if (event is RefreshDeckListEvent) {
        var decks = await deckService.getTrendingDecks(TRENDING_DECK_SIZE);
        yield DeckListLoaded(decks);
      }
    } on APIException catch (error) {
      switch (error.reason) {
        case ApiErrorReasons.NotAuthenticated:
          _logout(error.message);
          break;
        default:
          yield DeckListFailure(error: '${error.message}');
          break;
      }
    } catch (e) {
      yield DeckListFailure(error: e.message);
    }
  }
}

class NewDeckBloc extends Bloc<DeckListEvent, TrendingDeckState> {
  NewDeckBloc() : super(DeckListUnload());

  @override
  Stream<TrendingDeckState> mapEventToState(DeckListEvent event) async* {
    try {
      final DeckService deckService = DI.get(DeckService);
      if (event is LoadDeckListEvent) {
        yield DeckListLoading();
        var decks = await deckService.getNewDecks();
        yield DeckListLoaded(decks);
      }
    } on APIException catch (error) {
      switch (error.reason) {
        case ApiErrorReasons.NotAuthenticated:
          _logout(error.message);
          break;
        default:
          yield DeckListFailure(error: '${error.message}');
          break;
      }
    } catch (e) {
      yield DeckListFailure(error: e.message);
    }
  }
}

void _logout(String error) {
  NotificationBloc notifyBloc = DI.get(NotificationBloc);
  AuthenticationBloc authenBloc = DI.get(AuthenticationBloc);
  notifyBloc.add(ErrorNotification(error));
  authenBloc.add(LoggedOut());
}
