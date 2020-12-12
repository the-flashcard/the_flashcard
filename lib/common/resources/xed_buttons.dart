import 'dart:io';

import 'package:flutter/material.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/onboarding/onboarding.dart';
import 'package:the_flashcard/xerror.dart';

class XedButtons {
  XedButtons._();

  static Widget watermelonButton(
    String title,
    double radius,
    double fontSize,
    Function onTap, {
    double height,
    double width,
    EdgeInsets padding,
  }) {
    return InkWell(
      onTap: onTap != null ? () => XError.f0(onTap) : null,
      child: Container(
        padding: padding ?? null,
        alignment: Alignment.center,
        width: width ?? null,
        height: height ?? hp(56),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: XedColors.waterMelon.withOpacity(onTap != null ? 1.0 : 0.2),
          border: Border.all(
            color: onTap == null ? XedColors.transparent : XedColors.waterMelon,
          ),
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: BoldTextStyle(fontSize)
                .copyWith(color: Colors.white, fontSize: fontSize),
          ),
        ),
      ),
    );
  }

  static Widget azureBlueButton(
    String title,
    double radius,
    double fontSize,
    Function onTap, {
    double height,
    double width,
    EdgeInsets padding,
  }) {
    return InkWell(
      onTap: onTap != null ? () => XError.f0(onTap) : null,
      child: Container(
        padding: padding ?? null,
        alignment: Alignment.center,
        width: width ?? null,
        height: height ?? hp(56),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: XedColors.azure,
          border: Border.all(
            color: onTap == null ? XedColors.transparent : XedColors.azure,
          ),
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: BoldTextStyle(fontSize)
                .copyWith(color: Colors.white, fontSize: fontSize),
          ),
        ),
      ),
    );
  }

  static Widget watermelonButtonWithBorderLeft(
    String title,
    double radius,
    double fontSize,
    Function onTap, {
    double height,
    double width,
  }) {
    return InkWell(
      onTap: onTap != null ? () => XError.f0(onTap) : null,
      child: Container(
        alignment: Alignment.center,
        width: width ?? null,
        height: height ?? hp(56),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(radius),
            bottomLeft: Radius.circular(radius),
          ),
          color: XedColors.waterMelon.withOpacity(onTap != null ? 1.0 : 0.2),
          border: Border.all(
            color: onTap == null
                ? XedColors.transparent
                : XedColors.waterMelonChatBot,
          ),
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: SemiBoldTextStyle(fontSize)
                .copyWith(color: Colors.white, fontSize: fontSize),
          ),
        ),
      ),
    );
  }

  static Widget whiteButton(
    String title,
    double radius,
    double fontSize,
    Function onTap, {
    bool withBorder = true,
    Color textColor = XedColors.black,
    double height,
    double width,
    EdgeInsets padding,
  }) {
    return InkWell(
      onTap: onTap != null ? () => XError.f0(onTap) : null,
      child: Container(
        padding: padding ?? null,
        alignment: Alignment.center,
        width: width ?? null,
        height: height ?? hp(56),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: XedColors.white,
          border: Border.all(
            color: onTap == null ? XedColors.transparent : XedColors.black,
          ),
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: BoldTextStyle(fontSize)
                .copyWith(color: textColor, fontSize: fontSize),
          ),
        ),
      ),
    );
  }

  static Widget whiteButtonWithRegularText(
    String title,
    double radius,
    double fontSize,
    Function onTap, {
    bool withBorder = true,
    Color textColor = XedColors.black,
    double height,
    double width,
  }) {
    return InkWell(
      onTap: onTap != null ? () => XError.f0(onTap) : null,
      child: Container(
        alignment: Alignment.center,
        width: width ?? null,
        height: height ?? hp(56),
        decoration: withBorder
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                color: XedColors.white,
                border: Border.all(
                  color: XedColors.waterMelon,
                  // onTap == null ? XedColors.transparent : XedColors.black,
                ),
              )
            : null,
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: RegularTextStyle(fontSize)
                .copyWith(fontSize: fontSize, color: textColor),
          ),
        ),
      ),
    );
  }

  static Widget textWithArrowButton(String title, {VoidCallback onTap}) {
    return Material(
      color: XedColors.transparent,
      child: InkWell(
        onTap: onTap != null ? () => XError.f0(onTap) : null,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: wp(20)),
          child: Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text(
                title,
                style: SemiBoldTextStyle(16).copyWith(
                  fontSize: 16,
                  height: 1.2,
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 24,
                color: XedColors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget iconButton(Widget icon,
      {VoidCallback onTap, double sizeButton, Key key}) {
    sizeButton ??= 36;
    return Ink(
      key: key,
      width: sizeButton,
      height: sizeButton,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: XedColors.white255,
        boxShadow: [
          BoxShadow(
            color: XedColors.black.withAlpha(25),
            blurRadius: 8,
            offset: Offset(0, 5),
            spreadRadius: 0,
          )
        ],
      ),
      child: InkWell(
        customBorder: CircleBorder(),
        child: icon,
        onTap: onTap != null ? () => XError.f0(onTap) : null,
      ),
    );
  }

  static Widget closeButton({VoidCallback onTap, double sizeButton = 30}) {
    sizeButton ??= hp(36);
    return IconButton(
      icon: Icon(
        Icons.close,
        color: XedColors.black,
        size: sizeButton,
      ),
      alignment: Alignment.center,
      onPressed: onTap != null ? () => XError.f0(onTap) : null,
    );
  }

  static Widget iconCircleButton({
    Widget child,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    VoidCallback onTap,
  }) {
    return ClipOval(
      child: Material(
        color: Colors.transparent,
        shape: CircleBorder(),
        child: InkWell(
          child: Padding(
            padding: padding,
            child: child,
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  static Widget colorCTA({
    Widget child,
    VoidCallback onTap,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    Color color,
    BorderRadius borderRadius,
    double elevation,
  }) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.zero,
      ),
      color: color,
      child: child,
      padding: padding,
      onPressed: onTap,
      elevation: elevation ?? 0,
    );
  }

  static Widget leadingButton({
    VoidCallback onPressed,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    Color color,
    double size,
    String tooltip,
  }) {
    return IconButton(
      padding: padding,
      onPressed: onPressed,
      tooltip: tooltip ?? "Back",
      iconSize: size ?? 24,
      color: color ?? Colors.white,
      icon: Icon(
        Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios,
      ),
    );
  }
}

class XIconButton extends StatelessWidget implements OnboardingObject {
  final Key testDriverKey;
  final Widget icon;
  final VoidCallback onPressed;

  const XIconButton(
      {this.testDriverKey, Key globalKey, this.icon, this.onPressed})
      : super(key: globalKey);

  @override
  Widget cloneWithoutGlobalKey() {
    return Container(
      child: XIconButton(icon: icon),
      decoration: BoxDecoration(
        color: XedColors.white255,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return XedButtons.iconButton(icon, onTap: onPressed, key: testDriverKey);
  }
}

class XButton extends StatelessWidget implements OnboardingObject {
  final String title;
  final double radius;
  final double fontSize;
  final VoidCallback onTap;
  final bool withBorder;
  final Color textColor;
  final double height;
  final double width;
  final Color colorButton;
  final bool isOnboarding;

  XButton._(
      {this.title,
      this.radius,
      this.fontSize,
      this.onTap,
      this.withBorder,
      this.textColor,
      this.height,
      this.width,
      this.colorButton,
      this.isOnboarding});

  const XButton.white({
    @required this.title,
    @required this.radius,
    @required this.fontSize,
    @required this.onTap,
    Key globalKey,
    this.textColor = XedColors.black,
    this.height,
    this.width,
    this.withBorder = true,
    this.isOnboarding = false,
  })  : colorButton = XedColors.white255,
        super(key: globalKey);

  const XButton.watermelon({
    @required this.title,
    @required this.radius,
    @required this.fontSize,
    @required this.onTap,
    this.isOnboarding = false,
    Key globalKey,
    this.textColor = XedColors.white,
    this.height,
    this.width,
  })  : colorButton = XedColors.waterMelon,
        this.withBorder = false,
        super(key: globalKey);

  @override
  Widget build(BuildContext context) {
    final Border boder = withBorder
        ? Border.all(
            color: onTap == null ? XedColors.transparent : XedColors.black,
          )
        : null;
    final Color color = isOnboarding || colorButton != XedColors.waterMelon
        ? colorButton
        : colorButton.withOpacity(onTap != null ? 1.0 : 0.2);
    return InkWell(
      onTap: onTap != null ? () => XError.f0(onTap) : null,
      child: Container(
        alignment: Alignment.center,
        width: width ?? null,
        height: height ?? hp(56),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: color,
          border: boder,
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: BoldTextStyle(fontSize).copyWith(color: textColor),
          ),
        ),
      ),
    );
  }

  @override
  Widget cloneWithoutGlobalKey() {
    return XButton._(
      colorButton: colorButton,
      isOnboarding: true,
      title: this.title,
      radius: this.radius,
      fontSize: this.fontSize,
      onTap: null,
      textColor: this.textColor,
      height: this.height,
      width: this.width,
      withBorder: false,
    );
  }
}
