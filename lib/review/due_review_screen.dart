import 'package:ddi/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/resources.dart';
import 'package:the_flashcard/common/xwidgets/x_state.dart';
import 'package:the_flashcard/environment/driver_key.dart';
import 'package:the_flashcard/onboarding/onboarding.dart';
import 'package:the_flashcard/review/progress/review_progress_screen.dart';
import 'package:the_flashcard/review/review_default_screen.dart';
import 'package:the_flashcard/review/review_list_bloc.dart';
import 'package:the_flashcard/review/review_list_event.dart';
import 'package:the_flashcard/review/x_slider_deck_widget.dart';

class DueReviewScreen extends StatefulWidget {
  static String name = '/dueReview';
  static RefreshController refreshController = RefreshController();

  @override
  _DueReviewScreenState createState() => _DueReviewScreenState();
}

class _DueReviewScreenState extends XState<DueReviewScreen>
    implements OnSliderViewDeckWidgetCallBack {
  DueReviewBloc dueBloc;
  final controllerList = <SlidableController>[];
  final slidingList = <bool>[];

  @override
  void initState() {
    super.initState();
    dueBloc = BlocProvider.of<DueReviewBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    Dimens.context = context;
    return BlocConsumer<DueReviewBloc, ReviewListState>(
      cubit: dueBloc,
      listener: (BuildContext context, state) {
        if (state is! ReviewListLoading) {
          if (DueReviewScreen.refreshController.isLoading) {
            DueReviewScreen.refreshController.loadComplete();
          } else {
            DueReviewScreen.refreshController.refreshCompleted();
          }
        }
      },
      builder: (context, state) {
        _initSliderItems(state.records);
        return state.records.isNotEmpty
            ? Column(
                children: <Widget>[
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: state.records.isNotEmpty
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                '${state.total} Results',
                                style: RegularTextStyle(14)
                                    .copyWith(color: XedColors.battleShipGrey),
                              ),
                              Spacer(),
                              _buildButtonReviewAll(state.records),
                            ],
                          )
                        : SizedBox(),
                  ),
                  SizedBox(height: hp(20)),
                  Expanded(
                    child: SmartRefresher(
                      controller: DueReviewScreen.refreshController,
                      enablePullDown: true,
                      enablePullUp: state.canLoadMore,
                      onRefresh: () => dueBloc.add(RefreshReview()),
                      onLoading: () => dueBloc.add(LoadMore()),
                      child: state.records.isNotEmpty
                          ? ListView.builder(
                              itemCount: state.records.length,
                              itemBuilder: (_, int index) {
                                return XSliderDeckWidget(
                                  index,
                                  state.records[index],
                                  controllerList[index],
                                  reviewIn: ReviewIn.DueDay,
                                  sliding: slidingList[index],
                                  onDeleteTap: _onDeleteTap,
                                  valueKey: DriverKey.DECK + "_$index",
                                );
                              },
                            )
                          : SizedBox(),
                    ),
                  ),
                ],
              )
            : ReviewDefaultScreen();
      },
    );
  }

  Widget _buildButtonReviewAll(List<core.Deck> decks) {
    List<String> allCardIds =
        decks.map((deck) => deck.cardIds).expand((cardIds) => cardIds).toList();

    return _ButtonReviewAll(
      globalKey: GlobalKeys.dueDayButtonReviewAll,
      active: allCardIds?.isNotEmpty == true,
      onTap: () => XError.f0(
        () {
          if (allCardIds.isNotEmpty) {
            navigateToScreen(
              screen: ReviewProgressScreen(allCardIds, false),
              name: ReviewProgressScreen.name,
            );
          }
        },
      ),
    );
  }

  @override
  void onDelete(int index) {}

  @override
  void onSelected(int index) {}

  @override
  void onSliding(int index) {
    // for => if deck.index != index => slider =fase
  }

  void _initSliderItems(List<core.Deck> decks) {
    for (var i = 0; i < decks.length ?? 0; i++) {
      slidingList.add(false);
      controllerList.add(
        SlidableController(
            onSlideIsOpenChanged: (open) {
              setState(() {
                slidingList[i] = open;
                if (open) _closeOtherSlideItems(i);
              });
            },
            onSlideAnimationChanged: (value) {}),
      );
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

class _ButtonReviewAll extends StatelessWidget implements OnboardingObject {
  final bool active;
  final VoidCallback onTap;

  const _ButtonReviewAll({Key globalKey, this.active = true, this.onTap})
      : super(key: globalKey);

  @override
  Widget build(BuildContext context) {
    final Color color =
        active ? XedColors.waterMelon : XedColors.battleShipGrey;
    final Container child = Container(
      height: hp(38),
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: color,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            Assets.icThunder,
            color: XedColors.white,
          ),
          SizedBox(width: 5),
          Text(
            'Review all',
            style: SemiBoldTextStyle(14).copyWith(
              color: XedColors.white,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
    return onTap != null
        ? InkWell(
            onTap: () => XError.f0(onTap),
            child: child,
          )
        : child;
  }

  @override
  Widget cloneWithoutGlobalKey() {
    return _ButtonReviewAll(
      active: active,
      onTap: null,
    );
  }
}
