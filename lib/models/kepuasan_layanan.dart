
import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk menyimpan dan membaca data kepuasan layanan pasien.
class KepuasanLayanan {
  final String id;
  final String uidPasien;
  final String idAntrean;
  final String namaPasien;
  final String namaPoli;
  final String dokter;
  final int ratingKeseluruhan;
  final int ratingPetugas;
  final int ratingWaktuTunggu;
  final int ratingDokter;
  final String komentar;
  final Timestamp? tanggalPenilaian;

  const KepuasanLayanan({
    required this.id,
    required this.uidPasien,
    required this.idAntrean,
    required this.namaPasien,
    required this.namaPoli,
    required this.dokter,
    required this.ratingKeseluruhan,
    required this.ratingPetugas,
    required this.ratingWaktuTunggu,
    required this.ratingDokter,
    required this.komentar,
    this.tanggalPenilaian,
  });

  factory KepuasanLayanan.dariFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return KepuasanLayanan(
      id: doc.id,
      uidPasien: data['uidPasien'] as String? ?? '',
      idAntrean: data['idAntrean'] as String? ?? doc.id,
      namaPasien: data['namaPasien'] as String? ?? 'Pasien',
      namaPoli: data['namaPoli'] as String? ?? '-',
      dokter: data['dokter'] as String? ?? '-',
      ratingKeseluruhan: (data['ratingKeseluruhan'] as num?)?.toInt() ?? 0,
      ratingPetugas: (data['ratingPetugas'] as num?)?.toInt() ?? 0,
      ratingWaktuTunggu:
          (data['ratingWaktuTunggu'] as num?)?.toInt() ?? 0,
      ratingDokter: (data['ratingDokter'] as num?)?.toInt() ?? 0,
      komentar: data['komentar'] as String? ?? '',
      tanggalPenilaian: data['tanggalPenilaian'] as Timestamp?,
    );
  }

  Map<String, dynamic> keMap() {
    return {
      'uidPasien': uidPasien,
      'idAntrean': idAntrean,
      'namaPasien': namaPasien,
      'namaPoli': namaPoli,
      'dokter': dokter,
      'ratingKeseluruhan': ratingKeseluruhan,
      'ratingPetugas': ratingPetugas,
      'ratingWaktuTunggu': ratingWaktuTunggu,
      'ratingDokter': ratingDokter,
      'komentar': komentar,
      'tanggalPenilaian': FieldValue.serverTimestamp(),
    };
  }
}