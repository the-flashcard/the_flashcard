import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';

class ReviewBottomBarWidget extends StatelessWidget {
  final VoidCallback onTapNext;
  final int daysLeft;
  final bool isLastPage;

  const ReviewBottomBarWidget({
    Key key,
    @required this.onTapNext,
    @required this.daysLeft,
    @required this.isLastPage,
  }) : super(key: key);

  Widget build(BuildContext context) {
    return Container(
      height: hp(56),
      decoration: BoxDecoration(
        color: XedColors.white,
        border: Border(
          top: BorderSide(
            width: 1,
            color: XedColors.divider01,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            daysLeft is int ? _descriptionWidget() : SizedBox(),
            _buttonNextOrResultWidget(),
          ],
        ),
      ),
    ); // return Padding(
  }

  Widget _buttonNextOrResultWidget() {
    return Flexible(
      child: InkWell(
        onTap: onTapNext,
        child: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: wp(15)),
          child: Text('NEXT', style: SemiBoldTextStyle(18)),
        ),
      ),
    );
  }

  Widget _descriptionWidget() {
    final Text timeWidget = Text(
      '$daysLeft days left',
      style: BoldTextStyle(16).copyWith(
        height: 1.4,
        color: XedColors.waterMelon,
      ),
    );
    final Text descriptionWidget = Text(
      core.Config.getString("msg_card_review_again"),
      style: RegularTextStyle(14).copyWith(
        height: 1.4,
        color: XedColors.brownGrey,
      ),
    );

    return Expanded(
      child: Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          timeWidget,
          descriptionWidget,
        ],
      ),
    );
  }
}
