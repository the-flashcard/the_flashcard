import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/xed_progress.dart';
import 'package:the_flashcard/common/xwidgets/x_card_thumbnail_widget.dart';
import 'package:the_flashcard/deck_creation/multi_choice/bloc/multi_choice_bloc.dart';
import 'package:the_flashcard/deck_screen/card_list_bloc.dart';
import 'package:the_flashcard/deck_screen/deck_bloc.dart';

class SelectCardManager extends StatefulWidget {
  final DeckBloc bloc;

  const SelectCardManager({Key key, this.bloc}) : super(key: key);

  @override
  _SelectCardManagerState createState() => _SelectCardManagerState();
}

class _SelectCardManagerState extends State<SelectCardManager> {
  List<bool> isSelectCards = [];
  List<int> selectedCards = [];
  bool _isSelectAll;
  core.Deck deck;
  bool isDelete = false;

  @override
  void initState() {
    super.initState();
    deck = widget.bloc.state.deck;
    _isSelectAll = selectedCards.length == deck.cardIds.length;
    isSelectCards = List<bool>.generate(deck.cardIds.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeckBloc, DeckState>(
      bloc: widget.bloc,
      builder: (_, state) {
        if (isDelete && !state.isLoading) {
          deck = state.deck;
          isDelete = false;
          selectedCards.clear();
          _isSelectAll = false;

          isSelectCards = List<bool>.generate(
            deck.cardIds.length,
            (index) => false,
          );
        }

        return Stack(
          children: <Widget>[
            state.isLoading
                ? Center(child: XedProgress.indicator())
                : SizedBox(),
            _buildScafold(),
          ],
        );
      },
    );
  }

  Widget _toolBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          InkWell(
            onTap: () => XError.f0(() {
              if (!_isSelectAll) {
                for (int i = 0; i < deck.cardIds.length; i++) {
                  if (!isSelectCards[i]) {
                    isSelectCards[i] = true;
                    selectedCards.add(i);
                  }
                }
                setState(() {
                  _isSelectAll = true;
                });
              } else {
                selectedCards.clear();
                isSelectCards =
                    List<bool>.generate(deck.cardIds.length, (index) => false);
                setState(() {
                  _isSelectAll = false;
                });
              }
            }),
            child: Row(
              children: <Widget>[
                Icon(
                  _isSelectAll
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                SizedBox(width: 5.0),
                Text('Select all'),
              ],
            ),
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
                  color: selectedCards.isNotEmpty
                      ? XedColors.black
                      : XedColors.black50,
                ),
              ),
              onPressed: selectedCards.isNotEmpty
                  ? () => XError.f0(_openDeleteModelSheet)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardBar(CardListState state) {
    return state.isCardLoaded
        ? Padding(
            padding: EdgeInsets.only(top: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: selectedCards.isNotEmpty ? 60.0 : 0,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: selectedCards.length,
                itemBuilder: (BuildContext context, int index) {
                  int i = selectedCards[index];
                  core.Card card = state.getCard(i);
                  return InkWell(
                    child: SizedBox(
                      width: wp(44.0),
                      height: hp(58.0),
                      child: XCardThumbnailWidget(
                        card: card,
                        radius: 10,
                        sizeIcon: 30,
                      ),
                    ),
                    onTap: () => XError.f0(
                      () {
                        selectedCards.removeAt(index);
                        isSelectCards[i] = false;
                        setState(() {});
                      },
                    ),
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

  Widget _buildScafold() {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.4,
        title: Text(
          'Select Cards',
          style: BoldTextStyle(18),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () => XError.f0(() {
            Navigator.of(context).pop();
          }),
        ),
        backgroundColor: XedColors.white,
      ),
      body: BlocBuilder<CardListBloc, CardListState>(
        bloc: widget.bloc.cardListBloc,
        builder: (_, state) => Container(
          color: XedColors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: wp(15)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _cardBar(state),
                _toolBar(),
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: state.isCardLoaded ? null : 0,
                    child: GridView.builder(
                      shrinkWrap: true,
                      primary: true,
                      itemCount: state.isCardLoaded ? deck.cardIds.length : 0,
                      itemBuilder: (_, index) {
                        core.Card card = state.getCard(index);
                        return InkWell(
                          onTap: () => XError.f0(() {
                            setState(() {
                              if (isSelectCards[index]) {
                                selectedCards.remove(index);
                              } else {
                                selectedCards.add(index);
                              }
                              isSelectCards[index] = !isSelectCards[index];
                            });
                          }),
                          child: Container(
                            height: hp(109),
                            width: wp(77),
                            child: Stack(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                    left: wp(5),
                                    top: hp(5),
                                  ),
                                  child: XCardThumbnailWidget(
                                    card: card,
                                    radius: 8,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: isSelectCards[index]
                                      ? Icon(
                                          Icons.check_circle,
                                          color: XedColors.waterMelon,
                                          size: 20,
                                        )
                                      : SizedBox(),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: wp(10),
                        mainAxisSpacing: wp(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openDeleteModelSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
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
                  core.Config.getString("msg_delete_cards_warning"),
                  style: SemiBoldTextStyle(14.0).copyWith(height: 1.4),
                ),
                Spacer(),
                _CustomButton(
                  child: Text(
                    'Delete',
                    style: BoldTextStyle(18.0),
                  ),
                  backgroundColor: XedColors.duckEggBlue,
                  onTap: () => XError.f0(() {
                    isDelete = true;
                    widget.bloc?.add(
                      DeleteCard(
                        cardIds: selectedCards
                            .map((item) => deck.cardIds[item])
                            .toList(),
                        deckId: deck.id,
                      ),
                    );
                    Navigator.of(context).pop();
                  }),
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
                  onTap: () => XError.f0(() => Navigator.pop(context)),
                ),
                SizedBox(height: hp(10)),
              ],
            ),
          ),
        );
      },
    );
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
