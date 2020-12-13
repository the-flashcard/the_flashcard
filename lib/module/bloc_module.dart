import 'package:ddi/module.dart';
import 'package:flutter/foundation.dart';
import 'package:tf_core/tf_core.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/deck_creation/image/search_image_bloc/image_list_bloc.dart';
import 'package:the_flashcard/deck_screen/category_bloc.dart';
import 'package:the_flashcard/deck_screen/deck_list_bloc.dart';
import 'package:the_flashcard/home_screen/overview/bloc/statistic_bloc.dart';
import 'package:the_flashcard/home_screen/trending_deck_bloc.dart';
import 'package:the_flashcard/home_screen/welcome_page.dart';

import 'package:the_flashcard/review/review_list_bloc.dart';

class BlocModule extends AbstractModule {
  final AuthenticationBloc _authenBloc;

  BlocModule(this._authenBloc);

  @override
  void init() async {
    if (!kReleaseMode) {
      // Bloc.observer = SimpleBlocDelegate();
    }

    bind(NotificationBloc).to(NotificationBloc());
    bind(PageNavigatorBloc).to(PageNavigatorBloc());
    bind(AuthenticationBloc).to(_authenBloc);
    bind(StatisticBloc).to(StatisticBloc());
    bind(NewDeckBloc).to(NewDeckBloc());
    bind(TrendingDeckBloc).to(TrendingDeckBloc());
    bind(CategoryBloc).to(CategoryBloc());
    bind(MyDeckBloc).to(MyDeckBloc(Config.getDeckPageSize()));
    bind(SearchDeckBloc).to(SearchDeckBloc(Config.getDeckPageSize()));
    bind(GlobalDeckBloc).to(GlobalDeckBloc(Config.getDeckPageSize()));
    bind(FavoriteDeckBloc).to(FavoriteDeckBloc(Config.getDeckPageSize()));

    bind(DueReviewBloc).to(DueReviewBloc(Config.getDeckPageSize()));
    bind(DoneReviewBloc).to(DoneReviewBloc(Config.getDeckPageSize()));
    bind(LearningReviewBloc).to(LearningReviewBloc(Config.getDeckPageSize()));
    bind(ImageListBloc).to(ImageListBloc(10));
  }
}

// class SimpleBlocDelegate extends BlocObserver {
//   @override
//   void onEvent(Bloc bloc, Object event) {
//     super.onEvent(bloc, event);
//     Log.debug('${bloc.runtimeType}: $event');
//   }

//   @override
//   void onTransition(Bloc bloc, Transition transition) {
//     super.onTransition(bloc, transition);
//     Log.debug('${bloc.runtimeType}: $transition');
//   }

//   @override
//   void onError(Cubit bloc, Object error, StackTrace stacktrace) {
//     super.onError(bloc, error, stacktrace);
//     Log.error(error);
//     Log.error(stacktrace);
//   }
// }
