import 'package:flutter/material.dart';
import 'package:yezer/components/audio_button.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: kCPrimary.withAlpha(100),
        appBar: AppBar(
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
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(
                  Icons.menu,
                  color: kCSuccess,
                ),
                onPressed: () => _scaffoldKey.currentState!.openEndDrawer(),
              ),
            )
          ],
        ),
        endDrawer: const Drawer(backgroundColor: kCPrimary),
        floatingActionButton: FloatingActionButton(
          onPressed: () async => await import(),
          tooltip: 'Import Audio File',
          backgroundColor: kCSuccess,
          child: const Icon(
            Icons.add,
            color: kCPrimary,
          ),
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
                    AudioFile audio = _audioFiles[index];
                    return AudioButton(
                      key: Key('${audio.name}+$index'),
                      audio,
                      callback: () => setState(() {}),
                      onRemove: () {
                        _audioFiles.removeAt((index));
                        setState(() {});
                      },
                    );
                  },
                )
              ]),
        ),
      ),
    );
  }

  Future<void> import() async {
    List<AudioFile>? audio = await importAudioFile();
    if (audio == null) return;

    _audioFiles.addAll(audio);
    setState(() {});
  }
}
