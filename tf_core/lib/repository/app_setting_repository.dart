import 'dart:async';
import 'dart:convert';

import 'package:tf_core/tf_core.dart';

abstract class UserSessionRepository {
  Future<bool> hasToken();

  Future<String> getToken();

  Future<LoginData> getLoginSession();

  Future<void> saveLoginSession(LoginData loginData);

  Future<void> deleteLoginSession();

  Future<bool> isFirstRun();

  Future<void> setFirstRun(bool isFirstRun);
}

class UserSessionRepositoryImpl implements UserSessionRepository {
  static const String KEY_LOGIN_DATA = "current_user_login_data";
  static const String KEY_FIRST_RUN = "first_run";
  LoginData _loginData;
  final LocalStorage _storage;

  UserSessionRepositoryImpl(this._storage);

  @override
  Future<String> getToken() {
    return getLoginSession()
        .then((data) => data != null ? data.session.value : null);
  }

  @override
  Future<LoginData> getLoginSession() async {
    if (_loginData == null) {
      var s = await _storage.get(KEY_LOGIN_DATA);
      return s != null ? LoginData.fromJson(jsonDecode(s)) : null;
    }
    return _loginData;
  }

  @override
  Future<bool> hasToken() {
    return getLoginSession().then((x) => x != null);
  }

  @override
  Future<void> saveLoginSession(LoginData loginData) {
    this._loginData = loginData;
    return _storage.put(KEY_LOGIN_DATA, jsonEncode(loginData));
  }

  @override
  Future<void> deleteLoginSession() async {
    this._loginData = null;
    await _storage.delete(KEY_LOGIN_DATA);
  }

  @override
  Future<bool> isFirstRun() async {
    var isFirstRun = await _storage.get(KEY_FIRST_RUN);
    return isFirstRun ?? false;
  }

  @override
  Future<void> setFirstRun(bool isFirstRun) async {
    return _storage.put(KEY_FIRST_RUN, isFirstRun);
  }
}
