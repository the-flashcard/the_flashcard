import 'package:equatable/equatable.dart';
import 'package:tf_core/tf_core.dart';

abstract class ReviewProgressEvent extends Equatable {
  ReviewProgressEvent([this.props = const []]);

  @override
  final List<Object> props;
}

class CardLoaded extends ReviewProgressEvent {
  final List<String> cardIds;
  final Map<String, ReviewCard> reviewCards;

  CardLoaded(this.cardIds, this.reviewCards);

  @override
  String toString() => 'CardLoaded';
}

class Submit extends ReviewProgressEvent {
  final ReviewAnswer answer;
  final String cardId;
  final int elapsedTime;
  final bool isQuizMode;

  Submit(this.cardId, this.answer, this.elapsedTime, this.isQuizMode);

  @override
  String toString() => 'Submit';
}

class Explain extends ReviewProgressEvent {
  @override
  String toString() => 'Explain';
}

class Next extends ReviewProgressEvent {
  @override
  String toString() => 'Next';
}

class Yes extends ReviewProgressEvent {
  final String cardId;
  final int elapsedTime;
  final bool isQuizMode;

  Yes(this.cardId, this.elapsedTime, this.isQuizMode);

  @override
  String toString() => 'Yes';
}

class No extends ReviewProgressEvent {
  final String cardId;
  final int elapsedTime;
  final bool isQuizMode;

  No(this.cardId, this.elapsedTime, this.isQuizMode);

  @override
  String toString() => 'Yes';
}
