import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/deck_creation/multi_choice/answer_option_widget.dart';
import 'package:the_flashcard/deck_creation/multi_choice/bloc/multi_choice_bloc.dart';
import 'package:the_flashcard/deck_creation/multi_choice/button_more_option_widget.dart';
import 'package:the_flashcard/environment/driver_key.dart';

class AnswerListWidget extends StatefulWidget {
  AnswerListWidget({Key key}) : super(key: key);

  @override
  _AnswerListWidgetState createState() => _AnswerListWidgetState();
}

class _AnswerListWidgetState extends State<AnswerListWidget> {
  final List<AnswerOptionWidget> answers = [];
  MCStepOneBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<MCStepOneBloc>(context);
    bloc.answers.forEach((item) => _addAnswerComponent(item));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MCStepOneBloc, MCState>(
      cubit: bloc,
      listener: (_, state) {
        if (state is AddAnswerOption) {
          _addAnswerComponent(state.component);
          setState(() {});
        } else if (state is DeleteAnswerOption) {
          _deleteComponent(state.component);
          setState(() {});
        }
      },
      child: ListView.separated(
        key: Key(DriverKey.COMP_ANSWER),
        itemCount: answers.length + 1,
        itemBuilder: (_, int index) {
          return index < answers.length ? answers[index] : _buildButtonAdd();
        },
        separatorBuilder: (_, int index) {
          return SizedBox(height: index < answers.length - 1 ? 8 : 20);
        },
      ),
    );
  }

  void _addAnswerComponent(core.Answer component) {
    answers.add(
      AnswerOptionWidget(
        answer: component,
        key: UniqueKey(),
      ),
    );
  }

  Widget _buildButtonAdd() {
    return Flex(
      direction: Axis.vertical,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: ButtonMoreOptionWidget(),
        ),
        SizedBox(height: 50),
      ],
    );
  }

  void _deleteComponent(AnswerOptionWidget component) {
    this.answers.remove(component);
  }
}
