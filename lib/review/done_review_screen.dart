import 'package:ddi/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tf_core/tf_core.dart' as core;

import 'package:the_flashcard/common/resources/dimens.dart';
import 'package:the_flashcard/environment/driver_key.dart';
import 'package:the_flashcard/review/review_list_bloc.dart';
import 'package:the_flashcard/review/review_list_event.dart';
import 'package:the_flashcard/review/x_slider_deck_widget.dart';

class DoneReviewScreen extends StatefulWidget {
  @override
  _DoneReviewScreenState createState() => _DoneReviewScreenState();
}

class _DoneReviewScreenState extends State<DoneReviewScreen>
    implements OnSliderViewDeckWidgetCallBack {
  RefreshController refreshController;
  DoneReviewBloc doneBloc;
  final controllerList = <SlidableController>[];
  final slidingList = <bool>[];

  @override
  void initState() {
    super.initState();
    doneBloc = BlocProvider.of<DoneReviewBloc>(context);
    refreshController = RefreshController();
  }

  @override
  Widget build(BuildContext context) {
    Dimens.context = context;
    return Column(
      children: <Widget>[
        BlocListener(
          cubit: doneBloc,
          listener: (BuildContext context, state) {
            if (state is! ReviewListLoading) {
              if (refreshController.isLoading) {
                refreshController.loadComplete();
              } else {
                refreshController.refreshCompleted();
              }
            }
          },
          child: BlocBuilder<DoneReviewBloc, ReviewListState>(
            cubit: doneBloc,
            builder: (context, state) {
              _initSliderItems(state.records);
              return Expanded(
                child: SmartRefresher(
                  controller: refreshController,
                  enablePullDown: true,
                  enablePullUp: state.canLoadMore,
                  onRefresh: () => doneBloc.add(RefreshReview()),
                  onLoading: () => doneBloc.add(LoadMore()),
                  child: ListView.builder(
                    itemCount: state.records.length,
                    itemBuilder: (_, int index) {
                      return XSliderDeckWidget(
                        index,
                        state.records[index],
                        controllerList[index],
                        canReview: false,
                        reviewIn: ReviewIn.Done,
                        onDeleteTap: _onDeleteTap,
                        valueKey: DriverKey.DECK + "_$index",
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void onSelected(int index) {}

  @override
  void onDelete(int index) {}

  @override
  void onSliding(int index) {}

  void _initSliderItems(List<core.Deck> decks) {
    for (var i = 0; i < decks.length ?? 0; i++) {
      slidingList.add(false);
      controllerList.add(SlidableController(
          onSlideIsOpenChanged: (open) {
            setState(() {
              slidingList[i] = open;
              if (open) _closeOtherSlideItems(i);
            });
          },
          onSlideAnimationChanged: (value) {}));
    }
  }

  void _closeOtherSlideItems(int index) {
    for (var i = 0; i < controllerList.length ?? 0; i++) {
      if (i != index) {
        if (slidingList[i]) {
          slidingList[i] = false;
          controllerList[i].activeState.close();
        }
      }
    }
    setState(() {});
  }

  void _closeMenuItems() {
    for (var i = 0; i < controllerList.length ?? 0; i++) {
      if (slidingList[i]) {
        slidingList[i] = false;
        controllerList[i].activeState.close();
      }
    }
    setState(() {});
  }

  void _onDeleteTap(core.Deck deck) async {
    final core.SRSService srsService = DI.get(core.SRSService);

    var deletedNumber =
        await srsService.multiDelete(deck?.cardIds ?? <String>[]);
    if (deletedNumber > 0) {
      _closeMenuItems();
      BlocProvider.of<DueReviewBloc>(context).add(RemoveDeck(deck.id));
      BlocProvider.of<LearningReviewBloc>(context).add(RemoveDeck(deck.id));
      BlocProvider.of<DoneReviewBloc>(context).add(RemoveDeck(deck.id));
    }
  }
}
