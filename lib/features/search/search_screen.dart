import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lirih/core/constants/app_colors.dart';
import 'package:lirih/core/utils/duration_format.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:lirih/features/library/library_scan_controller.dart';
import 'package:lirih/features/player/player_controller.dart';
import 'package:lirih/features/search/search_history_controller.dart';
import 'package:lirih/shared/widgets/track_artwork.dart';

/// Layar Pencarian (task 3.5) — menyaring trek pustaka berdasarkan judul,
/// artis, atau album.
///
/// Saat kosong, menampilkan riwayat pencarian (tersimpan di Hive). Hasil
/// pencarian membentuk antrean pemutaran sehingga lagu yang cocok dapat
/// diputar berurutan.
class SearchScreen extends ConsumerStatefulWidget {
  /// Membuat layar Pencarian.
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _field = TextEditingController();

  String _query = '';

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  /// Menyimpan [kMaxSearchHistory] kueri terbaru saat pengguna submit.
  void _submit() {
    final trimmed = _query.trim();
    if (trimmed.isEmpty) return;
    unawaited(ref.read(searchHistoryControllerProvider.notifier).add(trimmed));
  }

  /// Trek yang cocok [_query] (case-insensitive) pada judul/artis/album.
  List<Track> _filter(List<Track> tracks) {
    final needle = _query.toLowerCase();
    return tracks
        .where(
          (track) =>
              track.title.toLowerCase().contains(needle) ||
              track.artist.toLowerCase().contains(needle) ||
              (track.album?.toLowerCase().contains(needle) ?? false),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final scan = ref.watch(libraryScanControllerProvider);
    final history = ref.watch(searchHistoryControllerProvider);
    final tracks = scan.maybeWhen(
      data: (tracks) => tracks,
      orElse: () => const <Track>[],
    );
    final results = _query.isEmpty ? const <Track>[] : _filter(tracks);

    return Scaffold(
      backgroundColor: AppColors.soga900,
      appBar: AppBar(
        backgroundColor: AppColors.soga800,
        foregroundColor: AppColors.soga50,
        titleSpacing: 0,
        title: _SearchField(
          controller: _field,
          onChanged: (value) => setState(() => _query = value),
          onSubmit: _submit,
        ),
      ),
      body: _query.isEmpty
          ? _RecentSearches(
              history: history,
              onTap: (value) {
                _field.text = value;
                _field.selection = TextSelection.collapsed(
                  offset: value.length,
                );
                setState(() => _query = value);
              },
            )
          : results.isEmpty
          ? _Hint(text: 'Tidak ada lagu yang cocok dengan "$_query".')
          : _Results(tracks: results),
    );
  }
}

/// Kolom pencarian dengan tombol bersihkan.
class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onSubmit,
  });

  final TextEditingController controller;

  final ValueChanged<String> onChanged;

  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: true,
      textInputAction: TextInputAction.search,
      style: const TextStyle(color: AppColors.soga50, fontSize: 16),
      cursorColor: AppColors.kunir500,
      decoration: InputDecoration(
        hintText: 'Cari judul, artis, atau album…',
        hintStyle: const TextStyle(color: AppColors.soga400),
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, value, _) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.soga300,
                    size: 20,
                  ),
                ),
        ),
      ),
      onChanged: onChanged,
      onSubmitted: (_) => onSubmit(),
    );
  }
}

/// Daftar riwayat pencarian saat kolom kosong.
class _RecentSearches extends ConsumerWidget {
  const _RecentSearches({required this.history, required this.onTap});

  final List<String> history;

  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (history.isEmpty) {
      return const _Hint(text: 'Ketik untuk mencari lagu di perangkatmu.');
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pernah dicari',
                style: TextStyle(
                  color: AppColors.soga200,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: ref
                    .read(searchHistoryControllerProvider.notifier)
                    .clear,
                child: const Text(
                  'Bersihkan',
                  style: TextStyle(color: AppColors.soga400, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        ...history.map(
          (entry) => ListTile(
            leading: const Icon(
              Icons.history,
              color: AppColors.soga400,
              size: 20,
            ),
            title: Text(
              entry,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.soga100, fontSize: 15),
            ),
            onTap: () => onTap(entry),
          ),
        ),
      ],
    );
  }
}

/// Pesan kosong di tengah layar.
class _Hint extends StatelessWidget {
  const _Hint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.soga300, fontSize: 15),
        ),
      ),
    );
  }
}

/// Hasil pencarian — memutar trek dengan hasil sebagai antrean.
class _Results extends ConsumerWidget {
  const _Results({required this.tracks});

  final List<Track> tracks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: tracks.length,
      separatorBuilder: (_, _) =>
          const Divider(color: AppColors.soga700, height: 1),
      itemBuilder: (context, index) {
        final track = tracks[index];
        return ListTile(
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
          onTap: () => ref
              .read(playerControllerProvider.notifier)
              .playTrack(track, queue: tracks),
        );
      },
    );
  }
}
