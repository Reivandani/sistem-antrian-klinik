import 'package:cloud_firestore/cloud_firestore.dart';

class AntreanService {
  // ============================================================
  // COLLECTION ANTREAN
  // ============================================================

  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static final CollectionReference<Map<String, dynamic>>
      antreanCollection = firestore.collection('antrean');

  // Collection untuk menyimpan nomor antrean terakhir setiap poli.
  static final CollectionReference<Map<String, dynamic>>
      counterCollection = firestore.collection('counter_antrean');

  // ============================================================
  // AMBIL ANTREAN
  // ============================================================

  static Future<String> ambilAntrean({
    required String uid,
    required String namaPoli,
    required String dokter,
  }) async {
    // ID counter dibuat berdasarkan nama poli.
    // Setiap poli memiliki penghitung nomor masing-masing.
    final String counterId = Uri.encodeComponent(namaPoli);

    final DocumentReference<Map<String, dynamic>> counterRef =
        counterCollection.doc(counterId);

    // Buat ID dokumen antrean sebelum transaksi.
    // ID ini tetap sama meskipun transaksi diulang oleh Firestore.
    final DocumentReference<Map<String, dynamic>> antreanRef =
        antreanCollection.doc();

    // ----------------------------------------------------------
    // MEMERIKSA NOMOR ANTREAN YANG SUDAH ADA
    // ----------------------------------------------------------
    //
    // Pemeriksaan ini membantu menyesuaikan counter dengan data
    // antrean lama yang mungkin sudah tersimpan di Firestore.
    //
    // Catatan: pengambilan nomor baru tetap dilakukan di dalam
    // transaksi agar permintaan bersamaan tidak memakai nomor sama.

    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await antreanCollection
            .where('namaPoli', isEqualTo: namaPoli)
            .get();

    int nomorTerakhir = 0;

    for (final doc in snapshot.docs) {
      final String nomor = doc.data()['nomorAntrean']?.toString() ?? '';

      if (nomor.startsWith('A')) {
        final int angka = int.tryParse(nomor.substring(1)) ?? 0;

        if (angka > nomorTerakhir) {
          nomorTerakhir = angka;
        }
      }
    }

    // ----------------------------------------------------------
    // TRANSAKSI FIRESTORE
    // ----------------------------------------------------------
    //
    // Firestore mengatur transaksi yang mengubah counter yang sama.
    // Jika dua pasien mengambil antrean bersamaan, transaksi yang
    // bertabrakan akan dicoba kembali oleh Firestore.

    return await firestore.runTransaction<String>((transaction) async {
      // Baca counter nomor antrean poli.
      final DocumentSnapshot<Map<String, dynamic>> counterSnapshot =
          await transaction.get(counterRef);

      // Ambil nomor terakhir dari counter.
      final int nomorCounter =
          (counterSnapshot.data()?['nomorTerakhir'] as num?)?.toInt() ?? 0;

      // Bandingkan counter dengan data antrean yang sudah ada.
      final int nomorDasar = nomorCounter > nomorTerakhir
          ? nomorCounter
          : nomorTerakhir;

      // Buat nomor berikutnya.
      final int nomorBaru = nomorDasar + 1;

      final String nomorAntrean =
          'A${nomorBaru.toString().padLeft(3, '0')}';

      // Simpan nomor terakhir ke counter poli.
      transaction.set(counterRef, {
        'namaPoli': namaPoli,
        'nomorTerakhir': nomorBaru,
        'diperbaruiPada': FieldValue.serverTimestamp(),
      });

      // Simpan data antrean pasien.
      transaction.set(antreanRef, {
        'uid': uid,
        'nomorAntrean': nomorAntrean,
        'namaPoli': namaPoli,
        'dokter': dokter,
        'status': 'Menunggu',
        'waktuAmbil': FieldValue.serverTimestamp(),
        'waktuDipanggil': null,
        'waktuSelesai': null,
      });

      // Kembalikan nomor antrean yang berhasil dibuat.
      return nomorAntrean;
    });
  }

  // ============================================================
  // SEMUA ANTREAN PADA SATU POLI
  // ============================================================

  static Stream<QuerySnapshot<Map<String, dynamic>>> semuaAntreanPoli(
    String namaPoli,
  ) {
    return antreanCollection
        .where('namaPoli', isEqualTo: namaPoli)
        .snapshots();
  }

  // ============================================================
  // ANTREAN PASIEN
  // ============================================================

  static Stream<QuerySnapshot<Map<String, dynamic>>> antreanPasien(
    String uid,
  ) {
    return antreanCollection.where('uid', isEqualTo: uid).snapshots();
  }

  // ============================================================
  // RIWAYAT ANTREAN PASIEN
  // ============================================================

  static Stream<QuerySnapshot<Map<String, dynamic>>> riwayatAntreanPasien(
    String uid,
  ) {
    return antreanCollection.where('uid', isEqualTo: uid).snapshots();
  }

  // ============================================================
  // ANTREAN YANG SEDANG DIPANGGIL
  // ============================================================

  static Stream<QuerySnapshot<Map<String, dynamic>>> antreanSedangDilayani(
    String namaPoli,
  ) {
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
    await antreanCollection.doc(documentId).update({
      'status': 'Dibatalkan',
    });
  }
}