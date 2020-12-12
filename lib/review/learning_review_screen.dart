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

class LearningReviewScreen extends StatefulWidget {
  @override
  _LearningReviewScreenState createState() => _LearningReviewScreenState();
}

class _LearningReviewScreenState extends State<LearningReviewScreen>
    implements OnSliderViewDeckWidgetCallBack {
  RefreshController refreshController;
  LearningReviewBloc learningBloc;
  final controllerList = <SlidableController>[];
  final slidingWidgetList = <XSliderDeckWidget>[];
  final slidingList = <bool>[];

  @override
  void initState() {
    super.initState();
    learningBloc = BlocProvider.of<LearningReviewBloc>(context);
    refreshController = RefreshController();
  }

  @override
  Widget build(BuildContext context) {
    Dimens.context = context;
    return Column(
      children: <Widget>[
        SizedBox(
          height: hp(20),
        ),
        BlocListener(
          bloc: learningBloc,
          listener: (BuildContext context, state) {
            if (state is! ReviewListLoading) {
              if (refreshController.isLoading) {
                refreshController.loadComplete();
              } else {
                refreshController.refreshCompleted();
              }
            }
          },
          child: BlocBuilder<LearningReviewBloc, ReviewListState>(
            bloc: learningBloc,
            builder: (context, state) {
              _initSliderItems(state.records);
              return Expanded(
                child: SmartRefresher(
                  controller: refreshController,
                  enablePullDown: true,
                  enablePullUp: state.canLoadMore,
                  onRefresh: () => learningBloc.add(RefreshReview()),
                  onLoading: () => learningBloc.add(LoadMore()),
                  child: ListView.builder(
                    itemCount: state.records.length ?? 0,
                    itemBuilder: (_, int index) {
                      return XSliderDeckWidget(
                        index,
                        state.records[index],
                        controllerList[index],
                        canReview: false,
                        reviewIn: ReviewIn.Learning,
                        sliding: slidingList[index],
                        onDeleteTap: _onDeleteTap,
                        valueKey: DriverKey.DECK + '_$index',
                      );
                    },
                  ),
                  // child: ListView(children: slidingWidgetList),
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
  void onSliding(int index) {
    // for (var i = 0; i < sliderWidgetList.length; i++) {
    //   if (i != index) sliderWidgetList[i].sliding = false;
    // }
  }

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
