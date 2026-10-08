import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

/// Generator berkas WAV nada murni untuk validasi PoC pitch shift (task 0.6).
///
/// Nada murni (sine) dipilih agar pergeseran pitch bisa **diukur objektif**:
/// sebuah 440 Hz yang digeser ke rasio `432/440` harus terdengar sebagai
/// ~432 Hz, tanpa artifact. Berkas ditulis ke [Directory.systemTemp]
/// (penyimpanan privat aplikasi — tidak butuh permission).
@immutable
class WavToneGenerator {
  /// Membuat generator dengan [sampleRate] default 44.1 kHz.
  const WavToneGenerator({this.sampleRate = 44100});

  /// Frekuensi sampling hasil (Hz).
  final int sampleRate;

  /// Menulis [duration] detik nada murni [frequency] Hz ke berkas sementara.
  ///
  /// Mengembalikan absolute path berkas WAV (16-bit PCM mono).
  Future<String> generate({
    required double frequency,
    required Duration duration,
  }) async {
    final totalSamples = (sampleRate * duration.inMilliseconds / 1000).round();
    final pcm = Int16List(totalSamples);
    for (var i = 0; i < totalSamples; i++) {
      // Sine murni, amplitude 0.9 agar tidak terlalu keras.
      final sample = 0.9 * math.sin(2 * math.pi * frequency * i / sampleRate);
      pcm[i] = (sample * 32767).round().clamp(-32768, 32767);
    }

    final file = await _targetFile(frequency, duration);
    final raf = await file.open(mode: FileMode.write);
    try {
      await raf.writeFrom(_buildHeader(totalSamples * 2));
      await raf.writeFrom(pcm.buffer.asUint8List());
    } finally {
      await raf.close();
    }
    return file.path;
  }

  Future<File> _targetFile(double frequency, Duration duration) async {
    final dir = await Directory.systemTemp.create(recursive: true);
    final name = 'lirih_poc_${frequency.round()}Hz_${duration.inSeconds}s.wav';
    return File('${dir.path}/$name');
  }

  /// Header WAV 44-byte: RIFF/WAVE, format PCM 16-bit mono.
  Uint8List _buildHeader(int dataSize) {
    final out = BytesBuilder()
      ..add('RIFF'.codeUnits)
      ..add(_int32(36 + dataSize))
      ..add('WAVE'.codeUnits)
      ..add('fmt '.codeUnits)
      ..add(_int32(16)) // ukuran chunk fmt
      ..add(_int16(1)) // format = PCM
      ..add(_int16(1)) // mono
      ..add(_int32(sampleRate))
      ..add(_int32(sampleRate * 2)) // byte rate
      ..add(_int16(2)) // block align
      ..add(_int16(16)) // bit per sample
      ..add('data'.codeUnits)
      ..add(_int32(dataSize));
    return out.toBytes();
  }
}

/// Integer little-endian 32-bit sebagai 4 byte.
Uint8List _int32(int value) {
  final b = ByteData(4)..setInt32(0, value, Endian.little);
  return b.buffer.asUint8List();
}

/// Integer little-endian 16-bit sebagai 2 byte.
Uint8List _int16(int value) {
  final b = ByteData(2)..setInt16(0, value, Endian.little);
  return b.buffer.asUint8List();
}
