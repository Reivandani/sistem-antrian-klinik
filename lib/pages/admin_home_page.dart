import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_page.dart';
import 'admin_konsultasi_page.dart';
import 'admin_antrean_page.dart';
import 'admin_data_pasien_page.dart';
import 'admin_profil_page.dart';

import '../widgets/menu_card.dart';

// ==========================================================
// ADMIN HOME PAGE
// ==========================================================

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  // ========================================================
  // BUILD
  // ========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ======================================================
      // APP BAR
      // ======================================================

      appBar: AppBar(
        title: const Text(
          'Panel Petugas Klinik',

          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        backgroundColor: Colors.blue,

        foregroundColor: Colors.white,

        actions: [
          // ==================================================
          // TOMBOL PROFIL PETUGAS
          // ==================================================

          IconButton(
            icon: const Icon(Icons.account_circle_outlined),

            tooltip: 'Profil Petugas',

            onPressed: () {
              // Membuka halaman profil petugas
              Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (context) => const AdminProfilePage(),
                ),
              );
            },
          ),

          // ==================================================
          // TOMBOL LOGOUT
          // ==================================================
          IconButton(
            icon: const Icon(Icons.logout),

            tooltip: 'Logout',

            onPressed: () {
              // Menampilkan dialog konfirmasi logout
              _showLogoutDialog(context);
            },
          ),
        ],
      ),

      // ======================================================
      // BODY
      // ======================================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ==================================================
            // GREETING
            // ==================================================

            const Text(
              'Halo, Petugas Klinik 👋',

              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            const Text(
              'Selamat datang di Panel Petugas Klinik',

              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // INFORMASI ADMIN
            // ==================================================
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.blue,

                borderRadius: BorderRadius.circular(20),
              ),

              child: const Row(
                children: [
                  // ==================================================
                  // ICON
                  // ==================================================

                  Icon(
                    Icons.admin_panel_settings,

                    color: Colors.white,

                    size: 45,
                  ),

                  SizedBox(width: 15),

                  // ==================================================
                  // TEXT
                  // ==================================================
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          'Panel Petugas',

                          style: TextStyle(
                            color: Colors.white,

                            fontSize: 19,

                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          'Kelola data dan pelayanan klinik melalui halaman ini.',

                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ==================================================
            // JUDUL MENU
            // ==================================================
            const Text(
              'Menu Petugas',

              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            // ==================================================
            // MENU KONSULTASI
            // ==================================================
            MenuCard(
              icon: Icons.medical_services,

              title: 'Kelola Konsultasi',

              subtitle: 'Melihat dan mengelola konsultasi pasien',

              onTap: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (context) => const AdminKonsultasiPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 15),

            // ==================================================
            // MENU ANTREAN
            // ==================================================
            MenuCard(
              icon: Icons.confirmation_number,

              title: 'Kelola Antrean',

              subtitle: 'Melihat dan mengelola antrean pasien',

              onTap: () {
                // Membuka halaman kelola antrean
                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (context) => const AdminAntreanPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 15),

            // ==================================================
            // MENU DATA PASIEN
            // ==================================================
            MenuCard(
              icon: Icons.people,

              title: 'Data Pasien',

              subtitle: 'Melihat data pengguna atau pasien',

              onTap: () {
                // Membuka halaman data pasien
                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (context) => const AdminDataPasienPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // ==================================================
            // INFORMASI
            // ==================================================
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(18),

                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.12),

                    blurRadius: 10,

                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // ==================================================
                  // ICON INFORMASI
                  // ==================================================

                  Icon(Icons.info_outline, color: Colors.blue),

                  SizedBox(width: 12),

                  // ==================================================
                  // TEXT INFORMASI
                  // ==================================================
                  Expanded(
                    child: Text(
                      'Petugas dapat mengelola pelayanan '
                      'klinik melalui menu yang tersedia. '
                      'Fitur tambahan dapat ditambahkan '
                      'sesuai kebutuhan sistem.',

                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // DIALOG LOGOUT
  // ==========================================================

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          // ==================================================
          // JUDUL
          // ==================================================

          title: const Text(
            'Logout',

            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          // ==================================================
          // ISI
          // ==================================================
          content: const Text(
            'Apakah Anda yakin ingin keluar dari akun petugas?',
          ),

          // ==================================================
          // TOMBOL
          // ==================================================
          actions: [
            // =================================================
            // BATAL
            // =================================================

            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },

              child: const Text('Batal'),
            ),

            // =================================================
            // LOGOUT
            // =================================================
            ElevatedButton(
              onPressed: () async {
                // =============================================
                // TUTUP DIALOG
                // =============================================

                Navigator.pop(dialogContext);

                // =============================================
                // LOGOUT DARI FIREBASE AUTH
                // =============================================

                await FirebaseAuth.instance.signOut();

                // =============================================
                // KEMBALI KE LOGIN
                // =============================================

                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,

                    MaterialPageRoute(builder: (context) => const LoginPage()),

                    (route) => false,
                  );
                }
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,

                foregroundColor: Colors.white,
              ),

              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
