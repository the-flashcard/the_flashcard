import 'dart:async';

import 'package:ddi/di.dart';
import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/xed_buttons.dart';
import 'package:the_flashcard/common/widgets/dot_indicator.dart';
import 'package:the_flashcard/login/authentication/authentication_bloc.dart';

class OnBoardingScreen extends StatefulWidget {
  static const name = '/on_boarding_screen';

  const OnBoardingScreen({Key key}) : super(key: key);

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final List _title = <String>[
    'Your own Personal Tutor ',
    'Long-Term Memorization',
    'Create Personalized Content',
    'Read The News More Easily',
  ];
  final List _description = <String>[
    'Learn and practice 4 English skills with KIKI Bot, a chatbot as your personal English tutor.',
    'Use the 7 Golden Touches method to store information in your long-term memory',
    'Make your own interactive flashcards using multiple choice, fill in the blanks and more',
    'Learn using translations, definitons and audio from daily news articles.',
  ];
  final List _image = <String>[
    Assets.imgSplash1,
    Assets.imgSplash2,
    Assets.imgSplash3,
    Assets.imgSplash4,
  ];
  PageController controller;
  int indexPage;
  Timer autoNavigationTimer;
  int secondRemain = 5;

  @override
  void initState() {
    super.initState();
    indexPage = 0;
    controller = PageController();
  }

  @override
  void dispose() {
    controller.dispose();
    autoNavigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Dimens.context = context;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: PageView.builder(
              controller: controller,
              onPageChanged: _onPageChanged,
              itemCount: _title.length,
              itemBuilder: (BuildContext context, int index) {
                return _pageBoardingWidget(
                    _image[index], _title[index], _description[index], index);
              },
            ),
          ),
          indexPage != _title.length - 1
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    XedButtons.whiteButtonWithRegularText(
                      "Skip",
                      0,
                      18,
                      _onNavigateToApp,
                      withBorder: false,
                      height: hp(40),
                      width: wp(87),
                    ),
                    XedButtons.watermelonButtonWithBorderLeft(
                      "Next",
                      100,
                      18,
                      _ontapNext,
                      height: hp(40),
                      width: wp(87),
                    ),
                  ],
                )
              : InkWell(
                  onTap: () => XError.f0(_onNavigateToApp),
                  child: Container(
                    height: hp(40),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: XedColors.waterMelonChatBot,
                      border: Border.all(
                        color: XedColors.waterMelonChatBot,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 25, right: 25, top: 4),
                      child: Flex(
                        direction: Axis.vertical,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Discover Now $secondRemain',
                            textAlign: TextAlign.center,
                            style: SemiBoldTextStyle(18)
                                .copyWith(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: hp(20)),
            child: DotIndicator(
              totalDots: _title.length,
              indexSpecialDot: indexPage,
            ),
          ),
        ],
      ),
    );
  }

  void _ontapNext() {
    if (indexPage < (_title.length - 1)) {
      setState(() {
        indexPage++;
      });
      controller.jumpToPage(indexPage);
    }
  }

  void _onNavigateToApp() async {
    core.UserSessionRepository repository = DI.get(core.UserSessionRepository);
    await repository.setFirstRun(false);

    autoNavigationTimer?.cancel();

    DI.get(AuthenticationBloc).add(AppStarted());
  }

  void _onPageChanged(int index) {
    setState(() {
      indexPage = index;
      startAutoNavigationTimer();
    });
  }

  void startAutoNavigationTimer() {
    if (autoNavigationTimer == null && indexPage == _title.length - 1) {
      autoNavigationTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          if (secondRemain <= 0) {
            _onNavigateToApp();
          } else {
            --secondRemain;
          }
        });
      });
    }
  }

  Widget _pageBoardingWidget(
      String image, String title, String description, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                height: hp(350),
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.contain,
                )),
              ),
            ],
          ),
        ),
        SizedBox(height: 30),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: MediumTextStyle(22).copyWith(
              fontSize: 22,
            ),
          ),
        ),
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: wp(30)),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: RegularTextStyle(16).copyWith(
              fontSize: 16,
              height: 1.4,
              color: XedColors.battleShipGrey,
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
