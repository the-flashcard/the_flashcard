import 'package:flutter/material.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:url_launcher/url_launcher.dart';

enum UpdateMode { None, Normal, Force }

class VersionPopUp extends StatelessWidget {
  final UpdateMode _mode;
  final void Function(UpdateMode) onSkipTap;
  final void Function(UpdateMode) onUpdateTap;
  VersionPopUp(
    this._mode, {
    this.onSkipTap,
    this.onUpdateTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (_mode) {
      case UpdateMode.Normal:
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: Container(
                  color: XedColors.black.withOpacity(0.7),
                ),
              ),
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: XedColors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AspectRatio(
                    aspectRatio: 354 / 245,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 30,
                      ),
                      child: Flex(
                        direction: Axis.vertical,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          _buildTitle("Hey There!"),
                          _buidDescription(
                              "Our new version is now available for download."),
                          Flex(
                            direction: Axis.horizontal,
                            children: <Widget>[
                              Flexible(
                                child: XedButtons.whiteButtonWithRegularText(
                                  "No, Skip this time",
                                  10,
                                  16,
                                  () => onSkipTap(_mode),
                                  withBorder: false,
                                ),
                              ),
                              Flexible(
                                  child: XedButtons.watermelonButton(
                                "UPDATE NOW",
                                10,
                                16,
                                () => onUpdateTap(_mode),
                              )),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
        break;
      case UpdateMode.Force:
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: Container(
                  color: XedColors.black.withOpacity(0.7),
                ),
              ),
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: XedColors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AspectRatio(
                    aspectRatio: 354 / 245,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 30,
                      ),
                      child: Flex(
                        direction: Axis.vertical,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          _buildTitle("Hey There!"),
                          _buidDescription(
                              "Our new version is now available for download."),
                          Flex(
                            direction: Axis.horizontal,
                            children: <Widget>[
                              Flexible(
                                child: XedButtons.watermelonButton(
                                  "UPDATE NOW",
                                  10,
                                  16,
                                  () => onUpdateTap(_mode),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
        break;
      default:
        return SizedBox();
    }
  }

  Widget _buildTitle(String title) {
    if (title is String) {
      return Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: FontFamily.tiempos,
          fontWeight: FontWeight.w600,
          fontSize: 24,
        ),
      );
    }
    return SizedBox();
  }

  Widget _buidDescription(String description) {
    if (description is String) {
      return Text(
        description,
        textAlign: TextAlign.center,
        style: RegularTextStyle(16).copyWith(
          color: XedColors.battleShipGrey,
          fontSize: 16,
        ),
      );
    }
    return SizedBox();
  }
}

Future<void> launchURL(String url, {bool forceBrowser = false}) async {
  if (await canLaunch(url)) {
    await launch(
      url,
      forceWebView: forceBrowser ? false : null,
      forceSafariVC: forceBrowser ? false : null,
    );
  } else {
    throw Exception('Could not launch $url');
  }
}

UpdateMode getUpdateMode(
  final int currentVersion,
  final int minVersion,
  final int lastestVersion,
) {
  if (currentVersion < minVersion) return UpdateMode.Force;
  if (currentVersion < lastestVersion) return UpdateMode.Normal;
  return UpdateMode.None;
}
