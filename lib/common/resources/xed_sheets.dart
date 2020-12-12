import 'package:flutter/material.dart';
import 'package:the_flashcard/common/common.dart';

enum XedSheetHeaderMode {
  Normal,
  AdditionDoneButton,
}

class XedSheetWidget extends StatelessWidget {
  final XedSheetHeaderWidget header;
  final Widget child;

  const XedSheetWidget({Key key, @required this.header, @required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: XedColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          header,
          const Divider(height: 1, color: XedColors.black10),
          Flexible(child: child),
        ],
      ),
    );
  }
}

// TODO(1): replace XedBottomSheets
class XedSheets {
  XedSheets._();

  static Widget bottomSheet<T>(
    BuildContext context,
    String title,
    Widget child, {
    T result,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: XedColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: hp(50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: wp(15)),
                  child: IconButton(
                    icon: Icon(Icons.close),
                    iconSize: 30,
                    onPressed: () => XError.f0(() {
                      if (result != null)
                        Navigator.of(context).pop(result);
                      else
                        Navigator.of(context).pop();
                    }),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Text(
                      title,
                      style: SemiBoldTextStyle(22).copyWith(
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
                // SizedBox(width: wp(45)),
                // Spacer(),
              ],
            ),
          ),
          Divider(height: 1, color: Color.fromRGBO(18, 18, 18, 0.1)),
          Flexible(child: child),
        ],
      ),
    );
  }
}

abstract class XedSheetHeaderWidget extends StatelessWidget {
  final XedSheetHeaderMode mode;

  const XedSheetHeaderWidget({Key key, this.mode}) : super(key: key);
}

class XedSheetHeaderWidgetImpl extends XedSheetHeaderWidget {
  final Widget title;
  final VoidCallback onTapClose;
  final VoidCallback onTapDone;

  const XedSheetHeaderWidgetImpl({
    Key key,
    @required this.title,
    this.onTapClose,
    this.onTapDone,
    XedSheetHeaderMode mode = XedSheetHeaderMode.Normal,
  }) : super(key: key, mode: mode);

  @override
  Widget build(BuildContext context) {
    final Widget iconClose = _iconClose();

    final Widget titleWidget = _getTitleWidget();

    final Widget doneWidget =
        mode == XedSheetHeaderMode.Normal ? SizedBox(width: 30) : _doneWidget();

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 15),
      child: Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          iconClose,
          titleWidget,
          doneWidget,
        ],
      ),
    );
  }

  Widget _iconClose() {
    return IconButton(
      icon: Icon(Icons.close, color: XedColors.black),
      iconSize: 30,
      onPressed: onTapClose,
    );
  }

  Widget _getTitleWidget() {
    return Flexible(
      child: DefaultTextStyle(
        style: SemiBoldTextStyle(20).copyWith(fontSize: 20, height: 1.4),
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        child: Semantics(
          child: title,
          header: true,
        ),
      ),
    );
  }

  Widget _doneWidget() {
    return GestureDetector(
      child: Text(
        'Done',
        textAlign: TextAlign.right,
        style: RegularTextStyle(16).copyWith(
          color: XedColors.deepSkyBlue,
          fontSize: 16,
          height: 1.4,
        ),
      ),
      onTap: onTapDone,
    );
  }
}

abstract class XedBottomSheets {
  static Future<T> showBottomSheet<T>({
    @required BuildContext context,
    @required Widget child,
    @required String title,
    String currentScreenName,
  }) {
    return showModalBottomSheet<T>(
      backgroundColor: XedColors.transparent,
      context: context,
      builder: (context) {
        return XedSheetWidget(
          header: XedSheetHeaderWidgetImpl(
            title: Text(title),
            onTapClose: () => _closePopUp(context, currentScreenName),
          ),
          child: child,
        );
      },
    );
  }

  static Future<T> showBottomSheetWithDoneButton<T>({
    @required BuildContext context,
    @required Widget child,
    @required String title,
    String currentScreenName,
    VoidCallback onTapDone,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      builder: (context) {
        return XedSheetWidget(
          child: child,
          header: XedSheetHeaderWidgetImpl(
            mode: XedSheetHeaderMode.AdditionDoneButton,
            title: Text(title),
            onTapClose: () => _closePopUp(context, currentScreenName),
            onTapDone: () {
              _closePopUp(context, currentScreenName);
              if (onTapDone != null) onTapDone();
            },
          ),
        );
      },
    );
  }

  static void _closePopUp<T>(BuildContext context, String currentScreenName) {
    if (currentScreenName != null) {
      Navigator.of(context).popUntil(ModalRoute.withName(currentScreenName));
    } else
      Navigator.pop(context);
  }
}
