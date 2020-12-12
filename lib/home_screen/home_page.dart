import 'package:ddi/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/resources.dart';
import 'package:the_flashcard/common/xwidgets/x_state.dart';
import 'package:the_flashcard/deck_screen/search_deck_screen.dart';
import 'package:the_flashcard/home_screen/overview/overview.dart';
import 'package:the_flashcard/home_screen/trending_deck_widget.dart';
import 'package:the_flashcard/home_screen/welcome_page.dart';
import 'package:the_flashcard/login/authentication/authentication_bloc.dart';

import 'new_deck_widget.dart';

class HomePage extends StatefulWidget {
  static final String name = "home_screen";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends XState<HomePage> with TickerProviderStateMixin {
  // StatisticBloc statisticBloc;

  AnimationController colorController;

  Animation backgroundColorValue;
  Animation appbarColorValue;
  Animation elevationValues;

  ScrollController scrollController;
  @override
  void initState() {
    super.initState();
    // statisticBloc = BlocProvider.of<StatisticBloc>(context);

    colorController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 0),
    );
    backgroundColorValue = ColorTween(
            begin: Color.fromARGB(255, 255, 123, 150), end: XedColors.white255)
        .animate(colorController);
    appbarColorValue = ColorTween(
            begin: Color.fromARGB(255, 255, 123, 150), end: XedColors.white255)
        .animate(colorController);
    elevationValues = Tween<double>(begin: 0, end: 1).animate(colorController);
    scrollController = ScrollController()
      ..addListener(handleOnScollControllerChange);
  }

  void handleOnScollControllerChange() {
    colorController.animateTo(scrollController.offset / 350);
  }

  @override
  void dispose() {
    scrollController
      ..removeListener(handleOnScollControllerChange)
      ..dispose();
    colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Dimens.context = context;
    double height142 = hp(142);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: AnimatedBuilder(
          animation: colorController,
          builder: (_, __) => AppBar(
            elevation: elevationValues.value,
            backgroundColor: appbarColorValue.value,
            automaticallyImplyLeading: false,
            title: PreferredSize(
              preferredSize: Size.fromHeight(86.0),
              child: Builder(builder: (context) => _header()),
            ),
          ),
        ),
      ),
      body: Stack(children: <Widget>[
        AnimatedBuilder(
          animation: colorController,
          builder: (_, __) => Container(color: backgroundColorValue.value),
        ),
        Container(
          margin: EdgeInsets.only(top: height142),
          height: double.infinity,
          color: Colors.white,
        ),
        SingleChildScrollView(
          // primary: true,
          controller: scrollController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Overview(),
              // SocialChallengeWidget(),
              NewDeckWidget(),
              TrendingDeckWidget()
            ],
          ),
        ),
      ]),
    );
  }

  Widget _header() {
    // final SvgPicture logo = SvgPicture.asset(
    //   Assets.icLogo,
    //   height: 42,
    // );
    final logo = _buildLogo(onTap: _handleTapLogo);
    final XIconButton iconSearch = XIconButton(
      icon: Icon(
        Icons.search,
        color: Colors.black,
        size: 24,
      ),
      onPressed: () => XError.f0(() {
        navigateToScreen(
          screen: SearchDeckScreen(),
          name: SearchDeckScreen.name,
        );
      }),
    );
    final XIconButton iconNotify = XIconButton(
      icon: Icon(
        Icons.notifications_none,
        color: Colors.black,
        size: 24,
      ),
      onPressed: () {},
    );
    return Flex(
      direction: Axis.horizontal,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        logo,
        Spacer(),
        iconSearch,
        SizedBox(width: 8.0),
        // iconNotify,
      ],
    );
  }

  void _gotoReviewPage() {
    BlocProvider.of<PageNavigatorBloc>(context).add(GotoReviewPage());
  }

  void _handleTapLogo() {
    BlocProvider.of<PageNavigatorBloc>(context).add(GoToProfileScreen());
  }
}

Widget _buildLogo({VoidCallback onTap}) {
  final AuthenticationBloc authenBloc = DI.get(AuthenticationBloc);
  return BlocBuilder<AuthenticationBloc, AuthenticationState>(
    bloc: authenBloc,
    builder: (context, state) {
      if (state is Authenticated) {
        String thumbnailUrl = state.loginData.userProfile?.avatar ?? '';
        return GestureDetector(
          onTap: onTap,
          child: XCachedImageWidget(
            url: thumbnailUrl,
            imageBuilder: (_, imageProvider) {
              return Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: imageProvider,
                  ),
                ),
              );
            },
            placeholder: (_, s) {
              return XImageLoading(
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white),
                    color: Colors.white,
                  ),
                ),
              );
            },
            errorWidget: (_, __, ___) {
              return XedIcon.iconDefaultAvatar(42, 42);
            },
          ),
        );
      }
      return SizedBox();
    },
  );
}
