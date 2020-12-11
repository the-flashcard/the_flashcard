import 'package:tf_core/tf_core.dart';

class LoginData {
  UserSession session;
  UserInfo userInfo;
  UserProfile userProfile;

  LoginData({this.session, this.userInfo, this.userProfile});

  LoginData.fromJson(Map<String, dynamic> json) {
    session =
        json['session'] != null ? UserSession.fromJson(json['session']) : null;
    userInfo =
        json['user_info'] != null ? UserInfo.fromJson(json['user_info']) : null;
    userProfile = json['user_profile'] != null
        ? UserProfile.fromJson(json['user_profile'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (session != null) data['session'] = this.session.toJson();
    if (userInfo != null) data['user_info'] = this.userInfo.toJson();
    if (userProfile != null) data['user_profile'] = this.userProfile.toJson();
    return data;
  }
}

class RegistrationData {
  UserInfo userInfo;
  UserProfile userProfile;

  RegistrationData({this.userInfo, this.userProfile});

  RegistrationData.fromJson(Map<String, dynamic> json) {
    userInfo =
        json['user_info'] != null ? UserInfo.fromJson(json['user_info']) : null;
    userProfile = json['user_profile'] != null
        ? UserProfile.fromJson(json['user_profile'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (userInfo != null) data['user_info'] = this.userInfo.toJson();
    if (userProfile != null) data['user_profile'] = this.userProfile.toJson();
    return data;
  }
}
