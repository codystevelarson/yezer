import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:yezer/models/waveform.dart';
import 'package:yezer/utilities/duration_helpers.dart';

class AudioFile {
  static const String defaultName = 'Audio File';
  String path;
  String name;
  int size;
  String extension;
  Duration duration;
  Duration elapsed;
  DateTime? lastPlayed;
  Waveform waveform = Waveform();
  ReleaseMode releaseMode = ReleaseMode.stop;
  PlayerMode get playerMode =>
      duration.inMinutes > 10 ? PlayerMode.mediaPlayer : PlayerMode.lowLatency;
  PlayerState? state;
  String get counter =>
      '${durationToText(elapsed, match: duration)} / ${durationToText(duration)}';
  String get elapsedCounter => durationToText(elapsed, match: duration);
  String get durationCounter => durationToText(duration);
  double volume = 1;

  AudioFile({
    this.path = '',
    this.name = AudioFile.defaultName,
    this.duration = const Duration(milliseconds: 1),
    this.elapsed = const Duration(),
    this.size = 0,
    this.extension = '',
  });

  void onPlay(PlayerState playerState) {
    state = playerState;
  }

  void onPause(PlayerState playerState) {
    state = playerState;
  }

  void onStop(PlayerState playerState) {
    state = playerState;
    elapsed = Duration.zero;
  }

  void onComplete(PlayerState playerState) {
    state = playerState;
    elapsed = Duration.zero;
  }
}
