import 'package:tf_core/tf_core.dart';

class VideoUtils {
  /*
  videoUrl: support youtube video && media.xed.ai link
  return: link to thubmnail if posible or null
*/
  static String getThumbFromVideoUrl(String videoUrl) {
    try {
      if (hasThumbnailFromVideo(videoUrl))
        return getThumbnail(videoUrl);
      else
        return getYoutubeThumbnail(videoUrl);
    } catch (ex) {
      Log.error('error get thumbnail video by url');
      return null;
    }
  }

  /*
  videoUrl: support youtube video link
  return: link to thubmnail if posible or null
*/
  static String getThumbnail(String url) {
    if (url == null || url.isEmpty) return null;
    return url.replaceAll(RegExp(r'(.mp4)$'), '.jpg');
  }

  /*
  videoUrl: support youtube videl && media.xed.ai link
  return: link to thubmnail if posible or null
*/
  static bool hasThumbnailFromVideo(String url) {
    if (url == null || url.isEmpty) return false;
    return url.contains(RegExp(r"^https?:\/\/media.*.mp4$"));
  }

  /*
  videoUrl: support youtube videl && media.xed.ai link
  return: link to thubmnail if posible or null
*/
  static String getYoutubeThumbnail(String url) {
    try {
      final String youtubeId = getYoutubeId(url);
      if (youtubeId == null || youtubeId.isEmpty) return null;
      final String host = Config.getYoutubeThumbnail();
      final String quality = Config.getThumbnailQuality();

      return host + youtubeId + quality;
    } catch (ex) {
      Log.error('error get thumbnail youtube by url $ex');
      return null;
    }
  }

  //youtubeId: id video yotuube
  // return url of thumbnail or null
  static String getYoutubeThumbnailById(String youtubeId) {
    try {
      final String host = Config.getYoutubeThumbnail();
      final String quality = Config.getThumbnailQuality();
      return host + youtubeId + quality;
    } catch (ex) {
      Log.error('error get thumbnail by id $ex');
      return null;
    }
  }

  static bool isYoutubeUrl(url) {
    return getYoutubeId(url) is String;
  }

  /// Converts fully qualified YouTube Url to video id.
  static String getYoutubeId(String url) {
    try {
      if (url != null &&
          (url.contains('youtube.com') || url.contains('youtu.be'))) {
        for (var exp in [
          RegExp(r"v=([_\-a-zA-Z0-9]{11}).*$"),
          RegExp(r"^embed\/([_\-a-zA-Z0-9]{11}).*$"),
          RegExp(r"\/([_\-a-zA-Z0-9]{11}).*$")
        ]) {
          Match match = exp.firstMatch(url);
          if (match != null && match.groupCount >= 1) return match.group(1);
        }
      }
      return null;
    } catch (ex) {
      Log.error('error get youtube id from url $ex');
      return null;
    }
  }
}
