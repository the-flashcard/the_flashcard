import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';

class DeckCreationDashboard extends StatefulWidget {
  static final name = "/deckCreationDashboard";

  @override
  _DeckCreationDashboardState createState() => _DeckCreationDashboardState();
}

class _DeckCreationDashboardState extends State<DeckCreationDashboard> {
  final int _cardQuantity = 0;

  @override
  Widget build(BuildContext context) {
    Dimens.context = context;
    AppBar appbar = _appBar();
    double appbarHeight = appbar.preferredSize.height;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                stops: [0.0, 1.0],
                colors: [
                  Color.fromARGB(255, 255, 123, 150),
                  XedColors.waterMelon,
                ],
              ),
            ),
            height: hp(150),
            width: double.infinity,
          ),
          appbar,
          Container(
            margin: EdgeInsets.only(top: hp(50 + appbarHeight)),
            alignment: Alignment.topCenter,
            child: SvgPicture.asset(
              Assets.bgCloud,
              width: wp(375),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: hp(121 + appbarHeight)),
            height: double.infinity,
            color: Colors.white,
          ),
          Container(
            margin: EdgeInsets.only(top: hp(85 + appbarHeight), left: wp(15)),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _deckOverall(),
                  SizedBox(height: hp(40)),
                  Text(
                    '$_cardQuantity Cards',
                    style: ColorTextStyle(
                        fontSize: 14,
                        color: XedColors.battleShipGrey,
                        fontWeight: FontWeight.normal),
                  ),
                  _createCardWidget()
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _createCardWidget() {
    return Padding(
        padding: EdgeInsets.only(top: hp(20)),
        child: InkWell(
            onTap: () => XError.f0(
                  () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return SingleChoiceDialog(
                              title:
                                  core.Config.getString("msg_choose_deck_type"),
                              options: ['Manual', 'Auto generate'],
                              onPressed: (value) {},
                              decisionContent: 'Create');
                        }).catchError(
                      (ex) => core.Log.error(ex),
                    );
                  },
                ),
            child: Image.asset(
              Assets.imgAddCardBg,
              height: hp(144),
              width: wp(108),
              fit: BoxFit.fill,
            )));
  }

  Widget _deckOverall() {
    return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          _avatarWidget(),
          _deckDescription(),
          _deckIntroduction()
        ]);
  }

  Widget _deckDescription() {
    return Expanded(
      child: Container(
        height: hp(143),
        width: wp(107),
        padding: EdgeInsets.only(left: wp(15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Title Deck',
              style: BoldTextStyle(16),
            ),
            Padding(
              padding: EdgeInsets.only(top: hp(20)),
              child: Text(
                'TP.HCM sẽ họp báo về những sai phạm ở Thủ Thiêm trong tuần tới',
                style: ColorTextStyle(
                  fontSize: 14,
                  color: XedColors.battleShipGrey,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deckIntroduction() {
    return Padding(
        padding: EdgeInsets.only(left: wp(15)),
        child: InkWell(
            onTap: () {},
            child: Image.asset(
              Assets.imgDeckIntroduction,
              height: hp(45.8),
              width: wp(36),
              fit: BoxFit.contain,
            )));
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: XedColors.white,
          size: hp(30.0),
        ),
        onPressed: () => XError.f0(() => Navigator.of(context).pop()),
      ),
      actions: <Widget>[
        IconButton(
          // action button
          icon: Icon(
            Icons.settings,
            color: XedColors.white,
            size: hp(24),
          ),
          onPressed: () => XError.f0(() {
            showModalBottomSheet(
                context: context,
                builder: (context) {
                  return SingleChoiceDialog(
                      title: 'Who can see your deck?',
                      options: ['Only me', 'Public'],
                      onPressed: (value) {},
                      decisionContent: 'Done');
                }).catchError((ex) => core.Log.error(ex));
          }),
        )
      ],
    );
  }

  Widget _avatarWidget() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: <Widget>[
        Container(
          child: Image.asset(
            '',
            height: hp(143),
            width: wp(107),
            fit: BoxFit.cover,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: XedColors.duckEggBlue,
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: hp(10), right: wp(10)),
          height: hp(26),
          width: wp(36),
          child: Icon(
            Icons.camera_alt,
            size: hp(20),
            color: XedColors.black,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            color: Color.fromARGB(255, 250, 250, 250),
          ),
        )
      ],
    );
  }
}
