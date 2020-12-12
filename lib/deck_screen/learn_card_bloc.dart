import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ddi/di.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:tf_core/tf_core.dart';
import 'package:the_flashcard/review/review_list_bloc.dart';
import 'package:the_flashcard/review/review_list_event.dart';

import 'card_list_bloc.dart';

enum LearningMode { Learning, QuizLearning }

@immutable
class LearnCardState extends Equatable {
  final Map<String, ReviewInfo> reviewInfoMap;
  final bool isLoading;
  final bool isSuccess;
  final String error;
  final LearningMode mode;
  final List<String> cardIds;

  @override
  final List<Object> props;

  LearnCardState({
    @required this.reviewInfoMap,
    this.isLoading = false,
    this.isSuccess = false,
    this.error = '',
    this.mode = LearningMode.Learning,
    this.cardIds = const <String>[],
  }) : props = ([reviewInfoMap, isLoading, isSuccess, error, mode, cardIds]);

  LearnCardState.init()
      : reviewInfoMap = <String, ReviewInfo>{},
        isLoading = false,
        isSuccess = false,
        error = null,
        mode = LearningMode.Learning,
        cardIds = const <String>[],
        props = const [];

  LearnCardState copyWith({
    Map<String, ReviewInfo> reviewInfoMap,
    bool isSuccess,
    bool isFailure,
    LearningMode mode,
    String error,
    List<String> cardIds,
  }) {
    return LearnCardState(
      reviewInfoMap: reviewInfoMap ?? this.reviewInfoMap,
      isLoading: isSuccess ?? this.isLoading,
      isSuccess: isFailure ?? this.isSuccess,
      error: error ?? this.error,
      mode: mode ?? this.mode,
      cardIds: cardIds ?? this.cardIds,
    );
  }

  LearnCardState loading() {
    return LearnCardState(
        reviewInfoMap: this.reviewInfoMap,
        isLoading: true,
        isSuccess: false,
        error: '');
  }

  LearnCardState success(Map<String, ReviewInfo> reviewInfoMap) {
    return LearnCardState(
        reviewInfoMap: reviewInfoMap,
        isLoading: false,
        isSuccess: true,
        error: '');
  }

  LearnCardState failure(String error) {
    return LearnCardState(
        reviewInfoMap: this.reviewInfoMap,
        isLoading: false,
        isSuccess: false,
        error: error);
  }

  @override
  String toString() => 'LearnCardState';

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => runtimeType.hashCode;
}

@immutable
abstract class LearnCardEvent {}

class LearnCard extends LearnCardEvent {
  final List<String> cardIds;

  LearnCard(this.cardIds);

  @override
  String toString() => 'LearnCard';
}

class QuizReview extends LearnCardEvent {
  final List<String> cardIds;

  QuizReview(this.cardIds);

  @override
  String toString() => 'QuizReview $cardIds';
}

class LearnCardBloc extends Bloc<LearnCardEvent, LearnCardState> {
  final CardListBloc cardListCubit;
  final DueReviewBloc dueCardCubit;
  final LearningReviewBloc learningCardCubit;
  final DoneReviewBloc doneCardCubit;

  final DeckService deckService = DI.get(DeckService);
  final SRSService srsService = DI.get(SRSService);

  LearnCardBloc({
    @required this.cardListCubit,
    @required this.dueCardCubit,
    @required this.learningCardCubit,
    @required this.doneCardCubit,
  });
  @override
  LearnCardState get initialState => LearnCardState.init();
  @override
  Stream<LearnCardState> mapEventToState(LearnCardEvent event) async* {
    switch (event.runtimeType) {
      case LearnCard:
        yield* _addCardToReview(event);
        break;
      case QuizReview:
        yield* _quizReview(event);
        break;
    }
  }

  Stream<LearnCardState> _addCardToReview(LearnCard event) async* {
    try {
      yield state.loading();
      final cardIds = event.cardIds ?? <String>[];
      Map<String, ReviewInfo> r = await srsService.addCards(cardIds);
      cardListCubit.add(UpdateReviewInfo(r));
      Future.delayed(Duration(seconds: 3), () {
        dueCardCubit.add(RefreshReview());
        learningCardCubit.add(RefreshReview());
      });
      yield state.success(r);
    } catch (e) {
      yield _handleError(e);
    }
  }

  LearnCardState _handleError(e) {
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

  Stream<LearnCardState> _quizReview(QuizReview event) async* {
    yield state.copyWith(
      mode: LearningMode.QuizLearning,
      cardIds: event.cardIds,
    );
  }
}
