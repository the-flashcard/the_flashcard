import 'package:ddi/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/xed_sheets.dart';
import 'package:the_flashcard/review/review_list_bloc.dart';
import 'package:the_flashcard/review/review_list_event.dart';

class SkipDoneBottomSheetWidget extends StatelessWidget {
  final String cardId;
  final VoidCallback countSkippedCard;
  final VoidCallback moveToNextPage;
  final VoidCallback inCreaseCorrectAnswer;
  final bool isQuizMode;

  SkipDoneBottomSheetWidget(
    this.cardId,
    this.countSkippedCard,
    this.moveToNextPage,
    this.inCreaseCorrectAnswer,
    this.isQuizMode,
  );

  @override
  Widget build(BuildContext context) {
    return XedSheets.bottomSheet(
      context,
      'More',
      SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: SvgPicture.asset(
                Assets.icDontView,
                width: wp(20),
                height: wp(20),
              ),
              title: Text(
                'Skip Card On This Time',
                style: SemiBoldTextStyle(16).copyWith(height: 1.4),
              ),
              onTap: () => XError.f0(
                () => _onSkipCardPressed(
                  context,
                  countSkippedCard,
                  moveToNextPage,
                ),
              ),
            ),
            ListTile(
              leading: SvgPicture.asset(
                Assets.icMoveTo,
                width: wp(16),
                height: wp(16),
              ),
              title: Text(
                'Move to DONE (never show again)',
                style: SemiBoldTextStyle(16).copyWith(height: 1.4),
              ),
              onTap: () => XError.f0(
                () => _onMoveToDonePressed(
                  context,
                  cardId,
                  inCreaseCorrectAnswer,
                  moveToNextPage,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onMoveToDonePressed(
    BuildContext context,
    String cardId,
    VoidCallback countCorrectAnswer,
    VoidCallback moveToNextPage,
  ) {
    if (!isQuizMode) _moveCardToDone(context, cardId);
    Navigator.of(context).pop();
    countCorrectAnswer();
    moveToNextPage();
  }

  void _onSkipCardPressed(
    BuildContext context,
    VoidCallback countSkippedCard,
    VoidCallback moveToNextPage,
  ) {
    Navigator.of(context).pop();
    countSkippedCard();
    moveToNextPage();
  }

  void _moveCardToDone(BuildContext context, String cardId) async {
    try {
      core.SRSService srsService = DI.get(core.SRSService);
      await srsService.moveDone(cardId);

      BlocProvider.of<DoneReviewBloc>(context).add(RefreshReview());
    } catch (ex) {
      core.Log.error("Move card $cardId to done: $ex");
    }
  }
}
