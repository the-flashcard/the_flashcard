import 'package:flutter/material.dart';

/// DriverKey chứa const value key để cho driver test
class DriverKey {
  static const String LOGIN_EMAIL = 'login_email';
  static const String LOGIN_PASSWORD = 'login_password';
  static const String LOGIN_SIGN_IN = 'login_signin';
  static const String WELCOME_ICON_DECK = 'welcome_icon_deck';
  static const String WELCOME_ICON_MORE = 'welcome_icon_more';
  static const String WELCOME_ICON_HOME = 'welcome_icon_home';
  static const String WELCOME_ICON_REVIEW = 'welcome_icon_review';
  static const String HOME_OVERVIEW = 'home_overview';
  static const String HOME_NEW_DECK = 'home_new_deck';
  static const String HOME_TRENDING_DECK = 'home_trending_deck';
  static const String TAB_MY_DECK = 'tab_my_deck';
  static const String TAB_GLOBAL_DECK = 'tab_global_deck';
  static const String TAB_FAV_DECK = 'tab_fav_deck';
  static const String CREATE_DECK = 'create_deck';
  static const String DECK_TITLE = 'deck_title';
  static const String DECK_CAMERA = 'deck_camera';
  static const String DECK_DESC = 'deck_desc';
  static const String EDIT_DECK_INFO = 'edit_deck_info';
  static const String INPUT_LINK = 'input_link';
  static const String CHOOSE_LINK = 'choose_link';
  static const String ADD_NEW_CARD = 'add_new_card';
  static const String ADD_NEW_FRONT = 'add_new_front';
  static const String BACK = 'back';
  static const String ICON_EDIT = 'icon_edit';
  static const String LIST_COMP = 'list_comp';
  static const String COMP_QUESTION = 'comp_question';
  static const String COMP_ANSWER = 'comp_answer';
  static const String MULTI_RIGHT_ANSWER = 'multi_right_answer';
  static const String FIB_BLANK = 'fib_blank';
  static const String ICON_SUBMIT = 'icon_submit';
  static const String ICON_RECORD = 'icon_record';
  static const String ICON_THUNDER = 'icon_thunder';
  static const String LIST_DECK = 'list_deck';
  static const String ICON_FLIP = 'icon_flip';
  static const String TEXT_YES = 'text_yes';
  static const String TEXT_LEARN = 'text_learn';
  static const String TEXT_QUIZ = 'text_quiz';
  static const String TEXT_LEARN_IT = 'text_learn_it';
  static const String TEXT_NO = 'text_no';
  static const String TEXT_RESULT = 'text_result';
  static const String TEXT_SUBMIT = 'text_submit';
  static const String DUE_DAY = 'due_date';
  static const String LEARNING = 'learning';
  static const String DONE = 'done';
  static const String DECK = 'deck';
  static const String MULTI_QUESTION = 'multi_question';

  static final GlobalKey<NavigatorState> navigatorGlobalKey =
      GlobalKey<NavigatorState>();

  static String deckIdToNavigateAfterLoggedIn = '';
}
