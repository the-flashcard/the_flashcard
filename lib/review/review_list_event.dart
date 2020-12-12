import 'package:equatable/equatable.dart';
import 'package:tf_core/tf_core.dart';

abstract class ReviewListEvent extends Equatable {
  ReviewListEvent([this.props = const []]);

  @override
  final List<Object> props;
}

class RefreshReview extends ReviewListEvent {
  @override
  String toString() => 'RefreshReview';
}

class LoadMore extends ReviewListEvent {
  @override
  String toString() => 'LoadMore';
}

class RemoveDeck extends ReviewListEvent {
  final String deckId;

  RemoveDeck(this.deckId);

  @override
  String toString() => 'RemoveDeck';
}

class AddCards extends ReviewListEvent {
  final Deck deck;
  final List<String> cardIds;

  AddCards(this.deck, this.cardIds);

  @override
  String toString() => 'AddCards';
}
