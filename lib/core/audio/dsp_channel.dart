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

  /// Status putar berubah (`"true"`/`"false"`); lihat [DspEventPayload.data].
  ///
  /// Dipicu mesin native saat jeda/lanjut dari **kontrol media standar**
  /// notifikasi (slot tengah) atau akibat audio focus — kedua nya tidak
  /// melalui Dart, sehingga Dart perlu diberi tahu agar mini player ikut
  /// sinkron.
  playingStateChanged,
}

/// Aksi tombol kustom di notifikasi media (task 3.5).
enum NotificationAction {
  /// Menandai/hapus trek aktif sebagai favorit.
  favorite,

  /// Trek sebelumnya.
  previous,

  /// Jeda/lanjutkan pemutaran.
  togglePlay,

  /// Trek berikutnya.
  next,

  /// Memutar mode pemutaran gabungan: mati → ulang semua → ulang satu →
  /// acak → mati (ulang & acak digabung agar muat di 5 slot notifikasi).
  mode;

  /// Membuat [NotificationAction] dari nama aksi native; `null` bila tidak
  /// dikenali (mis. aksi dari versi native lebih lama).
  static NotificationAction? fromName(String? name) => switch (name) {
    'io.github.bidinon07.lirih.action.FAVORITE' => favorite,
    'io.github.bidinon07.lirih.action.PREVIOUS' => previous,
    'io.github.bidinon07.lirih.action.TOGGLE_PLAY' => togglePlay,
    'io.github.bidinon07.lirih.action.NEXT' => next,
    'io.github.bidinon07.lirih.action.MODE' => mode,
    _ => null,
  };
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

  static final StreamController<NotificationAction> _notificationActions =
      StreamController<NotificationAction>.broadcast();

  static Completer<String?>? _pickCompleter;

  static bool _handlerInstalled = false;

  /// Aliran event mesin native (`completed`, `error`).
  Stream<DspEventPayload> get events {
    _ensureHandler();
    return _events.stream;
  }

  /// Aliran aksi tombol kustom notifikasi (task 3.5).
  Stream<NotificationAction> get notificationActions {
    _ensureHandler();
    return _notificationActions.stream;
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
            'playingStateChanged' => DspEvent.playingStateChanged,
            _ => DspEvent.error,
          };
          _events.add(
            DspEventPayload(event: event, data: args?['data'] as String?),
          );
        case 'onFilePicked':
          _pickCompleter?.complete(args?['uri'] as String?);
          _pickCompleter = null;
        case 'onNotificationAction':
          final action = NotificationAction.fromName(
            args?['action'] as String?,
          );
          if (action != null) _notificationActions.add(action);
      }
      return null;
    });
  }

  /// Memutar berkas audio di absolute [path] atau `content://` URI.
  ///
  /// Metadata opsional ([title], [artist], [artUri]) diteruskan ke
  /// `MediaMetadata` ExoPlayer agar **notifikasi media** menampilkan
  /// judul, artis, dan sampul album (task 1.7).
  Future<void> play(
    String path, {
    String? title,
    String? artist,
    String? artUri,
  }) => _channel.invokeMethod<void>('play', <String, dynamic>{
    'path': path,
    'title': title,
    'artist': artist,
    'artUri': artUri,
  });

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

  /// Memindahkan aplikasi ke background tanpa mematikan pemutar.
  ///
  /// Dipakai saat pengguna menekan tombol/gesture **back** di halaman
  /// utama: app hanya di-minimize (seperti tombol Home) sehingga
  /// foreground service pemutar tetap berjalan. Pemutar benar-benar
  /// berhenti hanya jika app dimatikan dari daftar aplikasi terbuka.
  Future<void> moveToBackground() =>
      _channel.invokeMethod<void>('moveTaskToBack');

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

  /// Mengirim state pemutar ke native agar ikon tombol kustom di notifikasi
  /// media selalu sinkron (task 3.5).
  ///
  /// Dipanggil setiap kali status pemutar, mode acak/pengulangan, atau
  /// status favorit trek aktif berubah.
  Future<void> setNotificationState({
    required bool isPlaying,
    required bool isShuffling,
    required int repeatMode,
    required bool isFavorite,
  }) => _channel.invokeMethod<void>('setNotificationState', <String, dynamic>{
    'state': <String, dynamic>{
      'isPlaying': isPlaying,
      'isShuffling': isShuffling,
      'repeatMode': repeatMode,
      'isFavorite': isFavorite,
    },
  });

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

  /// Lirik tertanam trek di [path] (`content://` URI atau absolute path).
  ///
  /// Mengembalikan `null` bila trek tidak punya frame lirik ID3v2 (`USLT`)
  /// atau terjadi kegagalan — **best effort**, tidak boleh mengganggu
  /// playback. Lirik tidak tersinkron (plain text); sinkronisasi otomatis
  /// butuh timestamp SYLT yang belum didukung (task 3.3 ditunda ke parser
  /// ID3 kustom yang lebih lengkap).
  Future<String?> lyricsFor(String path) async {
    final result = await _channel.invokeMethod<String>(
      'getLyrics',
      <String, dynamic>{'path': path},
    );
    return result;
  }

  /// Playlist perangkat hasil kueri MediaStore (task 3.1): nama + id audio
  /// MediaStore tiap anggota, terurut sesuai urutan putar.
  ///
  /// *Best effort*: mengembalikan list kosong bila tidak ada playlist, izin
  /// media belum diberikan, atau channel tidak tersedia (mis. di test).
  Future<List<DevicePlaylist>> queryDevicePlaylists() async {
    final List<dynamic>? result;
    try {
      result = await _channel.invokeMethod<List<dynamic>>(
        'queryDevicePlaylists',
      );
    } on Object {
      return const <DevicePlaylist>[];
    }
    if (result == null) return const <DevicePlaylist>[];
    return result
        .whereType<Map<dynamic, dynamic>>()
        .map((map) {
          final rawIds = map['audioIds'] as List<dynamic>? ?? const <dynamic>[];
          return (
            id: (map['id'] as num).toInt(),
            name: (map['name'] as String?) ?? '',
            audioIds: rawIds.whereType<num>().map((id) => id.toInt()).toList(),
          );
        })
        .where((playlist) => playlist.name.isNotEmpty)
        .toList();
  }

  /// Membuka pemilih berkas untuk berkas playlist (`.m3u`/`.m3u8`) via
  /// SAF — tanpa permission (task 3.1).
  ///
  /// Mengembalikan nama tampilan + isi teks berkas, atau `null` bila
  /// pengguna membatalkan.
  Future<PlaylistFile?> pickPlaylistFile() async {
    final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'pickPlaylistFile',
    );
    if (result == null) return null;
    final content = result['content'] as String?;
    if (content == null) return null;
    return (
      name: (result['name'] as String?) ?? 'Playlist diimpor',
      content: content,
    );
  }
}

/// Playlist perangkat (MediaStore) hasil [DspChannel.queryDevicePlaylists].
typedef DevicePlaylist = ({int id, String name, List<int> audioIds});

/// Berkas playlist yang dipilih via [DspChannel.pickPlaylistFile].
typedef PlaylistFile = ({String name, String content});
