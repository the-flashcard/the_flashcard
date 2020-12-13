import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/xwidgets/x_card_side_widget.dart';
import 'package:the_flashcard/deck_creation/multi_choice/multi_choice.dart';

class MultiCreationPreviewScreen extends StatefulWidget {
  static String name = '/deckMultiCreation3';

  @override
  _MultiCreationPreviewScreenState createState() =>
      _MultiCreationPreviewScreenState();
}

class _MultiCreationPreviewScreenState
    extends State<MultiCreationPreviewScreen> {
  final MCPreviewBloc bloc = MCPreviewBloc();

  @override
  Widget build(BuildContext context) {
    core.MultiChoice model = ModalRoute.of(context).settings.arguments;
    final double spacer = hp(44);
    final core.Container container = core.Container()..components.add(model);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: BlocListener(
          cubit: bloc,
          listener: (_, state) {
            if (state is CompletedState) {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop(model);
            }
            if (state is RequestionPreviousScreen) Navigator.of(context).pop();
          },
          child: Stack(
            children: [
              AppbarStepThree(text: 'Completed'),
              Container(
                margin: EdgeInsets.fromLTRB(18, hp(55), 18, hp(70)),
                child: Center(
                  child: XFlipperWidget(
                    back: SizedBox(),
                    front: XCardSideWidget(
                      cardContainer: container,
                      mode: XComponentMode.Review,
                      title: 'Question',
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  color: XedColors.waterMelon,
                  height: spacer,
                  width: double.infinity,
                  child: BottomActionBarWidget(
                    right: 'Done',
                    next: true,
                    left: 'Previous',
                    onTapLeft: _previous,
                    onTapRight: () => _complete(model),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _previous() {
    bloc.add(RequestionPreviousEvent());
  }

  void _complete(core.MultiChoice model) {
    bloc.add(CompleteEvent(model));
  }
}
