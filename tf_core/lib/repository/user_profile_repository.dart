import 'dart:async';

import 'package:tf_core/tf_core.dart';

abstract class UserProfileRepository {
  Future<UserProfile> getMyProfile();

  Future<UserProfile> getUserProfile(String username);

  Future<UserProfile> updateMyProfile(
      String fullName,
      int gender,
      int dateOfBirth,
      String avatar,
      String nationality,
      List<String> nativeLanguages,
      ProfileSettings userSettings);
}

class UserProfileRepositoryImpl implements UserProfileRepository {
  HttpClient _client;

  UserProfileRepositoryImpl(this._client);

  @override
  Future<UserProfile> getMyProfile() {
    return _client
        .get("/user/profile/me")
        .then((data) => UserProfile.fromJson(data));
  }

  @override
  Future<UserProfile> getUserProfile(String username) async {
    var data = await _client.get('/user/profile/${Uri.encodeFull(username)}');
    return UserProfile.fromJson(data);
  }

  @override
  Future<UserProfile> updateMyProfile(
      String fullName,
      int gender,
      int dateOfBirth,
      String avatar,
      String nationality,
      List<String> nativeLanguages,
      ProfileSettings userSettings) async {
    Map<String, dynamic> body = {
      'full_name': fullName,
      'gender': gender,
      'dob': dateOfBirth,
      'nationality': nationality,
      'native_languages': nativeLanguages,
      'user_settings': userSettings?.toJson(),
      'avatar': avatar,
    }..removeWhere((key, value) => value == null);
    Log.debug('body: $body');
    var data = await _client.put("/user/profile/me", body);
    return UserProfile.fromJson(data);
  }
}
