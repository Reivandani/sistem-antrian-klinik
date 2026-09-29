import 'package:cloud_firestore/cloud_firestore.dart';

class AntreanService {
  // ============================================================
  // COLLECTION ANTREAN
  // ============================================================

  static final CollectionReference antreanCollection = FirebaseFirestore
      .instance
      .collection('antrean');

  // ============================================================
  // AMBIL ANTREAN
  // ============================================================

  static Future<String> ambilAntrean({
    required String uid,
    required String namaPoli,
    required String dokter,
  }) async {
    // ----------------------------------------------------------
    // MENGAMBIL SEMUA ANTREAN PADA POLI TERSEBUT
    // ----------------------------------------------------------

    final QuerySnapshot snapshot = await antreanCollection
        .where('namaPoli', isEqualTo: namaPoli)
        .get();

    // Nomor terakhir
    int nomorTerakhir = 0;

    // ----------------------------------------------------------
    // MENCARI NOMOR ANTREAN TERAKHIR
    // ----------------------------------------------------------

    for (final doc in snapshot.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      final String nomor = data['nomorAntrean'] ?? '';

      if (nomor.startsWith('A')) {
        final int angka = int.tryParse(nomor.substring(1)) ?? 0;

        if (angka > nomorTerakhir) {
          nomorTerakhir = angka;
        }
      }
    }

    // ----------------------------------------------------------
    // MEMBUAT NOMOR BARU
    // ----------------------------------------------------------

    final int nomorBaru = nomorTerakhir + 1;

    final String nomorAntrean = 'A${nomorBaru.toString().padLeft(3, '0')}';

    // ----------------------------------------------------------
    // SIMPAN KE FIRESTORE
    // ----------------------------------------------------------

    await antreanCollection.add({
      'uid': uid,

      'nomorAntrean': nomorAntrean,

      'namaPoli': namaPoli,

      'dokter': dokter,

      'status': 'Menunggu',

      'waktuAmbil': FieldValue.serverTimestamp(),

      'waktuDipanggil': null,

      'waktuSelesai': null,
    });

    // Mengembalikan nomor antrean
    return nomorAntrean;
  }

  // ============================================================
  // SEMUA ANTREAN PADA SATU POLI
  // ============================================================

  static Stream<QuerySnapshot> semuaAntreanPoli(String namaPoli) {
    return antreanCollection.where('namaPoli', isEqualTo: namaPoli).snapshots();
  }

  // ============================================================
  // ANTREAN PASIEN
  // ============================================================

  static Stream<QuerySnapshot> antreanPasien(String uid) {
    return antreanCollection.where('uid', isEqualTo: uid).snapshots();
  }

  // ============================================================
  // RIWAYAT ANTREAN PASIEN
  // ============================================================

  static Stream<QuerySnapshot> riwayatAntreanPasien(String uid) {
    return antreanCollection.where('uid', isEqualTo: uid).snapshots();
  }

  // ============================================================
  // ANTREAN YANG SEDANG DIPANGGIL
  // ============================================================

  static Stream<QuerySnapshot> antreanSedangDilayani(String namaPoli) {
    return antreanCollection
        .where('namaPoli', isEqualTo: namaPoli)
        .where('status', isEqualTo: 'Dipanggil')
        .snapshots();
  }

  // ============================================================
  // ADMIN MEMANGGIL ANTREAN
  // ============================================================

  static Future<void> panggilAntrean(String documentId) async {
    await antreanCollection.doc(documentId).update({
      'status': 'Dipanggil',

      'waktuDipanggil': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // ADMIN MENYELESAIKAN ANTREAN
  // ============================================================

  static Future<void> selesaikanAntrean(String documentId) async {
    await antreanCollection.doc(documentId).update({
      'status': 'Selesai',

      'waktuSelesai': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // MEMBATALKAN ANTREAN
  // ============================================================

  static Future<void> batalkanAntrean(String documentId) async {
    await antreanCollection.doc(documentId).update({'status': 'Dibatalkan'});
  }
}
