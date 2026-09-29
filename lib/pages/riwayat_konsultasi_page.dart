import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/konsultasi_service.dart';
import 'detail_konsultasi_page.dart';

class RiwayatKonsultasiPage extends StatelessWidget {
  const RiwayatKonsultasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ========================================================
    // MENGAMBIL USER YANG SEDANG LOGIN
    // ========================================================

    final User? user = FirebaseAuth.instance.currentUser;

    // ========================================================
    // JIKA USER BELUM LOGIN
    // ========================================================

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Riwayat Konsultasi',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        body: const Center(child: Text('Silakan login terlebih dahulu.')),
      );
    }

    // ========================================================
    // HALAMAN RIWAYAT
    // ========================================================

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Konsultasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        // ====================================================
        // MENGAMBIL DATA DARI FIRESTORE
        // ====================================================

        stream: KonsultasiService.ambilRiwayatKonsultasi(user.uid),

        builder: (context, snapshot) {
          // ==================================================
          // LOADING
          // ==================================================

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ==================================================
          // ERROR
          // ==================================================

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'Gagal mengambil '
                      'riwayat konsultasi.',
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,

                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }

          // ==================================================
          // TIDAK ADA DATA
          // ==================================================

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(30),

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),

                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.history,
                        size: 55,
                        color: Colors.blue,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Belum Ada Riwayat',
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Konsultasi yang Anda lakukan '
                      'akan muncul di halaman ini.',
                      textAlign: TextAlign.center,

                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }

          // ==================================================
          // DATA FIRESTORE
          // ==================================================

          final List<QueryDocumentSnapshot> daftarKonsultasi =
              snapshot.data!.docs;

          // ==================================================
          // LIST RIWAYAT
          // ==================================================

          return ListView.builder(
            padding: const EdgeInsets.all(20),

            itemCount: daftarKonsultasi.length,

            itemBuilder: (context, index) {
              // ==================================================
              // MENGAMBIL DATA DOKUMEN
              // ==================================================

              final Map<String, dynamic> data =
                  daftarKonsultasi[index].data() as Map<String, dynamic>;

              // ==================================================
              // MENGAMBIL DOCUMENT ID
              // ==================================================

              final String documentId = daftarKonsultasi[index].id;

              // ==================================================
              // MENGAMBIL FIELD
              // ==================================================

              final String namaPasien = data['namaPasien'] ?? 'Pasien';

              final String poli = data['poli'] ?? 'Poli';

              final String dokter = data['dokter'] ?? 'Dokter';

              final String tanggal = data['tanggal'] ?? '-';

              final String jam = data['jam'] ?? '-';

              final String keluhan = data['keluhan'] ?? '-';

              // ==================================================
              // MENGAMBIL STATUS
              // ==================================================

              final String status = data['status'] ?? 'Menunggu';

              // ==================================================
              // CARD RIWAYAT
              // ==================================================

              return InkWell(
                borderRadius: BorderRadius.circular(20),

                // ==================================================
                // KETIKA CARD DIKLIK
                // ==================================================
                onTap: () {
                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (context) => DetailKonsultasiPage(
                        documentId: documentId,

                        namaPasien: namaPasien,

                        dokter: dokter,

                        poli: poli,

                        tanggal: tanggal,

                        jam: jam,

                        keluhan: keluhan,

                        status: status,
                      ),
                    ),
                  );
                },

                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(20),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.12),

                        blurRadius: 10,

                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(18),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        // ==========================================
                        // BAGIAN POLI DAN DOKTER
                        // ==========================================

                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,

                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),

                                borderRadius: BorderRadius.circular(15),
                              ),

                              child: const Icon(
                                Icons.medical_services,
                                color: Colors.blue,
                                size: 27,
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    poli,

                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    dokter,

                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ======================================
                            // ICON PANAH
                            // ======================================
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey,
                              size: 16,
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        // ==========================================
                        // STATUS
                        // ==========================================
                        _buildStatus(status),

                        const SizedBox(height: 18),

                        const Divider(),

                        const SizedBox(height: 12),

                        // ==========================================
                        // NAMA PASIEN
                        // ==========================================
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              color: Colors.grey,
                              size: 20,
                            ),

                            const SizedBox(width: 10),

                            const Text(
                              'Pasien',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(width: 15),

                            Expanded(
                              child: Text(
                                namaPasien,

                                textAlign: TextAlign.right,

                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // ==========================================
                        // TANGGAL
                        // ==========================================
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              color: Colors.grey,
                              size: 20,
                            ),

                            const SizedBox(width: 10),

                            const Text(
                              'Tanggal',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(width: 15),

                            Expanded(
                              child: Text(
                                tanggal,

                                textAlign: TextAlign.right,

                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // ==========================================
                        // JAM
                        // ==========================================
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Colors.grey,
                              size: 20,
                            ),

                            const SizedBox(width: 10),

                            const Text(
                              'Jam',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(width: 15),

                            Expanded(
                              child: Text(
                                jam,

                                textAlign: TextAlign.right,

                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        // ==========================================
                        // KELUHAN
                        // ==========================================
                        Container(
                          width: double.infinity,

                          padding: const EdgeInsets.all(14),

                          decoration: BoxDecoration(
                            color: const Color(0xffF5F9FF),

                            borderRadius: BorderRadius.circular(14),
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              const Text(
                                'Keluhan',

                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                keluhan,

                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ==========================================
                        // PETUNJUK KLIK
                        // ==========================================
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,

                          children: [
                            const Text(
                              'Lihat detail',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(width: 5),

                            const Icon(
                              Icons.arrow_forward,
                              color: Colors.blue,
                              size: 16,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ==========================================================
  // WIDGET STATUS
  // ==========================================================

  Widget _buildStatus(String status) {
    Color warna;
    IconData icon;

    // ========================================================
    // MENENTUKAN WARNA DAN ICON BERDASARKAN STATUS
    // ========================================================

    switch (status) {
      // ======================================================
      // STATUS MENUNGGU
      // ======================================================

      case 'Menunggu':
        warna = Colors.blue;
        icon = Icons.schedule;
        break;

      // ======================================================
      // STATUS DIJADWALKAN
      // ======================================================

      case 'Dijadwalkan':
        warna = Colors.orange;
        icon = Icons.event_available;
        break;

      // ======================================================
      // STATUS SELESAI
      // ======================================================

      case 'Selesai':
        warna = Colors.green;
        icon = Icons.check_circle;
        break;

      // ======================================================
      // STATUS DIBATALKAN
      // ======================================================

      case 'Dibatalkan':
        warna = Colors.red;
        icon = Icons.cancel;
        break;

      // ======================================================
      // STATUS LAINNYA
      // ======================================================

      default:
        warna = Colors.grey;
        icon = Icons.info_outline;
    }

    // ========================================================
    // TAMPILAN STATUS
    // ========================================================

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),

      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.1),

        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(icon, color: warna, size: 17),

          const SizedBox(width: 6),

          Text(
            status,

            style: TextStyle(
              color: warna,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
