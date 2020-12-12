import 'package:ddi/di.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/resources.dart';
import 'package:the_flashcard/common/xwidgets/x_state.dart';
import 'package:the_flashcard/deck_screen/deck_edit_screen.dart';
import 'package:the_flashcard/deck_screen/favorite_deck.dart';
import 'package:the_flashcard/deck_screen/global_deck.dart';
import 'package:the_flashcard/deck_screen/my_deck.dart';
import 'package:the_flashcard/deck_screen/search_deck_screen.dart';
import 'package:the_flashcard/environment/driver_key.dart';

class DeckScreen extends StatefulWidget {
  static String name = '/deck';

  @override
  _DeckScreenState createState() => _DeckScreenState();
}

class _DeckScreenState extends XState<DeckScreen> {
  TabController tabController;
  TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
  }

  Widget headerBar(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Deck',
                style: BoldTextStyle(28).copyWith(
                  height: 1.4,
                  fontSize: 28.0,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(25, 43, 43, 43),
                      offset: Offset(1.0, 1.0),
                      blurRadius: 5.0,
                    ),
                  ],
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                alignment: Alignment.center,
                child: XIconButton(
                  icon: Icon(Icons.search, size: 24, color: XedColors.black),
                  onPressed: () => XError.f0(() {
                    navigateToScreen(
                      screen: SearchDeckScreen(),
                      name: SearchDeckScreen.name,
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.0),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(25, 43, 43, 43),
                offset: Offset(1.0, 1.0),
                blurRadius: 5.0,
              ),
            ],
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          alignment: Alignment.center,
          child: XIconButton(
            icon: Icon(Icons.add, size: 24, color: XedColors.black),
            onPressed: () => _onAddDeckPressed(context),
            testDriverKey: Key(DriverKey.CREATE_DECK),
            globalKey: GlobalKeys.globalDeckIconAdd,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: 3, child: _buildMainScreen());
  }

  Widget _buildMainScreen() {
    final w15 = wp(15);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(112.0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          centerTitle: false,
          titleSpacing: w15,
          automaticallyImplyLeading: false,
          title: PreferredSize(
            preferredSize: Size.fromHeight(86.0),
            child: Builder(builder: (context) => headerBar(context)),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(26.0),
            child: TabBar(
              isScrollable: true,
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
                Tab(text: 'Global Deck'),
                Tab(
                  text: 'My Deck',
                  key: Key(DriverKey.TAB_MY_DECK),
                ),
                Tab(text: 'Favorite Deck'),
              ],
            ),
          ),
        ),
      ),
      body: NotificationListener(
        child: TabBarView(
          children: [
            GlobalDeck(),
            MyDeck(),
            FavoriteDeck(),
          ],
        ),
      ),
    );
  }

  void _onAddDeckPressed(context) async {
    try {
      final core.AuthService authService = DI.get(core.AuthService);
      var hasPerms = await authService.hasDeckCreationPermission();
      if (hasPerms) {
        navigateToScreen(
          screen: DeckEditScreen.create(),
          name: DeckEditScreen.name,
        );
      } else {
        showErrorSnakeBar(
            core.Config.getString("msg_no_permission_create_deck"),
            context: context);
      }
    } catch (ex) {
      core.Log.error(
          "$runtimeType._onAddDeckPressed error when click new deck $ex");
      showErrorSnakeBar(
        core.Config.getString("msg_no_permission_create_deck"),
        context: context,
      );
    }
  }
}
