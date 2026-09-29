import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/konsultasi.dart';

class KonsultasiService {
  static final CollectionReference konsultasiCollection = FirebaseFirestore
      .instance
      .collection('konsultasi');

  // ==========================================================
  // SIMPAN DATA KONSULTASI
  // ==========================================================

  static Future<void> simpanKonsultasi({
    required String uid,
    required Konsultasi konsultasi,
  }) async {
    await konsultasiCollection.add({
      'uid': uid,
      'namaPasien': konsultasi.namaPasien,
      'dokter': konsultasi.dokter,
      'poli': konsultasi.poli,
      'tanggal': konsultasi.tanggal,
      'jam': konsultasi.jam,
      'keluhan': konsultasi.keluhan,

      // ======================================================
      // STATUS AWAL KONSULTASI
      // ======================================================
      'status': 'Menunggu',

      // ======================================================
      // WAKTU DATA DIBUAT
      // ======================================================
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ==========================================================
  // MENGAMBIL NAMA PASIEN
  // ==========================================================

  static Future<String> ambilNamaPasien(String uid) async {
    final DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    // ========================================================
    // JIKA DATA USER TIDAK DITEMUKAN
    // ========================================================

    if (!snapshot.exists) {
      return 'Pasien';
    }

    // ========================================================
    // MENGUBAH DATA FIRESTORE MENJADI MAP
    // ========================================================

    final Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    // ========================================================
    // MENGAMBIL NAMA PASIEN
    // ========================================================

    return data['nama'] ?? 'Pasien';
  }

  // ==========================================================
  // MENGAMBIL RIWAYAT KONSULTASI
  // ==========================================================

  static Stream<QuerySnapshot> ambilRiwayatKonsultasi(String uid) {
    return konsultasiCollection.where('uid', isEqualTo: uid).snapshots();
  }

  // ==========================================================
  // MENGUBAH STATUS KONSULTASI
  // ==========================================================

  static Future<void> updateStatusKonsultasi({
    required String documentId,
    required String status,
  }) async {
    await konsultasiCollection.doc(documentId).update({'status': status});
  }
}
