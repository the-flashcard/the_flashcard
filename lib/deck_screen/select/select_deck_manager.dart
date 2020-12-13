import 'package:ddi/di.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/xed_progress.dart';
import 'package:the_flashcard/common/widgets/deck_thumnail_default.dart';
import 'package:the_flashcard/common/xwidgets/x_state.dart';
import 'package:the_flashcard/deck_creation/multi_choice/bloc/multi_choice_bloc.dart';
import 'package:the_flashcard/deck_screen/deck_list_bloc.dart';
import 'package:the_flashcard/deck_screen/deck_list_event.dart';
import 'package:the_flashcard/environment/driver_key.dart';

class MyDeckManager extends StatefulWidget {
  static const String name = "/my_deck_manager";

  const MyDeckManager({Key key}) : super(key: key);

  @override
  _MyDeckManagerState createState() => _MyDeckManagerState();
}

class _MyDeckManagerState extends XState<MyDeckManager> {
  bool isDeleting = false;
  RefreshController refreshController;
  MyDeckBloc deckBloc;

  @override
  void initState() {
    super.initState();
    refreshController = RefreshController();
    deckBloc = MyDeckBloc(30);
    deckBloc.add(Refresh());
  }

  @override
  void dispose() {
    refreshController.dispose();
    deckBloc = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.4,
        title: Text(
          'Select Decks',
          style: BoldTextStyle(18),
        ),
        leading: IconButton(
          key: Key(DriverKey.BACK),
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () => closeScreen(MyDeckManager.name),
        ),
        backgroundColor: XedColors.white,
      ),
      body: Stack(
        children: <Widget>[
          Container(
            color: XedColors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: wp(15)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  BlocBuilder<MyDeckBloc, DeckListState>(
                    cubit: deckBloc,
                    builder: (context, state) => _buildSelectedDecks(),
                  ),
                  BlocBuilder<MyDeckBloc, DeckListState>(
                    cubit: deckBloc,
                    builder: (context, state) => _buildToolBar(context),
                  ),
                  Expanded(
                    child: BlocConsumer<MyDeckBloc, DeckListState>(
                      cubit: deckBloc,
                      listener: (context, state) {
                        if (state is! DeckListLoading) {
                          refreshController.isLoading
                              ? refreshController.loadComplete()
                              : refreshController.refreshCompleted();
                        }
                      },
                      builder: (context, state) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          height: state.hasNoData ? null : 0,
                          child: SmartRefresher(
                            controller: refreshController,
                            enablePullDown: false,
                            enablePullUp: state.canLoadMore,
                            onRefresh: () => deckBloc.add(Refresh()),
                            onLoading: () => deckBloc.add(LoadMore()),
                            child: GridView.builder(
                              shrinkWrap: true,
                              primary: true,
                              itemCount: state.records.length,
                              itemBuilder: (_, index) {
                                core.Deck deck = state.records[index];
                                return InkWell(
                                  onTap: (!state.hasNoData && !isDeleting)
                                      ? () => _onDeckTap(deck)
                                      : null,
                                  child: _buildDeck(
                                    deck,
                                    deckBloc.isSelected(deck.id),
                                  ),
                                );
                              },
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: wp(10),
                                mainAxisSpacing: wp(10),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          isDeleting
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                    child: XedProgress.indicator(color: XedColors.waterMelon),
                  ),
                )
              : SizedBox()
        ],
      ),
    );
  }

  Widget _buildDeck(core.Deck deck, bool isSelected) {
    return Container(
      height: hp(109),
      width: wp(77),
      child: Stack(
        children: [
          deck.hasThumbnail
              ? Container(
                  margin: EdgeInsets.only(
                    left: wp(5),
                    top: hp(5),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(deck.thumbnail),
                    ),
                  ))
              : Container(
                  margin: EdgeInsets.only(
                    left: wp(5),
                    top: hp(5),
                  ),
                  child: DeckThumbnailDefaultWiget(
                    heightIcon: 60,
                    boxDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: XedColors.duckEggBlue,
                    ),
                  ),
                ),
          Align(
            alignment: Alignment.topLeft,
            child: isSelected
                ? Icon(
                    Icons.check_circle,
                    color: XedColors.waterMelon,
                    size: 20,
                  )
                : SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildToolBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          BlocBuilder<MyDeckBloc, DeckListState>(
            cubit: deckBloc,
            builder: (context, state) {
              return InkWell(
                onTap: (!isDeleting)
                    ? () => _onSelectAllToggleTaped(state.records)
                    : null,
                child: Row(
                  children: <Widget>[
                    Icon(
                      deckBloc.isAllSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                    ),
                    SizedBox(width: 5.0),
                    Text('Select all'),
                  ],
                ),
              );
            },
          ),
          Container(
            height: 44.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: XedColors.duckEggBlue,
            ),
            child: FlatButton(
              child: Text(
                'Delete',
                style: SemiBoldTextStyle(16.0).copyWith(
                  color: deckBloc.hasSelected
                      ? XedColors.black
                      : XedColors.black50,
                ),
              ),
              onPressed: (deckBloc.hasSelected && !isDeleting)
                  ? () => XError.f0(() => _onDeleteTap(context))
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDecks() {
    var selectedDecks = deckBloc.selectedDecks;
    return deckBloc.hasSelected
        ? Padding(
            padding: EdgeInsets.only(top: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: hp(60.0),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: selectedDecks.length,
                itemBuilder: (BuildContext context, int index) {
                  core.Deck deck = selectedDecks[index];
                  return InkWell(
                    child: deck.hasThumbnail
                        ? Container(
                            width: wp(44.0),
                            height: hp(58.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(deck.thumbnail),
                              ),
                            ))
                        : Container(
                            width: wp(44.0),
                            height: hp(58.0),
                            child: DeckThumbnailDefaultWiget(
                              heightIcon: 30,
                              boxDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: XedColors.duckEggBlue,
                              ),
                            ),
                          ),
                    onTap: () => XError.f0(() {
                      deckBloc.add(SelectDeck(deck.id));
                    }),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(width: 3.0);
                },
              ),
            ),
          )
        : SizedBox();
  }

  void _onDeleteTap(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext _) {
        return SafeArea(
          child: Container(
            height: hp(302),
            padding: EdgeInsets.only(
              top: hp(38),
              left: wp(15),
              right: wp(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Are you sure?',
                  style: BoldTextStyle(22.0),
                ),
                Spacer(),
                Text(
                  core.Config.getString("msg_delete_decks_warning"),
                  style: SemiBoldTextStyle(14.0).copyWith(height: 1.4),
                ),
                Spacer(),
                _CustomButton(
                  child: Text(
                    'Delete',
                    style: BoldTextStyle(18.0),
                  ),
                  backgroundColor: XedColors.duckEggBlue,
                  onTap: () => _onConfirmDeleteTapped(context),
                ),
                SizedBox(height: hp(8)),
                _CustomButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'HarmoniaSansProCyr',
                      fontWeight: FontWeight.w700,
                      fontSize: 18.0,
                      color: Color.fromARGB(255, 253, 253, 253),
                    ),
                  ),
                  backgroundColor: XedColors.waterMelon,
                  onTap: () => closeUntil(MyDeckManager.name, context: context),
                ),
                SizedBox(height: hp(10)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onDeckTap(core.Deck deck) {
    deckBloc.add(SelectDeck(deck.id));
  }

  void _onSelectAllToggleTaped(List<core.Deck> decks) {
    if (deckBloc.isAllSelected) {
      deckBloc.add(DeSelectAllDeck());
    } else {
      deckBloc.add(SelectAllDeck());
    }
  }

  void _onConfirmDeleteTapped(BuildContext context) async {
    try {
      setState(() {
        isDeleting = true;
      });

      final deckIds = deckBloc.selectedDeckMap.keys.toList();
      if (deckIds.isNotEmpty) {
        core.DeckService deckService = DI.get(core.DeckService);
        final deletedDeckIds = await deckService.deleteDecks(deckIds);

        deckBloc.add(RemoveDeck(Set.from(deletedDeckIds)));

        BlocProvider.of<MyDeckBloc>(context)
            .add(RemoveDeck(Set.from(deletedDeckIds)));
        BlocProvider.of<GlobalDeckBloc>(context)
            .add(RemoveDeck(Set.from(deletedDeckIds)));
        BlocProvider.of<FavoriteDeckBloc>(context)
            .add(RemoveDeck(Set.from(deletedDeckIds)));
      }
    } catch (e) {
      showErrorSnakeBar(core.Config.getString("msg_cant_delete_decks"),
          context: context);
    } finally {
      setState(() {
        isDeleting = false;
        closeUntil(MyDeckManager.name, context: context);
      });
    }
  }
}

class _CustomButton extends StatelessWidget {
  final Text child;
  final VoidCallback onTap;
  final Color backgroundColor;

  const _CustomButton({Key key, this.onTap, this.backgroundColor, this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final height55 = 55 / 667 * height;

    return Container(
      height: height55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: backgroundColor,
      ),
      child: InkWell(
        onTap: onTap != null ? () => XError.f0(onTap) : null,
        child: Center(child: child),
      ),
    );
  }
}
