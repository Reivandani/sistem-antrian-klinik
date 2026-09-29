import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/antrean_service.dart';

class AdminAntreanPage extends StatelessWidget {
  const AdminAntreanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        title: const Text(
          'Kelola Antrean',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('antrean').snapshots(),

        builder: (context, snapshot) {
          // ======================================================
          // LOADING
          // ======================================================

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ======================================================
          // ERROR
          // ======================================================

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Terjadi kesalahan:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // ======================================================
          // DATA KOSONG
          // ======================================================

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.queue_outlined, size: 70, color: Colors.grey),

                  SizedBox(height: 15),

                  Text(
                    'Belum ada antrean',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Antrean pasien akan muncul di sini.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // ======================================================
          // DATA ANTREAN
          // ======================================================

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),

            itemCount: docs.length,

            itemBuilder: (context, index) {
              final doc = docs[index];

              final Map<String, dynamic> data =
                  doc.data() as Map<String, dynamic>;

              final String nomorAntrean = data['nomorAntrean'] ?? '-';

              final String namaPoli = data['namaPoli'] ?? '-';

              final String dokter = data['dokter'] ?? '-';

              final String status = data['status'] ?? 'Menunggu';

              // ==================================================
              // CARD ANTREAN
              // ==================================================

              return Card(
                margin: const EdgeInsets.only(bottom: 15),

                elevation: 3,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(18),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      // ==========================================
                      // NOMOR ANTREAN
                      // ==========================================

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          Text(
                            nomorAntrean,

                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          _buildStatus(status),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // ==========================================
                      // POLI
                      // ==========================================
                      Row(
                        children: [
                          const Icon(Icons.local_hospital, color: Colors.blue),

                          const SizedBox(width: 10),

                          Text(
                            namaPoli,

                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // ==========================================
                      // DOKTER
                      // ==========================================
                      Row(
                        children: [
                          const Icon(Icons.person, color: Colors.grey),

                          const SizedBox(width: 10),

                          Text(
                            dokter,

                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // ==========================================
                      // TOMBOL AKSI
                      // ==========================================
                      _buildActionButton(context, doc.id, status),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  Widget _buildStatus(String status) {
    Color warna;

    IconData icon;

    switch (status) {
      case 'Dipanggil':
        warna = Colors.orange;
        icon = Icons.volume_up;

        break;

      case 'Selesai':
        warna = Colors.green;
        icon = Icons.check_circle;

        break;

      case 'Dibatalkan':
        warna = Colors.red;
        icon = Icons.cancel;

        break;

      default:
        warna = Colors.blue;
        icon = Icons.access_time;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),

      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.1),

        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(icon, size: 16, color: warna),

          const SizedBox(width: 5),

          Text(
            status,

            style: TextStyle(color: warna, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOMBOL AKSI
  // ============================================================

  Widget _buildActionButton(
    BuildContext context,
    String documentId,
    String status,
  ) {
    // ==========================================================
    // MENUNGGU → PANGGIL
    // ==========================================================

    if (status == 'Menunggu') {
      return SizedBox(
        width: double.infinity,

        child: ElevatedButton.icon(
          onPressed: () async {
            try {
              await AntreanService.panggilAntrean(documentId);

              if (!context.mounted) {
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Antrean berhasil dipanggil.')),
              );
            } catch (e) {
              if (!context.mounted) {
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal memanggil antrean: $e')),
              );
            }
          },

          icon: const Icon(Icons.volume_up),

          label: const Text('Panggil Antrean'),

          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      );
    }

    // ==========================================================
    // DIPANGGIL → SELESAIKAN
    // ==========================================================

    if (status == 'Dipanggil') {
      return SizedBox(
        width: double.infinity,

        child: ElevatedButton.icon(
          onPressed: () async {
            try {
              await AntreanService.selesaikanAntrean(documentId);

              if (!context.mounted) {
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Antrean berhasil diselesaikan.')),
              );
            } catch (e) {
              if (!context.mounted) {
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal menyelesaikan antrean: $e')),
              );
            }
          },

          icon: const Icon(Icons.check),

          label: const Text('Selesaikan Antrean'),

          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,

            foregroundColor: Colors.white,

            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      );
    }

    // ==========================================================
    // SELESAI / DIBATALKAN
    // ==========================================================

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(vertical: 12),

      alignment: Alignment.center,

      child: Text(
        status == 'Selesai' ? 'Antrean selesai dilayani' : 'Antrean dibatalkan',

        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
      ),
    );
  }
}
