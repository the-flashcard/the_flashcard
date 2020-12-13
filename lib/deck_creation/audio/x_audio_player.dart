import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:ddi/di.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:tf_core/tf_core.dart';

class XAudioPlayer {
  static BaseCacheManager cachedManager = DI.get("audio_cache_manager");

  final AudioPlayer _player = AudioPlayer();

  AudioPlayerState get state => _player.state;

  Future dispose() async {
    await _player?.dispose();
  }

  Future<int> play(
    String url, {
    bool isLocal = false,
    double volume = 1.0,
    // position must be null by default to be compatible with radio streams
    Duration position,
    bool respectSilence = false,
    bool stayAwake = false,
  }) async {
    int result = -404;
    if (url != null) {
      await _player.setVolume(1.0);
      result = await _play(
        url,
        volume: volume,
        position: position,
        respectSilence: respectSilence,
        stayAwake: stayAwake,
      );
    }
    return result;
  }

  Future<int> _play(
    String url, {
    double volume = 1.0,
    // position must be null by default to be compatible with radio streams
    Duration position,
    bool respectSilence = false,
    bool stayAwake = false,
  }) async {
    if ((Platform.isAndroid || Platform.isFuchsia) &&
        url.contains('dictionary.cambridge.org')) {
      File file = await cachedManager.getSingleFile(url);
      if (file != null) {
        return await _player
            .play(
              url,
              volume: volume,
              position: position,
              respectSilence: respectSilence,
              stayAwake: stayAwake,
            )
            .catchError((e) => {Log.error(e)});
      } else
        return 0;
    }

    return await _player
        .play(
          url,
          volume: volume,
          position: position,
          respectSilence: respectSilence,
          stayAwake: stayAwake,
        )
        .catchError((e) => {Log.error(e)});
  }

  Future<int> stop() async {
    Log.debug("$runtimeType.stop");
    return _player.stop().catchError((e) => Log.error(e));
  }

  Future<int> pause() async {
    Log.debug("$runtimeType.pause");
    return _player.pause().catchError((e) => Log.error(e));
  }

  void onStateChanged(void Function(AudioPlayerState state) callback) {
    _player.onPlayerStateChanged.listen(callback);
  }

  void onDurationChanged(void Function(Duration duration) callback) {
    _player.onDurationChanged.listen(callback);
  }

  void onAudioPositionChanged(void Function(Duration duration) callback) {
    _player.onAudioPositionChanged.listen(callback);
  }

  void onCompletion(void Function(void) callback) {
    _player.onPlayerCompletion.listen(callback, onError: callback);
  }

  void onError(void Function(String msg) callback) {
    _player.onPlayerError.listen(callback);
  }
}

class AudioPlayerManager {
  static final player = XAudioPlayer();

  XAudioPlayer _activePlayer;
  final Map<String, XAudioPlayer> _mapPlayers = Map();

  void registerOnAudioStateChanged(
      String url, void Function(AudioPlayerState state) callback) {
    if (callback != null && _mapPlayers.containsKey(url)) {
      XAudioPlayer player = _mapPlayers[url];
      player.onStateChanged(callback);
    }
  }

  void registerOnError(String url, void Function(String msg) cb) {
    if (cb != null && _mapPlayers.containsKey(url)) {
      XAudioPlayer player = _mapPlayers[url];
      player.onError(cb);
    }
  }

  void registerOnCompletion(String url, void Function(void) cb) {
    if (cb != null && _mapPlayers.containsKey(url)) {
      XAudioPlayer player = _mapPlayers[url];
      player.onCompletion(cb);
    }
  }

  void registerOnDurationChanged(
      String url, void Function(Duration duration) cb) {
    if (cb != null && _mapPlayers.containsKey(url)) {
      XAudioPlayer player = _mapPlayers[url];
      player.onDurationChanged(cb);
    }
  }

  void onAudioPositionChanged(String url, void Function(Duration duration) cb) {
    if (cb != null && _mapPlayers.containsKey(url)) {
      XAudioPlayer player = _mapPlayers[url];
      player.onAudioPositionChanged(cb);
    }
  }

  Future<void> setActivePlayer(XAudioPlayer newPlayer) async {
    if (_activePlayer != newPlayer) {
      if (_activePlayer != null) {
        await _activePlayer.pause();
      }
      _activePlayer = newPlayer;
    }
  }

  void add(String url) {
    if (_mapPlayers.containsKey(url)) {
      XAudioPlayer player = _mapPlayers[url];
      setActivePlayer(player);
    } else {
      XAudioPlayer newPlayer = XAudioPlayer();
      _mapPlayers[url] = newPlayer;
    }
  }

  Future<void> play(String url) async {
    try {
      await _activePlayer?.stop();
      if (_mapPlayers.containsKey(url)) {
        XAudioPlayer player = _mapPlayers[url];
        setActivePlayer(player);
        await player.play(url);
      } else {
        XAudioPlayer newPlayer = XAudioPlayer();
        _mapPlayers[url] = newPlayer;
        setActivePlayer(newPlayer);
        await newPlayer.play(url);
      }
    } catch (ex) {
      Log.error(ex);
    }
  }

  Future<void> pause(String url) async {
    if (_mapPlayers.containsKey(url)) {
      XAudioPlayer player = _mapPlayers[url];
      if (player.state == AudioPlayerState.PLAYING) {
        await player.pause().catchError((e) => Log.error(e));
      }
      if (player == _activePlayer) {
        _activePlayer = null;
      }
    }
  }

  void _registerCompletion(XAudioPlayer player) {
    if (player != null) {
      player.onCompletion((event) {
        Log.debug("XAudioPlayer::onCompletion");
        if (player == _activePlayer) {
          Log.debug("Reset currentActive");
          _activePlayer = null;
        }
      });
    }
  }

  bool isPlaying(url) {
    if (_mapPlayers.containsKey(url)) {
      XAudioPlayer player = _mapPlayers[url];
      return player.state == AudioPlayerState.PLAYING;
    }
    return false;
  }

  Future<void> stop(String url) async {
    if (_mapPlayers.containsKey(url)) {
      XAudioPlayer player = _mapPlayers[url];
      if (player.state == AudioPlayerState.PLAYING) {
        setActivePlayer(null);
        await player.stop().catchError((e) => Log.error(e));
      }
    }
  }

  void addNew(String url, {bool autoPlay = false}) {
    if (!_mapPlayers.containsKey(url)) {
      XAudioPlayer newPlayer = XAudioPlayer();
      _registerCompletion(newPlayer);
      _mapPlayers[url] = newPlayer;
      if (autoPlay) {
        newPlayer.play(url);
      }
    }
  }

  void removeUrl(String url) async {
    if (_mapPlayers.containsKey(url)) {
      XAudioPlayer player = _mapPlayers[url];
      await player.stop();
      player.dispose();
    }
    _mapPlayers.remove(url);
  }
}
