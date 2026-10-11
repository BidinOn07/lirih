import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lirih/core/constants/app_colors.dart';
import 'package:lirih/core/utils/duration_format.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:lirih/features/player/player_controller.dart';
import 'package:lirih/features/track_tags/track_options_sheet.dart';
import 'package:lirih/shared/widgets/track_artwork.dart';

/// Membuka *bottom sheet* antrean pemutar (task 2.9).
///
/// Antrean dapat diurutkan ulang (drag), trek dapat dihapus, dan mengetuk
/// sebuah trek langsung memutarnya. Trek aktif ditandai warna kunir.
Future<void> showQueueSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.soga850,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _QueueSheet(),
  );
}

class _QueueSheet extends ConsumerWidget {
  const _QueueSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerControllerProvider);
    final queue = player.queue;
    final notifier = ref.read(playerControllerProvider.notifier);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return _QueueBody(
          scrollController: scrollController,
          queue: queue,
          notifier: notifier,
          currentIndex: player.currentIndex,
        );
      },
    );
  }
}

/// Isi sheet: header + daftar antrean yang dapat diurutkan ulang.
class _QueueBody extends StatefulWidget {
  const _QueueBody({
    required this.scrollController,
    required this.queue,
    required this.notifier,
    required this.currentIndex,
  });

  final ScrollController scrollController;

  final List<Track> queue;

  final PlayerController notifier;

  final int currentIndex;

  @override
  State<_QueueBody> createState() => _QueueBodyState();
}

class _QueueBodyState extends State<_QueueBody> {
  /// Key baris pertama untuk mengukur tinggi baris (semua baris seragam).
  final GlobalKey _firstRowKey = GlobalKey();

  /// Agar hanya gulir sekali saat sheet dibuka.
  bool _hasScrolled = false;

  @override
  void initState() {
    super.initState();
    // Gulir ke trek aktif begitu layout pertama selesai, agar pengguna
    // tidak perlu scroll dari awal untuk menemukan lagu yang diputar.
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrent());
  }

  void _scrollToCurrent() {
    if (!mounted || _hasScrolled) return;
    if (!widget.scrollController.hasClients) return;
    if (widget.currentIndex <= 0) {
      _hasScrolled = true;
      return;
    }

    // Tinggi tiap baris seragam; ukur dari baris pertama yang pasti ter-render.
    double rowHeight = 68; // fallback sebelum terukur.
    final box = _firstRowKey.currentContext?.findRenderObject();
    if (box is RenderBox && box.hasSize) {
      rowHeight = box.size.height;
    }

    final position = widget.scrollController.position;
    // Posisikan trek aktif sedikit di bawah puncak sheet agar beberapa trek
    // sebelumnya juga terlihat (konteks posisi dalam antrean).
    final target = widget.currentIndex * rowHeight - rowHeight * 0.5;
    widget.scrollController.jumpTo(target.clamp(0.0, position.maxScrollExtent));
    _hasScrolled = true;
  }

  @override
  Widget build(BuildContext context) {
    final queue = widget.queue;
    final notifier = widget.notifier;

    return Column(
      children: [
        _SheetHandle(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Row(
            children: [
              const Text(
                'Antrean',
                style: TextStyle(
                  color: AppColors.soga50,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${queue.length} trek',
                style: const TextStyle(color: AppColors.soga400, fontSize: 13),
              ),
            ],
          ),
        ),
        const Divider(color: AppColors.soga700, height: 1),
        Expanded(
          child: queue.isEmpty
              ? const Center(
                  child: Text(
                    'Antrean kosong. Putar lagu dari Pustaka.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.soga300),
                  ),
                )
              : ReorderableListView.builder(
                  scrollController: widget.scrollController,
                  itemCount: queue.length,
                  onReorderItem: notifier.reorderQueue,
                  proxyDecorator: (child, _, _) => Material(
                    color: Colors.transparent,
                    elevation: 6,
                    borderRadius: BorderRadius.circular(12),
                    child: child,
                  ),
                  itemBuilder: (context, index) {
                    final track = queue[index];
                    return _QueueRow(
                      // Baris pertama memakai GlobalKey agar tinggi baris
                      // bisa diukur untuk auto-scroll; baris lain pakai
                      // ValueKey (id trek) untuk drag reorder.
                      key: index == 0
                          ? _firstRowKey
                          : ValueKey<String>(track.id),
                      track: track,
                      isCurrent: index == widget.currentIndex,
                      onTap: () {
                        Navigator.of(context).pop();
                        unawaited(notifier.jumpTo(index));
                      },
                      onRemove: () =>
                          unawaited(notifier.removeFromQueue(index)),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Pegangan drag di puncak sheet.
class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.soga500,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

/// Satu baris antrean: sampul, judul+artis, durasi, tombol hapus.
class _QueueRow extends StatelessWidget {
  const _QueueRow({
    required this.track,
    required this.isCurrent,
    required this.onTap,
    required this.onRemove,
    super.key,
  });

  final Track track;

  final bool isCurrent;

  final VoidCallback onTap;

  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isCurrent ? AppColors.soga800 : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              TrackArtwork(track: track, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isCurrent
                            ? AppColors.kunir500
                            : AppColors.soga50,
                        fontSize: 15,
                        fontWeight: isCurrent
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      track.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.soga300,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
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
                tooltip: 'Hapus dari antrean',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
