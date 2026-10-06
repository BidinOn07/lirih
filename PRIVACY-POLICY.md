# Kebijakan Privasi

**Aplikasi:** Lirih
**Versi:** 1.0.0
**Diterbitkan oleh:** [Sakadabra]
**Terakhir diperbarui:** 6 Oktober 2026

---

## 1. Ringkasan

**Lirih tidak mengumpulkan, tidak mengirim, dan tidak menjual data apa pun tentang Anda.**

Aplikasi ini bekerja sepenuhnya **offline**. File musik, playlist, dan riwayat pemutaran tetap berada di perangkat Anda dan tidak pernah dikirim ke server mana pun — karena aplikasi ini tidak memiliki server.

---

## 2. Cakupan kebijakan ini

Kebijakan ini berlaku untuk aplikasi seluler **Lirih** untuk sistem operasi Android, yang diterbitkan melalui **Google Play Store** oleh **[NAMA_PENGEMBANG]**.

Kebijakan ini **tidak mencakup** layanan pihak ketiga yang mungkin Anda akses melalui tautan di luar aplikasi.

---

## 3. Data yang kami kumpulkan

**Tidak ada data yang dikumpulkan.**

| Jenis data | Dikumpulkan? | Dibagikan ke pihak ketiga? | Disimpan di |
|---|---|---|---|
| Nama, email, nomor telepon | ❌ Tidak — aplikasi tidak memiliki pendaftaran akun | ❌ | — |
| Lokasi (GPS) | ❌ Tidak diminta | ❌ | — |
| Daftar kontak | ❌ Tidak diminta | ❌ | — |
| ID perangkat / ID iklan | ❌ Tidak | ❌ | — |
| Riwayat pemutaran | Hanya untuk kebutuhan aplikasi | ❌ Tidak keluar dari perangkat | Penyimpanan lokal perangkat |
| Playlist & pengaturan antarmuka | Hanya untuk kebutuhan aplikasi | ❌ Tidak keluar dari perangkat | Penyimpanan lokal perangkat |
| File musik yang Anda putar | ❌ Tidak disalin, tidak diunggah | ❌ | Tetap di lokasi aslinya |
| Data analitik / statistik penggunaan | ❌ Tidak ada | ❌ | — |
| Log kerusakan (crash log) | ❌ Tidak ada layanan pelacakan | ❌ | — |

> **Catatan:** riwayat pemutaran, playlist, riwayat pencarian, dan lirik disimpan **hanya** agar aplikasi dapat berfungsi — misalnya agar lagu terakhir yang Anda dengarkan bisa dilanjutkan saat aplikasi dibuka kembali. Data ini **tidak pernah dikirim ke luar perangkat**.

---

## 4. Izin yang diminta dan alasannya

| Izin | Diperlukan untuk | Berlaku di Android |
|---|---|---|
| `READ_MEDIA_AUDIO` | Membaca file musik yang tersimpan di perangkat Anda | 13 ke atas |
| `READ_EXTERNAL_STORAGE` | Membaca file musik (versi izin lama) | 12 ke bawah |
| `POST_NOTIFICATIONS` | Menampilkan kontrol pemutar di panel notifikasi | 13 ke atas |
| Layanan latar depan pemutaran media | Menjalankan pemutaran saat layar mati atau aplikasi di latar belakang | Semua versi |
| `WAKE_LOCK` | Mencegah perangkat tidur selama pemutaran berlangsung | Semua versi |

**Aplikasi ini tidak meminta izin `INTERNET` pada versi ini.**

> Izin hanya diminta saat Anda menggunakannya pertama kali, dan aplikasi tetap berfungsi bila Anda menolak izin tersebut (dengan keterbatasan yang wajar — misalnya tidak dapat memindai lagu bila akses media ditolak).

---

## 5. Penyimpanan di perangkat Anda

Aplikasi menyimpan data berikut **di penyimpanan internal perangkat** (sandbox aplikasi):

- Antrean pemutaran
- Lagu terakhir yang diputar
- Riwayat pencarian
- Playlist buatan Anda
- cache lirik dan gambar sampul album

Data ini **hanya ada di perangkat Anda** dan **hanya selama aplikasi terinstal**.

---

## 6. Penggunaan internet

Versi 1 aplikasi ini **tidak melakukan koneksi internet apa pun** — tidak ada pembaruan otomatis, tidak ada pengambilan konten, tidak ada pengiriman telemetri, dan tidak ada komunikasi dengan server.

Semua fungsi aplikasi (memutar, mengubah tinggi nada, mengatur kecepatan, menyusun playlist, menampilkan lirik) berjalan **sepenuhnya secara lokal** di perangkat Anda.

---

## 7. Iklan dan pembelian dalam aplikasi

- **Iklan:** Tidak ada. Aplikasi ini tidak menampilkan iklan apa pun.
- **Pembelian dalam aplikasi:** Tidak ada pada versi ini.
- **Langganan:** Tidak ada pada versi ini.
- **Transaksi keuangan:** Tidak ada. Aplikasi ini sepenuhnya gratis.

---

## 8. Anak-anak

Aplikasi ini **tidak ditujukan khusus untuk anak-anak di bawah 13 tahun**, dan **tidak secara sadar mengumpulkan informasi pribadi dari anak mana pun**.

Karena aplikasi tidak mengumpulkan data pengguna apa pun, tidak ada data anak yang dikumpulkan, disimpan, maupun dibagikan.

---

## 9. Pihak ketiga dan layanan eksternal

Aplikasi ini **tidak menggunakan**:

- SDK analitik
- SDK iklan
- SDK pihak ketiga untuk pelacakan
- Layanan awan / backend
- Basis data daring
- Penyedia otentikasi (tidak ada login)

Aplikasi dibangun dengan pustaka sumber terbuka (*open source*). Daftar dependensi tersedia pada berkas `pubspec.yaml` dan `THIRD_PARTY_NOTICES.md` di repositori proyek.

---

## 10. Keamanan

Karena **tidak ada data yang dikirim** melalui jaringan, tidak ada data yang dapat disadap dalam perjalanan.

Data yang tersimpan di perangkat dilindungi oleh mekanisme isolasi aplikasi (*sandbox*) bawaan sistem operasi Android.

> **Rekomendasi:** gunakan kunci layar (PIN/pola/biometrik) pada perangkat Anda agar data lokal tidak dapat diakses pihak lain yang memegang perangkat Anda.

---

## 11. Retensi dan penghapusan data

| Data | Berapa lama disimpan | Cara menghapus |
|---|---|---|
| Playlist, riwayat, pengaturan | Selama aplikasi terinstal | Hapus aplikasi, atau **Pengaturan → Aplikasi → Lirih → Hapus data** |
| Cache gambar sampul & lirik | Selama aplikasi terinstal | **Pengaturan → Penyimpanan → Hapus cache** |
| File musik Anda | Tidak pernah disentuh aplikasi | Tidak berpengaruh — file Anda tetap utuh |

**Menghapus aplikasi akan menghapus seluruh data lokal yang dibuat oleh aplikasi.** Tidak ada salinan data Anda yang tersimpan di tempat lain.

---

## 12. Hak Anda

Karena aplikasi **tidak mengumpulkan dan tidak menyimpan data di server mana pun**:

- **Tidak ada** data Anda yang dapat kami berikan, perbaiki, atau hapus atas permintaan — karena kami tidak pernah menerimanya.
- Anda memiliki **kendali penuh** atas seluruh data lokal melalui pengaturan di perangkat Anda (lihat bagian 11).
- Anda **tidak perlu membuat akun**, sehingga tidak ada data identitas yang melekat pada penggunaan aplikasi ini.

---

## 13. Tautan ke pihak ketiga

Aplikasi ini dapat menampilkan tautan statis (misalnya ke halaman resmi pengembang) yang membuka peramban perangkat Anda.

Saat Anda meninggalkan aplikasi, kebijakan privasi pihak ketiga tersebut yang berlaku. Kami tidak bertanggung jawab atas praktik privasi situs eksternal.

---

## 14. Perubahan kebijakan ini

Kebijakan ini dapat diperbarui sewaktu-waktu. Tanggal pembaruan terakhir tercantum di bagian atas halaman ini.

Perubahan material akan disertai pembaruan aplikasi di Google Play Store beserta catatan perubahan (*changelog*).

---

## 15. Kontak

Untuk pertanyaan mengenai kebijakan ini:

- **[NAMA_PENGEMBANG]**
- Email: **bidinwahyudin090@gmail.com**
- repositori proyek: **https://github.com/BidinOn07/lirih**
- situs: **https://bidinon07.github.io/lirih/**

---

## Pernyataan

Kebijakan ini disusun sesuai dengan kondisi nyata aplikasi pada tanggal penerbitan dan dapat diubah bila fitur aplikasi berubah. Bila versi mendatang menambahkan fitur yang terhubung ke internet, mengumpulkan data, menampilkan iklan, atau menyediakan pembelian dalam aplikasi, kebijakan ini **wajib diperbarui terlebih dahulu** sebelum fitur tersebut dirilis.

---

*Dokumen ini disiapkan sebagai templat untuk aplikasi ini dan bukan nasihat hukum. Konsultasikan dengan profesional hukum bila Anda memerlukan peninjauan formal.*
