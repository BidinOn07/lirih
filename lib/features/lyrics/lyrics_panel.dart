import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lirih/core/constants/app_colors.dart';
import 'package:lirih/features/lyrics/lyrics_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lyrics_panel.g.dart';

/// Apakah panel lirik sedang ditampilkan di Pemutar (task 3.3).
@riverpod
class LyricsVisibility extends _$LyricsVisibility {
  @override
  bool build() => false;

  /// Membuka/menutup panel lirik.
  void toggle() => state = !state;
}

/// Panel lirik trek aktif (task 3.3) — menggantikan sampul album saat
/// aktif. Lirik tertanam (plain text, tidak tersinkron) digulir manual.
class LyricsPanel extends ConsumerWidget {
  /// Membuat panel lirik.
  const LyricsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lyrics = ref.watch(lyricsControllerProvider);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.soga850,
        border: Border.all(color: AppColors.nila600, width: 1.5),
      ),
      child: lyrics.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.kunir500),
        ),
        error: (_, _) => const _LyricsHint(
          icon: Icons.error_outline,
          text: 'Lirik tidak dapat dimuat untuk trek ini.',
        ),
        data: (text) {
          if (text == null || text.trim().isEmpty) {
            return const _LyricsHint(
              icon: Icons.lyrics_outlined,
              text: 'Trek ini tidak memiliki lirik tertanam.',
            );
          }
          final lines = text.split('\n');
          return Scrollbar(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: lines.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text(
                  lines[index],
                  style: const TextStyle(
                    color: AppColors.soga100,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Pesan kosong di tengah panel lirik.
class _LyricsHint extends StatelessWidget {
  const _LyricsHint({required this.icon, required this.text});

  final IconData icon;

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.nila400, size: 32),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.soga300, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
