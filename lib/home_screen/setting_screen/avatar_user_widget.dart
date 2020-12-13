import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' show Log;
import 'package:the_flashcard/common/common.dart';

class AvatarUserWidget extends StatelessWidget {
  final String url;
  final void Function() onTapAvatar;
  final void Function() onTapEdit;

  const AvatarUserWidget(
      {Key key, @required this.url, this.onTapAvatar, this.onTapEdit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Center(
        child: Container(
          alignment: Alignment.center,
          width: hp(120),
          height: hp(120),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 1.0],
              colors: [
                XedColors.waterMelon,
                Color.fromRGBO(200, 109, 215, 1),
              ],
            ),
          ),
          child: GestureDetector(
            onTap: () {
              Log.debug('fullscreen avatar');
            },
            child: Stack(
              children: <Widget>[
                Center(
                  child: CachedImage(
                    url: url,
                    width: hp(116),
                    height: hp(116),
                    errorWidget: (_, __, ___) => SizedBox(),
                    placeholder: (_, s) {
                      return XImageLoading(
                        child: Container(
                          width: hp(116),
                          height: hp(116),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 2,
                              color: XedColors.white,
                            ),
                          ),
                        ),
                      );
                    },
                    imageBuilder: (_, imageProvider) {
                      return Container(
                        width: hp(116),
                        height: hp(116),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 2,
                            color: XedColors.white,
                          ),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: imageProvider,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Center(
                  child: Container(
                    alignment: Alignment.bottomRight,
                    padding: EdgeInsets.only(right: wp(10)),
                    child: Container(
                      alignment: Alignment.center,
                      width: hp(30),
                      height: hp(30),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: XedColors.white,
                        ),
                        color: XedColors.duckEggBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Builder(
                        builder: (context) => InkWell(
                          child: Icon(
                            Icons.camera_alt,
                            size: wp(20),
                          ),
                          onTap: onTapEdit,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
