import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
import 'package:yezer/models/audio_file.dart';
import 'package:yezer/services/audio/audio_services.dart';
import 'package:yezer/themes/colors.dart';

class SplashScreen extends StatefulWidget {
  static const String path = '/';
  static const String name = 'splash';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final List<AudioFile> _audioFiles = [];
  AudioPlayer _player = AudioPlayer();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: kCPrimary.withAlpha(100),
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(
                  Icons.menu,
                  color: kCPrimary,
                ),
                onPressed: () => _scaffoldKey.currentState!.openEndDrawer(),
              ),
            )
          ],
          backgroundColor: kCPrimary,
          leading: const Icon(
            Icons.audio_file,
            color: kCSuccess,
          ),
          title: Center(
            child: Text(
              'yezer',
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge!
                  .copyWith(color: kCSuccess),
            ),
          ),
        ),
        endDrawer: const Drawer(backgroundColor: kCPrimary),
        floatingActionButton: FloatingActionButton(
          onPressed: () async => import(),
          tooltip: 'Import Audio File',
          child: const Icon(
            Icons.add,
            color: kCPrimary,
          ),
          backgroundColor: kCSuccess,
        ),
        body: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _audioFiles.length,
                  itemBuilder: (BuildContext context, int index) {
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
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: []),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: _audioFiles[index].state ==
                                          PlayerState.playing
                                      ? () => _player.pause()
                                      : () => playAudio(
                                            _audioFiles[index],
                                          ),
                                  child: Icon(
                                    _audioFiles[index].state ==
                                            PlayerState.playing
                                        ? Icons.pause_circle
                                        : Icons.play_circle,
                                    color: kCPrimary,
                                    size: 60,
                                  ),
                                ),
                                GestureDetector(
                                  child: const Icon(
                                    Icons.stop,
                                    color: kCSuccess,
                                    size: 40,
                                  ),
                                  onTap: () => _player.stop(),
                                ),
                                GestureDetector(
                                  // onTapDown: (details) =>
                                  //     playFrom(_audioFiles[index]),
                                  onHorizontalDragDown: (details) => seekTo(
                                    details.localPosition.dx,
                                    MediaQuery.of(context).size.width - 200,
                                    _audioFiles[index],
                                  ),
                                  onHorizontalDragUpdate: (details) => seekTo(
                                    details.localPosition.dx,
                                    MediaQuery.of(context).size.width - 200,
                                    _audioFiles[index],
                                  ),
                                  onHorizontalDragEnd: (details) =>
                                      playFrom(_audioFiles[index]),
                                  child: PolygonWaveform(
                                    samples:
                                        _audioFiles[index].waveform.samples,
                                    height: 100,
                                    width:
                                        MediaQuery.of(context).size.width - 200,
                                    inactiveColor: kCLight,
                                    activeColor: kCPrimary,
                                    elapsedDuration: _audioFiles[index].elapsed,
                                    maxDuration: _audioFiles[index].duration,
                                  ),
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: kCError,
                                      ),
                                      onPressed: () {
                                        _audioFiles.removeAt((index));
                                        _player.stop();
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              ]),
        ),
      ),
    );
  }

  void playAudio(AudioFile audio) {
    _player.stop();
    _player = AudioPlayer();
    _player.play(DeviceFileSource(audio.path),
        mode: PlayerMode.lowLatency, position: audio.elapsed);

    _player.onDurationChanged.listen((Duration d) {
      if (!d.isNegative) setState(() => audio.duration = d);
    });
    _player.onPositionChanged.listen((Duration d) {
      setState(() => audio.elapsed = d);
    });
    _player.onPlayerComplete.listen((event) {
      audio.lastPlayed = DateTime.now();
    });

    _player.onPlayerStateChanged.listen((event) {
      switch (event) {
        case PlayerState.playing:
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
    });
  }

  void playFrom(AudioFile audio) {
    _player.pause();
    playAudio(audio);
  }

  void seekTo(double wPos, double width, AudioFile audio, {play = false}) {
    double percent = wPos / width;
    print('$wPos - $width');
    if (percent > 1) return;
    var position = Duration(
        milliseconds: (audio.duration.inMilliseconds * percent).floor());
    audio.elapsed = position;
    setState(() {});
    print(position);
  }

  Future<void> import() async {
    AudioFile? audio = await importAudioFile();
    if (audio == null) return;

    _audioFiles.add(audio);
    setState(() {});
  }
}
