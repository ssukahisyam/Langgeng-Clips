import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/features/media_intelligence/audio_level_analyzer.dart';

void main() {
  test('detects audio peaks from PCM WAV bytes', () {
    final bytes = _wav([0, 28000, 0, 1000], sampleRate: 4);
    final analysis = const AudioLevelAnalyzer(
      windowMillis: 250,
    ).analyzeWav(bytes);

    final peaks = analysis.peaks(thresholdDbfs: -3);

    expect(peaks, hasLength(1));
    expect(peaks.single.timeMillis, 250);
  });

  test('detects silence ranges from PCM WAV bytes', () {
    final bytes = _wav([0, 0, 0, 16000], sampleRate: 4);
    final analysis = const AudioLevelAnalyzer(
      windowMillis: 250,
    ).analyzeWav(bytes);

    final silences = analysis.silences(
      thresholdDbfs: -42,
      minimumDurationMillis: 500,
    );

    expect(silences, hasLength(1));
    expect(silences.single.startMillis, 0);
    expect(silences.single.endMillis, 750);
  });

  test('rejects non PCM WAV bytes', () {
    expect(
      () =>
          const AudioLevelAnalyzer().analyzeWav(Uint8List.fromList([1, 2, 3])),
      throwsA(isA<AudioLevelException>()),
    );
  });
}

Uint8List _wav(List<int> samples, {required int sampleRate}) {
  final dataLength = samples.length * 2;
  final bytes = Uint8List(44 + dataLength);
  final data = ByteData.sublistView(bytes);
  _writeAscii(bytes, 0, 'RIFF');
  data.setUint32(4, 36 + dataLength, Endian.little);
  _writeAscii(bytes, 8, 'WAVE');
  _writeAscii(bytes, 12, 'fmt ');
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little);
  data.setUint16(22, 1, Endian.little);
  data.setUint32(24, sampleRate, Endian.little);
  data.setUint32(28, sampleRate * 2, Endian.little);
  data.setUint16(32, 2, Endian.little);
  data.setUint16(34, 16, Endian.little);
  _writeAscii(bytes, 36, 'data');
  data.setUint32(40, dataLength, Endian.little);
  for (var index = 0; index < samples.length; index += 1) {
    data.setInt16(44 + index * 2, samples[index], Endian.little);
  }
  return bytes;
}

void _writeAscii(Uint8List bytes, int offset, String value) {
  for (var index = 0; index < value.length; index += 1) {
    bytes[offset + index] = value.codeUnitAt(index);
  }
}
