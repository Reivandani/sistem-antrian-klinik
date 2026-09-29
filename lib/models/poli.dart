import 'package:flutter/material.dart';

// ==========================================================
// ABSTRACT CLASS POLI
// ==========================================================

abstract class Poli {
  // ========================================================
  // DATA DASAR POLI
  // ========================================================

  String nama;
  String dokter;
  int jumlahAntrian;
  IconData icon;
  String gambar;

  // ========================================================
  // DATA DETAIL POLI
  // ========================================================

  String deskripsi;
  String jamPelayanan;
  String lokasi;
  List<String> layanan;

  // ========================================================
  // CONSTRUCTOR
  // ========================================================

  Poli({
    required this.nama,
    required this.dokter,
    required this.jumlahAntrian,
    required this.icon,
    required this.gambar,
    required this.deskripsi,
    required this.jamPelayanan,
    required this.lokasi,
    required this.layanan,
  });

  // ========================================================
  // METHOD ABSTRACT
  // ========================================================

  String getInfo();
}

// ==========================================================
// POLI UMUM
// ==========================================================

class PoliUmum extends Poli {
  PoliUmum({required super.dokter, required super.jumlahAntrian})
    : super(
        nama: 'Poli Umum',
        icon: Icons.medical_services,
        gambar: 'assets/poli/umum.png',

        deskripsi:
            'Poli Umum menyediakan layanan pemeriksaan '
            'kesehatan dasar dan penanganan berbagai '
            'keluhan kesehatan yang umum dialami pasien. '
            'Pemeriksaan dapat meliputi pengecekan kondisi '
            'tubuh, tekanan darah, suhu tubuh, serta '
            'konsultasi mengenai keluhan kesehatan sebelum '
            'pasien mendapatkan penanganan atau pemeriksaan '
            'lebih lanjut.',

        jamPelayanan: '08.00 - 15.00',

        lokasi: 'Lantai 1 - Ruang 101',

        layanan: [
          'Pemeriksaan kesehatan umum',
          'Pemeriksaan tekanan darah',
          'Pemeriksaan kondisi umum',
        ],
      );

  @override
  String getInfo() {
    return 'Pemeriksaan kesehatan umum untuk pasien.';
  }
}

// ==========================================================
// POLI GIGI
// ==========================================================

class PoliGigi extends Poli {
  PoliGigi({required super.dokter, required super.jumlahAntrian})
    : super(
        nama: 'Poli Gigi',
        icon: Icons.mood,
        gambar: 'assets/poli/gigi.png',

        deskripsi:
            'Poli Gigi menyediakan layanan pemeriksaan '
            'dan perawatan kesehatan gigi serta mulut. '
            'Pasien dapat melakukan konsultasi mengenai '
            'berbagai keluhan seperti sakit gigi, gigi '
            'berlubang, masalah gusi, serta mendapatkan '
            'pemeriksaan dan perawatan gigi sesuai dengan '
            'kondisi yang dialami.',

        jamPelayanan: '08.00 - 14.00',

        lokasi: 'Lantai 1 - Ruang 102',

        layanan: [
          'Pemeriksaan gigi',
          'Pembersihan gigi',
          'Konsultasi kesehatan gigi',
        ],
      );

  @override
  String getInfo() {
    return 'Pemeriksaan dan perawatan kesehatan gigi.';
  }
}

// ==========================================================
// POLI MATA
// ==========================================================

class PoliMata extends Poli {
  PoliMata({required super.dokter, required super.jumlahAntrian})
    : super(
        nama: 'Poli Mata',
        icon: Icons.remove_red_eye,
        gambar: 'assets/poli/mata.png',

        deskripsi:
            'Poli Mata menyediakan layanan pemeriksaan '
            'kesehatan mata dan penglihatan. Pemeriksaan '
            'dapat dilakukan untuk mengetahui kondisi '
            'penglihatan pasien serta membantu menangani '
            'berbagai keluhan seperti mata kabur, mata '
            'mudah lelah, atau gangguan penglihatan lainnya.',

        jamPelayanan: '08.00 - 14.00',

        lokasi: 'Lantai 2 - Ruang 201',

        layanan: [
          'Pemeriksaan mata',
          'Pemeriksaan penglihatan',
          'Konsultasi gangguan mata',
        ],
      );

  @override
  String getInfo() {
    return 'Pemeriksaan kesehatan dan penglihatan mata.';
  }
}

// ==========================================================
// POLI JANTUNG
// ==========================================================

class PoliJantung extends Poli {
  PoliJantung({required super.dokter, required super.jumlahAntrian})
    : super(
        nama: 'Poli Jantung',
        icon: Icons.favorite,
        gambar: 'assets/poli/jantung.png',

        deskripsi:
            'Poli Jantung menyediakan layanan pemeriksaan '
            'dan konsultasi yang berkaitan dengan kesehatan '
            'jantung dan sistem kardiovaskular. Pasien dapat '
            'melakukan pemeriksaan kondisi jantung serta '
            'berkonsultasi mengenai keluhan atau faktor '
            'risiko yang berkaitan dengan kesehatan jantung.',

        jamPelayanan: '08.00 - 13.00',

        lokasi: 'Lantai 2 - Ruang 202',

        layanan: [
          'Pemeriksaan jantung',
          'Konsultasi kesehatan jantung',
          'Pemeriksaan kondisi kardiovaskular',
        ],
      );

  @override
  String getInfo() {
    return 'Pemeriksaan kesehatan dan fungsi jantung.';
  }
}

// ==========================================================
// POLI ANAK
// ==========================================================

class PoliAnak extends Poli {
  PoliAnak({required super.dokter, required super.jumlahAntrian})
    : super(
        nama: 'Poli Anak',
        icon: Icons.child_care,
        gambar: 'assets/poli/anak.png',

        deskripsi:
            'Poli Anak menyediakan layanan pemeriksaan '
            'dan pemantauan kesehatan khusus bagi pasien '
            'anak. Pemeriksaan dapat mencakup kondisi '
            'kesehatan secara umum, pertumbuhan dan '
            'perkembangan anak, serta konsultasi mengenai '
            'berbagai keluhan kesehatan yang dialami oleh anak.',

        jamPelayanan: '08.00 - 15.00',

        lokasi: 'Lantai 1 - Ruang 103',

        layanan: [
          'Pemeriksaan kesehatan anak',
          'Pemantauan pertumbuhan',
          'Konsultasi kesehatan anak',
        ],
      );

  @override
  String getInfo() {
    return 'Pemeriksaan kesehatan khusus untuk anak.';
  }
}

// ==========================================================
// POLI SARAF
// ==========================================================

class PoliSaraf extends Poli {
  PoliSaraf({required super.dokter, required super.jumlahAntrian})
    : super(
        nama: 'Poli Saraf',
        icon: Icons.psychology,
        gambar: 'assets/poli/saraf.png',

        deskripsi:
            'Poli Saraf menyediakan layanan pemeriksaan '
            'dan konsultasi yang berkaitan dengan sistem '
            'saraf. Pasien dapat berkonsultasi mengenai '
            'berbagai keluhan yang berhubungan dengan '
            'fungsi saraf, seperti sakit kepala, gangguan '
            'keseimbangan, kesemutan, atau keluhan lainnya '
            'yang memerlukan pemeriksaan lebih lanjut.',

        jamPelayanan: '08.00 - 13.00',

        lokasi: 'Lantai 2 - Ruang 203',

        layanan: [
          'Pemeriksaan sistem saraf',
          'Konsultasi keluhan saraf',
          'Pemeriksaan kondisi neurologis',
        ],
      );

  @override
  String getInfo() {
    return 'Pemeriksaan kesehatan sistem saraf.';
  }
}
