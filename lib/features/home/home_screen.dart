import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lirih/core/constants/app_colors.dart';
import 'package:lirih/core/utils/duration_format.dart';
import 'package:lirih/core/utils/pitch_math.dart';
import 'package:lirih/domain/entities/frequency_preset.dart';
import 'package:lirih/domain/entities/playlist.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:lirih/features/home/recent_plays_controller.dart';
import 'package:lirih/features/library/library_scan_controller.dart';
import 'package:lirih/features/player/player_controller.dart';
import 'package:lirih/features/playlists/add_to_playlist_sheet.dart';
import 'package:lirih/features/playlists/playlist_detail_screen.dart';
import 'package:lirih/features/playlists/playlists_controller.dart';
import 'package:lirih/features/settings/settings_screen.dart';
import 'package:lirih/shared/widgets/track_artwork.dart';

/// Layar Beranda (task 2.6) — titik mula aplikasi.
///
/// Menampilkan sapaan sesuai waktu, tombol **Acak semua** (memutar seluruh
/// pustaka dalam urutan acak), kartu frekuensi penalaan aktif, **strip
/// daftar putar** (yang terakhir diputar di depan — task 3.1), **seluruh
/// lagu yang sudah diimpor**, dan daftar **Putar terakhir** (tersimpan di
/// Hive). Daftar kosong mengarahkan pengguna ke tab Pustaka.
class HomeScreen extends ConsumerWidget {
  /// Membuat layar Beranda.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recents = ref.watch(recentPlaysControllerProvider);
    final library = ref
        .watch(libraryScanControllerProvider)
        .maybeWhen(data: (tracks) => tracks, orElse: () => const <Track>[]);
    final playlists = ref.watch(playlistsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.soga900,
      appBar: AppBar(
        backgroundColor: AppColors.soga800,
        foregroundColor: AppColors.soga50,
        title: const Text('Beranda'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Pengaturan',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Greeting(recents: recents),
                  const SizedBox(height: 16),
                  _ShuffleAll(library: library),
                  const SizedBox(height: 16),
                  const _FrequencyCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: _PlaylistsStrip(playlists: playlists)),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(child: _RecentPlays(tracks: recents)),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          if (library.isEmpty)
            const SliverToBoxAdapter(
              child: _SectionHint(
                icon: Icons.library_music_outlined,
                text:
                    'Belum ada lagu di perangkat. Buka tab Pustaka untuk '
                    'memindai.',
              ),
            )
          else ...[
            const SliverToBoxAdapter(child: _AllSongsHeader()),
            SliverList.separated(
              itemCount: library.length,
              separatorBuilder: (_, _) =>
                  const Divider(color: AppColors.soga700, height: 1),
              itemBuilder: (context, index) {
                final track = library[index];
                return _RecentRow(
                  track: track,
                  onTap: () => ref
                      .read(playerControllerProvider.notifier)
                      .playTrack(track, queue: library),
                  onLongPress: () => showAddToPlaylistSheet(context, track),
                );
              },
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

/// Sapaan sesuai waktu + ringkasan koleksi.
class _Greeting extends StatelessWidget {
  const _Greeting({required this.recents});

  final List<Track> recents;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 11
        ? 'Selamat pagi'
        : hour < 15
        ? 'Selamat siang'
        : hour < 19
        ? 'Selamat sore'
        : 'Selamat malam';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting 🎧',
          style: const TextStyle(
            color: AppColors.soga50,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          recents.isEmpty
              ? 'Selamat datang di Lirih. Pilih lagu untuk mulai.'
              : '${recents.length} trek pernah kamu putar.',
          style: const TextStyle(color: AppColors.soga300, fontSize: 14),
        ),
      ],
    );
  }
}

/// Tombol besar "Acak semua" — memutar pustaka dalam urutan acak.
class _ShuffleAll extends ConsumerWidget {
  const _ShuffleAll({required this.library});

  final List<Track> library;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = library.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: enabled
            ? () {
                final shuffled = List<Track>.of(library)..shuffle();
                unawaited(
                  ref
                      .read(playerControllerProvider.notifier)
                      .playTrack(shuffled.first, queue: shuffled),
                );
              }
            : null,
        icon: const Icon(Icons.shuffle),
        label: const Text(
          'Acak semua',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.kunir600,
          foregroundColor: AppColors.soga50,
          disabledBackgroundColor: AppColors.soga700,
          disabledForegroundColor: AppColors.soga400,
        ),
      ),
    );
  }
}

/// Kartu frekuensi penalaan aktif — tanda tangan Lirih.
class _FrequencyCard extends ConsumerWidget {
  const _FrequencyCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerControllerProvider);
    final hz = player.frequencyHz;
    final cents = centsOffsetForFrequency(hz);
    final preset = FrequencyPreset.builtins
        .where((p) => (p.frequencyHz - hz).abs() < 0.5)
        .firstOrNull;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.soga850,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.nila600, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.tune, color: AppColors.nila400, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Penalaan aktif',
                  style: TextStyle(color: AppColors.soga200, fontSize: 13),
                ),
                Text(
                  '${hz.toStringAsFixed(hz == hz.roundToDouble() ? 0 : 1)} Hz'
                  '${preset != null ? ' · ${preset.name}' : ''}',
                  style: const TextStyle(
                    color: AppColors.kunir500,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${cents >= 0 ? '+' : ''}${cents.toStringAsFixed(1)} cents',
            style: const TextStyle(color: AppColors.nila400, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// Bagian "Putar terakhir" — memutar trek dengan riwayat sebagai antrean.
class _RecentPlays extends ConsumerWidget {
  const _RecentPlays({required this.tracks});

  final List<Track> tracks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tracks.isEmpty) {
      return const _SectionHint(
        icon: Icons.history,
        text: 'Belum ada lagu yang diputar. Mulai dari tab Pustaka.',
      );
    }

    final shown = tracks.take(10).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Putar terakhir',
            style: TextStyle(
              color: AppColors.soga100,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...shown.map(
          (track) => _RecentRow(
            track: track,
            onTap: () => ref
                .read(playerControllerProvider.notifier)
                .playTrack(track, queue: shown),
          ),
        ),
      ],
    );
  }
}

/// Satu baris trek terakhir.
class _RecentRow extends StatelessWidget {
  const _RecentRow({
    required this.track,
    required this.onTap,
    this.onLongPress,
  });

  final Track track;

  final VoidCallback onTap;

  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      onTap: onTap,
      onLongPress: onLongPress,
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
      trailing: Text(
        formatTrackDuration(track.durationMs),
        style: const TextStyle(color: AppColors.soga400, fontSize: 13),
      ),
    );
  }
}

/// Strip horizontal "Daftar putar" — playlist terakhir diputar di depan
/// (task 3.1). Menuju `PlaylistDetailScreen` saat ditekan.
class _PlaylistsStrip extends StatelessWidget {
  const _PlaylistsStrip({required this.playlists});

  final List<Playlist> playlists;

  @override
  Widget build(BuildContext context) {
    if (playlists.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: _SectionHint(
          icon: Icons.playlist_play,
          text: 'Belum ada daftar putar. Buat atau impor dari tab Pustaka.',
        ),
      );
    }

    // Favorit = yang terakhir diputar di depan; sisanya tetap (urutan buat).
    final sorted = [...playlists]
      ..sort((a, b) {
        final av = a.lastPlayedAt;
        final bv = b.lastPlayedAt;
        if (av == null && bv == null) return 0;
        if (av == null) return 1;
        if (bv == null) return -1;
        return bv.compareTo(av);
      });

    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daftar putar',
            style: TextStyle(
              color: AppColors.soga100,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 84,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 20),
              itemCount: sorted.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final playlist = sorted[index];
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
        ],
      ),
    );
  }
}

/// Kartu satu playlist untuk strip Beranda.
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

/// Judul bagian "Semua lagu" + jumlah trek terimpor.
class _AllSongsHeader extends ConsumerWidget {
  const _AllSongsHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref
        .watch(libraryScanControllerProvider)
        .maybeWhen(data: (tracks) => tracks.length, orElse: () => 0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
      child: Row(
        children: [
          const Text(
            'Semua lagu',
            style: TextStyle(
              color: AppColors.soga100,
              fontSize: 18,
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

/// Pesan kosong untuk sebuah bagian.
class _SectionHint extends StatelessWidget {
  const _SectionHint({required this.icon, required this.text});

  final IconData icon;

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.soga400, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppColors.soga300, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
