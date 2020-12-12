import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/cached_image/x_cached_image_widget.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/notification/notification_receiver.dart';
import 'package:the_flashcard/common/resources/xed_buttons.dart';
import 'package:the_flashcard/common/resources/xed_progress.dart';
import 'package:the_flashcard/common/resources/xed_shadows.dart';
import 'package:the_flashcard/common/widgets/deck_thumnail_default.dart';
import 'package:the_flashcard/common/widgets/share_feedback_bottom_sheet_widget.dart';
import 'package:the_flashcard/common/xwidgets/x_card_thumbnail_widget.dart';
import 'package:the_flashcard/common/xwidgets/x_state.dart';
import 'package:the_flashcard/deck_screen/card_list_bloc.dart';
import 'package:the_flashcard/deck_screen/card_view/learn_card_screen.dart';
import 'package:the_flashcard/deck_screen/deck_bloc.dart';
import 'package:the_flashcard/deck_screen/deck_list_bloc.dart';
import 'package:the_flashcard/deck_screen/learn_card_bloc.dart';
import 'package:the_flashcard/home_screen/trending_deck_bloc.dart';
import 'package:the_flashcard/home_screen/voting_bloc.dart';
import 'package:the_flashcard/home_screen/x_number_icon_widget.dart';
import 'package:the_flashcard/onboarding/onboarding.dart';
import 'package:the_flashcard/review/progress/review_progress_screen.dart';
import 'package:the_flashcard/review/review_list_bloc.dart';

import 'card_intro/card_intro.dart';

class DeckDetailScreen extends StatefulWidget {
  static const String name = '/deckDetail';
  final core.Deck deck;

  DeckDetailScreen(this.deck);

  @override
  _DeckDetailScreenState createState() => _DeckDetailScreenState();
}

class _DeckDetailScreenState extends XState<DeckDetailScreen> {
  CardListBloc bloc;
  DeckBloc deckBloc;
  LearnCardBloc learnBloc;
  VotingBloc votingBloc;
  // List<bool> optionChosen;

  void parentSetState() {
    reRender();
  }

  @override
  void initState() {
    super.initState();
    bloc = CardListBloc();
    deckBloc = DeckBloc.edit(
        bloc,
        BlocProvider.of<MyDeckBloc>(context),
        BlocProvider.of<GlobalDeckBloc>(context),
        BlocProvider.of<TrendingDeckBloc>(context),
        BlocProvider.of<NewDeckBloc>(context),
        widget.deck);
    votingBloc = VotingBloc(
      BlocProvider.of<FavoriteDeckBloc>(context),
      BlocProvider.of<TrendingDeckBloc>(context),
    );
    learnBloc = LearnCardBloc(
      cardListCubit: bloc,
      dueCardCubit: BlocProvider.of<DueReviewBloc>(context),
      learningCardCubit: BlocProvider.of<LearningReviewBloc>(context),
      doneCardCubit: BlocProvider.of<DoneReviewBloc>(context),
    );
    // optionChosen = [false, false, false, false, false];

    bloc.add(LoadCardList(widget.deck.cardIds));
  }

  @override
  Widget build(BuildContext context) {
    Dimens.context = context;
    core.Log.debug('deck_detail_screen :: build :: avatar: ${widget.deck.id}');
    return Stack(
      children: <Widget>[
        Container(color: XedColors.white255),
        Container(
          height: hp(150),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                XedColors.carnation,
                XedColors.waterMelon,
              ],
            ),
          ),
        ),
        Container(
          height: hp(150),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color.fromARGB(77, 0, 0, 0), Color.fromARGB(0, 0, 0, 0)],
            ),
          ),
        ),
        _buildScaffold(),
        _buildOnboarding(),
      ],
    );
  }

  Widget _buildIntroductionButton() {
    return widget.deck.design?.components?.isNotEmpty == true
        ? Container(
            height: hp(46),
            width: wp(36),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.elliptical(130, 90),
                bottomLeft: Radius.elliptical(130, 90),
              ),
              color: XedColors.duckEggBlue,
            ),
            child: InkWell(
              onTap: _previewPressed,
              child: Container(
                margin: EdgeInsets.all(2),
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: XedColors.waterMelon,
                  border: Border.all(color: Colors.white),
                ),
                child: SvgPicture.asset(
                  Assets.icComponentIntroduceGray,
                  color: Colors.white,
                ),
              ),
            ),
          )
        : SizedBox();
  }

  Widget _buildCloudWhite() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SvgPicture.asset(Assets.bgCloud, width: wp(375)),
        Expanded(
          child: Container(
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    final List<Widget> topActions = <Widget>[
      Padding(
        padding: EdgeInsets.symmetric(horizontal: wp(5)),
        child: IconButton(
          iconSize: 30,
          icon: Icon(Icons.more_horiz),
          onPressed: () => XError.f0(() {
            showModalBottomSheet(
              backgroundColor: XedColors.transparent,
              context: context,
              builder: (context) => ShareFeedbackBottomSheetWidget(
                deck: widget.deck,
              ),
            );
          }),
        ),
      ),
      BlocBuilder<VotingBloc, VotingState>(
        bloc: votingBloc,
        builder: (context, state) {
          return InkWell(
            onTap: state is! Liking ? () => XError.f0(_onLikePressed) : null,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Icon(
                  Icons.favorite_border,
                  size: 28.0,
                  color: Colors.white,
                ),
              ],
            ),
          );
        },
      ),
      SizedBox(width: wp(15)),
    ];

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          size: 30.0,
        ),
        onPressed: () => XError.f0(() {
          Navigator.of(context).pop();
        }),
      ),
      actions: topActions,
    );
  }

  Widget _buildDeckImage() {
    return AspectRatio(
      aspectRatio: 0.75,
      child: widget.deck.hasThumbnail
          ? XCachedImageWidget(
              url: widget.deck.thumbnail,
              width: wp(107),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Colors.white,
              ),
              imageBuilder: (_, imageProvider) {
                return GestureDetector(
                  onTap: () =>
                      onTapThumbnail(imageProvider, widget.deck.thumbnail),
                  child: Hero(
                    tag: widget.deck.thumbnail,
                    child: Container(
                      width: wp(107),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color.fromARGB(13, 0, 0, 0),
                        ),
                        boxShadow: [XedShadows.shadow5],
                        borderRadius: BorderRadius.circular(15.0),
                        color: XedColors.waterMelon,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          alignment: Alignment.bottomCenter,
                          image: imageProvider,
                        ),
                      ),
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
            ),
    );
  }

  Widget _buildDeckInfo() {
    return Flexible(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: wp(15)),
            child: Text(
              widget.deck?.name ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: SemiBoldTextStyle(16),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: wp(46), left: wp(15)),
            child: Text(
              widget.deck?.description ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: RegularTextStyle(14).copyWith(
                color: XedColors.battleShipGrey,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: wp(15)),
            child: _buildCreatorInfo(widget?.deck, votingBloc),
          ),
//          Padding(
//            padding: EdgeInsets.symmetric(horizontal: wp(15)),
//            child: _buildCreateChallenge(),
//          )
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      padding: EdgeInsets.only(top: 34, left: wp(15), bottom: 45),
      child: ListView(
        children: <Widget>[
          Container(
            height: wp(107) / 0.75,
            child: Stack(
              alignment: Alignment.centerRight,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _buildDeckImage(),
                    _buildDeckInfo(),
                  ],
                ),
                _buildIntroductionButton(),
              ],
            ),
          ),
          SizedBox(height: hp(30)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '${widget.deck.cardIds.length} cards',
                style: TextStyle(
                  fontFamily: 'HarmoniaSansProCyr',
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0,
                  color: Color.fromARGB(255, 123, 124, 125),
                ),
              ),
            ],
          ),
          SizedBox(height: hp(20)),
          BlocBuilder<CardListBloc, CardListState>(
            bloc: bloc,
            builder: (context, cardListState) {
              if (cardListState.isCardLoaded) {
                return Padding(
                  padding: EdgeInsets.only(bottom: hp(30), right: wp(15)),
                  child: GridView.builder(
                    shrinkWrap: true,
                    primary: false,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: widget.deck.cardIds.length,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.all(5),
                        child: _buildCardThumbnailWidget(
                          cardListState,
                          index,
                        ),
                      );
                    },
                  ),
                );
              } else if (cardListState.isFailure) {
                return Center(
                  child: XedButtons.whiteButton(
                    'Reload',
                    10,
                    18,
                    () => bloc.add(
                      LoadCardList(widget.deck.cardIds),
                    ),
                    width: wp(167),
                    height: hp(56),
                  ),
                );
              } else {
                return Center(child: XedProgress.indicator());
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buidLearnAndQuiz() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: BlocBuilder<CardListBloc, CardListState>(
        bloc: bloc,
        builder: (context, cardListState) {
          if (cardListState.isCardLoaded && cardListState.hasCards()) {
            return Container(
              height: hp(77),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Color.fromRGBO(18, 18, 18, 0.1),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: wp(15)),
                    Expanded(
                      child: XButton.watermelon(
                        globalKey: GlobalKeys.deckButtonLearn,
                        title: 'Learn',
                        radius: 10,
                        fontSize: 18,
                        onTap: (!cardListState.hasNotInReviewCards())
                            ? null
                            : () => _onLearnPressed(
                                  context,
                                  cardListState,
                                ),
                        width: wp(167),
                        height: hp(56),
                      ),
                    ),
                    SizedBox(width: wp(10)),
                    Expanded(
                      child: XButton.white(
                        globalKey: GlobalKeys.deckButtonQuiz,
                        title: 'Quiz',
                        radius: 10,
                        fontSize: 18,
                        onTap: () => _onQuizPressed(context, cardListState),
                        width: wp(167),
                        height: hp(56),
                      ),
                    ),
                    SizedBox(width: wp(15)),
                  ],
                ),
              ),
            );
          } else {
            return SizedBox();
          }
        },
      ),
    );
  }

  Widget _buildScaffold() {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(),
      body: NotificationReceiver(
        child: MultiBlocListener(
          listeners: [
            BlocListener<VotingBloc, VotingState>(
              bloc: votingBloc,
              listener: _onLikedStateChanged,
            ),
            BlocListener<CardListBloc, CardListState>(
              bloc: bloc,
              listener: _onCardListStateChanged,
            )
          ],
          child: Stack(
            children: <Widget>[
              _buildCloudWhite(),
              _buildBody(),
              _buidLearnAndQuiz(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnboarding() {
    final String descriptionQuiz = core.Config.getString('msg_onboarding_quiz');
    final String descriptionLearn =
        core.Config.getString('msg_onboarding_learn');

    return BlocBuilder<CardListBloc, CardListState>(
      bloc: bloc,
      builder: (_, cardListState) {
        if (cardListState.isCardLoaded && cardListState.hasCards()) {
          return buildOnboarding(
            currentNameScreen: DeckDetailScreen.name,
            localStoredKey: LocalStoredKeys.firstTimeInDeck,
            listOnboardingData: <OnboardingData>[
              OnboardingData.right(
                globalKey: GlobalKeys.deckButtonQuiz,
                description: descriptionQuiz,
                direction: OnboardingDirection.BottomToTop,
              ),
              OnboardingData.left(
                globalKey: GlobalKeys.deckButtonLearn,
                description: descriptionLearn,
                direction: OnboardingDirection.BottomToTop,
              ),
            ],
          );
        } else {
          return SizedBox();
        }
      },
    );
  }

  Widget _buildCardThumbnailWidget(CardListState state, int index) {
    core.Card card = state.getCard(index);

    return InkWell(
      onTap: () => XError.f0(() => _onCardPressed(state, index)),
      child: XCardThumbnailWidget(card: card),
    );
  }

  void _onCardListStateChanged(BuildContext context, CardListState state) {
    if (state.isFailure) {
      Scaffold.of(context).removeCurrentSnackBar();
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${core.Config.getString('msg_cant_load_cards')} ${state.error}",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onLikedStateChanged(BuildContext context, state) {
    final deck = widget.deck;
    if (state is Liked) {
      setState(() {
        deck.voteStatus = core.VoteStatus.Liked;
        deck.totalLikes += 1;
      });
    } else if (state is UnLiked) {
      setState(() {
        deck.voteStatus = core.VoteStatus.None;
        deck.totalLikes -= 1;
      });
    }
  }

  void _onCardPressed(CardListState state, int index) {
    String deckName = widget.deck.name;
    List<core.ReviewCard> cards = state.getReviewCards(firstIndex: index);
    navigateToScreen(
      screen: LearnCardScreen(
        deckName: deckName,
        cards: cards,
      ),
      name: LearnCardScreen.name,
    );
  }

  void _onLikePressed() {
    final deck = widget.deck;
    switch (deck.voteStatus) {
      case core.VoteStatus.None:
        votingBloc.add(
            LikeEvent(core.VotingService.ObjectDeck, deck.id, object: deck));
        break;
      default:
        votingBloc.add(
            UnLikeEvent(core.VotingService.ObjectDeck, deck.id, object: deck));
        break;
    }
  }

  void _onLearnPressed(BuildContext context, CardListState cardListState) {
    if (!cardListState.hasNotInReviewCards()) {
      Scaffold.of(context).removeCurrentSnackBar();
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(core.Config.getString("msg_already_add_cards")),
          backgroundColor: Colors.deepOrange,
        ),
      );
      return;
    }
    String deckName = widget.deck.name;
    List<core.ReviewCard> cards = cardListState.getNotInReviewCards();
    navigateToScreen(
      screen: LearnCardScreen(
        deckName: deckName,
        cards: cards,
        index: 0,
      ),
      name: LearnCardScreen.name,
    );
  }

  void _onQuizPressed(BuildContext context, CardListState cardListState) {
    navigateToScreen(
      screen: ReviewProgressScreen(cardListState.cardIds, true),
      name: ReviewProgressScreen.name,
    );
  }

  void _previewPressed() {
    navigateToScreen(
      screen: PreviewCardIntroScreen(
        deck: this.widget.deck,
        bloc: this.bloc,
        onLearnPress: _onLearnPressed,
      ),
      name: PreviewCardIntroScreen.name,
    );
  }

  Widget _buildFavorite(core.Deck deck, VotingBloc votingBloc) {
    return BlocBuilder<VotingBloc, VotingState>(
      bloc: votingBloc,
      builder: (context, state) {
        return XNumberIconWidget(
          icon: deck?.voteStatus == core.VoteStatus.Liked
              ? Icon(Icons.favorite, color: XedColors.waterMelon)
              : Icon(Icons.favorite_border, color: XedColors.battleShipGrey),
          fontSize: 14,
          count: deck?.totalLikes ?? 0,
          onTap: state is! Liking ? () => XError.f0(_onLikePressed) : null,
        );
      },
    );
  }

  Widget _buildCreatorInfo(core.Deck deck, VotingBloc votingBloc) {
    return Row(
      children: <Widget>[
        _buildAvatar(deck?.ownerDetail?.avatar),
        SizedBox(width: 5),
        Expanded(child: _buildUsername(deck)),
        SizedBox(width: 5),
        _buildFavorite(deck, votingBloc),
      ],
    );
  }

  Widget _buildAvatar(String avatar) {
    return avatar != null && avatar.isNotEmpty
        ? XCachedImageWidget(
            url: avatar,
            errorWidget: (_, __, ___) {
              return XedIcon.iconDefaultAvatar(hp(25), wp(25));
            },
            imageBuilder: (_, imageProvider) {
              return Container(
                width: wp(25),
                height: wp(25),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.1),
                      offset: Offset(2, 0),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          )
        : XedIcon.iconDefaultAvatar(hp(25), wp(25));
  }

  Widget _buildUsername(core.Deck deck) {
    return Text(
      _getUserName(deck),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: RegularTextStyle(14).copyWith(
        color: XedColors.battleShipGrey,
        height: 1.4,
      ),
    );
  }

  String _getUserName(core.Deck deck) {
    String result = '';
    if (deck?.ownerDetail != null) {
      result = deck.ownerDetail.fullName;
    } else {
      result = deck.username;
    }
    return result;
  }

  void onTapThumbnail(ImageProvider imageProvider, Object hero) {
    // navigateToScreen(
    //     screen: PreviewImage(imageProvider, hero, usePhotoView: true));
  }
}
