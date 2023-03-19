import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:yezer/models/audio_file.dart';

Future<List<AudioFile>?> importAudioFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.audio,
    allowMultiple: true,
  );
  if (result == null) return null;
  List<AudioFile> files = [];
  for (final file in result.files) {
    List<double> samples = await getAudioSamples(file.path!);
    List<double> parsedSamples = filterSamples(samples);

    AudioFile audio = AudioFile(
      path: file.path!,
      name: file.name,
      size: file.size,
    );

    audio.waveform.samples = parsedSamples;
    files.add(audio);
  }

  return files;
}

List<double> filterSamples(List<double> data, {double percentage = 0.2}) {
  if (percentage <= 0 || percentage >= 1) {
    throw ArgumentError('percent must be between 0 and 1, exclusive');
  }
  final int sampleCount = (data.length * percentage).floor();
  final List<double> results = List<double>.filled(sampleCount, 0);
  int resultIndex = 0;
  double accumulated = 0;
  for (final double value in data.where((element) => element < .6)) {
    accumulated += value;
    if (resultIndex < sampleCount) {
      results[resultIndex] = value;
      resultIndex++;
    } else {
      final double average = accumulated / sampleCount;
      if (value > average) {
        results[resultIndex - 1] = value;
        accumulated -= results[resultIndex - 1];
      }
    }
  }
  return results;
}

Future<List<double>> getAudioSamples(String filePath) async {
  File audioFile = File(filePath);
  Uint8List audioBytes = await audioFile.readAsBytes();
  int numChannels = 2; // assuming mono audio
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
