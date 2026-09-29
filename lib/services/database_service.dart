import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  // ==========================================================
  // COLLECTION USERS
  // ==========================================================

  static final CollectionReference users = FirebaseFirestore.instance
      .collection('users');

  // ==========================================================
  // SIMPAN DATA USER
  // ==========================================================

  static Future<void> simpanUser({
    required String uid,
    required String nama,
    required String email,
  }) async {
    await users.doc(uid).set({
      'nama': nama,
      'email': email,

      // ======================================================
      // ROLE USER
      // ======================================================
      // Setiap user yang melakukan register dari aplikasi
      // akan otomatis menjadi pasien.
      'role': 'pasien',

      // ======================================================
      // DATA PROFIL LAINNYA
      // ======================================================

      'jenisKelamin': '',
      'tempatLahir': '',
      'tanggalLahir': '',
      'golonganDarah': '',
      'nomorTelepon': '',
      'alamat': '',
      'fotoProfil': '',

      // ======================================================
      // TOKEN FCM
      // ======================================================
      // Array ini digunakan untuk menyimpan token notifikasi
      // dari berbagai perangkat milik user.
      //
      // Contoh:
      // HP     -> token HP
      // Laptop -> token browser laptop
      //
      // Untuk user baru, array dibuat kosong terlebih dahulu.
      'fcmTokens': [],

      // ======================================================
      // WAKTU PEMBUATAN AKUN
      // ======================================================

      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ==========================================================
  // AMBIL DATA USER
  // ==========================================================

  static Future<DocumentSnapshot> ambilUser(String uid) async {
    return await users.doc(uid).get();
  }

  // ==========================================================
  // AMBIL ROLE USER
  // ==========================================================

  static Future<String> ambilRole(String uid) async {
    // Mengambil data user berdasarkan UID
    final DocumentSnapshot snapshot = await users.doc(uid).get();

    // Jika data user tidak ditemukan,
    // maka dianggap sebagai pasien.
    if (!snapshot.exists) {
      return 'pasien';
    }

    // Mengubah data Firestore menjadi Map
    final Map<String, dynamic> data =
        snapshot.data() as Map<String, dynamic>;

    // Mengambil role dari Firestore.
    // Jika role belum ada, gunakan pasien
    // sebagai nilai default.
    return data['role'] ?? 'pasien';
  }

  // ==========================================================
  // SIMPAN TOKEN FCM
  // ==========================================================
  //
  // Token FCM digunakan Firebase Cloud Messaging (FCM)
  // untuk mengirim notifikasi ke perangkat user.
  //
  // Satu user dapat memiliki lebih dari satu token karena
  // user dapat login menggunakan beberapa perangkat.
  //
  // Contoh:
  //
  // HP:
  // token = "token_hp"
  //
  // Laptop:
  // token = "token_laptop"
  //
  // Firestore:
  //
  // fcmTokens:
  // [
  //   "token_hp",
  //   "token_laptop"
  // ]
  //
  // ==========================================================

  static Future<void> simpanFcmToken({
    required String uid,
    required String token,
  }) async {
    await users.doc(uid).set(
      {
        'fcmTokens': FieldValue.arrayUnion([token]),
      },
      SetOptions(merge: true),
    );
  }

  // ==========================================================
  // UPDATE DATA USER
  // ==========================================================

  static Future<void> updateUser({
    required String uid,
    String? nama,
    String? jenisKelamin,
    String? tempatLahir,
    String? tanggalLahir,
    String? golonganDarah,
    String? nomorTelepon,
    String? alamat,
    String? fotoProfil,
  }) async {
    final Map<String, dynamic> data = {};

    // ======================================================
    // NAMA
    // ======================================================

    if (nama != null) {
      data['nama'] = nama;
    }

    // ======================================================
    // JENIS KELAMIN
    // ======================================================

    if (jenisKelamin != null) {
      data['jenisKelamin'] = jenisKelamin;
    }

    // ======================================================
    // TEMPAT LAHIR
    // ======================================================

    if (tempatLahir != null) {
      data['tempatLahir'] = tempatLahir;
    }

    // ======================================================
    // TANGGAL LAHIR
    // ======================================================

    if (tanggalLahir != null) {
      data['tanggalLahir'] = tanggalLahir;
    }

    // ======================================================
    // GOLONGAN DARAH
    // ======================================================

    if (golonganDarah != null) {
      data['golonganDarah'] = golonganDarah;
    }

    // ======================================================
    // NOMOR TELEPON
    // ======================================================

    if (nomorTelepon != null) {
      data['nomorTelepon'] = nomorTelepon;
    }

    // ======================================================
    // ALAMAT
    // ======================================================

    if (alamat != null) {
      data['alamat'] = alamat;
    }

    // ======================================================
    // FOTO PROFIL
    // ======================================================

    if (fotoProfil != null) {
      data['fotoProfil'] = fotoProfil;
    }

    // ======================================================
    // UPDATE JIKA ADA DATA
    // ======================================================

    if (data.isNotEmpty) {
      await users.doc(uid).update(data);
    }
  }
}