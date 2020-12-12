import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart';
import 'package:the_flashcard/overlay_manager.dart';

import 'common/common.dart';

class VersionCheckerWidget extends StatefulWidget {
  final Widget child;
  VersionCheckerWidget({
    Key key,
    this.child,
  }) : super(key: key);

  _VersionCheckerWidgetState createState() => _VersionCheckerWidgetState();
}

class _VersionCheckerWidgetState extends State<VersionCheckerWidget> {
  OverLayManger overLayManger;

  @override
  void initState() {
    super.initState();
    checkVersion(context);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void checkVersion(BuildContext context) {
    void _onTapSkip(UpdateMode currentMode) {
      try {
        overLayManger.remove();
      } catch (ex) {
        Log.error(ex);
      }
    }

    void _onTapUpdate(UpdateMode currentMode) {
      try {
        launchURL(Config.getString('deeplink_appstore'));
      } catch (ex) {
        Log.error(ex);
      }
    }

    UpdateMode updateMode = getUpdateMode(
      Config.getCurrentVersion(),
      Config.getMinVersion(),
      Config.getLatestVersion(),
    );
    if (updateMode != UpdateMode.None)
      overLayManger.display(
        context,
        VersionPopUp(
          updateMode,
          onSkipTap: _onTapSkip,
          onUpdateTap: _onTapUpdate,
        ),
      );
  }
}
