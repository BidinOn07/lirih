import 'dart:async';

import 'package:hive_ce/hive.dart';
import 'package:lirih/core/audio/dsp_channel.dart';
import 'package:lirih/core/services/hive_service.dart';
import 'package:lirih/core/utils/m3u_parser.dart';
import 'package:lirih/data/mappers/track_mapper.dart';
import 'package:lirih/domain/entities/playlist.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'playlists_controller.g.dart';

/// Daftar putar pengguna (task 3.1) — disimpan di `playlistsBox`.
///
/// Tiap playlist disimpan sebagai satu entri: key = [Playlist.id],
/// value = `{'name': String, 'tracks': List<Map>}` (track di-serialisasi
/// via [TrackMapper]). Controller ini bersifat *inert* bila box belum
/// terbuka — operasi menjadi no-op alih-alih menghempaskan galat.
@riverpod
class PlaylistsController extends _$PlaylistsController {
  Box<dynamic>? _box;

  @override
  List<Playlist> build() {
    if (!Hive.isBoxOpen(HiveBoxes.playlists)) return const <Playlist>[];
    _box = Hive.box<dynamic>(HiveBoxes.playlists);
    return _readAll();
  }

  /// Membaca seluruh playlist dari box (urutan key = urutan pembuatan).
  List<Playlist> _readAll() {
    final box = _box;
    if (box == null) return const <Playlist>[];

    final playlists = <Playlist>[];
    for (final key in box.keys) {
      if (key is! String) continue;
      final value = box.get(key);
      if (value is! Map) continue;

      final json = Map<String, dynamic>.from(value);
      final name = json['name'] as String?;
      if (name == null) continue;

      final rawTracks = json['tracks'];
      final tracks = <Track>[];
      if (rawTracks is List) {
        for (final entry in rawTracks) {
          if (entry is! Map) continue;
          final track = TrackMapper.fromJson(Map<String, dynamic>.from(entry));
          if (track != null) tracks.add(track);
        }
      }

      playlists.add(
        Playlist(
          id: key,
          name: name,
          tracks: tracks,
          lastPlayedAt: json['lastPlayedAt'] as int?,
        ),
      );
    }
    return List<Playlist>.unmodifiable(playlists);
  }

  Future<void> _persist(Playlist playlist) async {
    await _box?.put(playlist.id, <String, dynamic>{
      'name': playlist.name,
      'tracks': playlist.tracks.map(TrackMapper.toJson).toList(),
      'lastPlayedAt': playlist.lastPlayedAt,
    });
  }

  /// Mencatat bahwa playlist ber-ID [id] baru saja diputar — memperbarui
  /// `lastPlayedAt` sehingga playlist naik ke depan di Beranda (task 3.1).
  Future<void> markPlayed(String id) async {
    final playlist = state.where((p) => p.id == id).firstOrNull;
    if (playlist == null) return;
    await _persist(
      playlist.copyWith(lastPlayedAt: DateTime.now().millisecondsSinceEpoch),
    );
    state = _readAll();
  }

  /// Membuat playlist baru bernama [name]; mengembalikan playlist tersebut.
  Future<Playlist> createPlaylist(String name) async {
    final trimmed = name.trim();
    final playlist = Playlist(
      id: 'pl_${DateTime.now().microsecondsSinceEpoch}',
      name: trimmed.isEmpty ? 'Daftar putar' : trimmed,
    );
    await _persist(playlist);
    state = _readAll();
    return playlist;
  }

  /// Mengganti nama playlist ber-ID [id] menjadi [name] (mengabaikan nama
  /// kosong).
  Future<void> renamePlaylist(String id, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final playlist = state.where((p) => p.id == id).firstOrNull;
    if (playlist == null) return;
    await _persist(playlist.copyWith(name: trimmed));
    state = _readAll();
  }

  /// Menghapus playlist ber-ID [id].
  Future<void> deletePlaylist(String id) async {
    await _box?.delete(id);
    state = _readAll();
  }

  /// Menambahkan [track] ke akhir playlist ber-ID [id] (dedupe per id trek).
  Future<void> addTrack(String id, Track track) async {
    final playlist = state.where((p) => p.id == id).firstOrNull;
    if (playlist == null) return;
    if (playlist.tracks.any((t) => t.id == track.id)) return;
    await _persist(playlist.copyWith(tracks: [...playlist.tracks, track]));
    state = _readAll();
  }

  /// Menghapus trek pada [index] dari playlist ber-ID [id].
  Future<void> removeTrack(String id, int index) async {
    final playlist = state.where((p) => p.id == id).firstOrNull;
    if (playlist == null) return;
    if (index < 0 || index >= playlist.tracks.length) return;
    final updated = List<Track>.of(playlist.tracks)..removeAt(index);
    await _persist(playlist.copyWith(tracks: updated));
    state = _readAll();
  }

  /// Mengatur ulang trek playlist ber-ID [id] (konvensi `onReorderItem`).
  Future<void> reorderTracks(String id, int oldIndex, int newIndex) async {
    final playlist = state.where((p) => p.id == id).firstOrNull;
    if (playlist == null) return;
    final tracks = List<Track>.of(playlist.tracks);
    if (oldIndex < 0 || oldIndex >= tracks.length) return;
    if (newIndex < 0 || newIndex > tracks.length) return;
    final moved = tracks.removeAt(oldIndex);
    tracks.insert(newIndex, moved);
    await _persist(playlist.copyWith(tracks: tracks));
    state = _readAll();
  }

  /// Mengimpor playlist dari MediaStore perangkat (task 3.1) — fitur
  /// *auto-import* "playlist yang sudah ada/sudah dibuat".
  ///
  /// Tiap playlist MediaStore yang anggotanya ada di [library] dibuatkan
  /// playlist Lirih; nama yang sudah dipakai **dilewati** agar operasi ini
  /// idempoten (aman dijalankan ulang tiap pemindaian). Mengembalikan
  /// jumlah playlist baru yang dibuat.
  Future<int> importDevicePlaylists(List<Track> library) async {
    final box = _box;
    if (box == null) return 0;

    final byMediaStoreId = <int, Track>{
      for (final track in library)
        if (track.mediaStoreId != null) track.mediaStoreId!: track,
    };

    final devicePlaylists = await const DspChannel().queryDevicePlaylists();
    var created = 0;
    for (final device in devicePlaylists) {
      if (state.any((playlist) => playlist.name == device.name)) continue;

      final tracks = <Track>[];
      for (final audioId in device.audioIds) {
        final track = byMediaStoreId[audioId];
        if (track != null && !tracks.any((t) => t.id == track.id)) {
          tracks.add(track);
        }
      }
      if (tracks.isEmpty) continue;

      await _persist(
        Playlist(
          id: 'pl_${DateTime.now().microsecondsSinceEpoch}_$created',
          name: device.name,
          tracks: tracks,
        ),
      );
      created++;
    }
    if (created > 0) state = _readAll();
    return created;
  }

  /// Mengimpor satu berkas playlist (`.m3u`/`.m3u8`) yang dipilih pengguna
  /// melalui pemilih berkas sistem (task 3.1).
  ///
  /// Entri dicocokkan ke trek [library] berdasarkan nama berkas
  /// (*basename*, *case-insensitive*). Mengembalikan jumlah trek yang
  /// berhasil dicocokkan, `0` bila tidak ada yang cocok, atau `-1` bila
  /// pengguna membatalkan pemilihan berkas.
  Future<int> importPlaylistFile(List<Track> library) async {
    if (_box == null) return 0;

    final picked = await const DspChannel().pickPlaylistFile();
    if (picked == null) return -1;

    final entries = M3uParser.entries(picked.content);
    if (entries.isEmpty) return 0;

    final byBasename = <String, Track>{
      for (final track in library)
        M3uParser.basenameOf(track.sourcePath): track,
    };

    final tracks = <Track>[];
    for (final entry in entries) {
      final track = byBasename[M3uParser.basenameOf(entry)];
      if (track != null && !tracks.any((t) => t.id == track.id)) {
        tracks.add(track);
      }
    }
    if (tracks.isEmpty) return 0;

    await _persist(
      Playlist(
        id: 'pl_${DateTime.now().microsecondsSinceEpoch}',
        name: M3uParser.playlistNameFromFileName(picked.name),
        tracks: tracks,
      ),
    );
    state = _readAll();
    return tracks.length;
  }
}
