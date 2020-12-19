import 'dart:math';

import 'package:ddi/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/xed_buttons.dart';
import 'package:the_flashcard/common/xwidgets/x_state.dart';
import 'package:the_flashcard/environment/driver_key.dart';
import 'package:the_flashcard/home_screen/welcome_page.dart';
import 'package:the_flashcard/review/progress/review_progress_screen.dart';
import 'package:the_flashcard/review/review_list_bloc.dart';
import 'package:the_flashcard/review/review_list_event.dart';

class ReviewResultScreen extends StatefulWidget {
  static String name = '/reviewResultScreen';
  final bool isQuizMode;
  final int cardCorrect;
  final int cardIncorrect;

  const ReviewResultScreen(
    this.isQuizMode, {
    Key key,
    this.cardCorrect = 0,
    this.cardIncorrect = 0,
  }) : super(key: key);

  @override
  _ReviewResultScreenState createState() => _ReviewResultScreenState();
}

class _ReviewResultScreenState extends XState<ReviewResultScreen> {
  final GlobalKey<AnimatedCircularChartState> _chartKey =
      GlobalKey<AnimatedCircularChartState>();
  List<CircularStackEntry> data;

  final List<String> _the100PercentMessages = [
    'You just dominated that deck!',
    'Not even 1 wrong...you’re good!',
    'People who get 100% are more attractive. Fact!',
    'Now that’s a score to be shared on social media!',
    'You’re a grade A student. Awesome!',
    'I bet your friends would be jealous of that score.',
    'Not even 99%, that’s 100% baby!',
    'Too easy! You’re the master.',
    'Does it hurt being so good?',
    'How does it feel to be so perfect?',
    'The iron throne is yours by right.',
    'Who’s the best? You are!',
    'You’ve earned a treat. Well done!',
    'Too cool for school.',
    'All hail, the great one!',
    'We bow down before you.',
    'You didn’t even break a sweat.',
    'You are the undisputed champion.',
    'Only sexy people can get 100%',
    'Who knows it? You know it!',
    'The people’s champion.',
    'You are officially a genius.',
    'The student has become the master.',
    'You’re a superstar!',
    'You’ve got skills to pay the bills!',
    'Now that’s what I call talent.',
    'You should be the president.',
    'Are you related to Albert Einstein?',
    'You’re simply the best.',
    'Too easy. NEXT!',
    'Slam dunk!',
    'Home run!',
    'Gooooooooaaaaaal!',
    'Not 98, not 99, 100%!',
    'Mastermind!',
    'Brain power!',
    'Beast mode activated!',
    'Zombies would love your delicious brain.',
    'I’d like to thank my family and friends...',
    'Hole in one!',
    'Are you an iphone? ‘Coz you’re smart!',
    'If brains were money, you’d be rich.',
    'Move over Bill Gates, we’ve got a new genius here.',
    'Don’t forget us when you’re famous.',
    'Is now a good time to ask for 5 stars?',
  ];

  final List<String> _from75To99PercentMessages = [
    'Not quite 100%, but a great effort.',
    'Whoop whoop, good score well done.',
    'Great score, can you get 100% next time?',
    'So close to a perfect score, keep it up!',
    'Good score, was it luck or skill?',
    'Progressing really well, keep it up.',
    'Wow, I’m impressed.',
    'You’re good...very good!',
    'Now that’s a score to brag about.',
    'Very nice, very nice indeed!',
    'So close to a perfect score, can you get 100%?',
    'Wow, I can’t wait to see what you do next.',
    'You’re on a roll, let’s try another one.',
    'Now we’re getting somewhere.',
    'You know this stuff pretty well.',
    'On course to becoming a master.',
    'I bet your Facebook friends couldn’t do better...',
    'You’re destined for success.',
    'You’re certainly going places.',
    'On the road to greatness.',
    'I like it!',
    'Gotta share that score!',
    'You know what you’re talking about.',
    'Hey there, nice score.',
    'That’s a nice score you’ve got there.',
    '100% is within your reach.',
    'Almost at the top of the mountain.',
    'A big thumbs up for you.',
    'You’re on the road to greatness.',
    'You’re on the road to immortality.',
    'This clearly isn’t your first time.',
    'Wow, are you cheating?',
    'Well above average, that’s great.',
    'Just a little more practice to achieve excellence.',
    'You’ve got the gift!',
    'The power is with you.',
    'A score to be proud of',
    'May the force be with you.',
    'I like what I see here.',
    'One more time and you’ll get 100%',
    'You can get 100% next time, I know it!',
    'You are the hero Gotham deserves.',
    'You’ve made your ancestors proud.',
    'A little bit of luck and it would have been 100%',
    'Climbing the ladder to greatness.',
  ];

  final List<String> _from50To74PercentMessages = [
    'Not bad, but can you do even better?',
    'Better than a beginner but not quite a master yet.',
    'You’re getting there, keep it up.',
    'Making progress, keep going.',
    'Mostly correct, but practice still needed.',
    'You’re getting there, keep going.',
    'Not a bad score, keep it up.',
    'That’s ok, but more practice and you’ll be great.',
    'Practice makes perfect, keep going.',
    'Admit it, you were just guessing some of them.',
    'Above average, well done.',
    'A good fight between you and this deck.',
    'Happy with that score?',
    'Keep it up and you’ll be a master in no time.',
    'Not bad, but let’s give it one more try.',
    'Not there yet, but you’re learning.',
    'You’ll get there, step by step.',
    'I see what you were trying there.',
    'Not the finished article just yet.',
    'Could be better, could be worse.',
    'Challenge yourself to do better.',
    'Push it harder.',
    'Good effort!',
    'Getting there.',
    'Not an “A”, but still ok.',
    'A solid score.',
    'You’re a work in progress.',
    'Each journey starts with a single step.',
    'Definitely some positives here.',
    'A good score, but still work to be done.',
    'Can you beat that score next time?',
    'Could your friends beat that score?',
    'Let’s take a look at those mistakes.',
    'Not perfect yet, but you’ll get there.',
    'A little bit more practice is needed.',
    'I see great potential in you.',
    'You’ll get there, keep it up.',
    'Just a few small mistakes.',
    'Keep up the learning.',
    'Keep trying.',
    'Not bad, don’t give up.',
    'What did you learn from this?',
    'Let’s give it another shot.',
    'Learning is a process.',
  ];

  final List<String> _from25To49PercentMessages = [
    'Keep practicing and success will come.',
    'Everyone has to start somewhere, don’t give up',
    'Well...at least it wasn’t 0%',
    'Practice, practice, practice.',
    'I think we need to try that again.',
    'You’re better than that, try again.',
    'Are you going to let this deck defeat you?',
    'Maybe you weren’t concentrating?',
    'Maybe take a nap and try again later.',
    'Come on, you’re better than this.',
    'Is that the best you can do?',
    'Focus!',
    'Never give up.',
    'Better luck next time.',
    'Next time you’ll get it I’m sure.',
    'Are you happy with that score?',
    'Do you need some help with that?',
    'More practice needed.',
    'I believe in you.',
    'Meh...',
    'That was ok...but just ok…',
    'Well, you tried…',
    'At least you’re trying.',
    'Regroup and try again.',
    'Not your best work.',
    'Are you going to let this deck defeat you?',
    'The next step is to practice more.',
    'Believe in yourself.',
    'Back to the training ground.',
    'Prove them wrong and try again.',
    'This deck thinks it has beaten you...prove it wrong!',
    'Keep trying and you could be great.',
    'That wasn’t pretty.',
    'Perhaps you should try another deck?',
    'Better check those mistakes.',
    'Let’s try to focus on the positives.',
    'It could have been worse.',
    'A bit too hard?',
    'It’s just one of those days…',
    'Never give up, never give in.',
    'Where did it all go wrong?',
    'It’s ok, you’re here to learn.',
    'Let’s review that again.',
    'Learn from your mistakes.',
    'Not your best day at the office.',
  ];

  final List<String> _from0To24PercentMessages = [
    'Maybe you shouldn’t share this score on social media…',
    'Uh oh, let’s just forget this one and move on.',
    'Oh dear...better luck next time.',
    'Lol',
    'Ouch! That’s gotta hurt.',
    'Hmm, let’s just forget about this one.',
    'The only way is up from here.',
    'I think that’s a fail.',
    'At least it wasn’t a minus score.',
    'That sunk faster than the titanic.',
    'I think that needs another try.',
    'Grab a coffee and try again.',
    'Let’s try that one again.',
    'I know that’s not your best effort.',
    'We all make mistakes, it’s ok.',
    'What was that?',
    'What just happened?',
    'Shake it off and try again.',
    'No worries, you’ll get it next time.',
    'Let’s try again right now.',
    'Not the score you were hoping for.',
    'Too challenging? Try something a bit easier.',
    'Try something a bit easier first.',
    'It’s ok, no one is a master straight away.',
    'Woops!',
    'Uh oh!',
    'Are you sure you’re ready for this?',
    'At least you finished the deck.',
    'At least you managed to open the app.',
    'Don’t let this deck beat you like that.',
    'Just try harder next time.',
    'Practice first, success second.',
    'Is this your first time?',
    'You can do it.',
    'If you can dream it, you can do it.',
    'Don’t show this result to your friends.',
    'Hide this result deep underground.',
    'Lock this result in a safe and throw away the key.',
    'Failure is necessary for success.',
    'No one gets them all right the first time.',
    'It was the decks fault…',
    'It’s fine you were just practicing.',
    'Were you just pushing random buttons?',
    'If at first you don’t succeed try, try again.',
    'Look away now.',
  ];

  @override
  void initState() {
    data = _initDataChart(widget.cardCorrect, widget.cardIncorrect);
    super.initState();
  }

  void _goToReviewScreen() {
    core.Log.debug('review_result_screen:: _goToReview');
    // ignore: close_sinks
    final welcomePageBloc = DI.get<PageNavigatorBloc>(PageNavigatorBloc);
    if (welcomePageBloc != null) welcomePageBloc.add(GotoReviewPage());
    closeUntilRootScreen();
  }

  void _goToDetailScreen() {
    core.Log.debug('review_result_screen:: goToDetailScreen');
    closeScreen(ReviewResultScreen.name);
    closeScreen(ReviewProgressScreen.name);
  }

  void finishReview() {
    var dueBloc = DI.get<DueReviewBloc>(DueReviewBloc);
    dueBloc.add(RefreshReview());

    DI.get<LearningReviewBloc>(LearningReviewBloc).add(RefreshReview());

    DI.get<DoneReviewBloc>(DoneReviewBloc).add(RefreshReview());

    widget.isQuizMode ? _goToDetailScreen() : _goToReviewScreen();
  }

  @override
  Widget build(BuildContext context) {
    Dimens.context = context;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          SvgPicture.asset(Assets.imgCongratulations),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Congratulations !!!",
                style: BoldTextStyle(24).copyWith(color: XedColors.waterMelon),
              ),
              SizedBox(
                height: hp(260),
                width: hp(260),
                child: Stack(
                  children: <Widget>[
                    AnimatedCircularChart(
                      key: _chartKey,
                      initialChartData: data,
                      chartType: CircularChartType.Radial,
                      edgeStyle: SegmentEdgeStyle.flat,
                      percentageValues: false,
                      size: Size(hp(260), hp(260)),
                    ),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: _calculateResultPercent(
                            widget.cardCorrect,
                            widget.cardIncorrect,
                          ).toString(),
                          style: BoldTextStyle(73).copyWith(
                            fontFamily: "Tiempos",
                          ),
                          children: [
                            TextSpan(text: ' %', style: BoldTextStyle(20)),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: hp(50)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    _numberSummary(
                      widget.cardCorrect,
                      "Correct",
                      XedColors.algaeGreen,
                    ),
                    _numberSummary(
                      widget.cardIncorrect,
                      "Incorrect",
                      XedColors.cherryRed,
                    ),
                  ],
                ),
              ),
              Padding(
                key: Key(DriverKey.TEXT_RESULT),
                padding: EdgeInsets.symmetric(horizontal: wp(60)),
                child: XedButtons.watermelonButton(
                  "Continue Review",
                  10,
                  18,
                  finishReview,
                  width: wp(244),
                  height: hp(56),
                ),
              ),
              SizedBox(height: hp(12)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: wp(42)),
                child: Text(
                  _pickRandomMessageOnPercent(),
                  textAlign: TextAlign.center,
                  style: RegularTextStyle(14).copyWith(
                    color: XedColors.battleShipGrey,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  int _calculateResultPercent(int correct, int incorrect) {
    return (correct == 0 && incorrect == 0)
        ? 0
        : ((correct / (correct + incorrect)) * 100).round();
  }

  String _pickRandomMessageOnPercent() {
    int result = _calculateResultPercent(
      widget.cardCorrect,
      widget.cardIncorrect,
    );

    core.Log.debug(
        'review_result_screen:: _pickRandomMessageOnPercent: RESULT: $result');

    if (result == 100) {
      return _pickRandomFromList(_the100PercentMessages);
    } else if (result >= 75 && result <= 99) {
      return _pickRandomFromList(_from75To99PercentMessages);
    } else if (result >= 50 && result <= 74) {
      return _pickRandomFromList(_from50To74PercentMessages);
    } else if (result >= 25 && result <= 49) {
      return _pickRandomFromList(_from25To49PercentMessages);
    } else if (result >= 0 && result <= 24) {
      return _pickRandomFromList(_from0To24PercentMessages);
    } else {
      return core.Config.getString("msg_review_congrats");
    }
  }

  T _pickRandomFromList<T>(List<T> list) {
    Random random = Random();
    T element = list[random.nextInt(list.length)];
    return element;
  }

  Widget _numberSummary(int card, String title, Color color) {
    return Column(
      children: <Widget>[
        Container(
          height: hp(10),
          width: hp(10),
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        SizedBox(
          height: hp(10),
        ),
        Text(
          card.toString(),
          style: BoldTextStyle(24),
        ),
        Container(
          height: hp(1),
          width: wp(30),
          color: XedColors.divider01,
        ),
        SizedBox(
          height: hp(7),
        ),
        Text(
          (widget.cardIncorrect + widget.cardCorrect).toString(),
          style: RegularTextStyle(18).copyWith(
            color: XedColors.battleShipGrey,
          ),
        ),
        Text(
          title,
          style: RegularTextStyle(14).copyWith(
            color: XedColors.battleShipGrey,
          ),
        )
      ],
    );
  }

  List<CircularStackEntry> _initDataChart(int cardCorrect, int cardInCorrect) {
    final result = <CircularStackEntry>[];
    if (cardCorrect == 0 && cardInCorrect == 0) {
      result.add(
        CircularStackEntry(
          <CircularSegmentEntry>[
            CircularSegmentEntry(
              1.0,
              XedColors.cherryRed,
            ),
          ],
        ),
      );
    } else {
      result.add(
        CircularStackEntry(
          <CircularSegmentEntry>[
            CircularSegmentEntry(
              cardCorrect.toDouble(),
              XedColors.algaeGreen,
            ),
            CircularSegmentEntry(
              cardInCorrect.toDouble(),
              XedColors.cherryRed,
            ),
          ],
        ),
      );
    }
    return result;
  }
}
