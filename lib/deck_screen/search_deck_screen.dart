import 'package:ddi/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/resources.dart';
import 'package:the_flashcard/common/widgets/x_view_mode_chooser.dart';
import 'package:the_flashcard/common/xwidgets/x_state.dart';
import 'package:the_flashcard/deck_screen/deck_detail_screen.dart';
import 'package:the_flashcard/deck_screen/deck_edit_screen.dart';
import 'package:the_flashcard/deck_screen/deck_item_widget.dart';
import 'package:the_flashcard/deck_screen/deck_list_bloc.dart';
import 'package:the_flashcard/deck_screen/deck_list_event.dart';

class SearchDeckScreen extends StatefulWidget {
  static const String name = "/search_deck_screen";

  @override
  _SearchDeckScreenState createState() => _SearchDeckScreenState();
}

class _SearchDeckScreenState extends XState<SearchDeckScreen> {
  ScrollController _scrollController;
  RefreshController refreshController;
  TextEditingController _textController;
  DeckListBloc deckListBloc;

  @override
  void initState() {
    super.initState();
    deckListBloc = BlocProvider.of<SearchDeckBloc>(context);
    _scrollController = ScrollController();
    refreshController = RefreshController();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    refreshController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        titleSpacing: wp(10),
        elevation: 0,
        title: _buildQueryText(context),
        actions: <Widget>[_cancelButton()],
      ),
      body: _buildListDeck(),
    );
  }

  Widget _buildQueryText(context) {
    return SizedBox(
      height: hp(36),
      child: TextField(
        autofocus: true,
        autocorrect: false,
        onSubmitted: (value) => _searchDecks(value),
        onChanged: (value) {
          setState(() {});
        },
        controller: _textController,
        textAlign: TextAlign.justify,
        decoration: _inputDecoration(context),
        cursorColor: XedColors.waterMelon,
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context) {
    OutlineInputBorder _outlineInputBorder() {
      return OutlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent),
        borderRadius: BorderRadius.circular(hp(18)),
      );
    }

    return InputDecoration(
      contentPadding: EdgeInsets.fromLTRB(wp(15), hp(10), wp(15), hp(7)),
      suffixIcon: Opacity(
        opacity: _textController.text.isNotEmpty ? 1.0 : 0.2,
        child: IconButton(
          alignment: Alignment.center,
          icon: Container(
            height: 24,
            width: 24,
            alignment: Alignment.center,
            child: Center(
              child: Icon(Icons.close, color: XedColors.duckEggBlue, size: 14),
            ),
            decoration: BoxDecoration(
              color: XedColors.brownGrey,
              shape: BoxShape.circle,
            ),
          ),
          onPressed: () => XError.f0(_onResetPressed),
        ),
      ),
      hintStyle: RegularTextStyle(18),
      filled: true,
      fillColor: XedColors.duckEggBlue,
      enabledBorder: _outlineInputBorder(),
      focusedBorder: _outlineInputBorder(),
      border: _outlineInputBorder(),
      errorBorder: _outlineInputBorder(),
    );
  }

  Widget _cancelButton() {
    return GestureDetector(
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: wp(10), right: wp(15)),
        child: Text('Cancel', style: SemiBoldTextStyle(14)),
      ),
      onTap: () => XError.f0(_onCancelPressed),
    );
  }

  Widget _buildListDeck() {
    return BlocConsumer<DeckListBloc, DeckListState>(
      bloc: deckListBloc,
      listener: (BuildContext context, DeckListState state) {
        if (state is! DeckListLoading) _finishRefresh();
      },
      builder: (context, state) {
        var decks = state.records;
        return SmartRefresher(
          controller: refreshController,
          enablePullDown: !(state is DeckListLoading),
          enablePullUp: state.canLoadMore,
          onRefresh: () {
            if (!(state is DeckListLoading)) {
              deckListBloc.add(Refresh());
            } else {
              refreshController.refreshCompleted();
            }
          },
          onLoading: () {
            if (!(state is DeckListLoading)) {
              deckListBloc.add(LoadMore());
            } else {
              refreshController.loadComplete();
            }
          },
          child: GridView.builder(
            padding: EdgeInsets.only(
              left: wp(15),
              right: wp(15),
              bottom: hp(10),
            ),
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisSpacing: wp(15),
              crossAxisSpacing: wp(10),
              childAspectRatio: ViewMode.list().gridAspectRatio,
              crossAxisCount: ViewMode.list().gridColumn,
            ),
            controller: _scrollController,
            itemCount: decks.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              var deck = decks[index];

              return InkWell(
                onTap: () => _handleDeckTapped(deck),
                child: DeckListItemWidget(
                  deck,
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _finishRefresh() {
    if (mounted) {
      if (refreshController.headerStatus == RefreshStatus.refreshing) {
        refreshController.refreshCompleted();
      }
      if (refreshController.footerStatus == LoadStatus.loading)
        refreshController.loadComplete();
    }
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

  void _onResetPressed() {
    _textController.text = '';
    _searchDecks(_textController.text);
  }

  void _onCancelPressed() {
    _textController.text = '';
    _searchDecks(_textController.text);
    closeScreen(SearchDeckScreen.name);
  }

  void _searchDecks(String text) {
    deckListBloc.add(QueryChanged(query: text));
    _scrollToTheFirstDeck();
  }

  void _scrollToTheFirstDeck() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _scrollController.animateTo(
          0,
          duration: Duration(milliseconds: 350),
          curve: Curves.easeInCubic,
        );
      } catch (ex) {}
    });
  }
}
