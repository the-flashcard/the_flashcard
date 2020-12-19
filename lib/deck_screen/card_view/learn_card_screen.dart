import 'package:ddi/di.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/xwidgets/x_card_side_widget.dart';
import 'package:the_flashcard/common/xwidgets/x_popup.dart';
import 'package:the_flashcard/common/xwidgets/x_state.dart';
import 'package:the_flashcard/deck_screen/report_modal_sheet.dart';
import 'package:the_flashcard/environment/constants.dart';
import 'package:the_flashcard/environment/driver_key.dart';
import 'package:the_flashcard/home_screen/welcome_page.dart';
import 'package:the_flashcard/onboarding/onboarding.dart';
import 'package:the_flashcard/onboarding/onboarding_widget.dart';
import 'package:the_flashcard/review/review_list_bloc.dart';
import 'package:the_flashcard/review/review_list_event.dart';
import 'package:the_flashcard/xerror.dart';

class LearnCardScreen extends StatefulWidget {
  static final name = '/learn_card';
  final int index;
  final String deckName;
  final List<core.ReviewCard> cards;

  LearnCardScreen({this.deckName, this.cards, this.index = 0});

  @override
  _LearnCardScreenState createState() =>
      _LearnCardScreenState(cardIndex: index);
}

class _LearnCardScreenState extends XState<LearnCardScreen> {
  final List<FlipController> listeners = [];
  final SwiperController controller = SwiperController();

  final core.SRSService srsService = DI.get(core.SRSService);
  int cardIndex = 0;
  core.Card currentCard;
  core.ReviewInfo reviewInfo;
  final List<core.ReviewCard> learnCards = [];
  int _frontIndex = 0;
  bool _isFrontShowing = true;
  final nerverScroll = NeverScrollableScrollPhysics();
  final alwayScroll = AlwaysScrollableScrollPhysics();

  _LearnCardScreenState({this.cardIndex = 0});

  @override
  void initState() {
    super.initState();
    _loadCard();
  }

  void _loadCard() {
    core.ReviewCard reviewCard = widget.cards[cardIndex];
    currentCard = reviewCard?.card;
    reviewInfo = reviewCard?.reviewInfo;

    _isFrontShowing = true;
    _frontIndex = 0;
    controller.move(_frontIndex);
    listeners.forEach((l) {
      l.reset();
      l.dispose();
    });
    listeners.clear();
    if (currentCard?.design?.fronts != null) {
      currentCard.design.fronts.forEach((item) {
        listeners.add(FlipController(isFront: true));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        _buildLearnCardScreen(),
        _buildOnboarding(),
      ],
    );
  }

  Widget _buildOnboarding() {
    final description = core.Config.getString('msg_onboarding_learn_it');
    return buildOnboarding(
      currentNameScreen: LearnCardScreen.name,
      localStoredKey: LocalStoredKeys.firstTimeInCardPreview,
      listOnboardingData: <OnboardingData>[
        OnboardingData.right(
          description: description,
          globalKey: GlobalKeys.cardButtonLearnIt,
          direction: OnboardingDirection.BottomToTop,
        )
      ],
    );
  }

  Widget _buildLearnCardScreen() {
    final double buttonHeight = hp(75);

    return Scaffold(
      resizeToAvoidBottomPadding: true,
      backgroundColor: Color.fromARGB(255, 250, 250, 250),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 250, 250, 250),
        leading: InkWell(
          child: Icon(
            Icons.arrow_back,
            size: 30,
            color: Color.fromARGB(255, 43, 43, 43),
          ),
          onTap: () => XError.f0(_onBackPressed),
        ),
        title: Text(
          widget.deckName ?? "[Untitled deck]",
          style: textStyleTitle,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              OMIcons.reportProblem,
              color: Colors.grey,
            ),
            onPressed: () => XError.f0(() {
              showModalBottomSheet(
                backgroundColor: XedColors.transparent,
                context: context,
                builder: (BuildContext context) {
                  return ReportModalSheet();
                },
              ).catchError((ex) => core.Log.error(ex));
            }),
          )
        ],
      ),
      body: WillPopScope(
        child: Swiper(
          itemCount: currentCard?.design?.getFrontCount() ?? 0,
          controller: controller,
          onIndexChanged: _onCardSwiped,
          viewportFraction: 0.805,
          scale: 0.9,
          loop: false,
          physics: _isFrontShowing ? alwayScroll : nerverScroll,
          itemBuilder: (_, int frontIndex) {
            return XFlipperWidget(
              isFront: true,
              front: XCardSideWidget(
                key: UniqueKey(),
                mode: XComponentMode.Review,
                title: "#Question ${frontIndex + 1}",
                cardContainer: currentCard?.design?.getFront(frontIndex) ??
                    currentCard?.design?.getFront(frontIndex) ??
                    core.Container(),
              ),
              back: XCardSideWidget(
                key: UniqueKey(),
                mode: XComponentMode.Review,
                cardContainer: currentCard?.design?.back ?? core.Container(),
                title: '#Answer',
              ),
              flipController: listeners[frontIndex],
            );
          },

          // fade: 0.5,
        ),
        onWillPop: _onPhysicBackPressed,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(bottom: 2),
          height: buttonHeight,
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => XError.f0(_onSkipItPressed),
                  child: Container(
                    child: Text('Skip It', style: textStyleBottomCard),
                    margin: EdgeInsets.only(left: 20),
                  ),
                ),
              ),
              Center(
                child: InkWell(
                  borderRadius: BorderRadius.circular(hp(60)),
                  child: Container(
                    height: buttonHeight,
                    width: buttonHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(hp(60)),
                      color: Color.fromARGB(255, 253, 68, 104),
                    ),
                    child: IconButton(
                      icon: SvgPicture.asset(
                        _isFrontShowing ? Assets.icFlip : Assets.icFlipBack,
                        width: hp(45),
                        height: hp(45),
                        color: XedColors.whiteTextColor,
                      ),
                      onPressed: () => XError.f0(() {
                        setState(() {
                          _isFrontShowing = !_isFrontShowing;
                        });
                        listeners[_frontIndex].flip();
                      }),
                    ),
                  ),
                  onTap: () => XError.f0(() {
                    listeners[_frontIndex].flip();
                  }),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Builder(
                  builder: (context) => _buildLearnItButton(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLearnItButton(BuildContext context) {
    if (reviewInfo != null) {
      // var days = reviewInfo.dayLeft();
      return GestureDetector(
        onTap: () => XError.f0(_onSkipItPressed),
        child: Container(
          child: Text('Next', style: textStyleBottomCard),
          margin: EdgeInsets.only(right: wp(20)),
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(right: 20),
        child: _TextWidget(
          testDriverKey: Key(DriverKey.TEXT_LEARN_IT),
          globalKey: GlobalKeys.cardButtonLearnIt,
          text: 'Learn It',
          style: textStyleBottomCard,
          onTap: () => XError.f1<BuildContext>(_onLearnItPressed, context),
        ),
      );
    }
  }

  void _onCardSwiped(int frontIndex) {
    core.Log.debug("card swiped: $frontIndex");
    _frontIndex = frontIndex;
  }

  Future<bool> _onPhysicBackPressed() async {
    try {
      int count = learnCards.length;
      if (count > 0) {
        _showReviewDialogIfNeeded(context);
        return false;
      }

      return true;
    } catch (ex) {
      core.Log.error(ex);
      return false;
    }
  }

  void _onBackPressed() {
    _showReviewDialogIfNeeded(context);
  }

  void _updateLearningCards(core.Card card, core.ReviewInfo reviewInfo) {
    //Save due cards to review later.
    var days = reviewInfo.dayLeft();
    if (days <= 0) {
      core.ReviewCard reviewCard = core.ReviewCard(card.id, card, reviewInfo);
      learnCards.add(reviewCard);
    }
  }

  void _nextCard() {
    int totalCard = widget.cards?.length ?? 0;
    if (cardIndex < (totalCard - 1)) {
      cardIndex++;
      _loadCard();
      //Request to render
      setState(() {});
    } else {
      _showReviewDialogIfNeeded(context);
    }
  }

  void _onSkipItPressed() {
    _nextCard();
  }

  void _onLearnItPressed(BuildContext context) async {
    try {
      String cardId = currentCard?.id;
      if (cardId != null) {
        var reviewInfo = await srsService.addCard(cardId);
        _updateLearningCards(currentCard, reviewInfo);
        _nextCard();
      }
    } catch (e) {
      core.Log.error(e);
      showErrorSnakeBar(core.Config.getString("msg_error_try_again"));
    }
  }

  void _showReviewDialogIfNeeded(BuildContext context) {
    int count = learnCards.length;
    if (count > 0) {
      xPopUp(
        context,
        title: 'Review it now?',
        description: 'You have just added $count to Review.',
        titleNo: 'No, later',
        titleYes: 'Review now',
        onTapNo: () {
          _close();
        },
        onTapYes: () {
          _gotoReview();
        },
      );
    } else {
      _close();
    }
  }

  void _gotoReview() async {
    closeUntilRootScreen();
    var welcomePageBloc = DI.get<PageNavigatorBloc>(PageNavigatorBloc);
    if (welcomePageBloc != null) {
      DI.get<DueReviewBloc>(DueReviewBloc).add(RefreshReview());
      welcomePageBloc.add(GotoReviewPage());
    }
  }

  void _close() async {
    core.Log.debug('close');
    DI.get<DueReviewBloc>(DueReviewBloc)?.add(RefreshReview());
    closeScreen(LearnCardScreen.name);
  }
}

class _TextWidget extends StatelessWidget implements OnboardingObject {
  final String text;
  final TextStyle style;
  final VoidCallback onTap;
  final Key testDriverKey;

  const _TextWidget({
    Key globalKey,
    this.testDriverKey,
    this.text,
    this.style,
    this.onTap,
  }) : super(key: globalKey);

  @override
  Widget build(BuildContext context) {
    Widget child = Text(text, style: style, textAlign: TextAlign.right);

    return GestureDetector(
      key: testDriverKey,
      onTap: onTap,
      child: child,
    );
  }

  @override
  Widget cloneWithoutGlobalKey() {
    return _TextWidget(
      testDriverKey: testDriverKey,
      style: style.copyWith(color: XedColors.white),
      text: text,
      onTap: null,
    );
  }
}
