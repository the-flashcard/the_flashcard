import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/assets.dart';
import 'package:the_flashcard/common/resources/dimens.dart';
import 'package:the_flashcard/common/resources/xed_colors.dart';
import 'package:the_flashcard/common/resources/xed_shadows.dart';
import 'package:the_flashcard/common/resources/xed_text_styles.dart';
import 'package:the_flashcard/common/widgets/deck_thumnail_default.dart';
import 'package:the_flashcard/home_screen/x_number_icon_widget.dart';
import 'package:the_flashcard/onboarding/onboarding.dart';

class DeckItemWidget extends StatelessWidget {
  final double THUMB_WITH = 150.0;
  final double THUMB_HEIGHT = 200.0;

  final core.Deck deck;

  DeckItemWidget(
    this.deck, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height30 = hp(30);
    double width10 = wp(10);

    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Stack(
        children: <Widget>[
          deckBackgroundOne(),
          deckBackgroundTwo(),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(bottom: hp(7), right: wp(7)),
              child: Container(
                margin: EdgeInsets.only(bottom: hp(9), right: wp(6.5)),
                decoration: BoxDecoration(
                  boxShadow: _getShadow(),
                  color: XedColors.white.withOpacity(0.9),
                  border: Border.all(color: XedColors.black.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Stack(
                  alignment: FractionalOffset.bottomLeft,
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        _buildThumbnailDeck(deck),
                        _buildGradientImage(),
                      ],
                    ),
                    _buildDeckName(deck?.name),
                    Container(
                      alignment: Alignment.bottomLeft,
                      padding: EdgeInsets.only(left: width10, bottom: hp(10)),
                      child: Row(
                        children: <Widget>[
                          XNumberIconWidget(
                            icon: deck.voteStatus == core.VoteStatus.Liked
                                ? Icon(
                                    Icons.favorite,
                                    color:
                                        deck.voteStatus == core.VoteStatus.Liked
                                            ? XedColors.waterMelon
                                            : XedColors.battleShipGrey,
                                    size: 15,
                                  )
                                : Icon(Icons.favorite_border,
                                    color:
                                        deck.voteStatus == core.VoteStatus.Liked
                                            ? XedColors.waterMelon
                                            : XedColors.battleShipGrey,
                                    size: 15),
                            count: deck.totalLikes ?? 0,
                            onTap: null,
                          ),
                          Spacer(flex: 5),
                          XNumberIconWidget(
                            icon: SvgPicture.asset(Assets.icCard),
                            count: deck.cardIds.length,
                          ),
                          Spacer(flex: 20)
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              height: height30,
              width: height30,
              margin: EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                boxShadow: _getShadow(),
                shape: BoxShape.circle,
                border: Border.all(width: 1, color: Colors.white),
              ),
              child: _buildAvatar(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildThumbnailDeck(core.Deck deck) {
    if (deck?.hasThumbnail ?? false) {
      return CachedImage(
        width: THUMB_WITH,
        height: THUMB_HEIGHT,
        url: deck?.thumbnail ?? '',
        errorWidget: (_, __, ___) {
          return defaultDeckThumbnail();
        },
        imageBuilder: (_, imageProvider) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
          );
        },
      );
    } else {
      return defaultDeckThumbnail();
    }
  }

  Widget _buildGradientImage() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: _getShadow(),
        gradient: _getGradient(),
        border: Border.all(color: XedColors.black.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }

  Widget defaultDeckThumbnail() {
    return AspectRatio(
      aspectRatio: 0.75,
      child: DeckThumbnailDefaultWiget(
        boxDecoration: BoxDecoration(
          color: XedColors.duckEggBlue,
          border: Border.all(
            width: 1.0,
            color: Color.fromARGB(13, 0, 0, 0),
          ),
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [XedShadows.shadow5],
        ),
      ),
    );
  }

  Widget _buildDeckName(String deckName) {
    deckName ??= '';
    return Container(
      alignment: Alignment.bottomLeft,
      padding: EdgeInsets.only(
        bottom: hp(40),
        left: wp(10),
        right: wp(10),
      ),
      child: Text(
        deckName,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: SemiBoldTextStyle(16).copyWith(
          height: 1.1,
          color: XedColors.whiteTextColor,
        ),
      ),
    );
  }

  Widget deckBackgroundOne() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        margin: EdgeInsets.only(
          top: hp(8),
          bottom: hp(9),
          left: wp(8),
          right: wp(6.5),
        ),
        decoration: BoxDecoration(
          boxShadow: _getShadow(),
          color: XedColors.white.withOpacity(0.9),
          border: Border.all(color: XedColors.black.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Widget deckBackgroundTwo() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: EdgeInsets.only(bottom: hp(4), right: wp(4)),
        child: Container(
          margin: EdgeInsets.only(
            top: hp(4),
            bottom: hp(9),
            left: wp(4),
            right: wp(6.5),
          ),
          decoration: BoxDecoration(
            boxShadow: _getShadow(),
            color: XedColors.white.withOpacity(0.9),
            border: Border.all(color: XedColors.black.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  List<BoxShadow> _getShadow() {
    return [
      BoxShadow(
        offset: Offset(0.0, 2.0),
        blurRadius: 4.0,
        spreadRadius: 0.0,
        color: Color.fromARGB(25, 0, 0, 0),
      ),
    ];
  }

  Gradient _getGradient() {
    return LinearGradient(
      colors: [
        Color.fromARGB(0, 0, 0, 0),
        Color.fromARGB(77, 0, 0, 0),
        Color.fromARGB(204, 0, 0, 0),
      ],
      stops: [0.53, 0.68, 1.0],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  Widget _buildAvatar() {
    return Container(
      child: deck.ownerDetail != null &&
              deck.ownerDetail.avatar != null &&
              deck.ownerDetail.avatar.isNotEmpty
          ? CachedImage(
              width: 32,
              height: 32,
              url: deck.ownerDetail.avatar,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              errorWidget: (_, __, ___) {
                return XedIcon.iconDefaultAvatar(hp(25), wp(25));
              },
              imageBuilder: (_, imageProvider) {
                return Container(
                    decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.1),
                      offset: Offset(2, 0),
                      blurRadius: 6,
                    ),
                  ],
                ));
              })
          : XedIcon.iconDefaultAvatar(hp(25), wp(25)),
    );
  }
}

class DeckListItemWidget extends StatelessWidget implements OnboardingObject {
  final double THUMB_WITH = 150.0;
  final double THUMB_HEIGHT = 200.0;

  final core.Deck deck;

  DeckListItemWidget(
    this.deck, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.centerRight,
          child:
              AspectRatio(aspectRatio: 3 / 4, child: _buildDeckItemThumbnail()),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: _buildDeckItemInfo(),
        ),
      ],
    );
  }

  Widget _buildDeckItemThumbnail() {
    return deck?.hasThumbnail ?? false
        ? CachedImage(
            url: deck.thumbnail,
            width: THUMB_WITH,
            height: THUMB_HEIGHT,
            placeholder: (_, __) => XImageLoading(
              child: Container(
                width: THUMB_WITH,
                height: THUMB_HEIGHT,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    width: 1.0,
                    color: Color.fromARGB(13, 0, 0, 0),
                  ),
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [XedShadows.shadow5],
                ),
              ),
            ),
            imageBuilder: (_, ImageProvider imageProvider) {
              return Container(
                width: THUMB_WITH,
                height: THUMB_HEIGHT,
                decoration: BoxDecoration(
                  color: XedColors.duckEggBlue,
                  border: Border.all(
                    width: 1.0,
                    color: Color.fromARGB(13, 0, 0, 0),
                  ),
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [XedShadows.shadow5],
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    alignment: Alignment.bottomCenter,
                    image: imageProvider,
                  ),
                ),
              );
            },
          )
        : DeckThumbnailDefaultWiget(
            boxDecoration: BoxDecoration(
              color: XedColors.duckEggBlue,
              border: Border.all(
                width: 1.0,
                color: Color.fromARGB(13, 0, 0, 0),
              ),
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [XedShadows.shadow5],
            ),
          );
  }

  Widget _buildDeckItemInfo() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: wp(25), vertical: hp(22)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: Text(
              deck.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: SemiBoldTextStyle(14),
            ),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  deck.ownerDetail != null
                      ? 'By ${deck.ownerDetail.fullName}'
                      : 'By ${deck.username}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LightTextStyle(12).copyWith(
                    color: XedColors.brownGrey,
                  ),
                ),
                SizedBox(height: 4),
                XNumberIconWidget(
                  icon: deck.voteStatus == core.VoteStatus.Liked
                      ? Icon(
                          Icons.favorite,
                          color: deck.voteStatus == core.VoteStatus.Liked
                              ? XedColors.waterMelon
                              : XedColors.battleShipGrey,
                          size: 14,
                        )
                      : Icon(
                          Icons.favorite_border,
                          color: deck.voteStatus == core.VoteStatus.Liked
                              ? XedColors.waterMelon
                              : XedColors.battleShipGrey,
                          size: 14,
                        ),
                  count: deck.totalLikes ?? 0,
                  onTap: null,
                ),
              ],
            ),
          ),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      deck.cardIds.length.toString(),
                      style: TextStyle(
                        fontFamily: 'HarmoniaSansProCyr',
                        fontWeight: FontWeight.w700,
                        fontSize: 14.0,
                        height: 14 / 14,
                        color: XedColors.waterMelon,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 3.0),
                      child: Text(
                        'Cards',
                        style: TextStyle(
                          fontFamily: 'HarmoniaSansProCyr',
                          fontWeight: FontWeight.w400,
                          fontSize: 12.0,
                          height: 12 / 14,
                          color: XedColors.battleShipGrey,
                        ),
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.chevron_right,
                  color: Color.fromARGB(255, 123, 124, 125),
                  size: 30.0,
                ),
              ],
            ),
          ),
        ],
      ),
      height: wp(200),
      width: wp(200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [XedShadows.shadow10],
        color: Colors.white,
      ),
    );
  }

  @override
  Widget cloneWithoutGlobalKey() {
    return DeckListItemWidget(deck);
  }
}
