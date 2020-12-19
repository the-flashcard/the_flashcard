import 'dart:math';

import 'package:ddi/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/dimens.dart';
import 'package:the_flashcard/common/resources/local_audio_manager.dart';
import 'package:the_flashcard/common/resources/xed_colors.dart';
import 'package:the_flashcard/common/resources/xed_progress.dart';
import 'package:the_flashcard/common/widgets/skip_done_bottom_sheet_widget.dart';
import 'package:the_flashcard/common/xwidgets/x_review_card_side_widget.dart';
import 'package:the_flashcard/common/xwidgets/x_state.dart';
import 'package:the_flashcard/deck_creation/multi_choice/bloc/multi_choice_bloc.dart';
import 'package:the_flashcard/deck_screen/card_list_bloc.dart';
import 'package:the_flashcard/review/progress/review_interaction_quiz_widget.dart';
import 'package:the_flashcard/review/progress/review_interaction_submit_widget.dart';
import 'package:the_flashcard/review/review_list_bloc.dart';
import 'package:the_flashcard/review/review_progress_bloc.dart';
import 'package:the_flashcard/review/review_progress_event.dart';
import 'package:the_flashcard/review/review_progress_state.dart';
import 'package:the_flashcard/review/review_result_screen.dart';

class ReviewProgressScreen extends StatefulWidget {
  static String name = '/reviewProgress';
  final List<String> cardIds;
  final bool isQuizMode;

  ReviewProgressScreen(this.cardIds, this.isQuizMode);

  @override
  _ReviewProgressScreenState createState() => _ReviewProgressScreenState();
}

class _ReviewProgressScreenState extends XState<ReviewProgressScreen> {
  Random random = Random();
  int numberOfPages;
  int progress = 0;
  int currentPage = 0;
  PageController pageController;
  CardListBloc cardListBloc;
  int step = 0;
  ReviewInteractionSubmitWidget submitInteraction;
  ReviewInteractionQuizWidget quizInteraction;
  ReviewProgressBloc reviewProgressBloc;
  int numberOfCorrectAnswers = 0;
  int numberOfSkippedCard = 0;

  final Map<int, Set<int>> userMCAnswers = <int, Set<int>>{};
  final Map<int, List<String>> userFIBAnswers = <int, List<String>>{};

  Stopwatch stopwatch;
  core.ReviewInfo currentReviewInfo;

  @override
  void initState() {
    super.initState();
    stopwatch = Stopwatch()..start();
    cardListBloc = CardListBloc();
    reviewProgressBloc = ReviewProgressBloc(
      dueBloc: DI.get<DueReviewBloc>(DueReviewBloc),
      learningBloc: DI.get<LearningReviewBloc>(LearningReviewBloc),
      doneBloc: DI.get<DoneReviewBloc>(DoneReviewBloc),
    );
    numberOfPages = widget.cardIds.length;
    pageController = PageController();
    resetInteraction();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: XedColors.white255.withAlpha(250),
        leading: IconButton(
          icon: Icon(
            Icons.close,
            size: wp(30),
            color: XedColors.brownGrey,
          ),
          onPressed: () => XError.f0(() {
            Navigator.of(context).pop();
          }),
        ),
        title: Row(
          children: <Widget>[
            Expanded(
              child: FAProgressBar(
                currentValue: progress,
                size: hp(6),
                borderRadius: 3,
                progressColor: XedColors.waterMelon,
                backgroundColor: XedColors.duckEggBlue,
              ),
            ),
            SizedBox(width: wp(20)),
            Text(
              '${currentPage + 1}/$numberOfPages',
              style: SemiBoldTextStyle(14).copyWith(color: XedColors.brownGrey),
            ),
            SizedBox(width: wp(20)),
            Container(
              width: wp(1),
              height: hp(20),
              color: Color.fromRGBO(43, 43, 43, 0.1),
            ),
            SizedBox(width: wp(10)),
            IconButton(
              icon: Icon(
                Icons.more_horiz,
                color: XedColors.battleShipGrey,
                size: 30,
              ),
              onPressed: () => XError.f0(() {
                showModalBottomSheet(
                  backgroundColor: XedColors.transparent,
                  context: context,
                  builder: (context) => SkipDoneBottomSheetWidget(
                    widget.cardIds[currentPage],
                    _increaseSkippedCard,
                    _goToNextPage,
                    _inscreaseCorrectAnswer,
                    widget.isQuizMode,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      body: BlocBuilder<CardListBloc, CardListState>(
        bloc: cardListBloc,
        builder: (BuildContext context, CardListState state) {
          if (state.isCardLoaded) {
            return PageView.builder(
              physics: NeverScrollableScrollPhysics(),
              controller: pageController,
              itemCount: numberOfPages + 1,
              itemBuilder: (BuildContext context, int index) {
                core.Card card = state.getCard(index);
                var frontAndBack = getFrontAndBack(state, index);
                final front = frontAndBack.key;
                final back = frontAndBack.value;

                return BlocBuilder(
                  bloc: reviewProgressBloc,
                  builder: (BuildContext context, ReviewProgressState state) {
                    if (state is ReviewProgressState) {
                      currentReviewInfo = state.reviewInfo;
                      reviewProgressBloc.state.card = card;
                      return front.hasActionComponent()
                          ? state?.isSubmitted == true
                              ? actionResultComponent(front, back)
                              : actionReviewComponent(card.id, front, back)
                          : state?.isNotRemember == true
                              ? nonActionResultComponent(back, state.reviewInfo)
                              : nonActionReviewComponent(card.id, front, back);
                    }
                    return Center(child: XedProgress.indicator());
                  },
                );
              },
              onPageChanged: (int index) {
                setState(() {
                  stopwatch.reset();
                  increaseProgress(index);
                });
              },
            );
          } else {
            cardListBloc.add(LoadCardList(widget.cardIds));
            return Center(child: XedProgress.indicator());
          }
        },
      ),
    );
  }

  Widget actionReviewComponent(
      String cardId, core.Container frontByLevel, core.Container backByIndex) {
    return Column(
      children: <Widget>[
        Expanded(
          child: XReviewCardSideWidget(
            cardContainer: frontByLevel,
            mode: XComponentMode.Review,
            title: '',
            userMCAnswers: userMCAnswers,
            userFIBAnswers: userFIBAnswers,
            onMCAnswerChanged: (componentIndex, choices) {
              if (choices.isNotEmpty)
                userMCAnswers[componentIndex] = choices;
              else
                userMCAnswers.remove(componentIndex);

              _checkAndEnableSubmitButton(cardId, frontByLevel, backByIndex);
            },
            onFIBAnswerChanged: (componentIndex, isSubmittable, answers) {
              if (isSubmittable) {
                userFIBAnswers[componentIndex] = answers;
              } else {
                userFIBAnswers.remove(componentIndex);
              }
              _checkAndEnableSubmitButton(cardId, frontByLevel, backByIndex);
            },
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: submitInteraction,
        ),
      ],
    );
  }

  Widget actionResultComponent(
      core.Container frontByLevel, core.Container backByIndex) {
    return Column(
      children: <Widget>[
        Expanded(
          child: XReviewCardSideWidget(
            cardContainer: frontByLevel,
            title: '',
            key: UniqueKey(),
            userMCAnswers:
                Map<int, Set<int>>.fromEntries(userMCAnswers.entries),
            userFIBAnswers:
                Map<int, List<String>>.fromEntries(userFIBAnswers.entries),
            mode: XComponentMode.Result,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: submitInteraction.withReviewInfo(currentReviewInfo),
        ),
      ],
    );
  }

  Widget nonActionReviewComponent(
      String cardId, core.Container front, core.Container back) {
    return Column(
      children: <Widget>[
        Expanded(
          child: XReviewCardSideWidget(
            cardContainer: front,
            title: '',
            mode: XComponentMode.Review,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: ReviewInteractionQuizWidget(
            false,
            isLastPage(),
            onNoPressed: () {
              core.Log.debug(stopwatch.elapsedMilliseconds);
              reviewProgressBloc.add(
                No(cardId, stopwatch.elapsedMilliseconds, widget.isQuizMode),
              );
              // _inscreaseCorrectAnswer();
              bool isBackEmpty = back?.getComponentCount() == 0 ?? true;
              if (isBackEmpty) {
                _goToNextPage();
                return;
              }
              quizInteraction = ReviewInteractionQuizWidget(
                true,
                isLastPage(),
                onNext: _goToNextPage,
              );
            },
            onYesPressed: () {
              core.Log.debug('Yes in time ${stopwatch.elapsed.inSeconds}');
              reviewProgressBloc.add(Yes(
                cardId,
                stopwatch.elapsedMilliseconds,
                widget.isQuizMode,
              ));
              _inscreaseCorrectAnswer();
              _goToNextPage();
            },
          ),
        ),
      ],
    );
  }

  void resetInteraction() {
    submitInteraction = ReviewInteractionSubmitWidget(
      reviewProgressBloc,
      pageController,
      step,
      isLastPage(),
      reviewInfo: currentReviewInfo,
    );
    quizInteraction = ReviewInteractionQuizWidget(false, isLastPage());
  }

  bool isLastPage() {
    return currentPage == numberOfPages - 1;
  }

  bool countCorrectAnswers(List<core.Component> components) {
    List<bool> answerResults = <bool>[];
    components.asMap().forEach((index, component) {
      core.Log.debug("Check answers: $index - ${component.runtimeType}");
      if (component is core.BaseMC) {
        final userAnswer = userMCAnswers[index] ?? <int>{};
        final resultStatus = component.validateAnswers(userAnswer);
        answerResults.add(resultStatus);
      } else if (component is core.FillInBlank) {
        final userAnswer = userFIBAnswers[index] ?? <String>[];
        final resultStatus = component.validateAnswers(userAnswer);
        answerResults.add(resultStatus);
      }
    });

//    final correctAnswers = answerResults.where((x) => x ==true);
    final incorrectAnswers = answerResults.where((x) => !x).toList();

    core.Log.debug("User answers: $answerResults");
    core.Log.debug("In correct answers: $incorrectAnswers");

    if (incorrectAnswers.isEmpty) {
      numberOfCorrectAnswers += 1;
      return true;
    } else {
      return false;
    }
  }

  void showReviewResult() {
    core.Log.debug(
      'numberOfPages: $numberOfPages - numberOfCorrectAnswers: $numberOfCorrectAnswers - numberOfSkippedCard: $numberOfSkippedCard',
    );

    final int cardIncorrect =
        numberOfPages - numberOfCorrectAnswers - numberOfSkippedCard;
    navigateToScreen(
      name: ReviewResultScreen.name,
      screen: ReviewResultScreen(
        widget.isQuizMode,
        cardCorrect: numberOfCorrectAnswers,
        cardIncorrect: cardIncorrect,
      ),
    );
  }

  void resetPage() {
    step = 0;
    resetInteraction();
    userFIBAnswers.clear();
    userMCAnswers.clear();
  }

  void nextPage() {
    reviewProgressBloc.add(Next());
    pageController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.linear,
    );
  }

  void _goToNextPage() {
    if (isLastPage()) {
      showReviewResult();
    } else {
      resetPage();
      nextPage();
    }
  }

  void _checkAndEnableSubmitButton(
    String cardId,
    core.Container frontCard,
    core.Container backCard,
    // core.ReviewInfo reviewInfo,
  ) {
    int totalUserAnswers = userFIBAnswers.length + userMCAnswers.length;
    int totalActionComponent = frontCard.countActionComponent();
    if (totalUserAnswers >= totalActionComponent) {
      step = 1;
      submitInteraction = ReviewInteractionSubmitWidget(
        reviewProgressBloc,
        pageController,
        step,
        isLastPage(),
        onSubmitted: () => _onSubmitAnswer(cardId, frontCard, backCard),
        reviewInfo: currentReviewInfo,
      );
    } else {
      step = 0;
      resetInteraction();
    }

    //Render changes
    setState(() {});
  }

  void _onSubmitAnswer(
    String cardId,
    core.Container frontByLevel,
    core.Container backByIndex,
  ) {
    try {
      var isCorrect = countCorrectAnswers(frontByLevel.components);
      isCorrect
          ? LocalAudioManager.playCorrectSound()
          : LocalAudioManager.playIncorrectSound();

      step = 2;
      submitInteraction = ReviewInteractionSubmitWidget(
        reviewProgressBloc,
        pageController,
        step,
        isLastPage(),
        onNext: _goToNextPage,
        backByIndex: backByIndex,
        isCorrect: isCorrect,
        reviewInfo: currentReviewInfo,
      );
      reviewProgressBloc.add(
        Submit(
          cardId,
          isCorrect ? core.ReviewAnswer.Known : core.ReviewAnswer.DontKnow,
          stopwatch.elapsedMilliseconds,
          widget.isQuizMode,
        ),
      );

      //Render changes
      setState(() {});
    } catch (e) {
      core.Log.error(e);
    }
  }

  void increaseProgress(int index) {
    currentPage = index;
    progress = ((100 / (numberOfPages - 1)) * index).toInt();
  }

  Widget nonActionResultComponent(
      core.Container back, core.ReviewInfo reviewInfo) {
    return Column(
      children: <Widget>[
        Expanded(
          child: XReviewCardSideWidget(
            cardContainer: back,
            title: '',
            mode: XComponentMode.Review,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: ReviewInteractionQuizWidget(
            true,
            isLastPage(),
            onNext: _goToNextPage,
            dayLeft: widget.isQuizMode ? null : reviewInfo?.dayLeft(),
          ),
        ),
      ],
    );
  }

  void _inscreaseCorrectAnswer() {
    numberOfCorrectAnswers += 1;
  }

  void _increaseSkippedCard() {
    numberOfSkippedCard += 1;
  }

  MapEntry<core.Container, core.Container> getFrontAndBack(
      CardListState state, int index) {
    core.Card card = state.getCard(index);
    int frontIndex = 0;

    if (widget.isQuizMode) {
      frontIndex = 0;
    } else {
      int level = state.reviewCards[card.id]?.reviewInfo?.memorizingLevel ?? 0;
      frontIndex = level % max(card.design?.fronts?.length ?? 0, 1);
    }

    core.Container front = card.design.getFront(frontIndex);
    core.Container back = card.design.back;

    return MapEntry(front, back);
  }
}
