import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Nama MethodChannel DSP — TERKUNCI task 0N.4 (lihat AGENTS.md).
const String kDspChannelName = 'io.github.bidinon07.lirih/dsp';

/// Event yang dipancarkan mesin native ke Dart.
enum DspEvent {
  /// Playback selesai (lagu habis).
  completed,

  /// Kegagalan playback; lihat [DspEventPayload.data].
  error,
}

/// Muatan event dari mesin native.
class DspEventPayload {
  /// Membuat payload [event] dengan [data] opsional.
  const DspEventPayload({required this.event, this.data});

  /// Jenis event.
  final DspEvent event;

  /// Data tambahan (mis. pesan galat).
  final String? data;
}

/// Client MethodChannel DSP — PoC task 0.8.
///
/// Mengabstraksi pemanggilan native (`LirihDspPlayer` di Android) sehingga
/// sisi UI tidak menyentuh MethodChannel langsung. Saat plugin `lirih_audio`
/// federated dibangun (Minggu 3, task 1.x), antarmuka ini diganti oleh
/// implementasi plugin dan layar tidak perlu berubah banyak.
///
/// MethodChannel hanya bisa memasang **satu** handler pesan. Karena itu
/// dispatcher tunggal membagi pesan masuk ke dua jalur: aliran [events]
/// (untuk `PlayerController`) dan completer [pickMusicFile] (untuk pemilih
/// berkas).
@immutable
class DspChannel {
  /// Membuat client untuk channel DSP.
  const DspChannel();

  static const MethodChannel _channel = MethodChannel(kDspChannelName);

  static final StreamController<DspEventPayload> _events =
      StreamController<DspEventPayload>.broadcast();

  static Completer<String?>? _pickCompleter;

  static bool _handlerInstalled = false;

  /// Aliran event mesin native (`completed`, `error`).
  Stream<DspEventPayload> get events {
    _ensureHandler();
    return _events.stream;
  }

  /// Memasang dispatcher pesan sekali saja.
  static void _ensureHandler() {
    if (_handlerInstalled) return;
    _handlerInstalled = true;
    _channel.setMethodCallHandler((call) async {
      final args = call.arguments as Map<Object?, Object?>?;
      switch (call.method) {
        case 'onEvent':
          final name = args?['event'] as String?;
          final event = switch (name) {
            'completed' => DspEvent.completed,
            _ => DspEvent.error,
          };
          _events.add(
            DspEventPayload(event: event, data: args?['data'] as String?),
          );
        case 'onFilePicked':
          _pickCompleter?.complete(args?['uri'] as String?);
          _pickCompleter = null;
      }
      return null;
    });
  }

  /// Memutar berkas audio di absolute [path] atau `content://` URI.
  Future<void> play(String path) =>
      _channel.invokeMethod<void>('play', <String, dynamic>{'path': path});

  /// Membuka pemilih berkas sistem (SAF) untuk memilih musik.
  ///
  /// Mengembalikan `content://` URI berkas yang dipilih (dan langsung
  /// diputar), atau `null` bila pengguna membatalkan. **Tanpa permission**
  /// — akses baca sementara diberikan oleh SAF.
  Future<String?> pickMusicFile() {
    final completer = Completer<String?>();
    _pickCompleter = completer;
    _ensureHandler();
    // Fire-and-forget: hasil datang via callback onFilePicked.
    unawaited(_channel.invokeMethod<void>('pickFile'));
    return completer.future;
  }

  /// Menjeda playback.
  Future<void> pause() => _channel.invokeMethod<void>('pause');

  /// Melanjutkan playback.
  Future<void> resume() => _channel.invokeMethod<void>('resume');

  /// Menghentikan playback.
  Future<void> stop() => _channel.invokeMethod<void>('stop');

  /// Melompat ke [position].
  Future<void> seek(Duration position) => _channel.invokeMethod<void>(
    'seek',
    <String, dynamic>{'positionMs': position.inMilliseconds},
  );

  /// Mengatur rasio pitch (0.5–2.0), tempo tetap. Berlaku real-time.
  Future<void> setPitch(double ratio) => _channel.invokeMethod<void>(
    'setPitch',
    <String, dynamic>{'ratio': ratio},
  );

  /// Mengatur rasio tempo (0.5–2.0), terpisah dari pitch.
  Future<void> setTempo(double ratio) => _channel.invokeMethod<void>(
    'setTempo',
    <String, dynamic>{'ratio': ratio},
  );

  /// Rasio pitch aktif di mesin native.
  Future<double> getPitch() async =>
      (await _channel.invokeMethod<num>('getPitch'))?.toDouble() ?? 1.0;

  /// Posisi playback saat ini.
  Future<Duration> getPosition() async => Duration(
    milliseconds:
        (await _channel.invokeMethod<num>('getPosition'))?.toInt() ?? 0,
  );

  /// Durasi media saat ini.
  Future<Duration> getDuration() async => Duration(
    milliseconds:
        (await _channel.invokeMethod<num>('getDuration'))?.toInt() ?? 0,
  );
}
