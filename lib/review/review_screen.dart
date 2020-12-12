import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/xwidgets/x_state.dart';
import 'package:the_flashcard/environment/driver_key.dart';
import 'package:the_flashcard/review/done_review_screen.dart';
import 'package:the_flashcard/review/due_review_screen.dart';
import 'package:the_flashcard/review/learning_review_screen.dart';
import 'package:the_flashcard/review/review_list_bloc.dart';

class ReviewScreen extends StatefulWidget {
  static String name = '/review';

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends XState<ReviewScreen>
    with TickerProviderStateMixin {
  DueReviewBloc dueBloc;

  @override
  void initState() {
    super.initState();
    dueBloc = BlocProvider.of<DueReviewBloc>(context);
  }

  Widget header() {
    return Text(
      'Review',
      style: BoldTextStyle(28),
    );
  }

  @override
  Widget build(BuildContext context) {
    Dimens.context = context;

    return DefaultTabController(
      length: 3,
      child: _buildReviewScreen(),
    );
  }

  Widget _buildReviewScreen() {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(112.0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          centerTitle: false,
          titleSpacing: wp(15),
          automaticallyImplyLeading: false,
          title: PreferredSize(
            preferredSize: Size.fromHeight(hp(86.0)),
            child: header(),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(hp(26.0)),
            child: TabBar(
              isScrollable: false,
              indicatorColor: XedColors.waterMelon,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 3.0,
              labelColor: XedColors.black,
              labelStyle: TextStyle(
                fontFamily: 'HarmoniaSansProCyr',
                fontWeight: FontWeight.w600,
                fontSize: 18.0,
              ),
              unselectedLabelColor: XedColors.battleShipGrey,
              unselectedLabelStyle: TextStyle(
                fontFamily: 'HarmoniaSansProCyr',
                fontWeight: FontWeight.w400,
                fontSize: 18.0,
              ),
              tabs: [
                Tab(
                  text: 'Due Day',
                  key: Key(DriverKey.DUE_DAY),
                ),
                Tab(
                  text: 'Learning',
                  key: Key(DriverKey.LEARNING),
                ),
                Tab(
                  text: 'Done',
                  key: Key(DriverKey.DONE),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        children: [
          DueReviewScreen(),
          LearningReviewScreen(),
          DoneReviewScreen(),
        ],
      ),
    );
  }
}
