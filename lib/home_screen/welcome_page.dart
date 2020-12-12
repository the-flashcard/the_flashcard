import 'package:bloc/bloc.dart';
import 'package:ddi/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/notification/notification_receiver.dart';
import 'package:the_flashcard/deck_screen/deck_detail_screen.dart';
import 'package:the_flashcard/deck_screen/deck_edit_screen.dart';
import 'package:the_flashcard/deck_screen/deck_list_bloc.dart';
import 'package:the_flashcard/deck_screen/deck_list_event.dart';
import 'package:the_flashcard/deck_screen/deck_screen.dart';
import 'package:the_flashcard/environment/driver_key.dart';
import 'package:the_flashcard/home_screen/home_page.dart';
import 'package:the_flashcard/home_screen/overview/bloc/statistic_bloc.dart';
import 'package:the_flashcard/home_screen/setting_screen/my_profile_screen.dart';
import 'package:the_flashcard/home_screen/trending_deck_bloc.dart'
    as trending_bloc;
import 'package:the_flashcard/login/authentication/authentication_bloc.dart';
import 'package:the_flashcard/onboarding/onboarding.dart';
import 'package:the_flashcard/overlay_manager.dart';
import 'package:the_flashcard/review/review_list_bloc.dart';
import 'package:the_flashcard/review/review_list_event.dart' as re;
import 'package:the_flashcard/review/review_screen.dart';

class PageNavigateState {
  final int index;

  PageNavigateState(this.index);
}

class ChatBotNavigateState extends PageNavigateState {
  final String message;

  ChatBotNavigateState(
    int index, {
    this.message,
  }) : super(index);
}

class DeckNavigateState extends PageNavigateState {
  final core.Deck deck;

  DeckNavigateState(int index, this.deck) : super(index);
}

class ProfileNavigateState extends PageNavigateState {
  ProfileNavigateState(int index) : super(index);
}

abstract class NavigateEvent {}

class Goto extends NavigateEvent {
  final int index;

  Goto(this.index);
}

class GotoHomePage extends NavigateEvent {}

class GotoReviewPage extends NavigateEvent {}

class GotoChatBotScreen extends NavigateEvent {
  final String message;

  GotoChatBotScreen({this.message});
}

class GotoDeckScreen extends NavigateEvent {
  final String deckId;

  GotoDeckScreen(this.deckId);
}

class GoToProfileScreen extends NavigateEvent {}

class PageNavigatorBloc extends Bloc<NavigateEvent, PageNavigateState> {
  int index = 0;

  PageNavigatorBloc();
  @override
  PageNavigateState get initialState => PageNavigateState(0);

  @override
  Stream<PageNavigateState> mapEventToState(NavigateEvent event) async* {
    switch (event.runtimeType) {
      case GotoHomePage:
        yield* _gotoHomePage();
        break;
      case GotoReviewPage:
        yield* _gotoReviewPage();
        break;
      case GotoChatBotScreen:
        yield* _gotoChatBotScreen(event);
        break;
      case GotoDeckScreen:
        yield* _gotoDeckScreen(event);
        break;
      case GoToProfileScreen:
        yield* _gotoProfileScreen(event);
        break;
      case Goto:
        yield* _goto(event);
        break;
    }
  }

  Stream<PageNavigateState> _gotoHomePage() async* {
    index = 0;
    yield PageNavigateState(index);
  }

  Stream<PageNavigateState> _gotoReviewPage() async* {
    index = 2;
    yield PageNavigateState(index);
  }

  Stream<PageNavigateState> _goto(Goto event) async* {
    index = event.index;
    yield PageNavigateState(index);
  }

  Stream<PageNavigateState> _gotoChatBotScreen(GotoChatBotScreen event) async* {
    yield ChatBotNavigateState(index, message: event.message);
  }

  Stream<PageNavigateState> _gotoDeckScreen(GotoDeckScreen event) async* {
    core.DeckService deckService = DI.get(core.DeckService);
    core.Deck deck = await deckService.getDeck(event.deckId);
    yield DeckNavigateState(index, deck);
  }

  Stream<PageNavigateState> _gotoProfileScreen(GoToProfileScreen event) async* {
    yield ProfileNavigateState(index);
  }
}

class WelcomePage extends StatefulWidget {
  static String name = '/welcome';

  @override
  _WelcomePage createState() => _WelcomePage();
}

class _WelcomePage extends XState<WelcomePage> {
  PageNavigatorBloc bloc;
  AuthenticationBloc authBloc;
  trending_bloc.NewDeckBloc newDeckBloc;
  trending_bloc.TrendingDeckBloc trendingDeckBloc;
  StatisticBloc statisticBloc;
  MyDeckBloc myDeckBloc;
  GlobalDeckBloc globalDeckBloc;
  FavoriteDeckBloc favoriteDeckBloc;
  SearchDeckBloc universalDeckBloc;
  DueReviewBloc dueReviewBloc;
  DoneReviewBloc doneReviewBloc;
  LearningReviewBloc learningReviewBloc;
  OverLayManger overLayManger = DI.get('overlay_manager');

  final List<Widget> tabs = [];

  @override
  void initState() {
    super.initState();

    tabs.addAll(<Widget>[
      HomePage(),
      DeckScreen(),
      ReviewScreen(),
    ]);

    _initBloc();
  }

  void _initBloc() {
    bloc = BlocProvider.of<PageNavigatorBloc>(context);
    authBloc = BlocProvider.of<AuthenticationBloc>(context);
    newDeckBloc = BlocProvider.of<trending_bloc.NewDeckBloc>(context);
    trendingDeckBloc = BlocProvider.of<trending_bloc.TrendingDeckBloc>(context);
    statisticBloc = BlocProvider.of<StatisticBloc>(context);
    myDeckBloc = BlocProvider.of<MyDeckBloc>(context);
    globalDeckBloc = BlocProvider.of<GlobalDeckBloc>(context);
    favoriteDeckBloc = BlocProvider.of<FavoriteDeckBloc>(context);
    universalDeckBloc = BlocProvider.of<SearchDeckBloc>(context);

    dueReviewBloc = BlocProvider.of<DueReviewBloc>(context);
    learningReviewBloc = BlocProvider.of<LearningReviewBloc>(context);
    doneReviewBloc = BlocProvider.of<DoneReviewBloc>(context);

    statisticBloc..add(LoadStats())..add(LoadNewCardLeaderboard());
    newDeckBloc.add(trending_bloc.LoadDeckListEvent());
    trendingDeckBloc.add(trending_bloc.LoadDeckListEvent());
    myDeckBloc.add(Refresh());
    globalDeckBloc.add(Refresh());
    favoriteDeckBloc.add(Refresh());
    universalDeckBloc.add(Refresh());

    dueReviewBloc.add(re.RefreshReview());
    doneReviewBloc.add(re.RefreshReview());
    learningReviewBloc.add(re.RefreshReview());

    if (DriverKey.deckIdToNavigateAfterLoggedIn != null &&
        DriverKey.deckIdToNavigateAfterLoggedIn.isNotEmpty) {
      navigateToDeckAfterLoggedIn(DriverKey.deckIdToNavigateAfterLoggedIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    Dimens.context = context;

    return Scaffold(
      body: NotificationReceiver(
        child: BlocListener(
          bloc: bloc,
          listener: (_, state) {
            if (state is DeckNavigateState) {
              navigateToDeck(state.deck);
            }
            if (state is ProfileNavigateState) {
              navigateToScreen(
                screen: MyProfileScreen(),
                name: MyProfileScreen.name,
              );
            }
          },
          child: Stack(
            children: <Widget>[
              BlocBuilder<PageNavigatorBloc, PageNavigateState>(
                bloc: bloc,
                builder: (context, state) {
                  return tabs[state.index];
                },
              ),
              BlocBuilder<PageNavigatorBloc, PageNavigateState>(
                bloc: bloc,
                builder: (context, state) {
                  switch (state.index) {
                    case 1: // Global deck
                      return _buildOnboardingGlobalDeck();
                      break;
                    case 2: //review
                      return _buildOnboardingReview();
                      break;
                    default:
                      return SizedBox();
                  }
                  // return state.index == 1 ? _buildOnboarding() : SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _bottomAppBar(),
    );
  }

  Widget _buildOnboardingGlobalDeck() {
    final String descriptionAddDeck =
        core.Config.getString('msg_onboarding_global_new_deck');
    final String descriptionClickDeck =
        core.Config.getString('msg_onboarding_global_deck');

    return BlocBuilder<GlobalDeckBloc, DeckListState>(
      bloc: globalDeckBloc,
      builder: (context, state) {
        return state.records?.isNotEmpty == true
            ? buildOnboarding(
                currentNameScreen: '/',
                localStoredKey: LocalStoredKeys.firstTimeGolbalDeck,
                listOnboardingData: <OnboardingData>[
                  OnboardingData.right(
                    globalKey: GlobalKeys.globalDeckIconAdd,
                    description: descriptionAddDeck,
                  ),
                  OnboardingData.right(
                    globalKey: GlobalKeys.globalDeckIconDeck,
                    description: descriptionClickDeck,
                    direction: OnboardingDirection.BottomToTop,
                  ),
                ],
              )
            : SizedBox();
      },
    );
  }

  Widget _buildOnboardingReview() {
    final String descriptionReviewAll =
        core.Config.getString('msg_onboarding_review_all');
    final String descriptionReview =
        core.Config.getString('msg_onboarding_review');
    return BlocBuilder<DueReviewBloc, ReviewListState>(
      bloc: dueReviewBloc,
      builder: (context, state) {
        return state.records?.isNotEmpty == true
            ? buildOnboarding(
                currentNameScreen: '/',
                localStoredKey: LocalStoredKeys.firstTimeReviewCard,
                listOnboardingData: <OnboardingData>[
                  OnboardingData.right(
                    description: descriptionReviewAll,
                    globalKey: GlobalKeys.dueDayButtonReviewAll,
                  ),
                  OnboardingData.right(
                    description: descriptionReview,
                    globalKey: GlobalKeys.dueDayButtonReview,
                  )
                ],
              )
            : SizedBox();
      },
    );
  }

  void navigateToDeckAfterLoggedIn(String deckId) async {
    core.DeckService deckService = DI.get(core.DeckService);
    core.Deck deck = await deckService.getDeck(deckId);

    globalPopToRoot();
    navigateToDeck(deck);
    clearDeckIdToNavigateAfterLoggedIn();
  }

  Future navigateToDeck(core.Deck deck) async {
    final authService = DI.get(core.AuthService);
    bool isOwner = await authService.isOwner(deck.username);
    globalPopToRoot();
    globalNavigateToScreen(
      screen: isOwner ? DeckEditScreen.edit(deck) : DeckDetailScreen(deck),
      name: isOwner ? DeckEditScreen.name : DeckDetailScreen.name,
    );
  }

  void clearDeckIdToNavigateAfterLoggedIn() {
    DriverKey.deckIdToNavigateAfterLoggedIn = '';
  }

  Widget _bottomAppBar() {
    return BlocBuilder<PageNavigatorBloc, PageNavigateState>(
      bloc: bloc,
      builder: (context, state) {
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          onTap: (index) => XError.f1<int>(
            _onItemTapped,
            index,
          ),
          selectedFontSize: 0.0,
          unselectedFontSize: 0.0,
          currentIndex: state.index,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: customIcon(Assets.icHomeNormal,
                  key: Key(DriverKey.WELCOME_ICON_HOME)),
              activeIcon: customActiveIcon(Assets.icHomeActive),
              title: Text(''),
            ),
            BottomNavigationBarItem(
              icon: customIcon(Assets.icDeckNormal,
                  key: Key(DriverKey.WELCOME_ICON_DECK)),
              activeIcon: customActiveIcon(Assets.icDeckActive),
              title: Text(''),
            ),
            BottomNavigationBarItem(
              icon: customIcon(Assets.icReviewNormal,
                  key: Key(DriverKey.WELCOME_ICON_REVIEW)),
              activeIcon: customActiveIcon(Assets.icReviewActive),
              title: Text(''),
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    if (bloc.index != index) {
      bloc.add(Goto(index));
    }
  }

  Widget customActiveIcon(String icon) {
    return Container(
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: wp(48),
              height: hp(3),
              decoration: BoxDecoration(
                color: XedColors.waterMelon,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(100),
                  bottomLeft: Radius.circular(100),
                ),
              ),
            ),
          ),
          Container(
            child: SvgPicture.asset(icon, height: 28.0, width: 28.0),
            margin: EdgeInsets.only(top: hp(6.5)),
          ),
        ],
      ),
    );
  }

  Widget customIcon(String icon, {Key key}) {
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        Column(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                key: key,
                width: wp(48),
                height: hp(3),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(100),
                    bottomLeft: Radius.circular(100),
                  ),
                ),
              ),
            ),
            Container(
              child: SvgPicture.asset(icon, height: 28.0, width: 28.0),
              margin: EdgeInsets.only(top: hp(6.5)),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    overLayManger.remove();
  }
}
