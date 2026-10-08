import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lirih/core/constants/app_colors.dart';
import 'package:lirih/core/constants/app_info.dart';
import 'package:lirih/core/utils/pitch_math.dart';
import 'package:lirih/domain/entities/frequency_preset.dart';
import 'package:lirih/features/player/player_controller.dart';
import 'package:lirih/features/settings/settings_controller.dart';
import 'package:lirih/shared/widgets/lirih_wordmark.dart';

/// Layar Pengaturan (task 5.x) — frekuensi default + tentang aplikasi.
///
/// Frekuensi yang dipilih disimpan permanen dan dipulihkan saat aplikasi
/// dibuka kembali (lihat [SettingsController] dan `PlayerController.build`).
class SettingsScreen extends ConsumerWidget {
  /// Membuat layar Pengaturan.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultHz = ref.watch(settingsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.soga900,
      appBar: AppBar(
        backgroundColor: AppColors.soga800,
        foregroundColor: AppColors.soga50,
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          const _SectionTitle(text: 'Penalaan'),
          const SizedBox(height: 8),
          _FrequencyDefaults(defaultHz: defaultHz),
          const SizedBox(height: 28),
          const _SectionTitle(text: 'Tentang'),
          const SizedBox(height: 8),
          const _AboutCard(),
        ],
      ),
    );
  }
}

/// Judul bagian.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.kunir500,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }
}

/// Pilihan frekuensi default pemutar.
class _FrequencyDefaults extends ConsumerWidget {
  const _FrequencyDefaults({required this.defaultHz});

  final double defaultHz;

  /// Ringkasan frekuensi aktif: "432 Hz (−31.8 cents)".
  String _frequencySummary(double hz) {
    final plain = hz == hz.roundToDouble();
    final cents = centsOffsetForFrequency(hz);
    final sign = cents >= 0 ? '+' : '';
    return '${hz.toStringAsFixed(plain ? 0 : 1)} Hz '
        '($sign${cents.toStringAsFixed(1)} cents)';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.soga850,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Frekuensi default',
            style: TextStyle(
              color: AppColors.soga50,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Dipakai pemutar setiap kali aplikasi dibuka.',
            style: TextStyle(color: AppColors.soga300, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: FrequencyPreset.builtins
                .map(
                  (preset) => Expanded(
                    child: _PresetChip(
                      preset: preset,
                      selected: (preset.frequencyHz - defaultHz).abs() < 0.5,
                      onTap: () {
                        unawaited(
                          ref
                              .read(settingsControllerProvider.notifier)
                              .setDefaultFrequency(preset.frequencyHz),
                        );
                        // Terapkan juga ke pemutar untuk feedback langsung.
                        unawaited(
                          ref
                              .read(playerControllerProvider.notifier)
                              .setFrequency(preset.frequencyHz),
                        );
                      },
                    ),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 12),
          Text(
            _frequencySummary(defaultHz),
            style: const TextStyle(color: AppColors.soga400, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// Satu chip preset frekuensi.
class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  final FrequencyPreset preset;

  final bool selected;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: selected ? AppColors.kunir600 : AppColors.soga700,
          foregroundColor: AppColors.soga50,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          preset.name,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// Kartu tentang aplikasi — identitas & privasi.
class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.soga850,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.nila600, width: 1.5),
      ),
      child: const Column(
        children: [
          LirihWordmark(fontSize: 30, color: AppColors.soga50),
          SizedBox(height: 4),
          Text(
            '$kAppTagline · $kAppVersion',
            style: TextStyle(color: AppColors.soga300, fontSize: 13),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.lock_outline, color: AppColors.nila400, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Lirih tidak mengumpulkan data apa pun. '
                  'Semua musik dan pengaturan ada di perangkatmu.',
                  style: TextStyle(
                    color: AppColors.soga200,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.music_note_outlined,
                color: AppColors.nila400,
                size: 18,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Penyetelan 432/528 Hz hanyalah pengaturan nada pemutaran '
                  '(pitch shift), bukan klaim efek apa pun.',
                  style: TextStyle(
                    color: AppColors.soga200,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Penerbit: $kAppPublisher',
            style: TextStyle(color: AppColors.soga400, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
