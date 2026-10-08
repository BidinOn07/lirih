import 'package:flutter/material.dart';

import 'package:lirih/core/constants/app_colors.dart';
import 'package:lirih/core/utils/pitch_math.dart';
import 'package:lirih/features/poc_pitch/dsp_channel.dart';
import 'package:lirih/features/poc_pitch/wav_tone_generator.dart';

/// Layar uji PoC pitch shift (task 0.6 & 0.8) — **sementara**.
///
/// Menghasilkan nada murni 440 Hz, memutarnya via MethodChannel DSP, lalu
/// menerapkan rasio pitch dari preset/slider. Tujuannya memvalidasi bahwa
/// pergeseran pitch berfungsi real-time dengan tempo terkunci dan **tanpa
/// artifact** pada 432/528 Hz (validasi 0.9).
///
/// Layar ini akan digantikan oleh layar player sungguhan (task 2.7/2.8) dan
/// mesinnya dipindah ke plugin `lirih_audio` (task 1.x).
class PoCPitchScreen extends StatefulWidget {
  /// Membuat layar uji PoC.
  const PoCPitchScreen({super.key});

  @override
  State<PoCPitchScreen> createState() => _PoCPitchScreenState();
}

class _PoCPitchScreenState extends State<PoCPitchScreen> {
  final DspChannel _dsp = const DspChannel();
  final WavToneGenerator _tones = const WavToneGenerator();

  static const double _reference = kReferenceFrequencyHz;

  double _frequency = 440;
  double _tempo = 1;
  bool _isPlaying = false;
  bool _isPreparing = false;
  String _status = 'Tekan "Bunyikan 440 Hz" untuk memulai.';

  Future<void> _playReference() async {
    setState(() {
      _isPreparing = true;
      _status = 'Menulis berkas WAV sementara…';
    });
    try {
      final path = await _tones.generate(
        frequency: _reference,
        duration: const Duration(seconds: 8),
      );
      await _dsp.play(path);
      if (mounted) {
        setState(() {
          _isPreparing = false;
          _isPlaying = true;
          _status = 'Memutar 440 Hz. Geser slider untuk mengubah nada.';
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _isPreparing = false;
          _status = 'Galat: $e';
        });
      }
    }
  }

  Future<void> _applyFrequency(double hz) async {
    setState(() => _frequency = hz);
    try {
      await _dsp.setPitch(pitchRatioForFrequency(hz));
    } on Exception catch (e) {
      if (mounted) setState(() => _status = 'Galat setPitch: $e');
    }
  }

  Future<void> _applyTempo(double ratio) async {
    setState(() => _tempo = ratio);
    try {
      await _dsp.setTempo(ratio);
    } on Exception catch (e) {
      if (mounted) setState(() => _status = 'Galat setTempo: $e');
    }
  }

  Future<void> _stop() async {
    try {
      await _dsp.stop();
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _status = 'Dihentikan.';
        });
      }
    } on Exception catch (e) {
      if (mounted) setState(() => _status = 'Galat stop: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cents = centsOffsetForFrequency(_frequency);
    return Scaffold(
      backgroundColor: AppColors.soga900,
      appBar: AppBar(
        backgroundColor: AppColors.soga800,
        foregroundColor: AppColors.soga50,
        title: const Text('PoC — Pitch Shift (0.6)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Status ──────────────────────────────────────────────
            Text(
              _status,
              style: const TextStyle(color: AppColors.soga200, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // ── Nada saat ini ────────────────────────────────────────
            Text(
              '${_frequency.toStringAsFixed(0)} Hz',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.kunir500,
                fontSize: 40,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${cents >= 0 ? '+' : ''}${cents.toStringAsFixed(1)} cents',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.nila400, fontSize: 15),
            ),
            const SizedBox(height: 16),

            // ── Preset ───────────────────────────────────────────────
            Row(
              children: <double>[440, 432, 528].map((preset) {
                final selected = (_frequency - preset).abs() < 0.5;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilledButton(
                      onPressed: _isPlaying
                          ? () => _applyFrequency(preset)
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: selected
                            ? AppColors.nila500
                            : AppColors.soga700,
                      ),
                      child: Text(
                        preset.toStringAsFixed(0),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ── Slider kontinu 400–600 Hz ─────────────────────────────
            const Text(
              'Slider kontinu (400–600 Hz)',
              style: TextStyle(color: AppColors.soga200, fontSize: 13),
            ),
            Slider(
              value: _frequency.clamp(kMinFrequencyHz, kMaxFrequencyHz),
              min: kMinFrequencyHz,
              max: kMaxFrequencyHz,
              divisions: 200,
              activeColor: AppColors.kunir500,
              onChanged: _isPlaying ? _applyFrequency : null,
            ),
            const SizedBox(height: 12),

            // ── Tempo 0.5×–2.0× ───────────────────────────────────────
            Text(
              'Tempo: ${_tempo.toStringAsFixed(2)}× (pitch tidak berubah)',
              style: const TextStyle(color: AppColors.soga200, fontSize: 13),
            ),
            Slider(
              value: _tempo,
              min: 0.5,
              max: 2,
              divisions: 30,
              activeColor: AppColors.nila500,
              onChanged: _isPlaying ? _applyTempo : null,
            ),
            const Spacer(),

            // ── Kendali utama ─────────────────────────────────────────
            if (_isPlaying)
              FilledButton.icon(
                onPressed: _stop,
                icon: const Icon(Icons.stop),
                label: const Text('Stop'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error500,
                ),
              )
            else
              FilledButton.icon(
                onPressed: _isPreparing ? null : _playReference,
                icon: _isPreparing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow),
                label: const Text('Bunyikan 440 Hz'),
              ),
            const SizedBox(height: 8),
            const Text(
              'Catatan: slider & preset hanya aktif saat memutar. '
              'Validasi telinga: 432 Hz harus terdengar sedikit lebih rendah '
              'dari 440 Hz; 528 Hz jelas lebih tinggi.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.soga400, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
