import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Nama berkas sampel uji di `assets/samples/` (task 0.9).
///
/// Berhak cipta — hanya untuk pengujian debug di perangkat sendiri, tidak
/// boleh masuk AAB rilis. Lihat `.gitignore` & AGENTS.md.
const String kBundledSampleAsset = 'assets/samples/sample.mp3';

/// Nama berkas sementara hasil ekstraksi sampel.
const String _tempSampleName = 'lirih_sample.mp3';

/// Menyiapkan sampel musik yang dibundel agar dapat diputar mesin DSP.
///
/// Flutter asset berada di dalam APK dan tidak memiliki absolute path,
/// sedangkan `LirihDspPlayer` memutar berkas via path/URI. Karena itu byte
/// aset ditulis dulu ke [Directory.systemTemp] (penyimpanan privat aplikasi,
/// tanpa permission), sama seperti WavToneGenerator.
@immutable
class BundledSample {
  /// Membuat helper sampel bundled.
  const BundledSample();

  /// Mengekstrak sampel ke berkas sementara dan mengembalikan path-nya.
  ///
  /// Mengembalikan `null` bila sampel tidak tersedia (folder `assets/samples/`
  /// kosong — mis. fresh clone atau build CI) sehingga UI bisa menampilkan
  /// pesan yang sesuai tanpa melempar galat.
  Future<String?> prepare() async {
    try {
      final bytes = await rootBundle.load(kBundledSampleAsset);
      final dir = await Directory.systemTemp.create(recursive: true);
      final file = File('${dir.path}/$_tempSampleName');
      await file.writeAsBytes(bytes.buffer.asUint8List());
      return file.path;
    } on Exception {
      // Aset tidak ada — kasus normal di CI/fresh clone.
      return null;
    }
  }
}
