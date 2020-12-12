import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/dimens.dart';
import 'package:the_flashcard/common/resources/resources.dart';
import 'package:the_flashcard/common/xwidgets/x_state.dart';
import 'package:the_flashcard/environment/driver_key.dart';
import 'package:the_flashcard/review/progress/review_explanation_screen.dart';
import 'package:the_flashcard/review/review_progress_bloc.dart';

class ReviewInteractionSubmitWidget extends StatefulWidget {
  final int step;
  final VoidCallback onSubmitted;
  final ReviewProgressBloc reviewProgressBloc;
  final PageController pageController;
  final VoidCallback onNext;
  final bool isCorrect;
  final bool isLastPage;
  final core.Container backByIndex;
  final core.ReviewInfo reviewInfo;

  ReviewInteractionSubmitWidget(
    this.reviewProgressBloc,
    this.pageController,
    this.step,
    this.isLastPage, {
    this.onSubmitted,
    this.isCorrect,
    this.onNext,
    this.backByIndex,
    @required this.reviewInfo,
  });

  ReviewInteractionSubmitWidget withReviewInfo(core.ReviewInfo reviewInfo) {
    return ReviewInteractionSubmitWidget(
      reviewProgressBloc,
      pageController,
      step,
      isLastPage,
      onSubmitted: onSubmitted,
      isCorrect: isCorrect,
      onNext: onNext,
      backByIndex: backByIndex,
      reviewInfo: reviewInfo,
    );
  }

  @override
  _ReviewInteractionSubmitWidgetState createState() =>
      _ReviewInteractionSubmitWidgetState();
}

class _ReviewInteractionSubmitWidgetState
    extends XState<ReviewInteractionSubmitWidget> {
  bool isNavigated = false;
  bool isBackEmpty = true;
  bool isStopTimer = false;
  Timer timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  void jumpToNextInDuration(BuildContext context, Duration duration) {
    if (isBackEmpty) return;
    timer = Timer(duration, () {
      if (!isStopTimer) {
        navigateToScreen(
          screen: ReviewExplanationScreen(
            widget.reviewProgressBloc,
            widget.pageController,
            widget.backByIndex,
            widget.onNext,
            widget.isLastPage,
            dayLeft: widget.reviewInfo?.dayLeft(),
          ),
        );
      }
    });
  }

  Widget submitButton(VoidCallback onSubmitted) {
    return InkWell(
      onTap: () => XError.f0(() {
        onSubmitted();
      }),
      child: Container(
        height: hp(56),
        width: wp(375),
        decoration: BoxDecoration(
          color: XedColors.white,
          border: Border(
            top: BorderSide(
              width: 1,
              color: Color.fromRGBO(18, 18, 18, 0.1),
            ),
          ),
        ),
        child: Center(
          child: Text(
            'SUBMIT ANSWER',
            style: SemiBoldTextStyle(18),
            key: Key(DriverKey.TEXT_SUBMIT),
          ),
        ),
      ),
    );
  }

  Widget explainButton() {
    if (widget.isCorrect != null &&
        widget.isCorrect == false &&
        isNavigated == false) {
      isNavigated = true;
      jumpToNextInDuration(context, Duration(milliseconds: 500));
    }
    return Container(
      height: hp(56),
      width: wp(375),
      decoration: BoxDecoration(
        color: XedColors.white,
        border: Border(
          top: BorderSide(
            width: 1,
            color: XedColors.divider01,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          isBackEmpty
              ? SizedBox()
              : Expanded(
                  child: InkWell(
                    onTap: () => XError.f0(() {
                      isStopTimer = true;
                      navigateToScreen(
                        screen: ReviewExplanationScreen(
                          widget.reviewProgressBloc,
                          widget.pageController,
                          widget.backByIndex,
                          widget.onNext,
                          widget.isLastPage,
                          dayLeft: widget.reviewInfo?.dayLeft(),
                        ),
                      );
                    }),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: wp(15)),
                      child: Text('EXPLANATION', style: SemiBoldTextStyle(18)),
                    ),
                  ),
                ),
          Expanded(
            child: InkWell(
              onTap: () => XError.f0(() {
                isStopTimer = true;
                widget.onNext();
              }),
              child: Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: wp(15)),
                child: Text('NEXT', style: SemiBoldTextStyle(18)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _checkBackCardSide() {
    setState(() {
      isBackEmpty = widget.backByIndex?.getComponentCount() == 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    _checkBackCardSide();
    return SafeArea(
      child: widget.step == 0
          ? Opacity(
              opacity: 0.2,
              child: submitButton(null),
            )
          : widget.step == 1
              ? submitButton(widget.onSubmitted)
              : explainButton(),
    );
  }
}
