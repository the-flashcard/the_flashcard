import 'dart:io';

import 'package:ddi/di.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/deck_creation/deck_creation.dart';
import 'package:the_flashcard/deck_creation/edit_card_screen.dart';
import 'package:the_flashcard/deck_creation/video/x_bottom_sheet_textfield.dart';
import 'package:the_flashcard/deck_creation/x_category_bottom_sheet.dart';
import 'package:the_flashcard/deck_creation/x_privacy_bottom_sheet.dart';
import 'package:the_flashcard/deck_screen/card_intro/card_intro.dart';
import 'package:the_flashcard/deck_screen/card_list_bloc.dart';
import 'package:the_flashcard/deck_screen/card_view/learn_card_screen.dart';
import 'package:the_flashcard/deck_screen/generate_card/generate_card.dart';
import 'package:the_flashcard/deck_screen/generate_card/generate_card_bottom_sheet.dart';
import 'package:the_flashcard/deck_screen/select/select_card_manager.dart';
import 'package:the_flashcard/deck_screen/setting_dropdown_widget.dart';
import 'package:the_flashcard/environment/driver_key.dart';
import 'package:the_flashcard/home_screen/trending_deck_bloc.dart';
import 'package:the_flashcard/home_screen/voting_bloc.dart';
import 'package:the_flashcard/onboarding/onboarding.dart';
import 'package:the_flashcard/review/progress/review_progress_screen.dart';

import 'deck_bloc.dart';
import 'deck_list_bloc.dart';

class DeckEditScreen extends StatefulWidget {
  static const String name = "/deck_edit_screen";
  final core.Deck deck;
  final bool isCreation;

  DeckEditScreen.create({this.deck, this.isCreation = true});

  DeckEditScreen.edit(this.deck, {this.isCreation = false});

  @override
  _DeckEditScreenState createState() => _DeckEditScreenState();
}

class _DeckEditScreenState extends XState<DeckEditScreen> {
  final cloud = SvgPicture.asset(Assets.bgCloud, width: wp(375));
  final UploadBloc uploadBloc = UploadBloc();
  final CardListBloc cardListBloc = CardListBloc();
  DeckBloc bloc;
  VotingBloc votingBloc;
  bool isDownloadingImage = false;

  @override
  void initState() {
    super.initState();
    if (widget.deck != null) {
      bloc = DeckBloc.edit(
          cardListBloc,
          DI.get<MyDeckBloc>(MyDeckBloc),
          DI.get<GlobalDeckBloc>(GlobalDeckBloc),
          DI.get<TrendingDeckBloc>(TrendingDeckBloc),
          DI.get<NewDeckBloc>(NewDeckBloc),
          widget.deck);
    } else {
      bloc = DeckBloc.create(
        cardListBloc,
        DI.get<MyDeckBloc>(MyDeckBloc),
        DI.get<GlobalDeckBloc>(GlobalDeckBloc),
        DI.get<TrendingDeckBloc>(TrendingDeckBloc),
        DI.get<NewDeckBloc>(NewDeckBloc),
      );
    }

    votingBloc = VotingBloc(
      DI.get<FavoriteDeckBloc>(FavoriteDeckBloc),
      DI.get<TrendingDeckBloc>(TrendingDeckBloc),
    );
    cardListBloc.add(LoadCardList(widget.deck?.cardIds));
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildCloudWhite() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          cloud,
          Expanded(
            child: Container(
              color: Colors.white,
            ),
          ),
        ],
      );
    }

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
              colors: [
                Color.fromARGB(77, 0, 0, 0),
                Color.fromARGB(0, 0, 0, 0),
              ],
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _buildAppbar(),
          body: NotificationReceiver(
            child: MultiBlocListener(
              listeners: [
                BlocListener<CardListBloc, CardListState>(
                  cubit: cardListBloc,
                  listener: _onCardListStateChanged,
                ),
                BlocListener<DeckBloc, DeckState>(
                  cubit: bloc,
                  listener: _onDeckStateChanged,
                ),
                BlocListener<UploadBloc, UploadState>(
                  cubit: uploadBloc,
                  listener: _onDCStateChange,
                ),
              ],
              child: BlocBuilder<DeckBloc, DeckState>(
                cubit: bloc,
                builder: (context, deckState) {
                  return Stack(
                    children: <Widget>[
                      _buildCloudWhite(),
                      _buildBody(deckState),
                      _buildLearnAndQuiz(),
                      buildDownloadingImage(isDownloadingImage),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        BlocBuilder<UploadBloc, UploadState>(
          cubit: uploadBloc,
          builder: (_, state) {
            return state is ImageUploading
                ? Center(child: LoadingIndicator())
                : SizedBox();
          },
        ),
        _buildOnboarding(),
      ],
    );
  }

  AppBar _buildAppbar() {
    final List<Widget> topActions = <Widget>[
      Opacity(
        opacity: widget.isCreation ? 0.2 : 1.0,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: wp(5)),
          child: InkWell(
            child: Icon(Icons.more_horiz, size: hp(30)),
            onTap: widget.isCreation
                ? null
                : () => XError.f0(() {
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
      ),
      SizedBox(width: wp(15)),
      Opacity(
        opacity: widget.isCreation ? 0.2 : 1.0,
        child: BlocBuilder<VotingBloc, VotingState>(
          cubit: votingBloc,
          builder: (context, state) {
            return XedButtons.iconCircleButton(
              onTap: widget.isCreation
                  ? null
                  : state is! Liking
                      ? () => XError.f0(_onLikePressed)
                      : null,
              child: Icon(
                Icons.favorite_border,
                size: 28.0,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
      SizedBox(width: wp(15)),
    ];

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        key: Key(DriverKey.BACK),
        icon: Icon(
          Icons.arrow_back,
          size: 30.0,
        ),
        onPressed: () => XError.f0(_onBackPressed),
      ),
      actions: topActions,
    );
  }

  Widget _buildBody(DeckState deckState) {
    final w15 = wp(15);
    final w107 = wp(107);
    final h20 = hp(20);
    final h30 = hp(30);

    return Container(
      padding: EdgeInsets.only(top: 34.0, left: w15, bottom: 45.0),
      child: ListView(
        children: <Widget>[
          Container(
            height: w107 / 0.75,
            child: Stack(
              alignment: Alignment.centerRight,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _buildDeckImage(deckState, w107),
                    _buildDeckInfo(deckState),
                  ],
                ),
                _buildIntroductionButton(),
              ],
            ),
          ),
          SizedBox(height: h30),
          Row(
            children: <Widget>[
              Text(
                '${bloc.state.deck != null ? bloc.state.deck.cardIds.length : 0} cards',
                style: TextStyle(
                  fontFamily: 'HarmoniaSansProCyr',
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0,
                  color: Color.fromARGB(255, 123, 124, 125),
                ),
              ),
              Spacer(),
              BlocBuilder<CardListBloc, CardListState>(
                cubit: cardListBloc,
                builder: (context, cardListState) {
                  return cardListState.loadCardCompleted
                      ? InkWell(
                          onTap: () => XError.f0(_onSelectPressed),
                          child: Container(
                            height: hp(36),
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: w15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: Color.fromARGB(255, 220, 221, 221),
                            ),
                            child: Text(
                              'Select',
                              style: TextStyle(
                                fontFamily: 'HarmoniaSansProCyr',
                                fontWeight: FontWeight.w600,
                                fontSize: 16.0,
                                color: XedColors.black,
                              ),
                            ),
                          ),
                        )
                      : SizedBox();
                },
              ),
              SizedBox(width: w15),
            ],
          ),
          SizedBox(height: h20),
          BlocBuilder<CardListBloc, CardListState>(
            cubit: cardListBloc,
            builder: (context, cardListState) {
              return Padding(
                padding: EdgeInsets.only(bottom: hp(30), right: w15),
                child: _buildCardListView(context, deckState, cardListState),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeckImage(DeckState deckState, double w107) {
    const shadow5 = const BoxShadow(
      color: const Color.fromARGB(13, 0, 0, 0),
      offset: const Offset(0.0, 2.0),
      blurRadius: 4.0,
    );
    return Container(
      width: w107,
      child: Stack(
        children: <Widget>[
          deckState.deck?.thumbnail?.isNotEmpty == true
              ? CachedImage(
                  width: w107,
                  url: deckState.deck.thumbnail,
                  imageBuilder: (_, imageProvider) {
                    return GestureDetector(
                      onTap: () => onTapThumbnail(
                          imageProvider, deckState.deck.thumbnail),
                      child: Hero(
                        tag: deckState.deck.thumbnail,
                        child: Container(
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Color.fromARGB(13, 0, 0, 0)),
                            boxShadow: [shadow5],
                            borderRadius: BorderRadius.circular(15.0),
                            color: XedColors.duckEggBlue,
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
                  placeholder: (_, __) {
                    return XImageLoading(
                      child: Container(
                        width: w107,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color.fromARGB(13, 0, 0, 0),
                          ),
                          boxShadow: [shadow5],
                          borderRadius: BorderRadius.circular(15.0),
                          color: XedColors.duckEggBlue,
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
          Container(
            alignment: Alignment.bottomRight,
            padding: EdgeInsets.only(
              bottom: 8.0,
              right: 8.0,
            ),
            child: InkWell(
              key: Key(DriverKey.DECK_CAMERA),
              child: Container(
                height: 26.0,
                width: 36.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  color: Color.fromARGB(255, 250, 250, 250),
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 20.0,
                  color: XedColors.black,
                ),
              ),
              onTap: () => XError.f0(_onUploadDeckThumbnailTap),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDeckInfo(DeckState deckState) {
    return Flexible(
      child: Container(
        padding: EdgeInsets.only(left: wp(15)),
        height: hp(150),
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  key: Key(DriverKey.DECK_TITLE),
                  onTap: () => deckState.isLoading
                      ? null
                      : XError.f0(
                          () => _onEditTitlePressed(deckState.deck?.name)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Icon(Icons.edit, size: hp(14)),
                      SizedBox(width: wp(10)),
                      Flexible(
                        child: Text(
                          deckState.deck?.name ?? 'Title here',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: RegularTextStyle(16).copyWith(
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.bold,
                            color: XedColors.black,
                          ),
                        ),
                      ),
                      SizedBox(width: wp(36)),
                    ],
                  ),
                ),
                Spacer(),
                InkWell(
                  key: Key(DriverKey.DECK_DESC),
                  onTap: () => XError.f0(
                    () => deckState.isLoading
                        ? null
                        : _onEditDescPressed(
                            deckState.deck?.description,
                          ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.edit,
                        size: hp(14),
                        color: XedColors.battleShipGrey,
                      ),
                      SizedBox(width: wp(10)),
                      Flexible(
                        child: Text(
                          deckState.deck?.description ?? 'Description here',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: RegularTextStyle(12).copyWith(
                            fontStyle: FontStyle.normal,
                            color: XedColors.battleShipGrey,
                          ),
                        ),
                      ),
                      SizedBox(width: wp(46)),
                    ],
                  ),
                ),
                Spacer(),
                _buildSettings()
              ],
            ),
            Container(
              child: deckState.isLoading
                  ? Center(child: XedProgress.indicator())
                  : SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroductionButton() {
    return Container(
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
        onTap: _editCardIntroPressed,
        child: _ButtonCardIntroWidget(
          key: GlobalKeys.createCardIntro,
        ),
      ),
    );
    // return ;
  }

  Widget _buildLearnAndQuiz() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: BlocBuilder<CardListBloc, CardListState>(
        cubit: cardListBloc,
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
                  )
                ],
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: wp(15)),
                    Expanded(
                      key: Key(DriverKey.TEXT_LEARN),
                      child: XedButtons.watermelonButton(
                        'Learn',
                        10,
                        18,
                        (!cardListState.hasNotInReviewCards())
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
                      key: Key(DriverKey.TEXT_QUIZ),
                      child: XedButtons.whiteButton(
                        'Quiz',
                        10,
                        18,
                        () => _onQuizPressed(context, cardListState),
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

  Widget _buildNewCardButton(BuildContext context) {
    return _NewCardButtonWidget(
      testDriverKey: Key(DriverKey.ADD_NEW_CARD),
      onTap: () => _onNewCardPressed(context),
      key: GlobalKeys.createCard,
    );
  }

  Widget _buildCardListView(
    BuildContext context,
    DeckState deckState,
    CardListState cardListState,
  ) {
    if (cardListState.isCardLoaded) {
      return GridView.builder(
        shrinkWrap: true,
        primary: false,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.75,
        ),
        itemCount: cardListState.cardIds?.length != null
            ? (cardListState.cardIds.length + 1)
            : 1,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.all(5),
            child: index <= 0
                ? _buildNewCardButton(context)
                : _buildCardWidget(context, cardListState, index - 1),
          );
        },
      );
    } else if (cardListState.isFailure) {
      return Center(
        child: XedButtons.whiteButton(
          'Reload',
          10,
          18,
          () => cardListBloc.add(LoadCardList(deckState?.deck?.cardIds)),
        ),
      );
    } else {
      return Center(
        child: XedProgress.indicator(),
      );
    }
  }

  Widget _buildCardWidget(
      BuildContext context, CardListState state, int index) {
    core.Card card = state.getCard(index);
    if (card != null) {
      return InkWell(
        onTap: () => XError.f0(() => _onCardPressed(card)),
        child: XCardThumbnailWidget(card: card),
      );
    } else {
      showErrorSnakeBar("${core.Config.getString("msg_cant_load_cards")}",
          context: context);
      return SizedBox();
    }
  }

  Widget _buildPrivacySettings() {
    String _getPrivacyName(DeckState deckState) {
      switch (deckState?.deck?.deckStatus) {
        case core.DeckStatus.Protected:
          return 'Only me';
        case core.DeckStatus.Published:
          return 'Public';
        default:
          return 'Only me';
      }
    }

    return InkWell(
      onTap: () => _showPrivacyBottomSheet(bloc.state),
      child: SettingDropdownWidget(
        _getPrivacyName(bloc?.state) ?? 'Only me',
        Icon(
          Icons.lock_outline,
          color: XedColors.battleShipGrey,
          size: hp(14),
        ),
      ),
    );
  }

  Widget _buildCategorySettings() {
    String _getCategoryName(String categoryId) {
      switch (categoryId) {
        case '':
          return 'None';
        case 'deck_cat_vocabulary':
          return 'Vocabulary';
        case 'deck_cat_grammar':
          return 'Grammar';
        case 'deck_cat_listening':
          return 'Listening';
        default:
          return 'None';
      }
    }

    return InkWell(
      onTap: () => _showCategoryBottomSheet(bloc.state),
      child: SettingDropdownWidget(
        _getCategoryName(bloc?.state?.deck?.categoryId) ?? 'Vocabulary',
        Icon(
          Icons.add,
          color: XedColors.battleShipGrey,
          size: wp(14),
        ),
      ),
    );
  }

  Widget _buildSettings() {
    return Wrap(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(2.5),
          child: _buildPrivacySettings(),
        ),
        Padding(
          padding: const EdgeInsets.all(2.5),
          child: _buildCategorySettings(),
        ),
//        Padding(
//          padding: const EdgeInsets.all(2.5),
//          child: _buildCreateChallenge(),
//        ),
      ],
    );
  }

  Widget _buildOnboarding() {
    final String createIntro =
        core.Config.getString('msg_onboarding_create_intro');
    final String createCard =
        core.Config.getString('msg_onboarding_create_card');

    return BlocBuilder<CardListBloc, CardListState>(
      cubit: cardListBloc,
      builder: (context, cardListState) {
        return cardListState.loadCardCompleted
            ? buildOnboarding(
                currentNameScreen: DeckEditScreen.name,
                localStoredKey: LocalStoredKeys.firstTimeReviewCard,
                listOnboardingData: <OnboardingData>[
                  OnboardingData.right(
                    globalKey: GlobalKeys.createCardIntro,
                    description: createIntro,
                  ),
                  OnboardingData.left(
                    globalKey: GlobalKeys.createCard,
                    description: createCard,
                    direction: OnboardingDirection.BottomToTop,
                  ),
                ],
              )
            : SizedBox();
      },
    );
  }

  void _onCardListStateChanged(BuildContext context, CardListState state) {
    if (state.isFailure) {
      showErrorSnakeBar(
        "${core.Config.getString("msg_cant_load_cards")} ${state.error}",
        context: context,
      );
    }
  }

  void _onDeckStateChanged(BuildContext context, DeckState state) {
    if (state.isFailure) {
      showErrorSnakeBar(state.error, context: context);
    }
  }

  void _onEditTitlePressed(String title) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) {
        return XBottomSheetTextFieldWidget(
          title: 'Title',
          text: title ?? '',
          textInputAction: TextInputAction.newline,
          onSubmit: (newTitle) {
            XError.f0(() => bloc.add(InfoChanged(name: newTitle)));
          },
          valueKey: DriverKey.EDIT_DECK_INFO,
        );
      },
    );
  }

  void _onEditDescPressed(String desc) {
    showCupertinoModalPopup(
        context: context,
        builder: (_) {
          return XBottomSheetTextFieldWidget(
            title: 'Description',
            text: desc ?? '',
            textInputAction: TextInputAction.newline,
            onSubmit: (newDesc) {
              XError.f0(() => bloc.add(InfoChanged(description: newDesc)));
            },
            valueKey: DriverKey.EDIT_DECK_INFO,
          );
        });
  }

  void _onSelectPressed() {
    navigateToScreen(screen: SelectCardManager(bloc: bloc));
  }

  void _onAddNewCardPressed(context) {
    if (bloc.state.deck != null) {
      navigateToScreen(
        screen: EditCardScreen.create(bloc, bloc.state.deck),
        name: EditCardScreen.name,
      );
    } else {
      showErrorSnakeBar(
        core.Config.getString("msg_must_enter_title"),
        context: context,
      );
    }
  }

  void _onCardPressed(core.Card card) {
    navigateToScreen(
      screen: EditCardScreen.edit(bloc, bloc.state.deck, card),
      name: EditCardScreen.name,
    );
  }

  void _controlDownloadingWidget(bool visible) {
    isDownloadingImage = visible;
    setState(() {});
  }

  void _onUploadDeckThumbnailTap() async {
    await XChooseImagePopup(
      context: context,
      onFileSelected: (file) {
        _controlDownloadingWidget(false);
        if (file != null) {
          addUploadImage(file: file);
        }
      },
      onDownloadingFile: () {
        _controlDownloadingWidget(true);
      },
      onCompleteDownloadFile: () {
        _controlDownloadingWidget(false);
      },
      ratioX: 3.0,
      ratioY: 4.0,
      onError: (Exception value) {
        _controlDownloadingWidget(false);
        addDownloadFail();
      },
      preScreenName: DeckEditScreen.name,
    ).show();

    closeUntil(DeckEditScreen.name);
  }

  void addDownloadFail() {
    uploadBloc.add(ErrorEvent());
  }

  void addCancelState() {
    uploadBloc.add(CancelUploadEvent());
  }

  void addUploadImage({File file}) {
    uploadBloc.add(UploadImageEvent(file));
  }

  void _onBackPressed() {
    closeScreen(DeckEditScreen.name);
  }

  void _onQuizPressed(BuildContext context, CardListState cardListState) {
    navigateToScreen(
      screen: ReviewProgressScreen(cardListState.cardIds, true),
      name: ReviewProgressScreen.name,
    );
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
    String deckName = widget.deck?.name;
    List<core.ReviewCard> cards = cardListState.getNotInReviewCards();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LearnCardScreen(
          deckName: deckName,
          cards: cards,
          index: 0,
        ),
        settings: RouteSettings(name: LearnCardScreen.name),
      ),
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

  void _showPrivacyBottomSheet(DeckState deckState) async {
    core.DeckStatus deckStatus = await showModalBottomSheet(
      backgroundColor: XedColors.transparent,
      context: context,
      builder: (BuildContext context) {
        core.DeckStatus status =
            deckState?.deck?.deckStatus ?? core.DeckStatus.Protected;
        int numberOfCards = bloc.cardListBloc.state.cardIds.length;
        return XDeckPrivacyBottomSheet(status, numberOfCards);
      },
    );

    if (deckStatus != null) {
      bloc.add(InfoChanged(deckStatus: deckStatus));
    }

    reRender();
  }

  void _showCategoryBottomSheet(DeckState deckState) async {
    String categoryId = await showModalBottomSheet(
      backgroundColor: XedColors.transparent,
      context: context,
      builder: (BuildContext context) {
        String currentCategoryId = deckState?.deck?.categoryId ?? '';
        return XDeckCategoryBottomSheet(currentCategoryId);
      },
    );

    if (categoryId != null) {
      bloc.add(InfoChanged(categoryId: categoryId));
    }

    reRender();
  }

  void _onDCStateChange(BuildContext context, UploadState state) {
    if (state is ImageUploadedSuccess) {
      bloc.add(InfoChanged(thumbnailUrl: state.component.url));
    }
    if (state is UploadFailed) {
      showErrorSnakeBar(state.messenge, context: context);
    }
  }

  void _editCardIntroPressed() {
    navigateToScreen(
      screen: EditCardIntroScreen(bloc: bloc),
      name: EditCardIntroScreen.name,
    );
  }

  void _onNewCardPressed(BuildContext context) {
    _showNewCardBottomSheet(context);
  }

  void _showNewCardBottomSheet(BuildContext context) {
    if (this.bloc.state.deck != null) {
      showModalBottomSheet(
        context: context,
        backgroundColor: XedColors.transparent,
        builder: (_) => GenerateCardBottomSheet(
          DeckEditScreen.name,
          onGeneratePressed: () => _onGeneratePressed(context),
          onManualPressed: () => _onManualPressed(context),
        ),
      );
    } else {
      showErrorSnakeBar(
        core.Config.getString("msg_must_enter_title"),
        context: context,
      );
    }
  }

  void _onGeneratePressed(BuildContext context) {
    if (this.bloc.state.deck != null) {
      navigateToScreen(
        screen: GenerateCardScreen(
          DeckEditScreen.name,
          onGenerate: _onGenerateWord,
        ),
        name: GenerateCardScreen.name,
      );
    } else {
      showErrorSnakeBar(
        core.Config.getString("msg_must_enter_title"),
        context: context,
      );
    }
  }

  void _onManualPressed(BuildContext context) {
    this._onAddNewCardPressed(context);
  }

  void _onGenerateWord(String value) {
    final List<String> words = core.getLines(value);

    this.bloc.add(CardGenerated(words));
  }

  void onTapThumbnail(ImageProvider imageProvider, Object hero) {
    // navigateToScreen(
    //     screen: PreviewImage(imageProvider, hero, usePhotoView: true));
  }
}

class _ButtonCardIntroWidget extends StatelessWidget
    implements OnboardingObject {
  const _ButtonCardIntroWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }

  @override
  Widget cloneWithoutGlobalKey() {
    return _ButtonCardIntroWidget();
  }
}

class _NewCardButtonWidget extends StatelessWidget implements OnboardingObject {
  final Key testDriverKey;
  final VoidCallback onTap;
  final bool onboarding;

  const _NewCardButtonWidget({Key key, this.testDriverKey, this.onTap})
      : onboarding = false,
        super(key: key);

  const _NewCardButtonWidget.onboarding()
      : testDriverKey = null,
        onTap = null,
        onboarding = true;

  Widget build(BuildContext context) {
    return InkWell(
      key: testDriverKey,
      onTap: onTap != null ? () => XError.f0(onTap) : null,
      child: Container(
        child: Container(
          decoration: BoxDecoration(
            color: onboarding ? XedColors.white255 : XedColors.skyColor,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Center(
            child: Icon(
              Icons.add,
              size: 30.0,
              color: XedColors.darkSkyBlueColor,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget cloneWithoutGlobalKey() {
    return _NewCardButtonWidget.onboarding();
  }
}

Widget buildDownloadingImage(bool visible) {
  return visible
      ? Container(
          width: double.infinity,
          height: double.infinity,
          color: XedColors.transparent,
          child: Center(child: XedProgress.indicator()),
        )
      : SizedBox();
}
