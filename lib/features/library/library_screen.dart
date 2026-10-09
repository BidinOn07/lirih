import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lirih/core/constants/app_colors.dart';
import 'package:lirih/core/errors/failures.dart';
import 'package:lirih/core/utils/duration_format.dart';
import 'package:lirih/domain/entities/playlist.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:lirih/features/library/library_scan_controller.dart';
import 'package:lirih/features/library/sort_mode.dart';
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

/// Isi Pustaka: strip playlist di puncak, pemilih bagian
/// (Lagu/Artis/Album), lalu isi bagian yang dipilih (task 2.5).
///
/// Artis & album diturunkan dari daftar trek yang sudah dipindai
/// (pengelompokan di memori) sehingga tidak butuh kueri MediaStore tambahan.
class _LibraryContent extends ConsumerStatefulWidget {
  const _LibraryContent({required this.tracks});

  final List<Track> tracks;

  @override
  ConsumerState<_LibraryContent> createState() => _LibraryContentState();
}

class _LibraryContentState extends ConsumerState<_LibraryContent> {
  /// 0 = Lagu, 1 = Artis, 2 = Album.
  int _section = 0;

  SortMode _sort = SortMode.title;

  /// Memutar [first] dalam konteks antrean [queue].
  void _play(Track first, List<Track> queue) {
    unawaited(
      ref
          .read(playerControllerProvider.notifier)
          .playTrack(first, queue: queue),
    );
  }

  /// Membandingkan dua label secara *case-insensitive* (urutan abjad).
  int _byLabel(String a, String b) =>
      a.toLowerCase().compareTo(b.toLowerCase());

  /// Daftar trek diurutkan sesuai [_sort].
  List<Track> _sortedTracks() {
    final tracks = List<Track>.of(widget.tracks);
    return tracks..sort((a, b) {
      switch (_sort) {
        case SortMode.artist:
          return _byLabel(a.artist, b.artist);
        case SortMode.album:
          return _byLabel(a.album ?? '~~', b.album ?? '~~');
        case SortMode.title:
          return _byLabel(a.title, b.title);
      }
    });
  }

  /// Mengelompokkan trek berdasarkan [keyOf], terurut abjad per nama grup.
  List<MapEntry<String, List<Track>>> _groupedBy(String Function(Track) keyOf) {
    final groups = <String, List<Track>>{};
    for (final track in widget.tracks) {
      groups.putIfAbsent(keyOf(track), () => <Track>[]).add(track);
    }
    final entries = groups.entries.toList();
    return entries..sort((a, b) => _byLabel(a.key, b.key));
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: _PlaylistsStrip()),
        SliverToBoxAdapter(
          child: _SectionTabs(
            section: _section,
            onChanged: (section) => setState(() => _section = section),
          ),
        ),
        ..._sectionSlivers(),
      ],
    );
  }

  /// Sliver isi sesuai bagian yang sedang dipilih.
  List<Widget> _sectionSlivers() {
    switch (_section) {
      case 1:
        return [
          _GroupsSliver(
            groups: _groupedBy((track) => track.artist),
            icon: Icons.person_outline,
          ),
        ];
      case 2:
        return [
          _GroupsSliver(
            groups: _groupedBy((track) => track.album ?? 'Tanpa album'),
            icon: Icons.album_outlined,
          ),
        ];
      default:
        final sorted = _sortedTracks();
        return [
          SliverToBoxAdapter(
            child: _TracksHeader(
              sort: _sort,
              onSortChanged: (sort) => setState(() => _sort = sort),
            ),
          ),
          SliverList.separated(
            itemCount: sorted.length,
            separatorBuilder: (_, _) =>
                const Divider(color: AppColors.soga700, height: 1),
            itemBuilder: (context, index) {
              final track = sorted[index];
              return _TrackRow(
                track: track,
                onTap: () => _play(track, sorted),
                onLongPress: () => showAddToPlaylistSheet(context, track),
              );
            },
          ),
        ];
    }
  }
}

/// Pemilih bagian Pustaka: Lagu / Artis / Album.
class _SectionTabs extends StatelessWidget {
  const _SectionTabs({required this.section, required this.onChanged});

  final int section;

  final ValueChanged<int> onChanged;

  static const _labels = <String>['Lagu', 'Artis', 'Album'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Row(
        children: [
          for (var i = 0; i < _labels.length; i++) ...[
            ChoiceChip(
              label: Text(_labels[i]),
              selected: section == i,
              onSelected: (_) => onChanged(i),
              selectedColor: AppColors.kunir600,
              backgroundColor: AppColors.soga800,
              side: const BorderSide(color: AppColors.soga700),
              labelStyle: TextStyle(
                color: section == i ? AppColors.soga50 : AppColors.soga300,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
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

/// Judul "Semua lagu" + jumlah + pengurutan (task 2.5).
class _TracksHeader extends ConsumerWidget {
  const _TracksHeader({required this.sort, required this.onSortChanged});

  final SortMode sort;

  final ValueChanged<SortMode> onSortChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref
        .watch(libraryScanControllerProvider)
        .maybeWhen(data: (tracks) => tracks.length, orElse: () => 0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 4),
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
          const Spacer(),
          PopupMenuButton<SortMode>(
            tooltip: 'Urutkan',
            icon: const Icon(Icons.sort, color: AppColors.soga200, size: 20),
            onSelected: onSortChanged,
            itemBuilder: (_) => [
              for (final mode in SortMode.values)
                PopupMenuItem(
                  value: mode,
                  child: Row(
                    children: [
                      Icon(
                        mode == sort ? Icons.check : Icons.sort_by_alpha,
                        size: 18,
                        color: mode == sort
                            ? AppColors.kunir500
                            : AppColors.soga300,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        mode.label,
                        style: TextStyle(
                          color: mode == sort
                              ? AppColors.soga50
                              : AppColors.soga200,
                          fontWeight: mode == sort
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Daftar kelompok (artis atau album) beserta jumlah treknya (task 2.5).
///
/// Menekan sebuah kelompok memutar seluruh trek di dalamnya, dimulai dari
/// trek pertama kelompok tersebut.
class _GroupsSliver extends ConsumerWidget {
  const _GroupsSliver({required this.groups, required this.icon});

  /// Nama kelompok → trek-treknya, sudah terurut abjad.
  final List<MapEntry<String, List<Track>>> groups;

  /// Ikon pembeda (artis vs album).
  final IconData icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverList.separated(
      itemCount: groups.length,
      separatorBuilder: (_, _) =>
          const Divider(color: AppColors.soga700, height: 1),
      itemBuilder: (context, index) {
        final group = groups[index];
        final tracks = group.value;
        return ListTile(
          onTap: () => ref
              .read(playerControllerProvider.notifier)
              .playTrack(tracks.first, queue: tracks),
          leading: CircleAvatar(
            backgroundColor: AppColors.soga800,
            child: Icon(icon, color: AppColors.kunir500, size: 20),
          ),
          title: Text(
            group.key,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.soga50,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            '${tracks.length} trek',
            style: const TextStyle(color: AppColors.soga300, fontSize: 13),
          ),
        );
      },
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
