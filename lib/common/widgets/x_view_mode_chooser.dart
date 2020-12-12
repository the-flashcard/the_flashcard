import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/dimens.dart';

class ViewMode {
  final bool horizontal;
  int gridColumn = 1;
  double gridAspectRatio = 1.5;

  ViewMode({this.horizontal = false});

  ViewMode.list({this.horizontal = false})
      : gridColumn = 1,
        gridAspectRatio = 1.5;

  ViewMode.grid({this.horizontal = false})
      : gridColumn = 2,
        gridAspectRatio = 0.75;

  void toggle() {
    if (gridColumn == 1) {
      gridColumn = 2;
      gridAspectRatio = 0.75;
    } else {
      gridColumn = 1;
      gridAspectRatio = 1.5;
    }
  }
}

class XViewModeChooser extends StatefulWidget {
  final void Function(int index) onTabChanged;

  XViewModeChooser({
    Key key,
    this.onTabChanged,
  }) : super(key: key);

  @override
  _XViewModeChooserState createState() => _XViewModeChooserState();
}

class _XViewModeChooserState extends XState<XViewModeChooser> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: wp(15), vertical: wp(15)),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: hp(80),
          height: hp(40),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Color.fromARGB(255, 220, 221, 221),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              InkWell(
                onTap: _handleTabChanged,
                child: Container(
                  width: hp(40),
                  height: hp(40),
                  decoration: index == 0
                      ? BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Color.fromARGB(255, 220, 221, 221),
                            width: 3.0,
                          ),
                          borderRadius: BorderRadius.circular(6.0))
                      : null,
                  child: Icon(Foundation.list),
                ),
              ),
              InkWell(
                onTap: _handleTabChanged,
                child: Container(
                  width: hp(40),
                  height: hp(40),
                  decoration: index == 1
                      ? BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Color.fromARGB(255, 220, 221, 221),
                            width: 3.0,
                          ),
                          borderRadius: BorderRadius.circular(6.0))
                      : null,
                  child: Icon(MaterialCommunityIcons.view_grid),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTabChanged() {
    reRender(fn: () {
      index = index == 0 ? 1 : 0;
      if (widget.onTabChanged != null) widget.onTabChanged(index);
    });
  }
}
