import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/xed_progress.dart';
import 'package:the_flashcard/common/widgets/share_feedback_bottom_sheet_widget.dart';
import 'package:the_flashcard/common/xwidgets/x_card_side_widget.dart';
import 'package:the_flashcard/deck_creation/multi_choice/multi_choice.dart';
import 'package:the_flashcard/deck_screen/card_list_bloc.dart';
import 'package:the_flashcard/environment/constants.dart';
import 'package:the_flashcard/xerror.dart';

class MultiCardDetailScreen extends StatefulWidget {
  final core.Deck deck;

  MultiCardDetailScreen(this.deck);

  @override
  _MultiCardDetailScreenState createState() =>
      _MultiCardDetailScreenState(this.deck);
}

class _MultiCardDetailScreenState extends State<MultiCardDetailScreen> {
  FlipController listener = FlipController(isFront: true);

  final SwiperController controller = SwiperController();
  final core.Deck deck;
  int currentCardIndex = 0;
  final List<core.Card> cardList = [];
  CardListBloc cardListBloc;
  double btnPreCardOpacity = 0.2;
  double btnNextCardOpacity = 1.0;

  _MultiCardDetailScreenState(this.deck);

  @override
  void initState() {
    super.initState();
    cardListBloc = CardListBloc();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    double heightButton = 0.11 * screen.height;
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      resizeToAvoidBottomInset: true,
      backgroundColor: Color.fromARGB(255, 250, 250, 250),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 250, 250, 250),
        leading: InkWell(
          child: Icon(
            Icons.arrow_back,
            size: 30,
            color: Color.fromARGB(255, 43, 43, 43),
          ),
          onTap: () => XError.f0(() {
            Navigator.of(context).pop();
          }),
        ),
        title: Text(
          widget.deck.name ?? "[Untitled deck]",
          style: textStyleTitle,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              OMIcons.reportProblem,
              color: Colors.grey,
            ),
            onPressed: () => XError.f0(() {
              showModalBottomSheet(
                backgroundColor: XedColors.transparent,
                context: context,
                builder: (context) => ShareFeedbackBottomSheetWidget(),
              );
            }),
          )
        ],
      ),
      body: BlocConsumer<CardListBloc, CardListState>(
        listener: _onCardListChanged,
        bloc: cardListBloc,
        builder: (context, state) {
          if (state.isCardLoaded) {
            final cardDesign = state.getCard(currentCardIndex).design;
            final count = cardDesign.getFrontCount();
            return Swiper(
              itemCount: count,
              controller: controller,
              loop: false,
              itemBuilder: (_, int i) {
                return XFlipperWidget(
                  front: XCardSideWidget(
                    key: UniqueKey(),
                    mode: XComponentMode.Review,
                    title: "#Question ${i + 1}",
                    cardContainer: cardDesign.getFront(i),
                  ),
                  back: XCardSideWidget(
                    key: UniqueKey(),
                    mode: XComponentMode.Review,
                    cardContainer: cardDesign.back,
                    title: "#Answer",
                  ),
                  flipController: listener,
                );
              },
              viewportFraction: 0.805,
              scale: 0.9,
            );
          } else {
            cardListBloc.add(LoadCardList(deck.cardIds));
            return Center(child: XedProgress.indicator());
          }
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(bottom: 2),
          height: heightButton,
          child: Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              GestureDetector(
                child: Opacity(
                  child: Text('Prev Card', style: textStyleBottomCard),
                  opacity: btnPreCardOpacity,
                ),
                onTap: () => XError.f0(_onPrevCardPressed),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(heightButton),
                child: Container(
                  height: heightButton,
                  width: heightButton,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(heightButton),
                    color: Color.fromARGB(255, 253, 68, 104),
                  ),
                  child: IconButton(
                    icon: SvgPicture.asset(
                      Assets.icFlip,
                      width: hp(45),
                      height: hp(45),
                      color: XedColors.whiteTextColor,
                    ),
                    onPressed: () => XError.f0(() {
                      listener.flip();
                    }),
                  ),
                ),
                onTap: () => XError.f0(() => listener.flip()),
              ),
              GestureDetector(
                child: Opacity(
                  child: Text('Next Card', style: textStyleBottomCard),
                  opacity: btnNextCardOpacity,
                ),
                onTap: () => XError.f0(_onNextCardPressed),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onPrevCardPressed() {
    if (currentCardIndex > 0) {
      final int totalCard = cardListBloc.state.cardIds.length;
      currentCardIndex -= 1;
      btnNextCardOpacity = _getBtnNextCardOpacity(currentCardIndex, totalCard);
      btnPreCardOpacity = _getBtnPreCardOpacity(currentCardIndex);
      setState(() {});
    }
  }

  void _onNextCardPressed() {
    final int totalCard = cardListBloc.state.cardIds.length;
    if (currentCardIndex < totalCard - 1) {
      currentCardIndex += 1;
      btnNextCardOpacity = _getBtnNextCardOpacity(currentCardIndex, totalCard);
      btnPreCardOpacity = _getBtnPreCardOpacity(currentCardIndex);
      setState(() {});
    }
  }

  double _getBtnNextCardOpacity(int currentCardIndex, int totalCard) {
    return currentCardIndex == totalCard - 1 ? 0.2 : 1.0;
  }

  double _getBtnPreCardOpacity(int currentCardIndex) {
    return currentCardIndex == 0 ? 0.2 : 1.0;
  }

  void _onCardListChanged(BuildContext context, CardListState state) {
    if (state.isCardLoaded) {
      final int totalCard = state.cardIds.length;
      btnNextCardOpacity = _getBtnNextCardOpacity(currentCardIndex, totalCard);
      btnPreCardOpacity = _getBtnPreCardOpacity(currentCardIndex);
      setState(() {});
    }
  }
}
