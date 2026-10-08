import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lirih/core/constants/app_colors.dart';
import 'package:lirih/core/errors/failures.dart';
import 'package:lirih/core/utils/duration_format.dart';
import 'package:lirih/domain/entities/playlist.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:lirih/features/library/library_scan_controller.dart';
import 'package:lirih/features/player/player_controller.dart';
import 'package:lirih/features/playlists/add_to_playlist_sheet.dart';
import 'package:lirih/features/playlists/playlist_detail_screen.dart';
import 'package:lirih/features/playlists/playlist_form_sheet.dart';
import 'package:lirih/features/playlists/playlists_controller.dart';
import 'package:lirih/shared/widgets/track_artwork.dart';
import 'package:permission_handler/permission_handler.dart';

/// Layar Pustaka — daftar lagu di perangkat pengguna (task 2.5).
///
/// Memuat [LibraryScanController] secara otomatis; memetakan tiap galat ke
/// *empty state* yang sesuai (task 3.6): izin ditolak → tombol buka
/// pengaturan; pustaka kosong → ajakan menyalin musik; galat teknis → coba
/// lagi. Tarik ke bawah untuk memindai ulang.
class LibraryScreen extends ConsumerWidget {
  /// Membuat layar Pustaka.
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scan = ref.watch(libraryScanControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.soga900,
      appBar: AppBar(
        backgroundColor: AppColors.soga800,
        foregroundColor: AppColors.soga50,
        title: const Text('Pustaka'),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(libraryScanControllerProvider.notifier).rescan(),
        child: scan.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.kunir500),
          ),
          error: (error, _) => _ErrorState(failure: _asFailure(error)),
          data: (tracks) => _LibraryContent(tracks: tracks),
        ),
      ),
    );
  }

  /// Mengubah galat AsyncValue menjadi [Failure] (dilempar oleh controller).
  Failure _asFailure(Object error) =>
      error is Failure ? error : const ScanFailure();
}

/// Isi Pustaka: strip playlist di puncak, lalu seluruh trek.
class _LibraryContent extends ConsumerWidget {
  const _LibraryContent({required this.tracks});

  final List<Track> tracks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: _PlaylistsStrip()),
        const SliverToBoxAdapter(child: _TracksHeader()),
        SliverList.separated(
          itemCount: tracks.length,
          separatorBuilder: (_, _) =>
              const Divider(color: AppColors.soga700, height: 1),
          itemBuilder: (context, index) {
            final track = tracks[index];
            return _TrackRow(
              track: track,
              onTap: () => ref
                  .read(playerControllerProvider.notifier)
                  .playTrack(track, queue: tracks),
              onLongPress: () => showAddToPlaylistSheet(context, track),
            );
          },
        ),
      ],
    );
  }
}

/// Strip horizontal playlist (task 3.1) + kartu "buat baru".
class _PlaylistsStrip extends ConsumerWidget {
  const _PlaylistsStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistsControllerProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 0, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Playlist',
            style: TextStyle(
              color: AppColors.kunir500,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 84,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 20),
              itemCount: playlists.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _NewPlaylistCard(
                    onTap: () async {
                      final created = await showPlaylistFormSheet(context);
                      if (created != null && context.mounted) {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                PlaylistDetailScreen(playlistId: created.id),
                          ),
                        );
                      }
                    },
                  );
                }
                final playlist = playlists[index - 1];
                return _PlaylistCard(
                  playlist: playlist,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          PlaylistDetailScreen(playlistId: playlist.id),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Kartu "＋ Playlist baru".
class _NewPlaylistCard extends StatelessWidget {
  const _NewPlaylistCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.soga800,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.kunir600, width: 1.5),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: AppColors.kunir500, size: 24),
            SizedBox(height: 6),
            Text(
              'Playlist baru',
              style: TextStyle(color: AppColors.kunir500, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Kartu satu playlist.
class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({required this.playlist, required this.onTap});

  final Playlist playlist;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.soga850,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.queue_music, color: AppColors.nila400, size: 24),
            const SizedBox(height: 6),
            Text(
              playlist.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.soga50,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${playlist.length} trek',
              style: const TextStyle(color: AppColors.soga400, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

/// Judul "Semua lagu" + jumlah.
class _TracksHeader extends ConsumerWidget {
  const _TracksHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref
        .watch(libraryScanControllerProvider)
        .maybeWhen(data: (tracks) => tracks.length, orElse: () => 0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        children: [
          const Text(
            'Semua lagu',
            style: TextStyle(
              color: AppColors.soga100,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count trek',
            style: const TextStyle(color: AppColors.soga400, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// Satu baris trek: judul, artis, durasi.
class _TrackRow extends StatelessWidget {
  const _TrackRow({required this.track, required this.onTap, this.onLongPress});

  final Track track;

  final VoidCallback onTap;

  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      leading: TrackArtwork(track: track),
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

/// Empty/error state sesuai jenis [Failure].
class _ErrorState extends ConsumerWidget {
  const _ErrorState({required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPermission = failure is PermissionDeniedFailure;
    final isEmpty = failure is EmptyLibraryFailure;

    return ListView(
      children: [
        const SizedBox(height: 96),
        Icon(
          isPermission
              ? Icons.lock_outline
              : isEmpty
              ? Icons.library_music_outlined
              : Icons.error_outline,
          size: 64,
          color: AppColors.soga400,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            failure.message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.soga200, fontSize: 15),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: FilledButton.icon(
            onPressed: () async {
              if (isPermission) {
                await openAppSettings();
              } else {
                await ref.read(libraryScanControllerProvider.notifier).rescan();
              }
            },
            icon: Icon(isPermission ? Icons.settings : Icons.refresh),
            label: Text(isPermission ? 'Buka pengaturan' : 'Coba lagi'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.kunir600,
              foregroundColor: AppColors.soga50,
            ),
          ),
        ),
      ],
    );
  }
}
