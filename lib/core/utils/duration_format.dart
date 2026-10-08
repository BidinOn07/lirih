/// Memformat milidetik menjadi `m:ss` untuk tampilan durasi trek.
///
/// Contoh: `275000` → `4:35`, `null`/negatif → `0:00`.
String formatTrackDuration(int? ms) {
  if (ms == null || ms <= 0) return '0:00';
  final totalSeconds = ms ~/ 1000;
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
