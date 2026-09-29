import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/database_service.dart';
import '../services/profile_photo_service.dart';
import 'edit_profile_page.dart';

class AboutMePage extends StatefulWidget {
  const AboutMePage({super.key});

  @override
  State<AboutMePage> createState() => _AboutMePageState();
}

class _AboutMePageState extends State<AboutMePage> {
  // ==========================================================
  // DATA PROFIL
  // ==========================================================

  String nama = '-';

  String email = '-';

  String jenisKelamin = '-';

  String tempatLahir = '-';

  String tanggalLahir = '-';

  String golonganDarah = '-';

  String nomorTelepon = '-';

  String alamat = '-';

  // ==========================================================
  // STATUS
  // ==========================================================

  bool isLoading = true;

  // ==========================================================
  // INIT STATE
  // ==========================================================

  @override
  void initState() {
    super.initState();

    ambilDataUser();
  }

  // ==========================================================
  // AMBIL DATA USER
  // ==========================================================

  Future<void> ambilDataUser() async {
    try {
      // ======================================================
      // MENGAMBIL USER YANG SEDANG LOGIN
      // ======================================================

      final User? user = FirebaseAuth.instance.currentUser;

      // ======================================================
      // JIKA USER TIDAK ADA
      // ======================================================

      if (user == null) {
        if (mounted) {
          setState(() {
            nama = '-';

            email = '-';

            isLoading = false;
          });
        }

        return;
      }

      // ======================================================
      // AMBIL DATA DARI FIRESTORE
      // ======================================================

      final document = await DatabaseService.ambilUser(user.uid);

      // ======================================================
      // JIKA DATA FIRESTORE ADA
      // ======================================================

      if (document.exists) {
        final data = document.data() as Map<String, dynamic>;

        if (!mounted) {
          return;
        }

        setState(() {
          // ==================================================
          // NAMA
          // ==================================================

          nama = data['nama'] ?? user.displayName ?? '-';

          // ==================================================
          // EMAIL
          // ==================================================

          email = data['email'] ?? user.email ?? '-';

          // ==================================================
          // JENIS KELAMIN
          // ==================================================

          final String jenisKelaminData = data['jenisKelamin'] ?? '';

          jenisKelamin = jenisKelaminData.isEmpty ? '-' : jenisKelaminData;

          // ==================================================
          // TEMPAT LAHIR
          // ==================================================

          final String tempatLahirData = data['tempatLahir'] ?? '';

          tempatLahir = tempatLahirData.isEmpty ? '-' : tempatLahirData;

          // ==================================================
          // TANGGAL LAHIR
          // ==================================================

          final String tanggalLahirData = data['tanggalLahir'] ?? '';

          if (tanggalLahirData.isEmpty) {
            tanggalLahir = '-';
          } else {
            final DateTime? tanggal = DateTime.tryParse(tanggalLahirData);

            if (tanggal != null) {
              tanggalLahir = formatTanggal(tanggal);
            } else {
              tanggalLahir = tanggalLahirData;
            }
          }

          // ==================================================
          // GOLONGAN DARAH
          // ==================================================

          final String golonganDarahData = data['golonganDarah'] ?? '';

          golonganDarah = golonganDarahData.isEmpty ? '-' : golonganDarahData;

          // ==================================================
          // NOMOR TELEPON
          // ==================================================

          final String nomorTeleponData = data['nomorTelepon'] ?? '';

          nomorTelepon = nomorTeleponData.isEmpty ? '-' : nomorTeleponData;

          // ==================================================
          // ALAMAT
          // ==================================================

          final String alamatData = data['alamat'] ?? '';

          alamat = alamatData.isEmpty ? '-' : alamatData;
        });
      }
      // ======================================================
      // JIKA DATA FIRESTORE BELUM ADA
      // ======================================================
      else {
        if (!mounted) {
          return;
        }

        setState(() {
          nama = user.displayName ?? '-';

          email = user.email ?? '-';

          jenisKelamin = '-';

          tempatLahir = '-';

          tanggalLahir = '-';

          golonganDarah = '-';

          nomorTelepon = '-';

          alamat = '-';
        });
      }
    }
    // ========================================================
    // ERROR
    // ========================================================
    catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil data profil: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    // ========================================================
    // SELESAI LOADING
    // ========================================================

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // ==========================================================
  // FORMAT TANGGAL
  // ==========================================================

  String formatTanggal(DateTime tanggal) {
    final String hari = tanggal.day.toString().padLeft(2, '0');

    final String bulan = tanggal.month.toString().padLeft(2, '0');

    final String tahun = tanggal.year.toString();

    return '$hari-$bulan-$tahun';
  }

  // ==========================================================
  // NAMA BULAN
  // ==========================================================

  String namaBulan(int bulan) {
    const List<String> daftarBulan = [
      'Januari',

      'Februari',

      'Maret',

      'April',

      'Mei',

      'Juni',

      'Juli',

      'Agustus',

      'September',

      'Oktober',

      'November',

      'Desember',
    ];

    return daftarBulan[bulan - 1];
  }

  // ==========================================================
  // FOTO PROFIL
  // ==========================================================

  Widget buildFotoProfil() {
    return ValueListenableBuilder<Uint8List?>(
      valueListenable: ProfilePhotoService.fotoProfil,

      builder: (context, foto, child) {
        // ====================================================
        // JIKA USER SUDAH MEMILIH FOTO
        // ====================================================

        if (foto != null) {
          return CircleAvatar(
            radius: 60,

            backgroundColor: Colors.blue.shade100,

            backgroundImage: MemoryImage(foto),
          );
        }

        // ====================================================
        // FOTO DEFAULT
        // ====================================================

        return const CircleAvatar(
          radius: 60,

          backgroundColor: Colors.blue,

          backgroundImage: AssetImage('assets/profile/profil.png'),
        );
      },
    );
  }

  // ==========================================================
  // CARD INFORMASI
  // ==========================================================

  Widget buildInfoCard({
    required String judul,
    required String isi,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(15),

        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.10),

            blurRadius: 8,

            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // ==================================================
          // ICON
          // ==================================================

          Container(
            width: 45,

            height: 45,

            decoration: BoxDecoration(
              color: Colors.blue.shade50,

              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(icon, color: Colors.blue),
          ),

          const SizedBox(width: 15),

          // ==================================================
          // TEXT
          // ==================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  judul,

                  style: const TextStyle(
                    fontSize: 13,

                    color: Colors.grey,

                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  isi,

                  style: const TextStyle(
                    fontSize: 15,

                    fontWeight: FontWeight.w600,

                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ======================================================
      // APP BAR
      // ======================================================

      appBar: AppBar(
        title: const Text(
          'About Me',

          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        actions: [
          // ==================================================
          // TOMBOL EDIT
          // ==================================================

          IconButton(
            icon: const Icon(Icons.edit),

            tooltip: 'Edit Profil',

            onPressed: () async {
              // Membuka halaman Edit Profil
              await Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (context) => const EditProfilePage(),
                ),
              );

              // =================================================
              // SETELAH KEMBALI DARI EDIT PROFIL
              // =================================================

              // Ambil ulang data Firestore
              ambilDataUser();

              // Foto otomatis berubah karena
              // menggunakan ValueListenableBuilder.
            },
          ),
        ],
      ),

      // ======================================================
      // BODY
      // ======================================================
      body:
          // ==================================================
          // LOADING
          // ==================================================
          isLoading
          ? const Center(child: CircularProgressIndicator())
          // =================================================
          // ISI ABOUT ME
          // =================================================
          : RefreshIndicator(
              onRefresh: ambilDataUser,

              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),

                padding: const EdgeInsets.all(20),

                child: Column(
                  children: [
                    // ==================================================
                    // FOTO PROFIL
                    // ==================================================

                    buildFotoProfil(),

                    const SizedBox(height: 15),

                    // ==================================================
                    // NAMA
                    // ==================================================
                    Text(
                      nama,

                      textAlign: TextAlign.center,

                      style: const TextStyle(
                        fontSize: 24,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    // ==================================================
                    // EMAIL
                    // ==================================================
                    Text(
                      email,

                      textAlign: TextAlign.center,

                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),

                    const SizedBox(height: 25),

                    // ==================================================
                    // JUDUL DATA PRIBADI
                    // ==================================================
                    const Align(
                      alignment: Alignment.centerLeft,

                      child: Text(
                        'Informasi Pribadi',

                        style: TextStyle(
                          fontSize: 20,

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ==================================================
                    // JENIS KELAMIN
                    // ==================================================
                    buildInfoCard(
                      judul: 'Jenis Kelamin',

                      isi: jenisKelamin,

                      icon: Icons.people,
                    ),

                    // ==================================================
                    // TEMPAT LAHIR
                    // ==================================================
                    buildInfoCard(
                      judul: 'Tempat Lahir',

                      isi: tempatLahir,

                      icon: Icons.location_city,
                    ),

                    // ==================================================
                    // TANGGAL LAHIR
                    // ==================================================
                    buildInfoCard(
                      judul: 'Tanggal Lahir',

                      isi: tanggalLahir,

                      icon: Icons.calendar_month,
                    ),

                    // ==================================================
                    // GOLONGAN DARAH
                    // ==================================================
                    buildInfoCard(
                      judul: 'Golongan Darah',

                      isi: golonganDarah,

                      icon: Icons.bloodtype,
                    ),

                    // ==================================================
                    // NOMOR TELEPON
                    // ==================================================
                    buildInfoCard(
                      judul: 'Nomor Telepon',

                      isi: nomorTelepon,

                      icon: Icons.phone,
                    ),

                    // ==================================================
                    // ALAMAT
                    // ==================================================
                    buildInfoCard(
                      judul: 'Alamat',

                      isi: alamat,

                      icon: Icons.home,
                    ),

                    const SizedBox(height: 10),

                    // ==================================================
                    // INFORMASI
                    // ==================================================
                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,

                        borderRadius: BorderRadius.circular(15),
                      ),

                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Icon(Icons.info_outline, color: Colors.blue),

                          SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              'Data profil dapat '
                              'diperbarui melalui '
                              'tombol edit di bagian '
                              'atas halaman.',

                              style: TextStyle(
                                fontSize: 13,

                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
