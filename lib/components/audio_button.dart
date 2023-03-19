import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
import 'package:yezer/models/audio_file.dart';
import 'package:yezer/themes/colors.dart';

class AudioButton extends StatefulWidget {
  final AudioFile audio;
  final Function? onPlay;
  final Function? onPause;
  final Function? onStop;
  final Function? onRemove;
  final Function? callback;
  const AudioButton(
    this.audio, {
    this.onRemove,
    this.onPlay,
    this.onPause,
    this.onStop,
    this.callback,
    super.key,
  });

  @override
  State<AudioButton> createState() => _AudioButtonState();
}

class _AudioButtonState extends State<AudioButton> {
  final AudioPlayer _player = AudioPlayer();
  bool loaded = false;
  bool seeking = false;

  late AudioFile audio;
  Function callback = () {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    audio = widget.audio;
    if (widget.callback != null) {
      callback = widget.callback!;
    }
    _player.onDurationChanged.listen((Duration d) {
      if (!d.isNegative) audio.duration = d;
      callback();
    });
    _player.onPositionChanged.listen((Duration d) {
      if (seeking) return;
      audio.elapsed = d;
      callback();
    });
    _player.onPlayerComplete.listen((event) {
      audio.lastPlayed = DateTime.now();
      callback();
    });

    _player.onPlayerStateChanged.listen((event) {
      switch (event) {
        case PlayerState.playing:
          if (!loaded) {
            _player.stop();
            setState(() {
              loaded = true;
            });
          }
          audio.onPlay(event);
          break;
        case PlayerState.paused:
          audio.onPause(event);
          break;
        case PlayerState.stopped:
          audio.onStop(event);
          break;
        case PlayerState.completed:
          audio.onComplete(event);
          break;
        default:
          return;
      }
      callback();
    });
    playAudio(audio);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
          border: Border.all(
        color: kCLight,
        width: 2,
        strokeAlign: BorderSide.strokeAlignOutside,
      )),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      audio.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: kCLight),
                    ),
                    if (!loaded) CircularProgressIndicator()
                  ],
                ),
                Text(
                  audio.counter,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: kCLight),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: kCError,
                  ),
                  onPressed: () {
                    _player.stop();
                    if (widget.onRemove != null) {
                      widget.onRemove!();
                    }
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        audio.releaseMode =
                            audio.releaseMode == ReleaseMode.loop
                                ? ReleaseMode.stop
                                : ReleaseMode.loop;
                        _player.setReleaseMode(audio.releaseMode);
                        callback();
                      },
                      child: Icon(
                        Icons.loop,
                        color: audio.releaseMode == ReleaseMode.loop
                            ? kCPrimary
                            : kCSuccess,
                        size: 20,
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: audio.state == PlayerState.playing
                              ? () => _player.pause()
                              : () => playAudio(
                                    audio,
                                  ),
                          child: Icon(
                            audio.state == PlayerState.playing
                                ? Icons.pause_circle
                                : Icons.play_circle,
                            color: audio.state == PlayerState.playing
                                ? kCError
                                : kCPrimary,
                            size: 60,
                          ),
                        ),
                        GestureDetector(
                          child: Icon(
                            Icons.stop,
                            color: audio.state == PlayerState.playing
                                ? kCError
                                : kCSuccess,
                            size: 40,
                          ),
                          onTap: () => _player.stop(),
                        ),
                      ],
                    ),
                  ],
                ),
                GestureDetector(
                  onTapDown: (details) {
                    setState(() {
                      seeking = true;
                    });
                  },
                  onTapUp: (details) {
                    setState(() {
                      seeking = false;
                    });
                    seekTo(
                      details.localPosition.dx,
                      MediaQuery.of(context).size.width - 400,
                      audio,
                      play: true,
                    );
                  },
                  onHorizontalDragDown: (details) {
                    setState(() {
                      seeking = true;
                    });
                    seekTo(
                      details.localPosition.dx,
                      MediaQuery.of(context).size.width - 400,
                      audio,
                    );
                  },
                  onHorizontalDragUpdate: (details) => seekTo(
                    details.localPosition.dx,
                    MediaQuery.of(context).size.width - 400,
                    audio,
                  ),
                  onHorizontalDragEnd: (details) {
                    setState(() {
                      seeking = false;
                    });
                    playFrom(audio);
                  },
                  child: PolygonWaveform(
                    samples: audio.waveform.samples,
                    height: 100,
                    width: MediaQuery.of(context).size.width - 400,
                    inactiveColor: kCLight,
                    activeColor: kCPrimary,
                    elapsedDuration: audio.elapsed > audio.duration
                        ? audio.duration
                        : audio.elapsed,
                    maxDuration: audio.duration ?? Duration(milliseconds: 1),
                  ),
                ),
                Column(
                  children: [
                    Slider(
                        min: 0,
                        max: 1,
                        value: audio.volume,
                        onChanged: (vol) {
                          audio.volume = vol;
                          _player.setVolume(vol);
                          callback();
                        }),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void playAudio(AudioFile audio) {
    _player.play(
      DeviceFileSource(audio.path),
      mode: PlayerMode.lowLatency,
      position: audio.elapsed,
    );
    _player.setReleaseMode(audio.releaseMode);
  }

  void playFrom(AudioFile audio) {
    _player.pause();
    playAudio(audio);
  }

  void seekTo(double wPos, double width, AudioFile audio, {play = false}) {
    double percent = wPos / width;
    if (percent > 1) percent = 1;
    if (percent < .00) percent = 0.0;
    var position = Duration(
        milliseconds: (audio.duration.inMilliseconds * percent).floor());
    audio.elapsed = position;

    callback();
    if (play) {
      playFrom(audio);
    }
  }
}
