import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:tf_core/tf_core.dart';

abstract class AuthRepository {
  Future<LoginData> checkSession(String ssid);

  Future<LoginData> login(String email, String password, bool remember);

  Future<LoginData> loginWithOAuth(String oauthType, String id, String token);

  Future<RegistrationData> register(
      String email, String password, String fullName);

  Future<LoginData> verifyCode(String email, String code);

  Future<bool> sendVerifyCode(String email);

  Future<bool> forgetPassword(String email);

  Future<String> verifyForgetPassword(String email, String code);

  Future<LoginData> changePassword(
      String email, String token, String newPassword);

  Future<LoginData> registerAndLogin(
      String email, String password, String fullName);
}

class AuthRepositoryImpl implements AuthRepository {
  HttpClient _client;

  AuthRepositoryImpl(this._client);

  @override
  Future<LoginData> checkSession(String ssid) async {
    Options options = Options(
        responseType: ResponseType.plain,
        headers: {HttpHeaders.authorizationHeader: ssid});
    var data = await _client.get("/user/auth/check_session", options: options);
    return LoginData.fromJson(data);
  }

  @override
  Future<LoginData> login(String email, String password, bool remember) async {
    Map<String, dynamic> body = {
      'email': email,
      'password': password,
      'remember': remember
    };
    print('body:: $body');
    var data = await _client.post("/user/auth/login", body);
    return LoginData.fromJson(data);
  }

  @override
  Future<LoginData> loginWithOAuth(
      String oauthType, String id, String token) async {
    Map<String, dynamic> body = {
      'oauth_type': oauthType,
      'id': id,
      'token': token
    };
    var data = await _client.post("/user/auth/login_oauth", body);
    return LoginData.fromJson(data);
  }

  @override
  Future<RegistrationData> register(
      String email, String password, String fullName) async {
    Map<String, dynamic> body = {
      'email': email,
      'password': password,
      'full_name': fullName
    };
    var data = await _client.post("/user/auth/register", body);
    return RegistrationData.fromJson(data);
  }

  @override
  Future<LoginData> registerAndLogin(
      String email, String password, String fullName) async {
    Map<String, dynamic> body = {
      'email': email,
      'password': password,
      'full_name': fullName,
    };
    var data = await _client.post("/user/auth/register_and_login", body);
    return LoginData.fromJson(data);
  }

  @override
  Future<bool> sendVerifyCode(String email) async {
    Map<String, dynamic> body = {'email': email};
    var data = await _client.post("/user/auth/verify_code/send", body) as bool;
    return data;
  }

  @override
  Future<LoginData> verifyCode(String email, String code) async {
    Map<String, dynamic> body = {'email': email, 'verify_code': code};
    var data = await _client.post("/user/auth/verify_code", body);
    return LoginData.fromJson(data);
  }

  @override
  Future<bool> forgetPassword(String email) async {
    Map<String, dynamic> body = {'email': email};
    var data = await _client.post("/user/auth/forgot_password", body) as bool;
    return data;
  }

  @override
  Future<String> verifyForgetPassword(String email, String code) async {
    Map<String, dynamic> body = {'email': email, 'verify_code': code};
    var data = await _client.post(
        "/user/auth/forgot_password/verify_code", body) as String;
    return data;
  }

  @override
  Future<LoginData> changePassword(
      String email, String token, String newPassword) async {
    Map<String, dynamic> body = {
      'email': email,
      'email_token': token,
      'new_password': newPassword
    };
    var data = await _client.post("/user/auth/forgot_password/change", body);
    return LoginData.fromJson(data);
  }
}

class MockAuthenRepository extends AuthRepositoryImpl {
  final _fakeData = LoginData(
    session: UserSession(value: 'fake'),
    userProfile: UserProfile.fromJson({
      'username': 'fake-username',
      'fullName': 'Cooky',
      'avatar':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcRER_W23Edog0op6Mf0kLqRCOeMFrRxBc_VSg&usqp=CAU',
    }),
  );

  MockAuthenRepository(BaseClient client) : super(client);

  @override
  Future<LoginData> checkSession(String ssid) async {
    return Future.value(_fakeData);
  }

  @override
  Future<LoginData> login(String email, String password, bool remember) async {
    return Future.delayed(const Duration(seconds: 3), () => _fakeData);
  }

  @override
  Future<LoginData> registerAndLogin(
      String email, String password, String fullName) async {
    return Future.delayed(const Duration(seconds: 3), () => _fakeData);
  }
}
