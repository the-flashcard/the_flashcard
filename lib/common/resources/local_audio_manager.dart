import 'package:audioplayers/audio_cache.dart';

class LocalAudioManager {
  static const String CorrectSoundFile = 'sound_correct_answer.mp3';
  static const String IncorrectSoundFile = 'sound_incorrect_answer.mp3';

  LocalAudioManager._() {
    effectPlayer.loadAll([
      CorrectSoundFile,
      IncorrectSoundFile,
    ]);
  }

  static AudioCache effectPlayer = AudioCache(prefix: 'audios/');

  static void playSound(String file) {
    effectPlayer.play(file);
  }

  static void playCorrectSound() {
    playSound(CorrectSoundFile);
  }

  static void playIncorrectSound() {
    playSound(IncorrectSoundFile);
  }
}
