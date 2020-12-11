import 'dart:async';
import 'dart:core';

import 'package:tf_core/tf_core.dart';

abstract class AuthService {
  Future<RegistrationData> register(
    String email,
    String password,
    String fullName,
  );

  Future<LoginData> verifyCode(String email, String code);

  Future<bool> sendVerifyCode(String email);

  Future<bool> forgetPassword(String email);

  Future<String> verifyForgetPassword(String email, String code);

  Future<LoginData> changePassword(
      String email, String token, String newPassword);

  Future<LoginData> checkToken();

  Future<LoginData> login(String email, String password, bool remember);

  Future<LoginData> loginWithOAuth(String oauthType, String id, String token);

  Future<void> logout();

  Future<bool> isOwner(String username);

  Future<LoginData> getLoginData();

  Future<void> updateUserProfile(LoginData loginData);

  Future<String> getToken();

  Future<bool> hasDeckCreationPermission();

  Future<LoginData> registerAndLogin(
    String email,
    String password,
    String fullName,
  );
}

class AuthServiceImpl implements AuthService {
  final AuthRepository repository;
  final UserSessionRepository appSettingRepository;

  AuthServiceImpl(this.repository, this.appSettingRepository);

  @override
  Future<LoginData> login(String email, String password, bool remember) {
    return repository.login(email, password, remember).then((loginData) {
      if (loginData != null) {
        return appSettingRepository
            .saveLoginSession(loginData)
            .then((_) => Future.value(loginData));
      } else
        return Future.value(loginData);
    });
  }

  Future<LoginData> loginWithOAuth(String oauthType, String id, String token) {
    return repository.loginWithOAuth(oauthType, id, token).then((loginData) {
      if (loginData != null) {
        return appSettingRepository
            .saveLoginSession(loginData)
            .then((_) => Future.value(loginData));
      } else
        return Future.value(loginData);
    });
  }

  @override
  Future<LoginData> verifyCode(String email, String code) {
    return repository.verifyCode(email, code).then((loginData) {
      if (loginData != null) {
        return appSettingRepository
            .saveLoginSession(loginData)
            .then((_) => Future.value(loginData));
      } else
        return Future.value(loginData);
    });
  }

  @override
  Future<void> logout() async {
    try {
      await appSettingRepository.deleteLoginSession();
    } catch (e, trace) {
      Log.debug('${this.runtimeType.toString()}: ${e.toString()}');
      Log.debug('${this.runtimeType.toString()}: $trace');
    }
    return;
  }

  @override
  Future<LoginData> checkToken() async {
    try {
      var loginData = await appSettingRepository.getLoginSession();
      if (loginData != null) {
        loginData = await repository.checkSession(loginData.session.value);
        await appSettingRepository.saveLoginSession(loginData);
      }
      return loginData;
    } catch (ex) {
      await logout();
    }
    return null;
  }

  @override
  Future<LoginData> getLoginData() {
    return appSettingRepository.getLoginSession();
  }

  @override
  Future<String> getToken() {
    return appSettingRepository.getToken();
  }

  @override
  Future<RegistrationData> register(
      String email, String password, String fullName) {
    return repository.register(email, password, fullName);
  }

  @override
  Future<LoginData> registerAndLogin(
      String email, String password, String fullName) {
    return repository
        .registerAndLogin(email, password, fullName)
        .then((loginData) {
      if (loginData != null) {
        return appSettingRepository
            .saveLoginSession(loginData)
            .then((_) => Future.value(loginData));
      } else
        return Future.value(loginData);
    });
  }

  @override
  Future<LoginData> changePassword(
      String email, String token, String newPassword) {
    return repository
        .changePassword(email, token, newPassword)
        .then((loginData) {
      if (loginData != null) {
        return appSettingRepository
            .saveLoginSession(loginData)
            .then((_) => Future.value(loginData));
      } else
        return Future.value(loginData);
    });
  }

  @override
  Future<bool> forgetPassword(String email) {
    return repository.forgetPassword(email);
  }

  @override
  Future<bool> sendVerifyCode(String email) {
    return repository.sendVerifyCode(email);
  }

  @override
  Future<String> verifyForgetPassword(String email, String code) {
    return repository.verifyForgetPassword(email, code);
  }

  @override
  Future<bool> isOwner(String username) {
    return appSettingRepository.getLoginSession().then((loginData) {
      return loginData != null && loginData.userInfo.username == username;
    });
  }

  @override
  Future<void> updateUserProfile(LoginData loginData) {
    return appSettingRepository.saveLoginSession(loginData);
  }

  @override
  Future<bool> hasDeckCreationPermission() async {
    try {
      String email = (await getLoginData())?.userProfile?.email;
      return _hasDeckCreationPermission(email);
    } catch (ex) {
      Log.error("$runtimeType hasCreateDeckPermission: $ex");
      return false;
    }
  }

  bool _hasDeckCreationPermission(String email) {
    var emails = Config.getDeckCreationWhitelistEmail();
    Log.debug("$runtimeType Whitelist emails: $emails ${emails.length}");
    if (emails.isEmpty)
      return true;
    else
      return emails.contains(email);
  }
}
