import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/dimens.dart';
import 'package:the_flashcard/common/widgets/x_view_mode_chooser.dart';
import 'package:the_flashcard/deck_screen/deck_item_widget.dart';

enum DeckIn {
  Global,
  MyDeck,
  Favorite,
  Search,
}

class DeckListWidget extends StatelessWidget {
  final ScrollController controller;
  final ViewMode viewMode;
  final List<core.Deck> decks;
  final Function(core.Deck) onTap;
  final bool isSearchMode;
  final DeckIn deckIn;

  DeckListWidget(
      {@required this.controller,
      @required this.viewMode,
      @required this.decks,
      @required this.deckIn,
      this.onTap,
      this.isSearchMode = false});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.only(
        left: wp(15),
        right: wp(15),
        bottom: hp(10),
      ),
      shrinkWrap: true,
      physics: isSearchMode
          ? ClampingScrollPhysics()
          : NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: wp(15),
        crossAxisSpacing: wp(10),
        childAspectRatio: viewMode.gridAspectRatio,
        crossAxisCount: viewMode.gridColumn,
      ),
      controller: controller,
      itemCount: decks.length,
      scrollDirection: viewMode.horizontal ? Axis.horizontal : Axis.vertical,
      itemBuilder: (context, index) {
        final key = deckIn == DeckIn.Global && index == 0
            ? GlobalKeys.globalDeckIconDeck
            : null;
        var deck = decks[index];

        return InkWell(
          onTap: () => _onDeckTap(context, deck),
          child: viewMode.gridColumn == 1
              ? DeckListItemWidget(
                  deck,
                  key: key,
                )
              : DeckItemWidget(deck),
        );
      },
    );
  }

  void _onDeckTap(BuildContext context, core.Deck deck) {
    if (onTap != null) onTap(deck);
  }
}
