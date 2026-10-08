/// Mode pengulangan antrean pemutar (task 1.11).
enum LoopMode {
  /// Tidak mengulang; pemutaran berhenti di trek terakhir.
  off,

  /// Mengulang seluruh antrean (kembali ke trek pertama setelah terakhir).
  all,

  /// Mengulang trek yang sedang diputar tanpa henti.
  one,
}

/// Urutan siklus tombol repeat: off → all → one → off.
const List<LoopMode> kLoopCycle = <LoopMode>[
  LoopMode.off,
  LoopMode.all,
  LoopMode.one,
];
