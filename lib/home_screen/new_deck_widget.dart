import 'dart:async';

import 'package:ddi/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/xed_progress.dart';
import 'package:the_flashcard/common/widgets/x_view_mode_chooser.dart';
import 'package:the_flashcard/common/xwidgets/x_state.dart';
import 'package:the_flashcard/deck_screen/deck_detail_screen.dart';
import 'package:the_flashcard/deck_screen/deck_edit_screen.dart';
import 'package:the_flashcard/deck_screen/deck_item_widget.dart';
import 'package:the_flashcard/environment/driver_key.dart';
import 'package:the_flashcard/home_screen/trending_deck_bloc.dart';

class NewDeckWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NewDeckState();
}

class _NewDeckState extends XState<NewDeckWidget> {
  final ViewMode deckViewMode = ViewMode.list(horizontal: true);
  RefreshController refreshController;

  @override
  void initState() {
    super.initState();
    refreshController = RefreshController(initialRefresh: false);
  }

  @override
  Widget build(BuildContext context) {
    double height20 = hp(20);
    // double width5 = wp(5);
    double width15 = wp(15);

    final bloc = BlocProvider.of<NewDeckBloc>(context);

    return BlocListener(
      cubit: bloc,
      listener: (context, state) => _onStateChanged(context, state, bloc),
      child: BlocBuilder<NewDeckBloc, TrendingDeckState>(
          cubit: bloc,
          builder: (BuildContext context, TrendingDeckState state) {
            switch (state.runtimeType) {
              case DeckListLoaded:
                return Wrap(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: width15, right: width15),
                      child: Text(
                        'New Decks',
                        style: BoldTextStyle(20.0),
                      ),
                    ),
                    Container(
                      height: hp(260),
                      padding: EdgeInsets.symmetric(vertical: height20),
                      child: SmartRefresher(
                        controller: refreshController,
                        enablePullDown: true,
                        enablePullUp: false,
                        header: ClassicHeader(
                          iconPos: IconPosition.top,
                          outerBuilder: (child) {
                            return Container(
                              width: 80.0,
                              child: Center(
                                child: child,
                              ),
                            );
                          },
                        ),
                        onRefresh: () => _onRefresh(context, bloc),
                        child: ListView.separated(
                          key: Key(DriverKey.HOME_NEW_DECK),
                          padding: EdgeInsets.symmetric(horizontal: wp(15)),
                          itemCount:
                              (state as DeckListLoaded).decks?.length ?? 0,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (_, index) {
                            final deck = (state as DeckListLoaded).decks[index];
                            return InkWell(
                              onTap: () => XError.f0(
                                () => _onDeckSelected(context, deck),
                              ),
                              child: DeckItemWidget(deck),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return SizedBox(width: wp(10));
                          },
                        ),
                      ),
                    ),
                  ],
                );
              case DeckListLoading:
                return Wrap(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: width15, right: width15),
                      child: Text(
                        'New Decks',
                        style: BoldTextStyle(20.0),
                      ),
                    ),
                    SizedBox(
                      height: hp(260),
                      child: Center(child: XedProgress.indicator()),
                    ),
                  ],
                );
              default:
                return SizedBox();
            }
          }),
    );
  }

  void _onStateChanged(
    BuildContext context,
    TrendingDeckState state,
    NewDeckBloc bloc,
  ) {
    switch (state.runtimeType) {
      case DeckListFailure:
        showErrorSnakeBar((state as DeckListFailure).error);
        Future.delayed(const Duration(seconds: 10), () {
          bloc.add(LoadDeckListEvent());
        });
        break;
      default:
        break;
    }
  }

  void _onRefresh(BuildContext context, NewDeckBloc bloc) {
    bloc.add(LoadDeckListEvent());
  }

  void _onDeckSelected(BuildContext context, core.Deck deck) {
    core.AuthService authService = DI.get(core.AuthService);
    authService.isOwner(deck.username).then((isOwner) {
      navigateToScreen(
        screen: isOwner ? DeckEditScreen.edit(deck) : DeckDetailScreen(deck),
        name: isOwner ? DeckEditScreen.name : DeckDetailScreen.name,
      );
    });
  }

  @override
  void dispose() {
    refreshController?.dispose();
    super.dispose();
  }
}
