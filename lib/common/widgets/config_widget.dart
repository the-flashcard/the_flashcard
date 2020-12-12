import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/environment/driver_key.dart';
import 'package:the_flashcard/xerror.dart';

enum ToolboxItem {
  NONE,
  TEXT,
  IMAGE,
  VIDEO,
  VOICE,
  MULTI_CHOICE,
  FILL_IN_BLANK,
  RESET,
  BACKGROUND,
  ALIGNMENT
}

final frontToolboxItems = <XToolboxModel>[
  XToolboxModel(
    ToolboxItem.TEXT,
    "Text Box",
    Assets.icTextWhite,
  ),
  XToolboxModel(
    ToolboxItem.IMAGE,
    "Images",
    Assets.icImgWhite,
  ),
  XToolboxModel(
    ToolboxItem.VIDEO,
    "Video",
    Assets.icVideoWhite,
  ),
  XToolboxModel(
    ToolboxItem.VOICE,
    "Voice",
    Assets.icVoiceWhite,
  ),
  XToolboxModel(
    ToolboxItem.MULTI_CHOICE,
    "MultiChoice",
    Assets.icMC,
  ),
  XToolboxModel(
    ToolboxItem.FILL_IN_BLANK,
    "Fill In Blank",
    Assets.icFIB,
  ),
];

final backToolboxItems = <XToolboxModel>[
  XToolboxModel(
    ToolboxItem.TEXT,
    "Text Box",
    Assets.icTextWhite,
  ),
  XToolboxModel(
    ToolboxItem.IMAGE,
    "Images",
    Assets.icImgWhite,
  ),
  XToolboxModel(
    ToolboxItem.VIDEO,
    "Video",
    Assets.icVideoWhite,
  ),
  XToolboxModel(
    ToolboxItem.VOICE,
    "Voice",
    Assets.icVoiceWhite,
  ),
];

final introToolboxItems = <XToolboxModel>[
  XToolboxModel(
    ToolboxItem.TEXT,
    "Text Box",
    Assets.icTextWhite,
  ),
  XToolboxModel(
    ToolboxItem.IMAGE,
    "Images",
    Assets.icImgWhite,
  ),
  XToolboxModel(
    ToolboxItem.VIDEO,
    "Video",
    Assets.icVideoWhite,
  ),
  XToolboxModel(
    ToolboxItem.VOICE,
    "Voice",
    Assets.icVoiceWhite,
  ),
];

class XToolboxModel {
  // static final _componentImageSize = 30.0;
  ToolboxItem id;
  String title;
  String path;

  XToolboxModel(this.id, this.title, this.path);
}

class XToolboxWidget extends StatelessWidget {
  static final name = 'DeckListComponent';

  final String title;
  final List<XToolboxModel> configs;
  final ValueChanged<ToolboxItem> callback; //selected position

  XToolboxWidget(
      {@required this.title, @required this.configs, @required this.callback});

  XToolboxWidget.components(
      {@required this.title, @required this.configs, @required this.callback});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      width: double.infinity,
      height: 159,
      color: XedColors.black,
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: configs.length > 3
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Container(
                padding: configs.length > 3
                    ? EdgeInsets.zero
                    : EdgeInsets.only(left: 22.0),
                child: _buildToolboxItemList(),
              ),
            ),
            Container(
              width: double.infinity,
              height: hp(1),
              color: Color.fromRGBO(255, 255, 255, 0.16),
            ),
            _addEditRow()
          ],
        ),
      ),
    );
  }

  Widget _addEditRow() {
    return Container(
      width: double.infinity,
      height: 46,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          InkWell(
              onTap: () {},
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: ColorTextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                width: double.infinity,
              )),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () => XError.f0(() {
                if (callback != null) {
                  callback(ToolboxItem.NONE);
                }
              }),
              iconSize: hp(20),
              icon: Icon(Icons.close),
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  ListView _buildToolboxItemList() {
    return ListView.builder(
      key: Key(DriverKey.LIST_COMP),
      itemCount: configs.length,
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) => _buildToolboxItem(configs[index]),
    );
  }

  Widget _buildToolboxItem(XToolboxModel model) {
    return InkWell(
      onTap: () => XError.f0(() {
        if (callback != null) {
          callback(model.id);
        }
      }),
      child: Padding(
        padding: EdgeInsets.only(left: wp(20), right: wp(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              model.path,
              width: 30,
              height: 30,
              color: XedColors.paleGrey,
            ),
            SizedBox(height: hp(12)),
            Text(
              model.title,
              style: ColorTextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            )
          ],
        ),
      ),
    );
  }
}
