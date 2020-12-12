import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/xwidgets/x_review_card_side_widget.dart';
import 'package:the_flashcard/review/progress/review_bottom_bar_widget.dart';
import 'package:the_flashcard/review/review_progress_bloc.dart';

class ReviewExplanationScreen extends StatelessWidget {
  final ReviewProgressBloc reviewProgressBloc;
  final PageController pageController;
  final core.Container backByIndex;
  final Function onNextPage;
  final bool isLastPage;
  final int dayLeft;

  ReviewExplanationScreen(this.reviewProgressBloc, this.pageController,
      this.backByIndex, this.onNextPage, this.isLastPage,
      {this.dayLeft});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: XedColors.white255.withAlpha(250),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: wp(30),
            color: XedColors.black,
          ),
          onPressed: () => XError.f0(() {
            Navigator.of(context).pop();
          }),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(),
            Expanded(
              child: XReviewCardSideWidget(
                cardContainer: backByIndex,
                mode: XComponentMode.Review,
                title: '',
              ),
            ),
            ReviewBottomBarWidget(
              isLastPage: isLastPage,
              daysLeft: dayLeft,
              onTapNext: () => XError.f1(_onTapNext, context),
            ),
          ],
        ),
      ),
    );
  }

  void _onTapNext(context) {
    Navigator.of(context).pop();
    onNextPage();
  }
}
