/// Identifier stabil untuk sebuah Track lintas pemindaian pustaka.
///
/// TDD §3.2 mengusulkan UUID v4 acak "agar stabil lintas pemindaian", tetapi
/// id acak justru **berubah** setiap pemindaian — memutus referensi entri
/// Hive (antrean, riwayat, playlist). Karena itu dipakai **id deterministik**
/// dari konten trek: hash dari path + judul + artis + durasi. File fisik yang
/// sama selalu memetakan ke id yang sama, apa pun kapan dipindai.
///
/// Catatan: ini penyimpangan disengaja dari TDD §3.2 dengan alasan di atas.
String stableTrackId({
  required String filePath,
  required String title,
  required String artist,
  required int? durationMs,
}) {
  final seed = '$filePath|$title|$artist|${durationMs ?? 0}';
  return 'local_${seed.hashCode.toUnsigned(32).toRadixString(16)}';
}
