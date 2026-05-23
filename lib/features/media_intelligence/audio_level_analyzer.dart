import 'dart:math' as math;
import 'dart:typed_data';

class AudioLevelAnalyzer {
  const AudioLevelAnalyzer({this.windowMillis = 100});

  final int windowMillis;

  AudioLevelAnalysis analyzeWav(Uint8List bytes) {
    final wav = PcmWavData.parse(bytes);
    if (windowMillis <= 0) {
      throw const AudioLevelException('Window audio tidak valid.');
    }

    final samplesPerWindow = (wav.sampleRate * windowMillis / 1000)
        .round()
        .clamp(1, wav.samples.length);
    final windows = <AudioLevelWindow>[];
    for (var start = 0; start < wav.samples.length; start += samplesPerWindow) {
      final end = math.min(start + samplesPerWindow, wav.samples.length);
      var peak = 0.0;
      var squareSum = 0.0;
      for (var index = start; index < end; index += 1) {
        final value = wav.samples[index].abs();
        peak = math.max(peak, value);
        squareSum += value * value;
      }
      final rms = math.sqrt(squareSum / (end - start));
      windows.add(
        AudioLevelWindow(
          startMillis: (start * 1000 / wav.sampleRate).round(),
          endMillis: (end * 1000 / wav.sampleRate).round(),
          peakDbfs: _toDbfs(peak),
          rmsDbfs: _toDbfs(rms),
        ),
      );
    }

    return AudioLevelAnalysis(windows: windows);
  }

  static double _toDbfs(double normalized) {
    if (normalized <= 0) {
      return -120;
    }

    return 20 * math.log(normalized) / math.ln10;
  }
}

class AudioLevelAnalysis {
  const AudioLevelAnalysis({required this.windows});

  final List<AudioLevelWindow> windows;

  List<AudioPeak> peaks({double thresholdDbfs = -18}) {
    return [
      for (final window in windows)
        if (window.peakDbfs >= thresholdDbfs)
          AudioPeak(timeMillis: window.startMillis, peakDbfs: window.peakDbfs),
    ];
  }

  List<SilenceRange> silences({
    double thresholdDbfs = -42,
    int minimumDurationMillis = 500,
  }) {
    final ranges = <SilenceRange>[];
    int? startMillis;
    int? endMillis;
    for (final window in windows) {
      if (window.rmsDbfs <= thresholdDbfs) {
        startMillis ??= window.startMillis;
        endMillis = window.endMillis;
      } else if (startMillis != null && endMillis != null) {
        if (endMillis - startMillis >= minimumDurationMillis) {
          ranges.add(
            SilenceRange(startMillis: startMillis, endMillis: endMillis),
          );
        }
        startMillis = null;
        endMillis = null;
      }
    }
    if (startMillis != null &&
        endMillis != null &&
        endMillis - startMillis >= minimumDurationMillis) {
      ranges.add(SilenceRange(startMillis: startMillis, endMillis: endMillis));
    }
    return ranges;
  }
}

class AudioLevelWindow {
  const AudioLevelWindow({
    required this.startMillis,
    required this.endMillis,
    required this.peakDbfs,
    required this.rmsDbfs,
  });

  final int startMillis;
  final int endMillis;
  final double peakDbfs;
  final double rmsDbfs;
}

class AudioPeak {
  const AudioPeak({required this.timeMillis, required this.peakDbfs});

  final int timeMillis;
  final double peakDbfs;
}

class SilenceRange {
  const SilenceRange({required this.startMillis, required this.endMillis});

  final int startMillis;
  final int endMillis;
}

class PcmWavData {
  const PcmWavData({required this.sampleRate, required this.samples});

  factory PcmWavData.parse(Uint8List bytes) {
    final data = ByteData.sublistView(bytes);
    if (bytes.length < 44 ||
        _ascii(bytes, 0, 4) != 'RIFF' ||
        _ascii(bytes, 8, 4) != 'WAVE') {
      throw const AudioLevelException('WAV PCM tidak valid.');
    }

    var offset = 12;
    int? sampleRate;
    int? bitsPerSample;
    int? channels;
    int? dataOffset;
    int? dataLength;
    while (offset + 8 <= bytes.length) {
      final chunkId = _ascii(bytes, offset, 4);
      final chunkSize = data.getUint32(offset + 4, Endian.little);
      final chunkDataOffset = offset + 8;
      if (chunkId == 'fmt ') {
        final audioFormat = data.getUint16(chunkDataOffset, Endian.little);
        channels = data.getUint16(chunkDataOffset + 2, Endian.little);
        sampleRate = data.getUint32(chunkDataOffset + 4, Endian.little);
        bitsPerSample = data.getUint16(chunkDataOffset + 14, Endian.little);
        if (audioFormat != 1 || bitsPerSample != 16) {
          throw const AudioLevelException(
            'Hanya WAV PCM 16-bit yang didukung.',
          );
        }
      } else if (chunkId == 'data') {
        dataOffset = chunkDataOffset;
        dataLength = chunkSize;
      }
      offset = chunkDataOffset + chunkSize + (chunkSize.isOdd ? 1 : 0);
    }

    if (sampleRate == null ||
        channels == null ||
        dataOffset == null ||
        dataLength == null) {
      throw const AudioLevelException('WAV PCM tidak lengkap.');
    }

    final samples = <double>[];
    final bytesPerFrame = channels * 2;
    for (
      var frameOffset = dataOffset;
      frameOffset + bytesPerFrame <= dataOffset + dataLength;
      frameOffset += bytesPerFrame
    ) {
      var mixed = 0.0;
      for (var channel = 0; channel < channels; channel += 1) {
        mixed +=
            data.getInt16(frameOffset + channel * 2, Endian.little) / 32768.0;
      }
      samples.add(mixed / channels);
    }

    return PcmWavData(sampleRate: sampleRate, samples: samples);
  }

  final int sampleRate;
  final List<double> samples;

  static String _ascii(Uint8List bytes, int offset, int length) {
    return String.fromCharCodes(bytes.sublist(offset, offset + length));
  }
}

class AudioLevelException implements Exception {
  const AudioLevelException(this.message);

  final String message;

  @override
  String toString() => message;
}
