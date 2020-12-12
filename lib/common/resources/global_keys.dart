import 'package:flutter/widgets.dart';

// use for onboarding
abstract class GlobalKeys {
  // Global deck
  static final GlobalKey globalDeckIconAdd = GlobalKey();
  static final GlobalKey globalDeckIconDeck = GlobalKey();

  // deck
  static final GlobalKey deckButtonQuiz = GlobalKey();
  static final GlobalKey deckButtonLearn = GlobalKey();

  // card
  static final GlobalKey cardButtonLearnIt = GlobalKey();

  // due day
  static final GlobalKey dueDayButtonReviewAll = GlobalKey();
  static final GlobalKey dueDayButtonReview = GlobalKey();

  //edit deck
  static final GlobalKey createCardIntro = GlobalKey();
  static final GlobalKey createCard = GlobalKey();

  //edit card screen
  static final GlobalKey flipCard = GlobalKey();
  static final GlobalKey editCard = GlobalKey();
}
