import 'package:ddi/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/assets.dart';
import 'package:the_flashcard/common/resources/xed_colors.dart';
import 'package:the_flashcard/common/resources/xed_text_styles.dart';
import 'package:the_flashcard/common/widgets/x_view_mode_chooser.dart';
import 'package:the_flashcard/common/xwidgets/x_state.dart';
import 'package:the_flashcard/deck_screen/deck_edit_screen.dart';
import 'package:the_flashcard/deck_screen/deck_list_bloc.dart';
import 'package:the_flashcard/deck_screen/deck_list_event.dart';
import 'package:the_flashcard/deck_screen/deck_list_widget.dart';

import 'deck_detail_screen.dart';

class FavoriteDeck extends StatefulWidget {
  FavoriteDeck({
    Key key,
  }) : super(key: key);

  @override
  _FavoriteDeckState createState() => _FavoriteDeckState();
}

class _FavoriteDeckState extends XState<FavoriteDeck> {
  final ViewMode viewMode = ViewMode();

  RefreshController refreshController;
  DeckListBloc deckBloc;

  @override
  void initState() {
    super.initState();

    refreshController = RefreshController();
    deckBloc = BlocProvider.of<FavoriteDeckBloc>(context);
  }

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  Widget _buildDefaultFavorite() {
    return Align(
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          SizedBox(height: (120)),
          SvgPicture.asset(
            Assets.imgFavoriteDefault,
            allowDrawingOutsideViewBox: false,
          ),
          SizedBox(height: (20)),
          Text(
            'No favorites yet!',
            style: BoldTextStyle(22).copyWith(
              fontSize: 22,
            ),
          ),
          Text(
            'Click the ♡ icon on any Deck to add a favorite.',
            textAlign: TextAlign.center,
            style: RegularTextStyle(14).copyWith(
              fontSize: 14,
              color: XedColors.battleShipGrey,
              height: 1.4,
            ),
          ),
        ],
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
        var decks = state.records;
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
              ? _buildDefaultFavorite()
              : ListView.builder(
                  itemCount: 2,
                  itemBuilder: (context, index) {
                    switch (index) {
                      case 0:
                        return XViewModeChooser(
                          key: ValueKey("view_mode"),
                          onTabChanged: _handleViewModeChanged,
                        );
                      default:
                        return DeckListWidget(
                          viewMode: viewMode,
                          decks: decks,
                          onTap: _handleDeckTapped,
                          deckIn: DeckIn.Favorite,
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
