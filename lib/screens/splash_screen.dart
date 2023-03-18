import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';

class SplashScreen extends StatefulWidget {
  static const String path = '/';
  static const String name = 'splash';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final List _audioFiles = [];
  AudioPlayer _player = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purpleAccent,
          leading: const Icon(Icons.audio_file),
          title: const Text('yeZer'),
        ),
        endDrawer: const Drawer(backgroundColor: Colors.purpleAccent),
        floatingActionButton: FloatingActionButton(
          onPressed: () async => await _importAudioFile(),
          tooltip: 'Import Audio File',
          child: Icon(Icons.add),
        ),
        body: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 1,
                  ),
                  itemCount: _audioFiles.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(_audioFiles[index][0]),
                      trailing: IconButton(
                        icon: Icon(Icons.stop),
                        onPressed: () => _player.stop(),
                      ),
                      subtitle: PolygonWaveform(
                        samples: _audioFiles[index][1],
                        height: 100,
                        width: 300,
                        inactiveColor: Colors.green,
                        activeColor: Colors.blue,
                        elapsedDuration: _audioFiles[index][3],
                        maxDuration: _audioFiles[index][2],
                      ),
                      onTap: () => playAudio(_audioFiles[index][0], index),
                    );
                  },
                )
              ]),
        ),
      ),
    );
  }

  void playAudio(String path, index) {
    _player.stop();
    _player = AudioPlayer();
    _player.play(DeviceFileSource(path), mode: PlayerMode.lowLatency);

    _player.onDurationChanged.listen((Duration d) {
      if (!d.isNegative) setState(() => _audioFiles[index][2] = d);
    });
    _player.onPositionChanged.listen((Duration d) {
      setState(() => _audioFiles[index][3] = d);
    });
    _player.onPlayerComplete.listen((event) async {
      await Future.delayed(
          Duration(milliseconds: 500),
          () => setState(
              () => _audioFiles[index][3] = Duration(milliseconds: 1)));
    });
  }

  Future<void> _importAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    if (result != null) {
      String filePath = result.files.single.path!;
      var samples = await getAudioSamples(filePath);
      var filePlayer = AudioPlayer();
      await filePlayer.setSourceDeviceFile(filePath);
      filePlayer.getDuration().then((duration) async {
        if (duration == null || duration.isNegative)
          duration = Duration(milliseconds: 1);
        setState(() {
          _audioFiles.add([filePath, samples, duration, Duration.zero]);
        });
      });
    }
  }

  Future<List<double>> getAudioSamples(String filePath) async {
    File audioFile = File(filePath);
    Uint8List audioBytes = await audioFile.readAsBytes();
    int numChannels = 1; // assuming mono audio
    int bytesPerSample = 8; // assuming 16-bit audio

    List<double> samples = <double>[];
    try {
      for (int i = 0;
          i < audioBytes.lengthInBytes;
          i += bytesPerSample * numChannels) {
        for (int channel = 0; channel < numChannels; channel++) {
          int sample = 0;

          for (int j = 0; j < bytesPerSample; j++) {
            int byte = audioBytes[i + j + channel * bytesPerSample];

            if (j < bytesPerSample - 1 || bytesPerSample == 1) {
              sample += byte << (j * 8);
            } else {
              // for the last byte, we need to sign extend it
              sample += (byte & 0x7F) << (j * 8);
              if ((byte & 0x80) == 0x80) {
                sample -= 1 << (bytesPerSample * 8 - 1);
              }
            }
          }

          // convert sample to a double value in the range [-1.0, 1.0]
          samples.add(sample / ((1 << (bytesPerSample * 8 - 1)).toDouble()));
        }
      }
    } catch (e) {
      double dcOffset = samples.reduce((a, b) => a + b) / samples.length;
      samples = samples.map((sample) => sample - dcOffset).toList();
      return samples;
    }

    double dcOffset = samples.reduce((a, b) => a + b) / samples.length;
    samples = samples.map((sample) => sample - dcOffset).toList();
    return samples;
  }
}
