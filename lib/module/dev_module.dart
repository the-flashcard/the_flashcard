import 'dart:io';

import 'package:ddi/di.dart';
import 'package:ddi/module.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:tf_core/tf_core.dart';
import 'package:the_flashcard/common/cached_image/x_file_cached_manager.dart';
import 'package:the_flashcard/deck_creation/audio/x_audio_player.dart';
import 'package:the_flashcard/error_handling_service.dart';
import 'package:the_flashcard/overlay_manager.dart';

class DevModule extends AbstractModule {
  LocalStorage _storage;
  DevModule(this._storage);
  @override
  void init() async {
    PaintingBinding.instance.imageCache.maximumSize =
        Config.getTotalImageInCache();
    PaintingBinding.instance.imageCache.maximumSizeBytes =
        Config.getTotalImageSizeInCache();

    bind(LocalStorage).to(_storage);

    bind("image_cache_manager").to(_buildImageCachedManager());
    bind("audio_cache_manager").to(_buildAudioCachedManager());
    bind("auth_dio_client").to(_buildAuthAPIClient());
    bind("api_dio_client").to(_buildAPIClient());
    bind("media_api_dio_client").to(_buildMediaAPIClient());
    bind("upload_dio_client").to(_buildUploadClient());
    bind('overlay_manager').to(OverLayManger());

    bind(ErrorHandlingService).to(ErrorHandlingService([]));

    bind(UserSessionRepository).to(_buildUserSessionRepository());

    bind(AuthRepository).to(_authRepository());
    bind(AuthService).to(_authService());

    bind(XDictRepository).to(_xdictRepository());
    bind(XDictService).to(_buildXDictService());

    bind(UserProfileRepository).to(_userProfileRepository());
    bind(UserProfileService).to(_userProfileService());

    bind(VotingRepository).to(_votingRepository());
    bind(VotingService).to(_votingService());

    bind(DeckRepository).to(_deckRepository());

    bind(CardRepository).to(_cardRepository());
    bind(GenerateCardRepository).to(_generateCardRepository());

    bind(SRSRepository).to(_srsRepository());
    bind(DeckService).to(_deckService());
    bind(SRSService).to(_srsService());

    bind(StatisticRepository).to(_statisticRepository());
    bind(StatisticService).to(_statisticService());

    bind(UploadRepository).to(_uploadRepository());
    bind(UploadService).to(_uploadService());

    bind(AudioPlayerManager).to(_buildAudioManager());

    bind(SearchImageRepository).to(_searchImageRepository());
    bind(SearchImageService).to(_searchImageService());
  }

  FileFetcherResponse _handleErrorCacheImage(dynamic ex, String url) {
    Log.error('XFileCachedManager:: Error load $url, $ex');
    return HttpFileFetcherResponse(null);
  }

  XFileCachedManager _buildImageCachedManager() {
    final Duration connectTimeout = Duration(seconds: 10);
    FileFetcher fileFetcher = (String url, {Map<String, String> headers}) {
      return http
          .get(url)
          .timeout(connectTimeout)
          .then((response) => HttpFileFetcherResponse(response))
          .catchError((ex) => _handleErrorCacheImage(ex, url));
    };

    return XFileCachedManager(
      "x_image_cache",
      maxAgeCachedDays: 7,
      totalCachedObjects: 50,
      fileFetcher: fileFetcher,
    );
  }

  XFileCachedManager _buildAudioCachedManager() {
    return XFileCachedManager(
      "x_audio_cache",
      maxAgeCachedDays: 15,
      totalCachedObjects: 50,
    );
  }

  HttpClient _buildAuthAPIClient() {
    Log.debug('API HOST = ${Config.getString("api_host")}');
    Dio dio = Dio(BaseOptions(
        baseUrl: Config.getString("api_host"),
        connectTimeout: 10000,
        receiveTimeout: 15000,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'}));
    return HttpClient(dio);
  }

  HttpClient _buildMediaAPIClient() {
    Dio dio = Dio(BaseOptions(
        baseUrl: Config.getString('upload_host'),
        connectTimeout: 10000,
        receiveTimeout: 15000,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'}));

    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options) async {
      AuthService authService = DI.get(AuthService);
      String token = await authService?.getToken();
      if (token != null) {
        options.headers["Authorization"] = token;
      }
      return options;
    }, onResponse: (Response response) {
      // Do something with response data
      return response;
    }, onError: (DioError e) {
      // Do something with response error
      return e; //continue
    }));
    return HttpClient(dio);
  }

  HttpClient _buildAPIClient() {
    Dio dio = Dio(BaseOptions(
        baseUrl: Config.getString("api_host"),
        connectTimeout: 10000,
        receiveTimeout: 15000,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'}));

    dio.interceptors.add(InterceptorsWrapper(
        onRequest: (RequestOptions options) async {
          AuthService authService = DI.get(AuthService);
          String token = await authService?.getToken();
          if (token != null) {
            options.headers["Authorization"] = token;
          }
          return options;
        },
        onResponse: (Response response) => response,
        onError: (DioError error) {
          var errorService =
              this.get<ErrorHandlingService>(ErrorHandlingService);
          errorService.handleDioError(error);
          return error;
        }));
    return HttpClient(dio);
  }

  AuthRepository _authRepository() {
    HttpClient client = this.get("auth_dio_client");
    return AuthRepositoryImpl(client);
    // return MockAuthenRepository(client);
  }

  XDictRepository _xdictRepository() {
    final HttpClient client = this.get("api_dio_client");
    return XDictRepositoryImpl(client);
  }

  HttpClient _buildUploadClient() {
    Dio dio = Dio(BaseOptions(
        baseUrl: Config.getString("upload_host"),
        connectTimeout: 10000,
        receiveTimeout: 30000,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'
        }));

    Log.debug(dio.options.baseUrl);

    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options) async {
      try {
        AuthService authService = DI.get(AuthService);
        String token = await authService?.getToken();
        if (token != null) {
          Log.debug("Upload token: $token");
          options.headers["Authorization"] = token;
        }
      } catch (e) {
        Log.error("Add authorization token: $e");
      }
      return options;
    }, onResponse: (Response response) {
      // Do something with response data
      return response;
    }, onError: (DioError e) {
      // Do something with response error
      return e; //continue
    }));
    return HttpClient(dio);
  }

  AuthService _authService() {
    AuthRepository repo = this.get(AuthRepository);
    UserSessionRepository appSettingRepo = this.get(UserSessionRepository);
    return AuthServiceImpl(repo, appSettingRepo);
  }

  UserProfileRepository _userProfileRepository() {
    HttpClient client = this.get("api_dio_client");
    return UserProfileRepositoryImpl(client);
  }

  UserProfileService _userProfileService() {
    UserProfileRepository repo = this.get(UserProfileRepository);
    return UserProfileServiceImpl(repo);
  }

  StatisticRepository _statisticRepository() {
    HttpClient client = this.get("api_dio_client");
    return StatisticRepositoryImpl(client);
  }

  StatisticService _statisticService() {
    StatisticRepository repo = this.get(StatisticRepository);
    return StatisticServiceImpl(repo);
  }

  VotingRepository _votingRepository() {
    HttpClient client = this.get("api_dio_client");
    return VotingRepositoryImpl(client);
  }

  VotingService _votingService() {
    VotingRepository repository = this.get(VotingRepository);
    return VotingServiceImpl(repository);
  }

  DeckRepository _deckRepository() {
    HttpClient client = this.get("api_dio_client");
    return DeckRepositoryImpl(client);
    // return MockDeckRepository();
  }

  CardRepository _cardRepository() {
    HttpClient client = this.get("api_dio_client");
    return CardRepositoryImpl(client);
  }

  SRSRepository _srsRepository() {
    HttpClient client = this.get("api_dio_client");
    return SRSRepositoryImpl(client);
  }

  GenerateCardRepository _generateCardRepository() {
    HttpClient client = this.get("api_dio_client");
    return GenerateCardRepositoryImpl(client);
  }

  UploadRepository _uploadRepository() {
    HttpClient client = this.get("upload_dio_client");
    return UploadRepositoryImpl(client);
  }

  DeckService _deckService() {
    DeckRepository repo = this.get(DeckRepository);
    CardRepository cardRepo = this.get(CardRepository);
    GenerateCardRepository generateCardRepo = this.get(GenerateCardRepository);
    VotingService votingService = this.get(VotingService);
    return DeckServiceImpl(repo, cardRepo, generateCardRepo, votingService);
  }

  SRSService _srsService() {
    SRSRepository repo = this.get(SRSRepository);
    CardRepository cardRepo = this.get(CardRepository);
    return SRSServiceImpl(repo, cardRepo);
  }

  UploadService _uploadService() {
    return UploadServiceImpl(_uploadRepository());
  }

  XDictService _buildXDictService() {
    final XDictRepository repository =
        this.get<XDictRepository>(XDictRepository);
    return XDictServiceImpl(repository);
  }

  AudioPlayerManager _buildAudioManager() {
    return AudioPlayerManager();
  }

  SearchImageRepository _searchImageRepository() {
    String url = Config.getString('google_search_host');
    String cx = Config.getString('google_search_cx');
    String key = Config.getString('google_search_key');
    return GoogleSearchImageRepository(
      url: url,
      cx: cx,
      key: key,
    );
  }

  SearchImageService _searchImageService() {
    SearchImageRepository imageRepository = this.get(SearchImageRepository);
    return SearchImageServiceImpl(imageRepository);
  }

  UserSessionRepository _buildUserSessionRepository() {
    return UserSessionRepositoryImpl(this.get(LocalStorage));
  }
}
