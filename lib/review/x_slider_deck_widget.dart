import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/cached_image/x_cached_image_widget.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/assets.dart';
import 'package:the_flashcard/common/resources/dimens.dart';
import 'package:the_flashcard/common/resources/xed_colors.dart';
import 'package:the_flashcard/common/resources/xed_shadows.dart';
import 'package:the_flashcard/common/resources/xed_text_styles.dart';
import 'package:the_flashcard/common/widgets/deck_thumnail_default.dart';
import 'package:the_flashcard/common/xwidgets/x_state.dart';
import 'package:the_flashcard/deck_screen/card_view/multi_card_detail_screen.dart';
import 'package:the_flashcard/onboarding/onboarding.dart';
import 'package:the_flashcard/review/progress/review_progress_screen.dart';

abstract class OnSliderViewDeckWidgetCallBack {
  void onSelected(int index);

  void onDelete(int index);

  void onSliding(int index);
}

enum ReviewIn { DueDay, Learning, Done }

class XSliderDeckWidget extends StatefulWidget {
  final int index;
  final core.Deck deck;
  final bool canReview;
  final bool sliding;
  final SlidableController controller;
  final Function(core.Deck) onDeleteTap;
  final String valueKey;
  final ReviewIn reviewIn;

  XSliderDeckWidget(
    this.index,
    this.deck,
    this.controller, {
    @required this.reviewIn,
    Key key,
    this.canReview = true,
    this.sliding = false,
    this.onDeleteTap,
    this.valueKey,
  }) : super(key: key);

  @override
  _XSliderDeckWidgetState createState() => _XSliderDeckWidgetState();

  void closeSlider() {
    if (controller.activeState != null) controller.activeState.close();
  }

  void openSlider() {
    if (controller.activeState != null) controller.activeState.open();
  }
}

class _XSliderDeckWidgetState extends XState<XSliderDeckWidget> {
  // bool sliding = false;
  // SlidableController _controller;

  @override
  void initState() {
    super.initState();
    // if (widget.controller == null)
    //   widget.controller = SlidableController(
    //     onSlideIsOpenChanged: (open) {
    //       setState(() {
    //         widget.sliding = open;
    //         widget?.callBack?.onSliding(widget.index);
    //       });
    //     },
    //     onSlideAnimationChanged: (value) {},
    //   );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => XError.f0(() {
        if (widget.canReview) {
          gotoReview(widget.deck);
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MultiCardDetailScreen(widget.deck),
            ),
          );
        }
      }),
      child: Slidable(
        key: Key(widget?.valueKey ?? ''),
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        controller: widget.controller,
        secondaryActions: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: wp(20)),
            child: _iconDelete(),
          ),
        ],
        child: Container(
          height: hp(88),
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            boxShadow: widget.sliding ? [XedShadows.shadow10WithoutOffset] : [],
            color: widget.sliding ? XedColors.white : XedColors.transparent,
          ),
          child: Row(
            children: <Widget>[
              _image(widget.deck.thumbnail),
              SizedBox(width: wp(18)),
              _textDescription(widget.deck.name, widget.deck.cardIds.length),
              Spacer(),
              (widget.canReview ?? true) ? _iconReview() : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconDelete() {
    return SizedBox(
      height: wp(40),
      width: wp(40),
      child: FloatingActionButton(
        key: Key(widget.valueKey + "_delete" ?? ''),
        heroTag: "Delete",
        child: SizedBox(
          height: wp(24),
          width: wp(24),
          child: SvgPicture.asset(
            Assets.icDelete,
            color: XedColors.white,
          ),
        ),
        backgroundColor: XedColors.waterMelon,
        onPressed: () => XError.f0(() {
          onDeleteReviewDeck();
        }),
      ),
    );
  }

  Widget _textDescription(String title, int totalCards) {
    return SizedBox(
      width: wp(215),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: SemiBoldTextStyle(14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '$totalCards Cards',
            style:
                RegularTextStyle(14).copyWith(color: XedColors.battleShipGrey),
          ),
        ],
      ),
    );
  }

  Widget _image(String thumbnail) {
    bool hasThumbnail = thumbnail?.isEmpty == false ?? true;
    return hasThumbnail
        ? XCachedImageWidget(
            width: wp(52),
            height: wp(52),
            url: thumbnail,
            imageBuilder: (BuildContext context, ImageProvider imageProvider) {
              return Container(
                padding: EdgeInsets.symmetric(vertical: 18),
                width: wp(52),
                height: wp(52),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: XedColors.white255,
            ),
          )
        : Container(
            width: wp(52),
            height: wp(52),
            child: DeckThumbnailDefaultWiget(
              heightIcon: 24,
              boxDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: XedColors.duckEggBlue,
              ),
            ),
          );
  }

  Widget _iconReview() {
    final Key key = widget.reviewIn == ReviewIn.DueDay && widget.index == 0
        ? GlobalKeys.dueDayButtonReview
        : null;
    return _IconReview(
      globalKey: key,
      testDriverKey: Key(widget.valueKey + "_review" ?? ''),
      onTap: () => gotoReview(widget.deck),
    );
  }

  void onDeleteReviewDeck() {
    if (widget.onDeleteTap != null) widget.onDeleteTap(widget.deck);
  }

  void gotoReview(core.Deck deck) {
    try {
      navigateToScreen(
        screen: ReviewProgressScreen(deck.cardIds, false),
        name: ReviewProgressScreen.name,
      );
    } catch (ex) {
      core.Log.error(ex);
      showErrorSnakeBar(core.Config.getString("msg_something_went_wrong"));
    }
  }
}

class _IconReview extends StatelessWidget implements OnboardingObject {
  final Key testDriverKey;
  final VoidCallback onTap;
  final Color color;

  const _IconReview({Key globalKey, this.testDriverKey, this.onTap, this.color})
      : super(key: globalKey);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: testDriverKey,
      customBorder: CircleBorder(),
      child: Container(
        height: wp(35),
        width: wp(35),
        child: Padding(
          padding: EdgeInsets.all(1),
          child: SvgPicture.asset(
            Assets.icReview,
            width: wp(24),
            height: wp(24),
            color: color,
          ),
        ),
      ),
      onTap: onTap != null ? () => XError.f0(onTap) : null,
    );
  }

  @override
  Widget cloneWithoutGlobalKey() {
    return _IconReview(color: XedColors.white);
  }
}
