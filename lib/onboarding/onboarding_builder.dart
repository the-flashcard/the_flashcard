import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/onboarding/onboarding.dart';

typedef OnboardingIndexerBuilderDefault = Widget Function(
  Widget child,
  Widget arrowWidget,
  Widget toolTipWidget,
  Offset position,
  int index,
);

typedef OnboardingIndexerBuilder = Widget Function(
  Widget child,
  Widget toolTipWidget,
  Widget arrowWidget,
  Offset position,
  int index,
  OnboardingIndexerBuilderDefault defaultLayout,
);

class OnboardingBuilder extends StatefulWidget {
  final List<OnboardingData> listOnboardingData;
  final SharedPreferences preferences;
  final String currentNameScreen;
  final String onboardingKey;
  final bool force;
  final OnboardingIndexerBuilder builder;

  OnboardingBuilder({
    Key key,
    @required this.listOnboardingData,
    @required this.preferences,
    @required this.currentNameScreen,
    this.force = false,
    this.onboardingKey,
  })  : assert(listOnboardingData?.isNotEmpty == true),
        builder = null,
        super(key: key);

  OnboardingBuilder.custom({
    Key key,
    @required this.listOnboardingData,
    @required this.preferences,
    @required this.currentNameScreen,
    @required this.builder,
    this.force = false,
    this.onboardingKey,
  })  : assert(listOnboardingData?.isNotEmpty == true),
        super(key: key);

  @override
  _OnboardingBuilderState createState() => _OnboardingBuilderState();
}

class _OnboardingBuilderState extends State<OnboardingBuilder> {
  int index = 0;
  Widget currentWidget;
  bool needOnboarding = true;

  @override
  void initState() {
    super.initState();
    needOnboarding = widget.preferences.getBool(widget.onboardingKey) ?? true;
    if (needOnboarding)
      _markOnboardingCompleted(widget.onboardingKey, widget.preferences);
  }

  @override
  Widget build(BuildContext context) {
    currentWidget = _builder(context, index);
    return widget.force || needOnboarding ? currentWidget : SizedBox();
  }

  Widget _builder(BuildContext context, int index) {
    final OnboardingData data = index < widget.listOnboardingData.length
        ? widget.listOnboardingData[index]
        : null;
    Widget child;
    if (data is OnboardingData) {
      child = OnboardingWidget(
        data.globalKey,
        onTapCancel: _onTap,
        description: data.description,
        currentNameScreen: widget.currentNameScreen,
        crossAxisAlignment: data.crossAxisAlignment,
        mainAxisAlignment: data.mainAxisAlignment,
        direction: data.direction,
        builder: widget.builder != null ? _buildCustom : null,
        // : null,
      );
    } else
      child = SizedBox();
    return child;
  }

  void _onTap() {
    setState(() {
      index++;
      if (index >= widget.listOnboardingData.length && widget.force)
        currentWidget = SizedBox();
    });
  }

  Widget _buildCustom(Widget child, Widget arrowWidget, Widget toolTipWidget,
      Offset position, OnBoardingBuilderDefault defaultLayout) {
    return widget.builder(
      child,
      arrowWidget,
      toolTipWidget,
      position,
      index,
      (child, arrowWidget, toolTipWidget, position, int index) =>
          _buildCustomDefault(child, arrowWidget, toolTipWidget, position,
              index, defaultLayout),
    );
  }

  Widget _buildCustomDefault(
    Widget child,
    Widget arrowWidget,
    Widget toolTipWidget,
    Offset position,
    int index,
    OnBoardingBuilderDefault defaultLayout,
  ) {
    return defaultLayout(child, arrowWidget, toolTipWidget, position);
  }
}

void _markOnboardingCompleted(String key, SharedPreferences preferences) {
  preferences.setBool(key, false);
}

Widget buildOnboarding({
  @required List<OnboardingData> listOnboardingData,
  @required String localStoredKey,
  @required String currentNameScreen,
  bool force = false,
}) {
  final _value = Future.delayed((Duration(milliseconds: 150)))
      .then((_) => SharedPreferences.getInstance());
  return FutureBuilder<SharedPreferences>(
    future: _value,
    builder: (_, snapshot) {
      if (snapshot.connectionState == ConnectionState.done &&
          snapshot.hasData) {
        return _getOnboardingWidget(
          preferences: snapshot.data,
          localStoredKey: localStoredKey,
          currentNameScreen: currentNameScreen,
          listOnboardingData: listOnboardingData,
          force: force,
        );
      } else
        return SizedBox();
    },
  );
}

Widget _getOnboardingWidget({
  @required SharedPreferences preferences,
  @required List<OnboardingData> listOnboardingData,
  @required String localStoredKey,
  @required String currentNameScreen,
  bool force,
}) {
  return Material(
    color: XedColors.transparent,
    child: OnboardingBuilder(
      preferences: preferences,
      currentNameScreen: currentNameScreen,
      force: force,
      onboardingKey: localStoredKey,
      listOnboardingData: listOnboardingData,
    ),
  );
}
