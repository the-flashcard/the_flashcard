import 'package:ddi/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/widgets/x_view_mode_chooser.dart';
import 'package:the_flashcard/deck_screen/deck_edit_screen.dart';
import 'package:the_flashcard/deck_screen/deck_list_bloc.dart';
import 'package:the_flashcard/deck_screen/deck_list_event.dart';
import 'package:the_flashcard/deck_screen/deck_list_widget.dart';
import 'package:the_flashcard/deck_screen/select/select_deck_manager.dart';

import 'deck_detail_screen.dart';

class MyDeck extends StatefulWidget {
  static final String name = "my_deck_tab";

  MyDeck({
    Key key,
  }) : super(key: key);

  @override
  _MyDeckState createState() => _MyDeckState();
}

class _MyDeckState extends XState<MyDeck> {
  final ViewMode viewMode = ViewMode();

  RefreshController refreshController;
  DeckListBloc deckBloc;

  @override
  void initState() {
    super.initState();

    refreshController = RefreshController();
    deckBloc = BlocProvider.of<MyDeckBloc>(context);
  }

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  Widget _buildDefaultMyDeck() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(height: (120)),
          SvgPicture.asset(Assets.imgCreateDeck),
          SizedBox(height: (15)),
          Text(
            'Create your first deck',
            textAlign: TextAlign.center,
            style: BoldTextStyle(22).copyWith(
              fontSize: 22,
            ),
          ),
          Text(
            'Let’s get you started with your cool vocabularies',
            textAlign: TextAlign.center,
            style: RegularTextStyle(14).copyWith(
              fontSize: 14,
              color: XedColors.battleShipGrey,
              height: 1.4,
            ),
          ),
          SizedBox(height: 40),
          Container(
            width: wp(203),
            height: hp(40),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: XedColors.waterMelon,
              borderRadius: BorderRadius.circular(22),
            ),
            child: InkWell(
              onTap: () => XError.f0(() {
                navigateToScreen(
                  screen: DeckEditScreen.create(),
                  name: DeckEditScreen.name,
                );
              }),
              child: Text(
                'CREATE DECK',
                style: BoldTextStyle(14).copyWith(
                  fontSize: 14,
                  letterSpacing: 1,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectDeckButton() {
    void _handleSelectPressed() {
      navigateToScreen(
        screen: MyDeckManager(),
        name: MyDeckManager.name,
      );
    }

    return InkWell(
      onTap: _handleSelectPressed,
      child: Container(
        height: hp(36),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: wp(15)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Color.fromARGB(255, 220, 221, 221),
        ),
        child: Text(
          'Select',
          style: TextStyle(
            fontFamily: 'HarmoniaSansProCyr',
            fontWeight: FontWeight.w600,
            fontSize: 16.0,
            color: XedColors.black,
          ),
        ),
      ),
    );
  }

  void finishRefresh() {
    if (mounted) {
      if (refreshController.headerStatus == RefreshStatus.refreshing)
        refreshController.refreshCompleted();
      if (refreshController.footerStatus == LoadStatus.loading)
        refreshController.loadComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeckListBloc, DeckListState>(
      cubit: deckBloc,
      listener: (BuildContext context, DeckListState state) {
        if (state is! DeckListLoading) finishRefresh();
      },
      builder: (context, state) {
        return SmartRefresher(
          controller: refreshController,
          enablePullDown: !(state is DeckListLoading),
          enablePullUp: state.canLoadMore,
          onRefresh: () {
            if (!(state is DeckListLoading)) {
              deckBloc.add(Refresh());
            } else {
              refreshController.refreshCompleted();
            }
          },
          onLoading: () {
            if (!(state is DeckListLoading)) {
              deckBloc.add(LoadMore());
            } else {
              refreshController.loadComplete();
            }
          },
          child: state.hasNoData
              ? _buildDefaultMyDeck()
              : ListView.builder(
                  itemCount: 2,
                  itemBuilder: (context, index) {
                    switch (index) {
                      case 0:
                        return Row(
                          children: <Widget>[
                            XViewModeChooser(
                              onTabChanged: _handleViewModeChanged,
                            ),
                            Spacer(),
                            _buildSelectDeckButton(),
                            SizedBox(width: wp(15)),
                          ],
                        );
                      default:
                        return DeckListWidget(
                          viewMode: viewMode,
                          decks: state.records,
                          onTap: _handleDeckTapped,
                          deckIn: DeckIn.MyDeck,
                        );
                    }
                  },
                ),
        );
      },
    );
  }

  _handleViewModeChanged(int index) {
    if (mounted) {
      setState(() {
        viewMode.toggle();
      });
    }
  }

  void _handleDeckTapped(core.Deck deck) async {
    final core.AuthService service = DI.get(core.AuthService);
    var isOwner = await service.isOwner(deck.username);

    navigateToScreen(
      screen: isOwner ? DeckEditScreen.edit(deck) : DeckDetailScreen(deck),
      name: isOwner ? DeckEditScreen.name : DeckDetailScreen.name,
    );
  }
}
