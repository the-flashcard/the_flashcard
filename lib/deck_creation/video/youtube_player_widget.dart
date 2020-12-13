import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_youtube/flutter_youtube.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';

class YoutubePlayerWidget extends StatelessWidget {
  final String youtubeId;

  YoutubePlayerWidget({Key key, this.youtubeId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String thumbnail = core.VideoUtils.getYoutubeThumbnailById(youtubeId);
    return InkWell(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          thumbnail is String
              ? CachedImage(
                  url: thumbnail,
                  imageBuilder: (_, ImageProvider imageProvider) {
                    return Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                )
              : SizedBox(),
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromRGBO(43, 43, 43, 0.6),
            ),
            child: Center(
              child: SvgPicture.asset(
                Assets.icPlay,
                color: XedColors.white,
                width: 30,
                height: 30,
              ),
            ),
          ),
        ],
      ),
      onTap: () {
        FlutterYoutube.playYoutubeVideoById(
          apiKey: core.Config.getYoutubeApiKey(),
          videoId: youtubeId,
          autoPlay: true,
          fullScreen: true,
        );
      },
    );
  }
}
