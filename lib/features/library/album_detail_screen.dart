import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lirih/core/constants/app_colors.dart';
import 'package:lirih/core/utils/duration_format.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:lirih/features/player/player_controller.dart';
import 'package:lirih/features/playlists/add_to_playlist_sheet.dart';
import 'package:lirih/shared/widgets/track_artwork.dart';

/// Layar detail album — trek pada album tersebut (task 2.5).
///
/// Trek **diurutkan berdasarkan nomor trek** (tag `TRK`) bila tersedia,
/// baru kemudian judul — tidak seperti daftar lagu biasa. Memutar trek
/// menjadikan seluruh isi album sebagai antrean.
class AlbumDetailScreen extends ConsumerWidget {
  /// Membuat layar detail album bernama [album].
  const AlbumDetailScreen({
    required this.album,
    required this.tracks,
    this.artist,
    super.key,
  });

  /// Nama album (untuk judul layar).
  final String album;

  /// Trek album — sudah disaring oleh pemanggil (kelompok album).
  final List<Track> tracks;

  /// Nama artis bila album berada dalam konteks artis; `null` bila album
  /// dibuka langsung dari tab Pustaka (album lintas artis).
  final String? artist;

  /// Mengurutkan trek per nomor trek (null di belakang), lalu judul.
  static List<Track> sortByTrackNumber(List<Track> tracks) {
    final list = List<Track>.of(tracks)
      ..sort((a, b) {
        final an = a.trackNumber;
        final bn = b.trackNumber;
        if (an != null && bn != null) return an.compareTo(bn);
        if (an != null) return -1;
        if (bn != null) return 1;
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      });
    return list;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sorted = sortByTrackNumber(tracks);
    final subtitle = artist ?? sorted.firstOrNull?.artist ?? '';

    return Scaffold(
      backgroundColor: AppColors.soga900,
      appBar: AppBar(
        backgroundColor: AppColors.soga800,
        foregroundColor: AppColors.soga50,
        title: Text(album, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: sorted.isEmpty
          ? const Center(
              child: Text(
                'Album ini tidak memiliki trek.',
                style: TextStyle(color: AppColors.soga300),
              ),
            )
          : ListView(
              children: [
                _AlbumHeader(
                  album: album,
                  artist: subtitle,
                  count: sorted.length,
                  representative: sorted.first,
                  onPlay: () => ref
                      .read(playerControllerProvider.notifier)
                      .playTrack(sorted.first, queue: sorted),
                ),
                const Divider(color: AppColors.soga700, height: 1),
                ...sorted.map(
                  (track) => _AlbumTrackRow(
                    track: track,
                    onTap: () => ref
                        .read(playerControllerProvider.notifier)
                        .playTrack(track, queue: sorted),
                    onLongPress: () => showAddToPlaylistSheet(context, track),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}

/// Bagian kepala layar album: sampul besar, nama album, artis, jumlah
/// trek, dan tombol "Putar semua".
class _AlbumHeader extends StatelessWidget {
  const _AlbumHeader({
    required this.album,
    required this.artist,
    required this.count,
    required this.representative,
    required this.onPlay,
  });

  final String album;

  final String artist;

  final int count;

  final Track representative;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TrackArtwork(track: representative, size: 120),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  album,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.soga50,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (artist.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.soga300,
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '$count trek',
                  style: const TextStyle(
                    color: AppColors.soga400,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: onPlay,
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text('Putar semua'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.kunir600,
                    foregroundColor: AppColors.soga50,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Satu baris trek album — menampilkan nomor trek (bila ada) di kiri.
class _AlbumTrackRow extends StatelessWidget {
  const _AlbumTrackRow({
    required this.track,
    required this.onTap,
    required this.onLongPress,
  });

  final Track track;

  final VoidCallback onTap;

  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      title: Text(
        track.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.soga50,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        track.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AppColors.soga300, fontSize: 13),
      ),
      trailing: Text(
        formatTrackDuration(track.durationMs),
        style: const TextStyle(color: AppColors.soga400, fontSize: 13),
      ),
    );
  }
}
