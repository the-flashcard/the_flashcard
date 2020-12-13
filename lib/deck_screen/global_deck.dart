import 'package:ddi/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/dimens.dart';
import 'package:the_flashcard/common/resources/xed_progress.dart';
import 'package:the_flashcard/common/widgets/x_view_mode_chooser.dart';
import 'package:the_flashcard/common/xwidgets/x_state.dart';
import 'package:the_flashcard/deck_screen/category_bloc.dart';
import 'package:the_flashcard/deck_screen/category_event.dart';
import 'package:the_flashcard/deck_screen/category_slider.dart';
import 'package:the_flashcard/deck_screen/category_state.dart' as cs;
import 'package:the_flashcard/deck_screen/deck_detail_screen.dart';
import 'package:the_flashcard/deck_screen/deck_edit_screen.dart';
import 'package:the_flashcard/deck_screen/deck_item_widget.dart';
import 'package:the_flashcard/deck_screen/deck_list_bloc.dart';
import 'package:the_flashcard/deck_screen/deck_list_event.dart';

class GlobalDeck extends StatefulWidget {
  GlobalDeck({
    Key key,
  }) : super(key: key);

  @override
  _GlobalDeckState createState() => _GlobalDeckState();
}

class _GlobalDeckState extends XState<GlobalDeck> {
  ViewMode viewMode = ViewMode();
  DeckListBloc deckBloc;
  CategoryBloc categoryBloc;
  RefreshController refreshController;
  List<core.DeckCategory> categories = [];

  @override
  void initState() {
    super.initState();
    refreshController = RefreshController();
    deckBloc = BlocProvider.of<GlobalDeckBloc>(context);
    categoryBloc = BlocProvider.of<CategoryBloc>(context);
    if (categoryBloc.state is cs.NotLoaded) {
      categoryBloc.add(SearchGlobalCategory());
    }
  }

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  Widget _buildCategorySlider() {
    return Container(
      padding: EdgeInsets.only(top: 30.0),
      height: wp(98),
      child: BlocBuilder<CategoryBloc, cs.CategoryState>(
        cubit: categoryBloc,
        builder: (BuildContext context, cs.CategoryState state) {
          if (state is cs.Loaded) {
            return CategorySlider(
              categories: state.result,
              selectedId: state.categoryId,
              onSelected: _onCategorySelected,
              onDeSelected: _onCategoryDeSelected,
            );
          }
          return Center(child: XedProgress.indicator());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      cubit: deckBloc,
      listener: (BuildContext context, DeckListState state) {
        if (categoryBloc.state is cs.NotLoaded) {
          categoryBloc.add(SearchGlobalCategory());
        }
        if (state is! DeckListLoading) {
          _finishRefresh();
        }
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
          child: ListView.builder(
            itemCount: 3,
            itemBuilder: (context, index) {
              switch (index) {
                case 0:
                  return _buildCategorySlider();
                case 1:
                  return XViewModeChooser(
                    key: ValueKey("view_mode"),
                    onTabChanged: _handleViewModeChanged,
                  );
                default:
                  return (state?.records?.length ?? 0) <= 0
                      ? SizedBox(
                          height: 50,
                        )
                      : GridView.builder(
                          primary: false,
                          padding: EdgeInsets.only(
                            left: wp(15),
                            right: wp(15),
                            bottom: hp(10),
                          ),
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            mainAxisSpacing: wp(15),
                            crossAxisSpacing: wp(10),
                            childAspectRatio: viewMode.gridAspectRatio,
                            crossAxisCount: viewMode.gridColumn,
                          ),
                          itemCount: decks.length,
                          scrollDirection: viewMode.horizontal
                              ? Axis.horizontal
                              : Axis.vertical,
                          itemBuilder: (context, index) {
                            var deck = decks[index];
                            final key = index == 0
                                ? GlobalKeys.globalDeckIconDeck
                                : ValueKey(deck.id);

                            return InkWell(
                              onTap: () => _handleDeckTapped(deck),
                              child: viewMode.gridColumn == 1
                                  ? DeckListItemWidget(
                                      deck,
                                      key: key,
                                    )
                                  : DeckItemWidget(
                                      deck,
                                      key: key,
                                    ),
                            );
                          },
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

  void _finishRefresh() {
    try {
      if (mounted) {
        if (refreshController.headerStatus == RefreshStatus.refreshing)
          refreshController.refreshCompleted();
        if (refreshController.footerStatus == LoadStatus.loading)
          refreshController.loadComplete();
      }
    } catch (ex) {
      core.Log.debug(ex);
    }
  }

  void _onCategorySelected(String id) {
    categoryBloc.add(CategorySelected(id));
    deckBloc.add(CategoryChanged(categoryId: id));
  }

  void _onCategoryDeSelected(String id) {
    deckBloc.add(CategoryChanged(categoryId: id, isRemoved: true));
    categoryBloc.add(CategoryDeselected());
  }

  void _handleDeckTapped(core.Deck deck) {
    core.AuthService authService = DI.get(core.AuthService);
    authService.isOwner(deck.username).then((isOwner) {
      navigateToScreen(
        screen: isOwner ? DeckEditScreen.edit(deck) : DeckDetailScreen(deck),
        name: isOwner ? DeckEditScreen.name : DeckDetailScreen.name,
      );
    });
  }
}
