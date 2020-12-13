import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ddi/di.dart';
import 'package:flutter/widgets.dart';
import 'package:tf_core/tf_core.dart';
import 'package:the_flashcard/review/review_list_bloc.dart';
import 'package:the_flashcard/review/review_list_event.dart';
import 'package:the_flashcard/review/review_progress_event.dart';
import 'package:the_flashcard/review/review_progress_state.dart';

class ReviewProgressBloc
    extends Bloc<ReviewProgressEvent, ReviewProgressState> {
  final List<String> cardIds = <String>[];
  final Map<String, ReviewCard> reviewCards = <String, ReviewCard>{};

  final SRSService srsService = DI.get(SRSService);
  final DueReviewBloc dueBloc;
  final LearningReviewBloc learningBloc;
  final DoneReviewBloc doneBloc;

  ReviewProgressBloc({
    @required this.dueBloc,
    @required this.learningBloc,
    @required this.doneBloc,
  }) : super(ReviewProgressState.empty());

  @override
  Stream<ReviewProgressState> mapEventToState(
      ReviewProgressEvent event) async* {
    switch (event.runtimeType) {
      case CardLoaded:
        break;
      case Submit:
        yield* _submitAnswer(event);
        break;
      case Explain:
        Log.debug('explain');
        break;
      case Yes:
        yield* _yes(event);
        break;
      case No:
        yield* _no(event);
        break;
      case Next:
        yield ReviewProgressLoading();
        yield ReviewProgressState.empty();
        break;
    }
  }

  Stream<ReviewProgressState> _yes(Yes yesEvent) async* {
    yield ReviewProgressLoading();
    if (yesEvent.isQuizMode == false) {
      ReviewInfo reviewInfo = await srsService.review(
        yesEvent.cardId,
        ReviewAnswer.Known,
        yesEvent.elapsedTime,
      );
      _refreshReviewListing();
      yield ReviewProgressState(
        isNotRemember: false,
        reviewInfo: reviewInfo,
      );
    } else {
      yield ReviewProgressState(isNotRemember: false, reviewInfo: null);
    }
  }

  Stream<ReviewProgressState> _no(No noEvent) async* {
    yield ReviewProgressLoading();
    if (noEvent.isQuizMode == false) {
      var reviewInfo = await srsService.review(
        noEvent.cardId,
        ReviewAnswer.DontKnow,
        noEvent.elapsedTime,
      );
      _refreshReviewListing();
      yield ReviewProgressState(
        isNotRemember: true,
        reviewInfo: reviewInfo,
      );
    } else {
      yield ReviewProgressState(isNotRemember: true, reviewInfo: null);
    }
  }

  Stream<ReviewProgressState> _submitAnswer(Submit event) async* {
    yield ReviewProgressLoading();
    Submit submitEvent = event;
    if (submitEvent.isQuizMode == false) {
      ReviewInfo reviewInfo = await srsService.review(
        submitEvent.cardId,
        submitEvent.answer,
        submitEvent.elapsedTime,
      );
      _refreshReviewListing();
      yield ReviewProgressState(isSubmitted: true, reviewInfo: reviewInfo);
    } else {
      yield ReviewProgressState(isSubmitted: true, reviewInfo: null);
    }
  }

  void _refreshReviewListing() {
    Future.delayed(Duration(seconds: 2), () {
      dueBloc.add(RefreshReview());
      learningBloc.add(RefreshReview());
      doneBloc.add(RefreshReview());
    });
  }
}
