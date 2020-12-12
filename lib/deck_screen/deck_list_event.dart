import 'package:equatable/equatable.dart';
import 'package:tf_core/tf_core.dart';

abstract class DeckListEvent extends Equatable {
  DeckListEvent([this.props = const []]);

  @override
  final List<Object> props;
}

class CategoryChanged extends DeckListEvent {
  final bool isRemoved;
  final String categoryId;

  CategoryChanged({this.categoryId, this.isRemoved = false});

  @override
  String toString() => 'CategoryChanged';
}

class QueryChanged extends DeckListEvent {
  final String query;

  QueryChanged({this.query});

  @override
  String toString() => 'NameChanged';
}

class Refresh extends DeckListEvent {
  @override
  String toString() => 'Refresh';
}

class LoadMore extends DeckListEvent {
  @override
  String toString() => 'LoadMore';
}

class AddOrUpdateListing extends DeckListEvent {
  final Deck deck;

  AddOrUpdateListing(this.deck);
}

class SelectDeck extends DeckListEvent {
  final String deckId;

  SelectDeck(this.deckId);
}

class SelectAllDeck extends DeckListEvent {}

class DeSelectAllDeck extends DeckListEvent {}

class DeleteSelectedDecks extends DeckListEvent {}

class RemoveDeck extends DeckListEvent {
  final Set<String> deckIds;

  RemoveDeck(this.deckIds);
}
