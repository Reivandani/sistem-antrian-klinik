
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/kepuasan_layanan.dart';

class KepuasanService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _koleksiPenilaian =>
      _db.collection('penilaian_layanan');

  /// Memeriksa apakah antrean sudah memiliki penilaian.
  Future<bool> sudahDinilai(String idAntrean) async {
    final doc = await _koleksiPenilaian.doc(idAntrean).get();
    return doc.exists;
  }

  /// Menyimpan penilaian.
  ///
  /// ID dokumen penilaian menggunakan ID dokumen antrean.
  /// Dengan demikian, satu antrean hanya mempunyai satu dokumen penilaian.
  Future<void> kirimPenilaian({
    required String idAntrean,
    required int ratingKeseluruhan,
    required int ratingPetugas,
    required int ratingWaktuTunggu,
    required int ratingDokter,
    required String komentar,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Silakan login terlebih dahulu.');
    }

    if ([
      ratingKeseluruhan,
      ratingPetugas,
      ratingWaktuTunggu,
      ratingDokter,
    ].any((rating) => rating < 1 || rating > 5)) {
      throw Exception('Semua rating harus antara 1 sampai 5.');
    }

    final antreanRef = _db.collection('antrean').doc(idAntrean);
    final penilaianRef = _koleksiPenilaian.doc(idAntrean);

    // Transaction membantu mencegah pengiriman ganda.
    await _db.runTransaction((transaction) async {
      final antreanDoc = await transaction.get(antreanRef);
      final penilaianDoc = await transaction.get(penilaianRef);

      if (!antreanDoc.exists) {
        throw Exception('Data antrean tidak ditemukan.');
      }

      if (penilaianDoc.exists) {
        throw Exception('Antrean ini sudah pernah dinilai.');
      }

      final antrean = antreanDoc.data()!;
      final uidAntrean = antrean['uid'] as String?;
      final status = antrean['status'] as String?;

      if (uidAntrean != user.uid) {
        throw Exception('Kamu tidak berhak menilai antrean ini.');
      }

      if (status != 'Selesai') {
        throw Exception('Penilaian hanya dapat diberikan setelah antrean selesai.');
      }

      final userDoc = await transaction.get(
        _db.collection('users').doc(user.uid),
      );

      final dataUser = userDoc.data();
      final namaPasien =
          (dataUser?['nama'] as String?)?.trim().isNotEmpty == true
              ? (dataUser!['nama'] as String).trim()
              : (user.displayName ?? 'Pasien');

      transaction.set(penilaianRef, {
        'uidPasien': user.uid,
        'idAntrean': idAntrean,
        'namaPasien': namaPasien,
        'namaPoli': antrean['namaPoli'] ?? '-',
        'dokter': antrean['dokter'] ?? '-',
        'ratingKeseluruhan': ratingKeseluruhan,
        'ratingPetugas': ratingPetugas,
        'ratingWaktuTunggu': ratingWaktuTunggu,
        'ratingDokter': ratingDokter,
        'komentar': komentar.trim(),
        'tanggalPenilaian': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Stream semua penilaian untuk dashboard petugas.
  Stream<List<KepuasanLayanan>> streamSemuaPenilaian() {
    return _koleksiPenilaian.snapshots().map((snapshot) {
      final daftar = snapshot.docs
          .map((doc) => KepuasanLayanan.dariFirestore(doc))
          .toList();

      daftar.sort((a, b) {
        final waktuA = a.tanggalPenilaian?.millisecondsSinceEpoch ?? 0;
        final waktuB = b.tanggalPenilaian?.millisecondsSinceEpoch ?? 0;
        return waktuB.compareTo(waktuA);
      });

      return daftar;
    });
  }

  /// Stream penilaian untuk satu pasien.
  Stream<List<KepuasanLayanan>> streamPenilaianPasien(String uid) {
    return _koleksiPenilaian
        .where('uidPasien', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      final daftar = snapshot.docs
          .map((doc) => KepuasanLayanan.dariFirestore(doc))
          .toList();

      daftar.sort((a, b) {
        final waktuA = a.tanggalPenilaian?.millisecondsSinceEpoch ?? 0;
        final waktuB = b.tanggalPenilaian?.millisecondsSinceEpoch ?? 0;
        return waktuB.compareTo(waktuA);
      });

      return daftar;
    });
  }
}