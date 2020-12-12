import 'dart:async';

import 'package:ddi/di.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/xwidgets/x_state.dart';
import 'package:the_flashcard/environment/driver_key.dart';
import 'package:the_flashcard/home_screen/overview/bloc/statistic_bloc.dart';
import 'package:the_flashcard/home_screen/trending_deck_bloc.dart';
import 'package:the_flashcard/home_screen/welcome_page.dart';
import 'package:the_flashcard/login/authentication/authentication_bloc.dart';
import 'package:the_flashcard/onboarding/on_boarding_screen.dart';
import 'package:the_flashcard/onboarding/splash_screen.dart';
import 'package:the_flashcard/review/review_list_bloc.dart';

import 'common/common.dart';
import 'deck_screen/category_bloc.dart';
import 'deck_screen/deck_list_bloc.dart';
import 'error_handling_service.dart';
import 'login/login_email_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    if (kReleaseMode) FlutterError.dumpErrorToConsole(details);
    Zone.current.handleUncaughtError(details.exception, details.stack);
  };
  runApp(App());
  // runZonedGuarded<Future<void>>(() async {
  //   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // }, (error, stackTrace) async {
  //   // await FlutterCrashlytics().reportCrash(
  //   //   error,
  //   //   stackTrace,
  //   //   forceCrash: false,
  //   // );
  // });
}

class App extends StatefulWidget {
  App({Key key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends XState<App> with WidgetsBindingObserver {
  AuthenticationBloc authenBloc;
  ErrorHandlingService errorResponseHandlingService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    authenBloc = AuthenticationBloc()..add(AppStarted());
    // errorResponseHandlingService = DI.get(ErrorHandlingService);
  }

  @override
  void dispose() {
    authenBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // errorResponseHandlingService.handlers.add(
      //   SessionExpiredErrorHandler(context),
      // );
    });
    return MaterialApp(
      navigatorKey: DriverKey.navigatorGlobalKey,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthenticationBloc>(create: (_) => authenBloc),
          BlocProvider<PageNavigatorBloc>(
              create: (_) => DI.get(PageNavigatorBloc)),
          BlocProvider<StatisticBloc>(create: (_) => DI.get(StatisticBloc)),
          BlocProvider<CategoryBloc>(create: (_) => DI.get(CategoryBloc)),
          BlocProvider<GlobalDeckBloc>(create: (_) => DI.get(GlobalDeckBloc)),
          BlocProvider<MyDeckBloc>(create: (_) => DI.get(MyDeckBloc)),
          BlocProvider<FavoriteDeckBloc>(
              create: (_) => DI.get(FavoriteDeckBloc)),
          BlocProvider<SearchDeckBloc>(create: (_) => DI.get(SearchDeckBloc)),
          BlocProvider<NewDeckBloc>(create: (_) => DI.get(NewDeckBloc)),
          BlocProvider<TrendingDeckBloc>(
              create: (_) => DI.get(TrendingDeckBloc)),
          BlocProvider<DueReviewBloc>(create: (_) => DI.get(DueReviewBloc)),
          BlocProvider<DoneReviewBloc>(create: (_) => DI.get(DoneReviewBloc)),
          BlocProvider<LearningReviewBloc>(
              create: (context) => DI.get(LearningReviewBloc))
        ],
        child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          bloc: authenBloc,
          builder: (BuildContext context, AuthenticationState state) {
            Dimens.context = context;
            switch (state.runtimeType) {
              case AuthenticationUninitialized:
                return SplashScreen();
              case Authenticated:
                return WelcomePage();
              case Unauthenticated:
                return LoginEmailScreen();
              case FirstRunState:
                return OnBoardingScreen();
              default:
                return LoginEmailScreen();
            }
          },
        ),
      ),
    );
  }
}
