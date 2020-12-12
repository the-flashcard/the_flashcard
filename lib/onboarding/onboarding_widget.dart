import 'dart:ui';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' show Log;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/xwidgets/x_state.dart';

abstract class OnboardingObject extends Widget {
  /// Clone object, remove global key because flutter don't allow two key same time
  Widget cloneWithoutGlobalKey();
}

/// Widget `child`: widget get from golbal key
///
/// Offset `position`: position of widget
///
/// return a `Widget`
typedef OnBoardingBuilder = Widget Function(
  Widget child,
  Widget arrowWidget,
  Widget toolTipWidget,
  Offset position,
  OnBoardingBuilderDefault defaultLayout,
);

typedef OnBoardingBuilderDefault = Widget Function(
  Widget child,
  Widget arrowWidget,
  Widget toolTipWidget,
  Offset position,
);

enum OnboardingDirection {
  BottomToTop,
  TopToBottom,
}

class OnboardingWidget extends StatefulWidget {
  final GlobalKey currentKey;
  final String description;
  final String currentNameScreen;
  final Duration timeShowTooltips;
  final OnBoardingBuilder builder;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final OnboardingDirection direction;
  final VoidCallback onTapCancel;

  const OnboardingWidget(
    this.currentKey, {
    Key key,
    @required this.description,
    @required this.currentNameScreen,
    this.builder,
    this.timeShowTooltips = const Duration(milliseconds: 300),
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.direction = OnboardingDirection.TopToBottom,
    this.onTapCancel,
  })  : assert(currentNameScreen is String),
        assert(currentKey is GlobalKey),
        assert(timeShowTooltips is Duration),
        assert(crossAxisAlignment is CrossAxisAlignment),
        assert(mainAxisAlignment is MainAxisAlignment),
        assert(direction is OnboardingDirection),
        super(key: key);

  @override
  _OnboardingWidgetState createState() => _OnboardingWidgetState();
}

class _OnboardingWidgetState extends XState<OnboardingWidget> {
  OnBoardingBuilder builder;

  bool isCustomBuilder;

  static const _arrowWidget = const FlareActor(
    Flares.focusArrow,
    animation: FlareAnimations.focusArrow,
  );

  @override
  void initState() {
    super.initState();
    isCustomBuilder = widget.builder != null;
    builder = widget.builder ?? _defaultBuilder;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => XError.f0(_onTapCancel),
      child: Stack(
        children: <Widget>[
          _buildBlur(),
          FutureBuilder(
            future: Future.delayed(widget.timeShowTooltips),
            builder: (_, snapShot) {
              switch (snapShot.connectionState) {
                case ConnectionState.done:
                  return _buildTooltipComponent(widget.currentKey);
                default:
                  return SizedBox();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTooltipComponent(GlobalKey<State<StatefulWidget>> currentKey) {
    final Offset point = getPosition(currentKey) ?? Offset.zero;
    final OnboardingObject child = currentKey.currentWidget as OnboardingObject;
    final Widget arrowWidget = _buildArrow();
    final Widget tootlTipWidget = _buildDescription(widget.description);
    return child != null
        ? builder(
            child.cloneWithoutGlobalKey(),
            arrowWidget,
            tootlTipWidget,
            point,
            _defaultLayout,
          )
        : SizedBox();
  }

  Widget _buildBlur() {
    return BackdropFilter(
      child: Container(
        color: Color.fromARGB((0.7 * 255).toInt(), 18, 18, 18),
      ),
      filter: ImageFilter.blur(
        sigmaX: 1,
        sigmaY: 1,
      ),
    );
  }

  Widget _buildArrow() {
    return Container(
      width: 40,
      height: 40,
      child: _arrowWidget,
    );
  }

  Widget _buildDescription(String description) {
    description ??= '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: XedColors.waterMelon,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 290),
        child: Text(
          description,
          textAlign: TextAlign.center,
          style: RegularTextStyle(16).copyWith(
            height: 1.4,
            fontSize: 16,
            color: XedColors.white255,
          ),
        ),
      ),
    );
  }

  Offset getPosition(GlobalKey<State<StatefulWidget>> currentKey) {
    try {
      final RenderBox findRenderObject =
          currentKey.currentContext.findRenderObject();

      return findRenderObject.localToGlobal(Offset.zero);
    } catch (ex) {
      Log.error(ex);
      return null;
    }
  }

  Size getSize(GlobalKey<State<StatefulWidget>> currentKey) {
    try {
      final RenderBox findRenderObject =
          currentKey.currentContext.findRenderObject();
      Log.error(findRenderObject.size.toString());

      return findRenderObject.size;
    } catch (ex) {
      Log.error(ex);
      return Size.zero;
    }
  }

  Widget _defaultBuilder(Widget child, Widget arrowWidget, Widget toolTipWidget,
      Offset position, OnBoardingBuilderDefault defaultLayout) {
    return defaultLayout(child, arrowWidget, toolTipWidget, position);
  }

  Widget _defaultLayout(
      Widget child, Widget arrowWidget, Widget tooltipWiget, Offset position) {
    final bool isTopToBottom =
        widget.direction == OnboardingDirection.TopToBottom;
    child = isTopToBottom
        ? _positionWidgetTopToBottom(
            _buildTopToButtom(child, arrowWidget, tooltipWiget), position)
        : _positionWidgetBottomToTop(
            child, arrowWidget, tooltipWiget, position);
    return child;
  }

  Widget _positionWidgetTopToBottom(
    Widget child,
    Offset position,
  ) {
    final bool isLeft = widget.crossAxisAlignment == CrossAxisAlignment.start;
    final double left = isLeft ? position.dx : null;
    final double right = isLeft ? null : _getRight(position.dx);

    Log.debug('_positionWidgetTopToBottom: RIGHT: $right, LEFT: $left');

    return Positioned(
      top: position.dy,
      left: left,
      right: right,
      child: child,
    );
  }

  Widget _positionWidgetBottomToTop(
    Widget child,
    Widget arrowWidget,
    Widget tooltipWiget,
    Offset position,
  ) {
    final bool isLeft = widget.crossAxisAlignment == CrossAxisAlignment.start;
    final double left = isLeft ? position.dx : null;
    final double right = isLeft ? null : _getRight(position.dx);
    Log.debug('_positionWidgetBottomToTop: RIGHT: $right, LEFT: $left');
    final double bottom = _getBottom(position.dy);
    child = Positioned(
      top: position.dy,
      left: left,
      right: right,
      child: _defaultSize(child),
    );
    final Widget newChild = Positioned(
      bottom: bottom,
      left: left,
      right: right,
      child: _defaultColumn([
        tooltipWiget,
        _rotateWidget(arrowWidget),
      ]),
    );
    return Stack(
      children: <Widget>[
        child,
        newChild,
      ],
    );
  }

  Widget _defaultSize(Widget child) {
    return child is OnboardingObject
        ? SizedBox.fromSize(child: child, size: getSize(widget.currentKey))
        : child;
  }

  Widget _defaultColumn(List<Widget> children) {
    return Flex(
      direction: Axis.vertical,
      mainAxisAlignment: widget.mainAxisAlignment,
      crossAxisAlignment: widget.crossAxisAlignment,
      mainAxisSize: MainAxisSize.max,
      children: children,
    );
  }

  Widget _rotateWidget(Widget child, {int quarterTurns = 90}) {
    return RotatedBox(child: child, quarterTurns: quarterTurns);
  }

  Widget _buildTopToButtom(
      Widget child, Widget arrowWidget, Widget tooltipWiget) {
    child = _defaultSize(child);
    return _defaultColumn([
      _defaultColumn([child, arrowWidget]),
      tooltipWiget,
    ]);
  }

  double _getBottom(double top) {
    try {
      double height = MediaQuery.of(context).size.height;
      return height - top;
    } catch (ex) {
      Log.error(ex);
      return 0;
    }
  }

  double _getRight(double left) {
    try {
      final double childWidth = getSize(widget.currentKey).width;
      double width = MediaQuery.of(context).size.width;
      return width - left - childWidth;
    } catch (ex) {
      Log.error(ex);
      return 0;
    }
  }

  void _onTapCancel() {
    closeUntil(widget.currentNameScreen);
    if (widget.onTapCancel != null) {
      widget.onTapCancel();
    }
  }
}

/// ------------------------------------------------------
/// Show onboarding
/// ------------------------------------------------------
/// @key is key of shared preferences
///
/// @context for show popup
///
/// @description description for onboarding
///
/// @globalKey find a widget, if not exsts widget will be a sizedbox
///
/// @currentNameScreen current name of this screen

class OnboardingData {
  final GlobalKey globalKey;
  final String description;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final OnboardingDirection direction;

  const OnboardingData.left({
    @required this.globalKey,
    @required this.description,
    this.direction = OnboardingDirection.TopToBottom,
  })  : this.crossAxisAlignment = CrossAxisAlignment.start,
        this.mainAxisAlignment = MainAxisAlignment.start;

  const OnboardingData.right({
    @required this.globalKey,
    @required this.description,
    this.direction = OnboardingDirection.TopToBottom,
  })  : this.crossAxisAlignment = CrossAxisAlignment.end,
        this.mainAxisAlignment = MainAxisAlignment.end;
}
