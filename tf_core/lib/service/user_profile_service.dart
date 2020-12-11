import 'dart:async';

import 'package:tf_core/tf_core.dart';

abstract class UserProfileService {
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

class UserProfileServiceImpl implements UserProfileService {
  UserProfileRepository _repository;

  UserProfileServiceImpl(this._repository);

  @override
  Future<UserProfile> getMyProfile() {
    return _repository.getMyProfile();
  }

  @override
  Future<UserProfile> getUserProfile(String username) {
    return _repository.getUserProfile(username);
  }

  @override
  Future<UserProfile> updateMyProfile(
      String fullName,
      int gender,
      int dateOfBirth,
      String avatar,
      String nationality,
      List<String> nativeLanguages,
      ProfileSettings userSettings) {
    return _repository.updateMyProfile(
      fullName,
      gender,
      dateOfBirth,
      avatar,
      nationality,
      nativeLanguages,
      userSettings,
    );
  }
}
