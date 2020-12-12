import 'dart:core';
import 'dart:io';

import 'package:tf_core/tf_core.dart';

enum Mode { Debug, Production }

class Config {
  static Map<String, dynamic> _debug = {
    'test_key': 'test_value',
    "api_host": "http://theflashcard.tk/api",
    'web_host': 'http://theflashcard.tk',
    "upload_host": "http://media.theflashcard.tk",
    "static_host": "http://media.theflashcard.tk/static",
    "protocol": "http://",
    "PAGING_DECK_SIZE": 20,
    "min_version": 2,
    "latest_version": 2,
    "appstore_id": "1469907764",
    "ios_min_version": "2.0.0",
    "ios_bundle_id": "x.education.lp",
    "android_min_version": 1,
    "android_package_name": "education.x.lp",
    "deeplink_prefix": "https://xed.page.link",
    "log_endpoint": "http://log.xed.ai/event_log/xed_v2_dev",
    "dict_lookup_path": "/dictionary/lookup",
    "log_level": LogLevel.INFO.index,
    "youtube_api_key": "AIzaSyDxGTs--h5gc4VF3KET486H3QHauEMvAAo",
    'google_search_host': 'https://www.googleapis.com/customsearch/v1?',
    'google_search_cx': '010705263601399736210:doyhwhrmfoy',
    'google_search_key': 'AIzaSyACepEUPcUivKmNk1O8V8qNYeld9bTl4dU',
    'bing_search_host':
        'https://api.cognitive.microsoft.com/bing/v7.0/images/search?q=',
    'bing_search_key': "e4be23d72caa41eba3b10a7c576301ff",
    "whitelist_deck_creation_emails": "",
    'cache_total_image': 1000,
    'cache_total_image_size_in_bytes': 40000000,
    "video_max_size": 20,
    "image_max_size": 20,
    "audio_max_size": 20,
    "msg_upload_exceed_video": "Video size must be smaller than 20MB",
    "msg_upload_exceed_image": "Image size must be smaller than 20MB",
    "msg_upload_exceed_audio": "Audio size must be smaller than 20MB",
    "youtube_thumbnail": "https://img.youtube.com/vi/",
    "youtube_thumbnail_quality": "/mqdefault.jpg",
    'msg_init_speech_error':
        'Sorry! The speech engine cannot start at the moment.',
    'msg_not_authenticated':
        'The session is expired. Please logout and login again!',
    "msg_error": "Error! Try again!",
    "msg_cant_load_cards": "Can't load cards, please try again later:",
    "msg_already_add_cards":
        "These cards have already been added to your review.",
    "msg_must_enter_title": "Please enter a deck title and description!",
    "msg_something_went_wrong": "Oops, something went wrong. Please try again.",
    "msg_verification_code_sent":
        "A verification code was sent to your email address",
    "msg_code_sent_success": "Verification code sent successfuly",
    "msg_not_received_code": "Code not recieved?",
    "msg_code_invalid": "Invalid verification code",
    "msg_ask_check_inbox": "Please check your email inbox or spam folder",
    "msg_limit_reached": "Limit reached! Please wait!",
    "msg_email_not_existed": "Email address does not exist",
    "msg_sent_success": "Sent successfully",
    "msg_login_success": "Login successful",
    "msg_error_try_again": "Error, please try again later!",
    "msg_choose_correct_answer": "Choose the correct answer",
    "msg_type_answer": "Type answer here...",
    "msg_tap_record_button": "Tap the Record button to start",
    "msg_fill_sub_content": "Enter subtitles (optional)",
    "msg_tap_add_content": "Tap to add content",
    "msg_load_video_failed": "Failed to load video.\n(Tap to reload)",
    "msg_record_video": "Record video",
    "msg_record_audio": "Record audio",
    "msg_input_youtube_link": "Insert Youtube link",
    "msg_choose_from_library": "Choose from library",
    "msg_paste_link_here": "Paste link here",
    "msg_search_photo": "Search online",
    "msg_take_a_photo": "Take a photo",
    "msg_input_image_link": "Insert image link",
    "msg_input_audio_link": "Insert audio link",
    "msg_input_word": "Insert a word",
    "msg_choose_deck_type": "Which type of deck do you want to create?",
    "msg_discard_change": "Discard changes?",
    "msg_who_can_see_deck": "Who can see your deck?",
    "msg_no_permission_create_deck":
        "You don’t have permission to create a deck",
    "msg_well_done": "Well done so far! It\'s time to learn more",
    "msg_leave_feedback":
        "You can give feedback or report this deck after selecting a problem.",
    "msg_leave_opinion":
        "Leave message here to help improve the quality of this deck.",
    "msg_feedback_thanks": "Thanks for your feedback",
    "msg_ask_time_period": "Which time do you choose?",
    "msg_password_not_match": "Passwords do not match",
    "msg_new_password_invalid": "Password is invalid",
    "msg_retype_password_invalid": "Re-typed Password is invalid",
    "msg_password_rule": "Minimum of 6 characters.",
    "msg_email_invalid": "Email is invalid.",
    "msg_check_login":
        "Incorrect credentials! Please check your email and password!",
    "msg_welcome": "Welcome to our community. Your journey starts here.",
    "msg_fullname_invalid": "Full name is invalid.",
    "msg_email_existed": "This email already exists. You might want to login.",
    "msg_check_profile": "Please check your profile again!",
    "msg_code_incorrect": "Your code is expired or incorrect.",
    "msg_cant_resend_code": "Can't resend your code at the moment.",
    "msg_card_review_again": "This card will be reviewed.",
    "msg_due_date_intro":
        "Review cards at the optimal times to store information in your long-term memory.",
    "msg_review_congrats":
        "Review successfully completed! Continuing reviewing to improve your skills",
    "msg_delete_cards_warning":
        "If you delete these Cards, they'll be gone permanently.",
    "msg_delete_decks_warning":
        "If you delete these Decks, they'll be gone permanently.",
    "msg_cant_delete_decks": "Can't delete decks, please try again later!",
    "msg_search_vocabulary": "Search vocabulary",
    "msg_generate": "Currently you can only auto-generate cards in English",
    "msg_fill_word": "Fill your words here line by line",
    "msg_public_deck_rule":
        "To set the deck as public, please create at least 5 cards, a thumbnail and a description.",
    "msg_vocab_not_available": "This vocabulary is not available!",
    "msg_share_content": "Learn English with XED at",
    "msg_no_news": "Please try searching for something else.",
    "msg_no_load_news": "Connection error. Please try again",
    "msg_no_load_category": "Connection error. Please try again",
    "msg_no_connection": "Connection error. Please try again",
    "msg_no_load_list_new": "Connection error. Please try again",
    "msg_no_translate": "Sorry, no translation for this word yet",
    "msg_out_of_translation_quota":
        "You have reached your translation limit for today. Please try again tomorrow.",
    "msg_perfer_lang":
        "We will show English as a default translation in case we dont have it.",
    "msg_perfer_country":
        "We will show English as a default translation in case we dont have it.",
    "msg_onboarding_news":
        "Tap any word to view the explaination and translation.",
    "msg_onboarding_global_new_deck": "Create content for your flashcards here",
    "msg_onboarding_global_deck":
        "See and learn the latest decks from the community",
    "msg_onboarding_quiz":
        "Tap here to preview the deck content before learning",
    "msg_onboarding_learn": "Choose cards from the deck to learn",
    "msg_onboarding_learn_it": "Learn this card",
    "msg_onboarding_review_all": "Choose to review all your cards now",
    "msg_onboarding_review":
        "Or choose whatever decks you like to reviews cards in these deckss cards in these decks",
    "msg_onboarding_create_intro":
        "Tap here to create an introduction for your deck",
    "msg_onboarding_create_card": "Create your cards here",
    "msg_onboarding_edit_content_card":
        "Tap here to create content for the card",
    "msg_onboarding_edit_back_card":
        "Tap here to see and edit the back of the card",
    "msg_share_success": "Share Successfully",
    "msg_share_error": "Share Unsuccessfully",
    "app_id_android_ads": "ca-app-pub-5865605604985131~1862739603",
    "app_id_ios_ads": "ca-app-pub-5865605604985131~9881077841",
    "ad_unit_id_android_ads_video": "ca-app-pub-2003575359427086/3524198572",
    "ad_unit_id_ios_ads_video": "ca-app-pub-2003575359427086/6500171113",
    "ad_unit_id_android_ads_banner": "ca-app-pub-5865605604985131/1671167917",
    "ad_unit_id_ios_ads_banner": "ca-app-pub-5865605604985131/4628751168",
    "deeplink_deck_pattern": "https://x.education/deck/",
    "deeplink_kiki_pattern": "https://x.education/kiki/",
    "deeplink_appstore": "http://onelink.to/xed-app",
    "invite_point": 10,
    "deeplink_kiki_msg_pattern": "open?msg=",
    "param_join_challenge": "join_url",
    "chatbot_min_message_delay_millis": 1000,
    "chatbot_max_message_delay_millis": 1200,
    "chatbot_kiki_guide_json": """{
      "features": [{
    "name": "Review",
    "icon_background_color": {"colors":[4294933398,4294788200],"stops":[0.0,1.0],"begin":0,"end":1},
    "icon_url" : "https://github.com/tvc12/playing-typescript/raw/tvc12-patch-1/btn%20review.svg",
    "kiki_commands": [
      {
        "title": "Begin to Review",
        "sub_commands": [
          "Review cards",
          "Let's review now!"
        ]
      },
      {
        "title": "Exit",
        "sub_commands": [
          "Exit",
          "Stop review",
          "Quit review",
          "Leave review"
        ]
      }
    ]
  },
   {
    "name": "Learn Vocabulary",
    "icon_background_color":{"colors":[4288130047,4279383447],"stops":[0.0,1.0],"begin":0,"end":1},
    "icon_url" : "https://github.com/tvc12/playing-typescript/raw/tvc12-patch-1/bot-deck-icon.svg",
    "kiki_commands": [
      {
        "title": "Begin to Learn",
        "sub_commands": [
          "Teach me vocabulary",
          "Learn vocabulary",
          "I want to learn vocabulary"
        ]
      },
      {
        "title": "Exit",
        "sub_commands": [
          "Exit",
          "Stop learning"
        ]
      }
    ]
  },
   {
    "name": "Lookup Dictionary",
    "icon_background_color": {"colors":[4286708664,4280862575],"stops":[0.0,1.0],"begin":0,"end":1},
    "icon_url" : "https://github.com/tvc12/playing-typescript/raw/tvc12-patch-1/bot-new-icon.svg",
    "kiki_commands": [
      {
        "title": "Lookup",
        "sub_commands": [
         "What is cat in English?",
          "What is cat in Vietnamese?",
          "What is the meaning of cat?",
          "What's the meaning of cat?",
          "What's the meaning of cat in Vietnamese?"
        ]
      },
      {
        "title": "Exit",
        "sub_commands": [
          "Exit"
        ]
      }
    ]
  }
]
}
    """,
    'email_error': "Email is not available!",
    'password_error': "Password is not available!",
    "msg_no_load_list_news_deck": "Connection error. Please try again",
    "msg_no_load_list_trending_deck": "Connection error. Please try again",
    "msg_generate_news_card_success":
        "The word has been successfully generated!",
    "bot_message_learn_a_course": 'I want to learn :couse_id',
    "bot_message_learn_new_course": 'I want to learn',
    "bot_message_join_a_challenge": 'Join challenge :challenge_id',
    "message_share_challenge": 'Join :challenge_name with XED at :link',
    "message_share_deck": 'Learn :deck_name with XED at :link',
    "text_button_challenge_header": "Join now",
    "bot_message_challenge_header": 'Join challenge',
    "reload_leaderboard_interval_in_second": 15,
    "title_newcard_leaderboard_overview": "Top Achievers",
    "reload_alert_interval_in_minute": 1,
    "badge_max_count": 99,
  };
  static Map<String, dynamic> _production = {
    'key': 'value',
    "api_host": "http://theflashcard.tk/api",
    'web_host': 'http://theflashcard.tk',
    "upload_host": "http://media.theflashcard.tk",
    "static_host": "http://media.theflashcard.tk/static",
    "protocol": "http://",
    "PAGING_DECK_SIZE": 20,
    "min_version": 2,
    "latest_version": 2,
    "appstore_id": "1469907764",
    "ios_min_version": "2.0.0",
    "ios_bundle_id": "x.education.lp",
    "android_min_version": 1,
    "android_package_name": "education.x.lp",
    "deeplink_prefix": "https://xed.page.link",
    "log_endpoint": "http://log.xed.ai/event_log/xed_v2_live",
    "dict_lookup_path": "/dictionary/lookup",
    "log_level": LogLevel.ERROR.index,
    "youtube_api_key": "AIzaSyDxGTs--h5gc4VF3KET486H3QHauEMvAAo",
    'google_search_host': 'https://www.googleapis.com/customsearch/v1?',
    'google_search_cx': '015696359129984038617:85dyeyehhoq',
    'google_search_key': 'AIzaSyCuSNfLCslXy9dKpcJ8z310VusTdwopWz8',
    'bing_search_host':
        'https://api.cognitive.microsoft.com/bing/v7.0/images/search?q=',
    'bing_search_key': "e4be23d72caa41eba3b10a7c576301ff",
    "whitelist_deck_creation_emails": "",
    'cache_total_image': 1000,
    'cache_total_image_size_in_bytes': 40000000,
    "video_max_size": 20,
    "image_max_size": 20,
    "audio_max_size": 20,
    "msg_upload_exceed_video": "Video size must be smaller than 20MB",
    "msg_upload_exceed_image": "Image size must be smaller than 20MB",
    "msg_upload_exceed_audio": "Audio size must be smaller than 20MB",
    "youtube_thumbnail": "https://img.youtube.com/vi/",
    "youtube_thumbnail_quality": "/mqdefault.jpg",
    'msg_init_speech_error':
        'Sorry! The speech engine cannot start at the moment.',
    'msg_not_authenticated':
        'The session is expired. Please logout and login again!',
    "msg_error": "Error! Try again!",
    "msg_cant_load_cards": "Can't load cards, please try again later:",
    "msg_already_add_cards":
        "These cards have already been added to your review.",
    "msg_must_enter_title": "Please enter a deck title and description!",
    "msg_something_went_wrong": "Oops, something went wrong. Please try again.",
    "msg_verification_code_sent":
        "A verification code was sent to your email address",
    "msg_code_sent_success": "Verification code sent successfuly",
    "msg_not_received_code": "Code not recieved?",
    "msg_code_invalid": "Invalid verification code",
    "msg_ask_check_inbox": "Please check your email inbox or spam folder",
    "msg_limit_reached": "Limit reached! Please wait!",
    "msg_email_not_existed": "Email address does not exist",
    "msg_sent_success": "Sent successfully",
    "msg_login_success": "Login successful",
    "msg_error_try_again": "Error, please try again later!",
    "msg_choose_correct_answer": "Choose the correct answer",
    "msg_type_answer": "Type answer here...",
    "msg_tap_record_button": "Tap the Record button to start",
    "msg_fill_sub_content": "Enter subtitles (optional)",
    "msg_tap_add_content": "Tap to add content",
    "msg_load_video_failed": "Failed to load video.\n(Tap to reload)",
    "msg_record_video": "Record video",
    "msg_record_audio": "Record audio",
    "msg_input_youtube_link": "Insert YouTube link",
    "msg_choose_from_library": "Choose from library",
    "msg_paste_link_here": "Paste link here",
    "msg_search_photo": "Search online",
    "msg_take_a_photo": "Take a photo",
    "msg_input_image_link": "Insert image link",
    "msg_input_audio_link": "Insert audio link",
    "msg_input_word": "Insert a word",
    "msg_choose_deck_type": "Which type of deck do you want to create?",
    "msg_discard_change": "Discard changes?",
    "msg_who_can_see_deck": "Who can see your deck?",
    "msg_no_permission_create_deck":
        "You don’t have permission to create a deck",
    "msg_well_done": "Well done so far! It\'s time to learn more",
    "msg_leave_feedback":
        "You can give feedback or report this deck after selecting a problem.",
    "msg_leave_opinion":
        "Leave message here to help improve the quality of this deck.",
    "msg_feedback_thanks": "Thanks for your feedback",
    "msg_ask_time_period": "Which time do you choose?",
    "msg_password_not_match": "Passwords do not match",
    "msg_new_password_invalid": "password is invalid",
    "msg_retype_password_invalid": "Re-typed Password is invalid",
    "msg_password_rule": "Minimum of 6 characters.",
    "msg_email_invalid": "Email is invalid.",
    "msg_check_login":
        "Incorrect credentials! Please check your email and password!",
    "msg_welcome": "Welcome to our community. Your journey starts here.",
    "msg_fullname_invalid": "Full name is invalid.",
    "msg_email_existed": "This email already exists. You might want to login.",
    "msg_check_profile": "Please check your profile again!",
    "msg_code_incorrect": "Your code is expired or incorrect.",
    "msg_cant_resend_code": "Can't resend your code at the moment.",
    "msg_card_review_again": "This card will be reviewed.",
    "msg_due_date_intro":
        "Review cards at the optimal times to store information in your long-term memory.",
    "msg_review_congrats":
        "Review successfully completed! Continuing reviewing to improve your skills",
    "msg_delete_cards_warning":
        "If you delete these Cards, they'll be gone permanently.",
    "msg_delete_decks_warning":
        "If you delete these Decks, they'll be gone permanently.",
    "msg_cant_delete_decks": "Can't delete decks, please try again later!",
    "msg_search_vocabulary": "Search vocabulary",
    "msg_generate": "Currently you can only auto-generate cards in English",
    "msg_fill_word": "Fill your words here line by line",
    "msg_public_deck_rule":
        "To set the deck as public, please create at least 5 cards, a thumbnail and a description.",
    "msg_vocab_not_available": "This vocabulary is not available!",
    "msg_share_content": "Learn English with XED at",
    "msg_no_news": "Please try searching for something else.",
    "msg_no_load_news": "Connection error. Please try again",
    "msg_no_load_category": "Connection error. Please try again",
    "msg_no_load_list_new": "Connection error. Please try again",
    "msg_no_connection": "Connection error. Please try again",
    "msg_no_translate": "Sorry, no translation for this word yet",
    "msg_out_of_translation_quota":
        "You have reached your translation limit for today. Please try again tomorrow.",
    "msg_perfer_lang":
        "We will show English as a default translation in case we dont have it.",
    "msg_perfer_country":
        "We will show English as a default translation in case we dont have it.",
    "msg_onboarding_news":
        "Tap any word to view the explaination and translation.",
    "msg_onboarding_global_new_deck": "Create content for your flashcards here",
    "msg_onboarding_global_deck":
        "See and learn the latest decks from the community",
    "msg_onboarding_quiz":
        "Tap here to preview the deck content before learning",
    "msg_onboarding_learn": "Choose cards from the deck to learn",
    "msg_onboarding_learn_it": "Learn this card",
    "msg_onboarding_review_all": "Choose to review all your cards now",
    "msg_onboarding_review":
        "Or choose whatever decks you like to reviews cards in these decks",
    "msg_onboarding_create_intro":
        "Tap here to create an introduction for your deck",
    "msg_onboarding_create_card": "Create your cards here",
    "msg_onboarding_edit_content_card":
        "Tap here to create content for the card",
    "msg_onboarding_edit_back_card":
        "Tap here to see and edit the back of the card",
    "msg_share_success": "Share Successfully",
    "msg_share_error": "Share Unsuccessfully",
    "app_id_android_ads": "ca-app-pub-3737344197583673~6954808821",
    "app_id_ios_ads": "ca-app-pub-3737344197583673~5049580654",
    "ad_unit_id_android_ads_video": "ca-app-pub-3737344197583673/1301907331",
    "ad_unit_id_ios_ads_video": "ca-app-pub-3737344197583673/8605682282",
    "ad_unit_id_android_ads_banner": "ca-app-pub-3737344197583673/9169267999",
    "ad_unit_id_ios_ads_banner": "ca-app-pub-3737344197583673/2870618806",
    "chatbot_min_message_delay_millis": 500,
    "chatbot_max_message_delay_millis": 1200,
    "deeplink_deck_pattern": "https://x.education/deck/",
    "deeplink_kiki_pattern": "https://x.education/kiki/",
    "deeplink_appstore": "http://onelink.to/xed-app",
    "invite_point": 10,
    "deeplink_kiki_msg_pattern": "open?msg=",
    "param_join_challenge": "join_url",
    "chatbot_kiki_guide_json": """      {
  "features": [{
    "name": "Review",
    "icon_background_color": {"colors":[4294933398,4294788200],"stops":[0.0,1.0],"begin":0,"end":1},
    "icon_url" : "https://github.com/tvc12/playing-typescript/raw/tvc12-patch-1/btn%20review.svg",
    "kiki_commands": [
      {
        "title": "Begin to Review",
        "sub_commands": [
          "Review cards",
          "Let's review now!"
        ]
      },
      {
        "title": "Exit",
        "sub_commands": [
          "Exit",
          "Stop review",
          "Quit review",
          "Leave review"
        ]
      }
    ]
  },
   {
    "name": "Learn Vocabulary",
    "icon_background_color":{"colors":[4288130047,4279383447],"stops":[0.0,1.0],"begin":0,"end":1},
    "icon_url" : "https://github.com/tvc12/playing-typescript/raw/tvc12-patch-1/bot-deck-icon.svg",
    "kiki_commands": [
      {
        "title": "Begin to Learn",
        "sub_commands": [
          "Teach me vocabulary",
          "Learn vocabulary",
          "I want to learn vocabulary"
        ]
      },
      {
        "title": "Exit",
        "sub_commands": [
          "Exit",
          "Stop learning"
        ]
      }
    ]
  },
   {
    "name": "Lookup Dictionary",
    "icon_background_color": {"colors":[4286708664,4280862575],"stops":[0.0,1.0],"begin":0,"end":1},
    "icon_url" : "https://github.com/tvc12/playing-typescript/raw/tvc12-patch-1/bot-new-icon.svg",
    "kiki_commands": [
      {
        "title": "Lookup",
        "sub_commands": [
         "What is cat in English?",
          "What is cat in Vietnamese?",
          "What is the meaning of cat?",
          "What's the meaning of cat?",
          "What's the meaning of cat in Vietnamese?"
        ]
      },
      {
        "title": "Exit",
        "sub_commands": [
          "Exit"
        ]
      }
    ]
  }
]
}
  
    """,
    'email_error': "Email is not available!",
    'password_error': "Password is not available!",
    "msg_no_load_list_news_deck": "Connection error. Please try again",
    "msg_no_load_list_trending_deck": "Connection error. Please try again",
    "msg_generate_news_card_success":
        "The word has been successfully generated!",
    "bot_message_learn_a_course": 'I want to learn :couse_id',
    "bot_message_learn_new_course": 'I want to learn',
    "bot_message_join_a_challenge": 'Join challenge :challenge_id',
    "message_share_challenge": 'Join :challenge_name with XED at :link',
    "message_share_deck": 'Learn :deck_name with XED at :link',
    "text_button_challenge_header": "Join now",
    "bot_message_challenge_header": 'Join challenge',
    "reload_leaderboard_interval_in_second": 15,
    "title_newcard_leaderboard_overview": "Top Achievers",
    "reload_alert_interval_in_minute": 1,
    "badge_max_count": 99,
  };

  static RemoteConfig _config;

  static void init(Mode mode) {
    _config = RemoteConfig(_debug);
    // if (Mode.Debug == mode) {
    //   _config = RemoteConfig(_debug);
    // } else {
    //   _config = FireBaseRemoteConfig(_production);
    // }
  }

  static int getInt(String key) {
    return _config.getInt(key);
  }

  static String getString(String key) {
    return _config.getString(key);
  }

  static double getDouble(String key) {
    return _config.getDouble(key);
  }

  static bool getBool(String key) {
    return _config.getBool(key);
  }

  static int getDeckPageSize() => getInt("PAGING_DECK_SIZE");

  static int getCurrentVersion() => 3;

  static String get storeCurrentVersion => "3.0.2";

  /*Use to force update, be careful */
  static int getLatestVersion() => getInt("latest_version");

  static int getMinVersion() => getInt("min_version");

  static int getUploadVideoMaxSize() => getInt("video_max_size");

  static int getUploadImageMaxSize() => getInt("image_max_size");

  static int getUploadAudioMaxSize() => getInt("audio_max_size");

  static String getYoutubeApiKey() => getString("youtube_api_key");

  static String getStaticHost() => getString("static_host");

  static String getProtocol() => getString("protocol");

  static String getYoutubeThumbnail() => getString("youtube_thumbnail");

  static int getPoints() => getInt("invite_point");

  static String getThumbnailQuality() => getString("youtube_thumbnail_quality");

  static String getAdsAppId() => Platform.isAndroid
      ? getString("app_id_android_ads")
      : getString("app_id_ios_ads");

  static String getAdsVideoUnitId() => Platform.isAndroid
      ? getString("ad_unit_id_android_ads_video")
      : getString("ad_unit_id_ios_ads_video");

  static String getAdsBannerUnitId() => Platform.isAndroid
      ? getString("ad_unit_id_android_ads_banner")
      : getString("ad_unit_id_ios_ads_banner");

  static int getMinMessageDelayMillis() =>
      getInt("chatbot_min_message_delay_millis") ?? 800;

  static int getMaxMessageDelayMillis() =>
      getInt("chatbot_max_message_delay_millis") ?? 1800;

  static List<String> getDeckCreationWhitelistEmail() {
    var data = getString("whitelist_deck_creation_emails");
    return (data?.split(",") ?? <String>[])
        .where((x) => (x != null && x.trim().isNotEmpty))
        .toList();
  }

  static String buildMediaStaticUrl(String rawUrl) {
    return "${Config.getStaticHost()}/$rawUrl";
  }

  static String getShareSuccessMsg() => getString("msg_share_success");

  static String getShareErrorMsg() => getString("msg_share_error");

  static int getTotalImageSizeInCache() =>
      getInt('cache_total_image_size_in_bytes');

  static int getTotalImageInCache() => getInt('cache_total_image');

  static String getNotAuthenticatedMsg() => getString('msg_not_authenticated');

  static String getSpeechInitFailedMsg() => getString('msg_init_speech_error');

  static String getMessageGenerateNewsCardSuccess() =>
      getString("msg_generate_news_card_success");

  static String getMessageError() => getString("msg_error_try_again");

  static String getMessageNoConnection() => getString("msg_no_connection");
}

class RemoteConfig {
  Map<String, dynamic> _default;

  RemoteConfig(this._default);

  int getInt(String key) {
    return _default[key];
  }

  String getString(String key) {
    return _default[key];
  }

  double getDouble(String key) {
    return _default[key];
  }

  bool getBool(String key) {
    return _default[key];
  }

  dynamic get(String key) {
    return _default[key];
  }

  Map<String, dynamic> getAll() {
    return _default;
  }
}

// class FireBaseRemoteConfig extends RemoteConfig {
//   frc.RemoteConfig _conf;
//
//   FireBaseRemoteConfig(Map<String, dynamic> defaultValue)
//       : super(defaultValue) {
//     _init();
//   }
//
//   void _init() async {
//     try {
//       _conf = await frc.RemoteConfig.instance;
//       _conf.setDefaults(_default ?? <String, dynamic>{});
//       _conf.fetch(expiration: Duration(hours: 1));
//       await _conf.activateFetched();
//       _conf.addListener(() {
//         getAll().forEach((key, value) {
//           Log.error("Key: " + key + " Value: " + value.toString());
//         });
//       });
//     } catch (e) {
//       Log.error('Fail to fetch config from firebase: $e');
//     }
//   }
//
//   @override
//   int getInt(String key) {
//     return _conf == null ? _default[key] : _conf.getInt(key);
//   }
//
//   @override
//   String getString(String key) {
//     return _conf == null ? _default[key] : _conf.getString(key);
//   }
//
//   @override
//   double getDouble(String key) {
//     return _conf == null ? _default[key] : _conf.getDouble(key);
//   }
//
//   @override
//   bool getBool(String key) {
//     return _conf == null ? _default[key] : _conf.getBool(key);
//   }
//
//   @override
//   dynamic get(String key) {
//     return _conf == null ? _default[key] : _conf.getValue(key);
//   }
//
//   @override
//   Map<String, dynamic> getAll() {
//     return _conf == null ? _default : _conf.getAll();
//   }
// }
