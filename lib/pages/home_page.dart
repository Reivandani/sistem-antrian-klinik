import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_page.dart';
import 'about_me_page.dart';
import 'ambil_antrean_page.dart';
import 'konsultasi_page.dart';
import 'riwayat_antrean_page.dart';
import 'riwayat_konsultasi_page.dart';

import '../models/poli.dart';

// ============================================================
// HOME PAGE
// ============================================================

class HomePage extends StatelessWidget {
  final String username;

  HomePage({
    super.key,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        title: const Text(
          'Sistem Antrian Klinik',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [

          // ========================================================
          // TOMBOL ABOUT ME
          // ========================================================

          IconButton(
            icon: const Icon(
              Icons.account_circle_outlined,
            ),

            tooltip: 'About Me',

            onPressed: () {
              Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (context) =>
                      const AboutMePage(),
                ),
              );
            },
          ),

          // ========================================================
          // TOMBOL LOGOUT
          // ========================================================

          IconButton(
            icon: const Icon(
              Icons.logout,
            ),

            tooltip: 'Logout',

            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              if (!context.mounted) {
                return;
              }

              Navigator.pushAndRemoveUntil(
                context,

                MaterialPageRoute(
                  builder: (context) =>
                      const LoginPage(),
                ),

                (route) => false,
              );
            },
          ),
        ],
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: CustomScrollView(
        slivers: [

          // ========================================================
          // BAGIAN ATAS
          // ========================================================

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              20,
            ),

            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  // ==================================================
                  // GREETING
                  // ==================================================

                  Text(
                    'Halo, $username 👋',

                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Selamat datang di Sistem Antrian Klinik',

                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ==================================================
                  // INFORMASI ANTREAN SAYA
                  // ==================================================

                  _buildAntreanSaya(),

                  const SizedBox(height: 30),

                  // ==================================================
                  // MENU UTAMA
                  // ==================================================

                  const Text(
                    'Menu Utama',

                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  _buildMenuGrid(context),

                  const SizedBox(height: 30),

                  // ==================================================
                  // INFORMASI KLINIK
                  // ==================================================

                  _buildInformasiKlinik(),

                  const SizedBox(height: 20),

                  // ==================================================
                  // FOOTER
                  // ==================================================

                  const Center(
                    child: Text(
                      'Sistem Antrian Klinik',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFORMASI ANTREAN SAYA
  // ============================================================

  Widget _buildAntreanSaya() {
    final User? user =
        FirebaseAuth.instance.currentUser;

    // ==========================================================
    // USER BELUM LOGIN
    // ==========================================================

    if (user == null) {
      return _buildTidakAdaAntrean();
    }

    // ==========================================================
    // AMBIL DATA ANTREAN USER
    // ==========================================================

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('antrean')
          .where(
            'uid',
            isEqualTo: user.uid,
          )
          .snapshots(),

      builder: (
        context,
        snapshot,
      ) {

        // ======================================================
        // LOADING
        // ======================================================

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return Container(
            width: double.infinity,

            padding:
                const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: Colors.blue,

              borderRadius:
                  BorderRadius.circular(20),
            ),

            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          );
        }

        // ======================================================
        // ERROR
        // ======================================================

        if (snapshot.hasError) {
          return _buildTidakAdaAntrean();
        }

        // ======================================================
        // CARI ANTREAN AKTIF
        // ======================================================

        QueryDocumentSnapshot?
            antreanSaya;

        if (snapshot.hasData) {

          for (
            final doc
                in snapshot.data!.docs
          ) {

            final Map<String, dynamic>
                data =
                doc.data()
                    as Map<String, dynamic>;

            final String status =
                data['status'] ??
                    'Menunggu';

            if (
              status == 'Menunggu' ||
              status == 'Dipanggil'
            ) {

              antreanSaya = doc;

              break;
            }
          }
        }

        // ======================================================
        // TIDAK ADA ANTREAN
        // ======================================================

        if (antreanSaya == null) {
          return _buildTidakAdaAntrean();
        }

        // ======================================================
        // DATA ANTREAN
        // ======================================================

        final Map<String, dynamic>
            data =
            antreanSaya.data()
                as Map<String, dynamic>;

        final String nomorSaya =
            data['nomorAntrean'] ?? '-';

        final String namaPoli =
            data['namaPoli'] ?? '-';

        final String status =
            data['status'] ??
                'Menunggu';

        // ======================================================
        // CARI ANTREAN YANG SEDANG DILAYANI
        // ======================================================

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('antrean')

              .where(
                'namaPoli',
                isEqualTo: namaPoli,
              )

              .where(
                'status',
                isEqualTo: 'Dipanggil',
              )

              .snapshots(),

          builder: (
            context,
            currentSnapshot,
          ) {

            String nomorDilayani = '-';

            if (
              currentSnapshot.hasData &&
              currentSnapshot
                  .data!
                  .docs
                  .isNotEmpty
            ) {

              final Map<String, dynamic>
                  currentData =
                  currentSnapshot
                      .data!
                      .docs
                      .first
                      .data()
                      as Map<String, dynamic>;

              nomorDilayani =
                  currentData[
                          'nomorAntrean'] ??
                      '-';
            }

            // ==================================================
            // CARD ANTREAN
            // ==================================================

            return Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.blue,

                borderRadius:
                    BorderRadius.circular(20),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  // ==============================================
                  // JUDUL
                  // ==============================================

                  const Text(
                    'Antrean Anda',

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    namaPoli,

                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==============================================
                  // NOMOR ANTREAN
                  // ==============================================

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                    children: [

                      // ==========================================
                      // NOMOR USER
                      // ==========================================

                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          const Text(
                            'Nomor Anda',

                            style: TextStyle(
                              color:
                                  Colors.white70,
                            ),
                          ),

                          const SizedBox(
                            height: 5,
                          ),

                          Text(
                            nomorSaya,

                            style:
                                const TextStyle(
                              color:
                                  Colors.white,

                              fontSize: 30,

                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      // ==========================================
                      // NOMOR YANG SEDANG DILAYANI
                      // ==========================================

                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          const Text(
                            'Sedang Dilayani',

                            style: TextStyle(
                              color:
                                  Colors.white70,
                            ),
                          ),

                          const SizedBox(
                            height: 5,
                          ),

                          Text(
                            nomorDilayani,

                            style:
                                const TextStyle(
                              color:
                                  Colors.white,

                              fontSize: 30,

                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ==============================================
                  // STATUS
                  // ==============================================

                  Container(
                    width: double.infinity,

                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white
                          .withValues(
                        alpha: 0.15,
                      ),

                      borderRadius:
                          BorderRadius.circular(12),
                    ),

                    child: Row(
                      children: [

                        Icon(
                          status == 'Dipanggil'
                              ? Icons.campaign
                              : Icons.access_time,

                          color: Colors.white,

                          size: 20,
                        ),

                        const SizedBox(
                          width: 8,
                        ),

                        Text(
                          status,

                          style:
                              const TextStyle(
                            color:
                                Colors.white,

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // TIDAK ADA ANTREAN
  // ============================================================

  Widget _buildTidakAdaAntrean() {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.blue,

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: const Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(
            'Informasi Antrean Anda',

            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          SizedBox(height: 15),

          Row(
            children: [

              Icon(
                Icons.confirmation_number_outlined,

                color: Colors.white,

                size: 30,
              ),

              SizedBox(width: 12),

              Expanded(
                child: Text(
                  'Anda belum memiliki antrean aktif.\n'
                  'Silakan pilih menu Ambil Antrean.',

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MENU UTAMA
  // ============================================================

  Widget _buildMenuGrid(
    BuildContext context,
  ) {

    return Column(
      children: [

        // ========================================================
        // BARIS 1
        // ========================================================

        Row(
          children: [

            Expanded(
              child: _buildMenuCard(
                icon:
                    Icons.confirmation_num,

                title:
                    'Ambil Antrean',

                subtitle:
                    'Ambil nomor antrean',

                onTap: () {

                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (context) =>
                          AmbilAntreanPage(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(
              width: 15,
            ),

            Expanded(
              child: _buildMenuCard(
                icon:
                    Icons.medical_services,

                title:
                    'Konsultasi',

                subtitle:
                    'Konsultasi dengan dokter',

                onTap: () {

                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (context) =>
                          KonsultasiPage(
                        daftarPoli:
                            _getDaftarPoli(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 15,
        ),

        // ========================================================
        // BARIS 2
        // ========================================================

        Row(
          children: [

            Expanded(
              child: _buildMenuCard(
                icon:
                    Icons.history,

                title:
                    'Riwayat Antrean',

                subtitle:
                    'Lihat riwayat antrean',

                onTap: () {

                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (context) =>
                          const RiwayatAntreanPage(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(
              width: 15,
            ),

            Expanded(
              child: _buildMenuCard(
                icon:
                    Icons.history_edu,

                title:
                    'Riwayat Konsultasi',

                subtitle:
                    'Lihat riwayat konsultasi',

                onTap: () {

                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (context) =>
                          const RiwayatKonsultasiPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // DATA POLI UNTUK KONSULTASI
  // ============================================================
  //
  // Daftar poli sudah tidak ditampilkan di HomePage.
  //
  // Tetapi KonsultasiPage masih membutuhkan parameter
  // daftarPoli. Oleh karena itu data poli untuk konsultasi
  // dibuat melalui method ini.
  //
  // Data ini TIDAK ditampilkan di HomePage.
  // ============================================================

  List<Poli> _getDaftarPoli() {
    return [
      PoliUmum(
        dokter: 'dr. Andi',
        jumlahAntrian: 0,
      ),

      PoliGigi(
        dokter: 'drg. Sinta',
        jumlahAntrian: 0,
      ),

      PoliMata(
        dokter: 'dr. Budi',
        jumlahAntrian: 0,
      ),

      PoliJantung(
        dokter: 'dr. Rina',
        jumlahAntrian: 0,
      ),

      PoliAnak(
        dokter: 'dr. Dimas',
        jumlahAntrian: 0,
      ),

      PoliSaraf(
        dokter: 'dr. Fajar',
        jumlahAntrian: 0,
      ),
    ];
  }

  // ============================================================
  // CARD MENU
  // ============================================================

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {

    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding:
            const EdgeInsets.all(15),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
              BorderRadius.circular(18),

          boxShadow: [
            BoxShadow(
              color:
                  Colors.grey.withValues(
                alpha: 0.12,
              ),

              blurRadius: 8,

              offset:
                  const Offset(0, 3),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // ====================================================
            // ICON
            // ====================================================

            Container(
              width: 45,
              height: 45,

              decoration: BoxDecoration(
                color:
                    Colors.blue.withValues(
                  alpha: 0.1,
                ),

                borderRadius:
                    BorderRadius.circular(12),
              ),

              child: Icon(
                icon,

                color:
                    Colors.blue,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            // ====================================================
            // TITLE
            // ====================================================

            Text(
              title,

              maxLines: 1,

              overflow:
                  TextOverflow.ellipsis,

              style:
                  const TextStyle(
                fontSize: 15,

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            // ====================================================
            // SUBTITLE
            // ====================================================

            Text(
              subtitle,

              maxLines: 2,

              overflow:
                  TextOverflow.ellipsis,

              style:
                  const TextStyle(
                fontSize: 12,

                color:
                    Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INFORMASI KLINIK
  // ============================================================

  Widget _buildInformasiKlinik() {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color:
                Colors.grey.withValues(
              alpha: 0.10,
            ),

            blurRadius: 8,

            offset:
                const Offset(0, 3),
          ),
        ],
      ),

      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Icon(
            Icons.info_outline,

            color:
                Colors.blue,
          ),

          SizedBox(
            width: 12,
          ),

          Expanded(
            child: Text(
              'Silakan pilih menu Ambil Antrean '
              'untuk melihat daftar poli dan mengambil '
              'nomor antrean. Anda juga dapat menggunakan '
              'menu Konsultasi untuk berkonsultasi dengan dokter.',

              style: TextStyle(
                fontSize: 13,

                color:
                    Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}