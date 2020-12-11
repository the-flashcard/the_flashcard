import 'package:intl/intl.dart';
import 'package:tf_core/tf_core.dart';

class ShortUserProfile {
  String username;
  String fullName;
  String firstName;
  String lastName;
  String avatar;

  ShortUserProfile(
    this.username,
    this.fullName, {
    this.firstName,
    this.lastName,
    this.avatar,
  });

  ShortUserProfile.from(UserProfile profile) {
    username = profile.username;
    fullName = profile.fullName;
    firstName = profile.firstName;
    lastName = profile.lastName;
    avatar = profile.avatar;
  }

  ShortUserProfile.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    fullName = json['full_name'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    avatar = UrlUtils.resolveUploadUrl(json['avatar']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['username'] = this.username;
    data['full_name'] = this.fullName;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['avatar'] = this.avatar;
    return data;
  }

  @override
  String toString() {
    return "avatar $avatar - fullname $fullName";
  }
}

class UserProfile {
  bool alreadyConfirmed;
  String username;
  String fullName;
  String firstName;
  String lastName;
  String email;
  String phone;
  int gender;
  int dob;
  String nationality;
  final List<String> nativeLanguages = [];
  String avatar;
  String oauthType;
  Map<String, String> extraInfo;
  ProfileSettings userSettings;
  int updatedTime;
  int createdTime;

  UserProfile();

  UserProfile.fromJson(Map<String, dynamic> json) {
    oauthType = json['oauth_type'];
    alreadyConfirmed = json['already_confirmed'];
    username = json['username'];
    fullName = json['full_name'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    phone = json['phone'];
    gender = json['gender'];
    dob = json['dob'];
    nationality = json['nationality'];
    if (json['native_languages'] != null) {
      json['native_languages'].forEach((v) => nativeLanguages.add(v));
    }
    if (json['user_settings'] != null) {
      userSettings = ProfileSettings.fromJson(json['user_settings']);
    } else
      userSettings = ProfileSettings();

    avatar = UrlUtils.resolveUploadUrl(json['avatar']);
    createdTime = json['created_time'];
    updatedTime = json['updated_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['oauth_type'] = this.oauthType;
    data['already_confirmed'] = this.alreadyConfirmed;
    data['username'] = this.username;
    data['full_name'] = this.fullName;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['gender'] = this.gender;
    data['dob'] = this.dob;
    data['nationality'] = this.nationality;
    data['native_languages'] = this.nativeLanguages;
    data['avatar'] = this.avatar;
    if (userSettings != null) {
      data['user_settings'] = userSettings.toJson();
    }
    data['created_time'] = this.createdTime;
    data['updated_time'] = this.updatedTime;
    return data;
  }
}

class ProfileSettings {
  String nationality;
  List<String> nativeLanguages = [];
  NotificationSchedule reviewNotificationSchedule;
  BotSettings botSettings;

  ProfileSettings({
    this.nationality,
    this.nativeLanguages = const <String>[],
    this.reviewNotificationSchedule,
    this.botSettings,
  });

  ProfileSettings.fromJson(Map<String, dynamic> json) {
    nationality = json['nationality'];
    if (json['native_languages'] != null) {
      json['native_languages'].forEach((v) => nativeLanguages.add(v));
    }
    if (json['review_notification_schedule'] != null) {
      reviewNotificationSchedule =
          NotificationSchedule.fromJson(json['review_notification_schedule']);
    }
    if (json['bot_settings'] != null) {
      botSettings = BotSettings.fromJson(json['bot_settings']);
    } else {
      botSettings = BotSettings();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (nationality != null) {
      data['nationality'] = nationality;
    }
    if (nativeLanguages != null) {
      data['native_languages'] = nativeLanguages;
    }
    if (reviewNotificationSchedule != null)
      data['review_notification_schedule'] =
          reviewNotificationSchedule.toJson();
    if (botSettings != null) data['bot_settings'] = botSettings.toJson();
    return data;
  }
}

class BotSettings {
  XGradientColor messageBgColor;
  bool autoPlayAudio;

  BotSettings({
    this.autoPlayAudio,
    this.messageBgColor,
  });

  BotSettings.fromJson(Map<String, dynamic> json) {
    if (json['message_bg_color'] != null) {
      messageBgColor = XGradientColor.fromJson(json['message_bg_color']);
    } else {
      messageBgColor = XGradientColor.init();
    }
    autoPlayAudio = json['auto_play_audio'] ?? true;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (messageBgColor != null)
      data['message_bg_color'] = messageBgColor.toJson();
    data['auto_play_audio'] = autoPlayAudio ?? true;
    return data;
  }
}

class NotificationSchedule {
  String timeStr;
  String timezoneName;

  NotificationSchedule({
    this.timeStr,
    this.timezoneName,
  });

  NotificationSchedule.fromJson(Map<String, dynamic> json) {
    timeStr = json['time_str'];
    timezoneName = json['timezone_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['time_str'] = this.timeStr;
    data['timezone_name'] = this.timezoneName;
    return data;
  }

  NotificationSchedule.fromDateTime(DateTime time) {
    String timeString = TimeUtils.toStringTime(time);
    this.timeStr = timeString;
    this.timezoneName = time.timeZoneName;
  }

  DateTime toDateTime() {
    final DateFormat dateFormat = DateFormat.Hm();
    return dateFormat.parse(timeStr);
  }
}
