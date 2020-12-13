import 'package:flutter/material.dart';
import 'package:the_flashcard/deck_creation/deck_creation.dart';
import 'package:the_flashcard/deck_creation/multi_choice/bloc/multi_choice_bloc.dart';
import 'package:the_flashcard/xerror.dart';

import '../common.dart';

class AppBarWithSetting extends StatelessWidget implements PreferredSizeWidget {
  final ValueChanged<ToolboxItem> settingSelectedCallback;

  final String titleText;
  final VoidCallback onTap;
  final VoidCallback cancelCallBack;
  final VoidCallback saveCallBack;
  final DesignCardBloc bloc;

  AppBarWithSetting({
    Key key,
    @required this.titleText,
    @required this.settingSelectedCallback,
    this.cancelCallBack,
    this.saveCallBack,
    this.bloc,
    @required this.onTap,
  })  : preferredSize = Size.fromHeight(hp(56.0)),
        super(key: key);

  @override
  final Size preferredSize; // default is 56.0

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Flex(
        direction: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.center,
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildInkwell(
            child: Icon(
              Icons.arrow_back,
              size: 30,
              color: Color.fromARGB(255, 43, 43, 43),
            ),
            onTap: () => XError.f0(cancelCallBack),
          ),
          SizedBox(width: wp(10)),
          Flexible(child: Text(titleText, style: SemiBoldTextStyle(18))),
        ],
      ),
      automaticallyImplyLeading: false,
      actions: _actionWidgets(context),
    );
  }

  List<Widget> _actionWidgets(BuildContext context) {
    return [
      IconButton(
        onPressed: () => XError.f0(() => _onPressedSettingIcon(context)),
        icon: Icon(Icons.settings),
        color: XedColors.battleShipGrey,
      ),
      SizedBox(width: 18),
      Container(
        width: 1,
        height: 20.0,
        color: XedColors.black.withAlpha(25),
      ),
      SizedBox(width: 20),
      _buildSaveButton(),
      SizedBox(width: 15)
    ];
  }

  static final List<XToolboxModel> settingModels = [
    XToolboxModel(
      ToolboxItem.RESET,
      "Reset all",
      Assets.icReset,
    ),
    XToolboxModel(
      ToolboxItem.BACKGROUND,
      "Background",
      Assets.icColor,
    ),
    XToolboxModel(
      ToolboxItem.ALIGNMENT,
      "Alignment",
      Assets.icAlignment,
    ),
  ];

  void _onPressedSettingIcon(BuildContext context) {
    if (this.onTap != null) this.onTap();
    showBottomSheet(
      context: context,
      builder: (context) {
        return XToolboxWidget(
          title: 'SETTING',
          configs: settingModels,
          callback: (id) {
            if (settingSelectedCallback != null) {
              Navigator.pop(context);
              settingSelectedCallback(id);
            }
          },
        );
      },
    );
  }

  Widget _buildSaveButton() {
    return bloc != null
        ? BlocBuilder<DesignCardBloc, DesignState>(
            cubit: bloc,
            builder: (BuildContext context, DesignState state) {
              var style = bloc.hasChanges()
                  ? RegularTextStyle(18).copyWith(color: XedColors.waterMelon)
                  : RegularTextStyle(18)
                      .copyWith(color: XedColors.waterMelon.withOpacity(0.2));
              return Center(
                child: _buildInkwell(
                  child: Text('Save', style: style),
                  onTap:
                      bloc.hasChanges() ? () => XError.f0(saveCallBack) : null,
                ),
              );
            },
          )
        : SizedBox();
  }

  Widget _buildInkwell({@required Widget child, VoidCallback onTap}) {
    return InkWell(
      splashColor: XedColors.transparent,
      highlightColor: XedColors.transparent,
      child: child,
      onTap: onTap,
    );
  }
}
