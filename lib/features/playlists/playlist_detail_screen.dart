import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lirih/core/constants/app_colors.dart';
import 'package:lirih/core/utils/duration_format.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:lirih/features/player/player_controller.dart';
import 'package:lirih/features/playlists/playlist_form_sheet.dart';
import 'package:lirih/features/playlists/playlists_controller.dart';
import 'package:lirih/features/shell/main_bottom_bar.dart';
import 'package:lirih/features/track_tags/track_options_sheet.dart';
import 'package:lirih/shared/widgets/track_artwork.dart';

/// Layar detail playlist (task 3.1) — daftar trek yang dapat diputar,
/// diurutkan ulang, atau dihapus.
///
/// Nama dapat diganti; playlist dapat dihapus (dengan konfirmasi). Memutar
/// trek menjadikan seluruh isi playlist sebagai antrean.
class PlaylistDetailScreen extends ConsumerWidget {
  /// Membuat layar detail playlist ber-ID [playlistId].
  const PlaylistDetailScreen({required this.playlistId, super.key});

  /// ID playlist yang ditampilkan.
  final String playlistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistsControllerProvider);
    final playlist = playlists.where((p) => p.id == playlistId).firstOrNull;

    if (playlist == null) {
      // Playlist sudah dihapus — kembali.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.of(context).maybePop();
      });
      return const SizedBox.shrink();
    }

    final tracks = playlist.tracks;

    Future<void> playFromPlaylist(Track first) async {
      await ref
          .read(playlistsControllerProvider.notifier)
          .markPlayed(playlistId);
      unawaited(
        ref
            .read(playerControllerProvider.notifier)
            .playTrack(first, queue: tracks),
      );
    }

    /// Memutar dengan mode khusus (acak / terakhir dimainkan) sekaligus
    /// memperbarui `lastPlayedAt` — sama seperti [playFromPlaylist].
    Future<void> playWithMode(
      Future<void> Function(PlayerController) action,
    ) async {
      await ref
          .read(playlistsControllerProvider.notifier)
          .markPlayed(playlistId);
      unawaited(action(ref.read(playerControllerProvider.notifier)));
    }

    return Scaffold(
      backgroundColor: AppColors.soga900,
      appBar: AppBar(
        backgroundColor: AppColors.soga800,
        foregroundColor: AppColors.soga50,
        title: Text(
          playlist.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: () => showPlaylistFormSheet(
              context,
              editId: playlist.id,
              initialName: playlist.name,
            ),
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Ganti nama',
          ),
          IconButton(
            onPressed: () => _confirmDelete(context, ref, playlist.id),
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Hapus playlist',
          ),
        ],
      ),
      // Mini player hidup di MainShell, tetapi layar ini di-push sebagai
      // route penuh yang menutupinya — pasang ulang di sini (task 3.5).
      bottomNavigationBar: const MainBottomBar(),
      body: tracks.isEmpty
          ? const _EmptyPlaylist()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => playFromPlaylist(tracks.first),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Putar semua'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.kunir600,
                            foregroundColor: AppColors.soga50,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Putar trek terakhir yang dimainkan dalam playlist
                      // ini; bila belum ada, mainkan trek pertama saja.
                      OutlinedButton.icon(
                        onPressed: () => playWithMode(
                          (notifier) => notifier.playLastPlayed(tracks),
                        ),
                        icon: const Icon(Icons.history, size: 18),
                        label: const Text('Terakhir dimainkan'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.soga100,
                          side: const BorderSide(color: AppColors.soga600),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Acak: ikon saja, langsung memutar urutan acak.
                      IconButton(
                        onPressed: () => playWithMode(
                          (notifier) => notifier.playShuffled(tracks),
                        ),
                        icon: const Icon(Icons.shuffle),
                        color: AppColors.soga100,
                        tooltip: 'Putar acak',
                        style: IconButton.styleFrom(
                          side: const BorderSide(color: AppColors.soga600),
                          padding: const EdgeInsets.all(14),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ReorderableListView.builder(
                    itemCount: tracks.length,
                    padding: const EdgeInsets.only(bottom: 24),
                    onReorderItem: (oldIndex, newIndex) => ref
                        .read(playlistsControllerProvider.notifier)
                        .reorderTracks(playlistId, oldIndex, newIndex),
                    proxyDecorator: (child, _, _) => Material(
                      color: Colors.transparent,
                      elevation: 6,
                      borderRadius: BorderRadius.circular(12),
                      child: child,
                    ),
                    itemBuilder: (context, index) {
                      final track = tracks[index];
                      return _PlaylistTrackRow(
                        key: ValueKey<String>(track.id),
                        track: track,
                        onTap: () => playFromPlaylist(track),
                        onRemove: () => ref
                            .read(playlistsControllerProvider.notifier)
                            .removeTrack(playlistId, index),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.soga850,
        title: const Text(
          'Hapus playlist?',
          style: TextStyle(color: AppColors.soga50),
        ),
        content: const Text(
          'Lagu-lagu di dalamnya tidak akan dihapus dari perangkatmu.',
          style: TextStyle(color: AppColors.soga300),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.kunir500),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(playlistsControllerProvider.notifier).deletePlaylist(id);
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}

/// Baris trek dalam playlist.
class _PlaylistTrackRow extends StatelessWidget {
  const _PlaylistTrackRow({
    required this.track,
    required this.onTap,
    required this.onRemove,
    super.key,
  });

  final Track track;

  final VoidCallback onTap;

  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: TrackArtwork(track: track, size: 44),
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatTrackDuration(track.durationMs),
            style: const TextStyle(color: AppColors.soga400, fontSize: 12),
          ),
          IconButton(
            onPressed: () => showTrackOptionsSheet(context, track),
            icon: const Icon(Icons.more_vert),
            color: AppColors.soga200,
            iconSize: 20,
            tooltip: 'Opsi',
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close),
            color: AppColors.soga400,
            iconSize: 20,
            tooltip: 'Hapus dari playlist',
          ),
        ],
      ),
    );
  }
}

/// Status kosong saat playlist belum berisi trek.
class _EmptyPlaylist extends StatelessWidget {
  const _EmptyPlaylist();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Text(
          'Playlist ini masih kosong. Tekan lama sebuah lagu di Pustaka '
          'untuk menambahkannya.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.soga300, fontSize: 15),
        ),
      ),
    );
  }
}
