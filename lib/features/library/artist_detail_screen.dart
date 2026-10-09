import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lirih/core/constants/app_colors.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:lirih/features/library/album_detail_screen.dart';
import 'package:lirih/features/library/group_card.dart';
import 'package:lirih/features/library/library_scan_controller.dart';
import 'package:lirih/features/player/player_controller.dart';

/// Label untuk trek tanpa tag album (agar tidak hilang dari grid).
const String _noAlbumLabel = 'Tanpa album';

/// Layar detail artis — grid album milik artis tersebut (task 2.5).
///
/// Trek dikelompokkan per album di memori (tidak butuh kueri MediaStore
/// tambahan). Memilih album membuka [AlbumDetailScreen] yang memuat trek
/// album tersebut, terurut per nomor trek.
class ArtistDetailScreen extends ConsumerWidget {
  /// Membuat layar detail artis bernama [artist].
  const ArtistDetailScreen({required this.artist, super.key});

  /// Nama artis (sesuai tag trek).
  final String artist;

  /// Mengelompokkan [tracks] per album, terurut abjad per nama album.
  static List<MapEntry<String, List<Track>>> albumsOf(List<Track> tracks) {
    final groups = <String, List<Track>>{};
    for (final track in tracks) {
      groups
          .putIfAbsent(track.album ?? _noAlbumLabel, () => <Track>[])
          .add(track);
    }
    final entries = groups.entries.toList()
      ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));
    return entries;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref
        .watch(libraryScanControllerProvider)
        .maybeWhen(data: (tracks) => tracks, orElse: () => const <Track>[]);
    final tracks = library.where((track) => track.artist == artist).toList();
    final albums = albumsOf(tracks);

    return Scaffold(
      backgroundColor: AppColors.soga900,
      appBar: AppBar(
        backgroundColor: AppColors.soga800,
        foregroundColor: AppColors.soga50,
        title: Text(artist, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: tracks.isEmpty
          ? const Center(
              child: Text(
                'Tidak ada trek dari artis ini.',
                style: TextStyle(color: AppColors.soga300),
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _ArtistHeader(
                    artist: artist,
                    trackCount: tracks.length,
                    albumCount: albums.length,
                    onPlay: () => ref
                        .read(playerControllerProvider.notifier)
                        .playTrack(tracks.first, queue: tracks),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.78,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final album = albums[index];
                      return GroupCard(
                        title: album.key,
                        subtitle: '${album.value.length} trek',
                        representative: album.value.first,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => AlbumDetailScreen(
                              album: album.key,
                              artist: album.key == _noAlbumLabel
                                  ? null
                                  : artist,
                              tracks: album.value,
                            ),
                          ),
                        ),
                      );
                    }, childCount: albums.length),
                  ),
                ),
              ],
            ),
    );
  }
}

/// Bagian kepala layar artis: nama, jumlah trek, jumlah album, dan
/// tombol "Putar semua".
class _ArtistHeader extends StatelessWidget {
  const _ArtistHeader({
    required this.artist,
    required this.trackCount,
    required this.albumCount,
    required this.onPlay,
  });

  final String artist;

  final int trackCount;

  final int albumCount;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artist,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.soga50,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$albumCount album • $trackCount trek',
                  style: const TextStyle(
                    color: AppColors.soga400,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
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
    );
  }
}
