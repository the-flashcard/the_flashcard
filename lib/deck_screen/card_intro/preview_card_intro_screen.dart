import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/xwidgets/x_image_component.dart';
import 'package:the_flashcard/deck_screen/card_intro/icon_back.dart';
import 'package:the_flashcard/deck_screen/card_list_bloc.dart';

class PreviewCardIntroScreen extends StatelessWidget {
  static const name = '/PreviewCardIntroScreen';
  final core.Deck deck;
  final CardListBloc bloc;
  final void Function(BuildContext, CardListState) onLearnPress;

  PreviewCardIntroScreen({
    Key key,
    @required this.deck,
    this.bloc,
    this.onLearnPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: XedColors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconBack(
          onTap: () => _backPressed(context),
        ),
      ),
      body: SafeArea(
        child: _buildCard(
          container: deck.design,
          title: '#INTRODUCTION',
          context: context,
        ),
      ),
    );
  }

  Widget _buildCard({
    @required core.Container container,
    @required String title,
    BuildContext context,
  }) {
    final components = container?.components ?? const <core.Component>[];
    double marginHorizontal = 20;
    double marginTop = hp(25);
    double width = wp(355);
    double height = hp(504);
    double width27 = wp(125);
    double partPaddingTop = marginTop / 2;

    var margin = EdgeInsets.only(
      left: marginHorizontal,
      top: marginTop,
      right: marginHorizontal,
    );
    EdgeInsets margin2 = margin.copyWith(
      left: width27 - wp(5),
      top: margin.top / 2 - 1.2,
    );
    return Stack(
      children: [
        Container(
          height: hp(30),
          width: width27,
          margin: margin2,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.1),
                spreadRadius: 0,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
        ),
        SizedBox(
          height: double.infinity,
          child: Container(
            margin: margin,
            height: height,
            width: width,
            alignment: container?.toAlignment(),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: XedColors.white,
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.1),
                  spreadRadius: 0,
                  blurRadius: 20,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(10, partPaddingTop + hp(5), 10, 10),
              child: SingleChildScrollView(
                child: Flex(
                  direction: Axis.vertical,
                  mainAxisSize: MainAxisSize.min,
                  children: _buildListWidget(context, components),
                ),
              ),
            ),
          ),
        ),
        Container(
          height: hp(30),
          width: width27,
          margin: margin2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: XedColors.white,
          ),
          child: Center(
            child: AutoSizeText(
              title ?? '',
              textAlign: TextAlign.justify,
              style: BoldTextStyle(12).copyWith(
                letterSpacing: 0.43,
                color: XedColors.brownGrey,
              ),
              maxLines: 1,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildListWidget(
    BuildContext context,
    List<core.Component> components,
  ) {
    int len = components.length;
    final widgets = <Widget>[];
    for (var i = 0; i < len; ++i) {
      widgets.add(_buildWidget(i, components[i]));
    }
    widgets.add(
      Container(
        constraints: BoxConstraints(
          maxHeight: hp(125),
        ),
        alignment: Alignment.center,
        child: SizedBox(
          height: 60,
          width: wp(175),
          child: BlocBuilder<CardListBloc, CardListState>(
            bloc: bloc,
            builder: (context, state) {
              bool enableButton = state.isCardLoaded &&
                  state.hasCards() &&
                  state.hasNotInReviewCards();
              return FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: XedColors.waterMelon.withOpacity(
                  enableButton ? 1.0 : 0.2,
                ),
                child: Text(
                  "Learn deck",
                  style: BoldTextStyle(14).copyWith(color: XedColors.white255),
                ),
                onPressed: () {
                  if (enableButton)
                    XError.f0(() => _learnDeckPressed(context, state));
                },
              );
            },
          ),
        ),
      ),
    );
    return widgets;
  }

  Widget _buildWidget(int index, core.Component component) {
    return _componentWidget(index, component);
  }

  Widget _componentWidget(int index, core.Component component) {
    switch (component.runtimeType) {
      case core.Text:
        return XTextWidget(componentData: component, index: index);
      case core.Image:
        return XImageComponent(componentData: component, index: index);
      case core.Video:
        return XVideoPlayerWidget(component, index);

      case core.Dictionary:
        return XDictionaryWidget(component, index);
      default:
        return SizedBox();
    }
  }

  void _backPressed(BuildContext context) {
    Navigator.pop(context);
  }

  void _learnDeckPressed(BuildContext context, CardListState cardListState) {
    if (this.onLearnPress != null) this.onLearnPress(context, cardListState);
  }
}
