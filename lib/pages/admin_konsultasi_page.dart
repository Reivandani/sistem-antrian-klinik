import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/konsultasi_service.dart';

class AdminKonsultasiPage extends StatelessWidget {
  const AdminKonsultasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ======================================================
      // APP BAR
      // ======================================================

      appBar: AppBar(
        title: const Text(
          'Kelola Konsultasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      // ======================================================
      // BODY
      // ======================================================
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('konsultasi').snapshots(),

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
              child: Text(
                'Terjadi kesalahan:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          // ==================================================
          // DATA KOSONG
          // ==================================================

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 70,
                    color: Colors.grey,
                  ),

                  SizedBox(height: 15),

                  Text(
                    'Belum ada konsultasi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Belum ada pasien yang membuat konsultasi.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // ==================================================
          // DATA KONSULTASI
          // ==================================================

          final daftarKonsultasi = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),

            itemCount: daftarKonsultasi.length,

            itemBuilder: (context, index) {
              final document = daftarKonsultasi[index];

              final data = document.data() as Map<String, dynamic>;

              // ==================================================
              // AMBIL DATA
              // ==================================================

              final String namaPasien = data['namaPasien'] ?? 'Pasien';

              final String poli = data['poli'] ?? '-';

              final String dokter = data['dokter'] ?? '-';

              final String tanggal = data['tanggal'] ?? '-';

              final String jam = data['jam'] ?? '-';

              final String keluhan = data['keluhan'] ?? '-';

              final String status = data['status'] ?? 'Menunggu';

              // ==================================================
              // WARNA STATUS
              // ==================================================

              Color warnaStatus;

              IconData iconStatus;

              switch (status) {
                case 'Menunggu':
                  warnaStatus = Colors.orange;
                  iconStatus = Icons.schedule;
                  break;

                case 'Dijadwalkan':
                  warnaStatus = Colors.blue;
                  iconStatus = Icons.event_available;
                  break;

                case 'Selesai':
                  warnaStatus = Colors.green;
                  iconStatus = Icons.check_circle;
                  break;

                case 'Dibatalkan':
                  warnaStatus = Colors.red;
                  iconStatus = Icons.cancel;
                  break;

                default:
                  warnaStatus = Colors.grey;
                  iconStatus = Icons.info_outline;
              }

              // ==================================================
              // CARD KONSULTASI
              // ==================================================

              return Card(
                margin: const EdgeInsets.only(bottom: 15),

                elevation: 3,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      // ==========================================
                      // NAMA PASIEN
                      // ==========================================

                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue.shade50,

                            child: const Icon(Icons.person, color: Colors.blue),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              namaPasien,

                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // STATUS
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),

                            decoration: BoxDecoration(
                              color: warnaStatus.withValues(alpha: 0.1),

                              borderRadius: BorderRadius.circular(20),
                            ),

                            child: Row(
                              mainAxisSize: MainAxisSize.min,

                              children: [
                                Icon(iconStatus, size: 15, color: warnaStatus),

                                const SizedBox(width: 5),

                                Text(
                                  status,

                                  style: TextStyle(
                                    color: warnaStatus,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // ==========================================
                      // INFORMASI POLI
                      // ==========================================
                      _buildInfoRow(
                        Icons.local_hospital_outlined,
                        'Poli',
                        poli,
                      ),

                      const SizedBox(height: 10),

                      // ==========================================
                      // DOKTER
                      // ==========================================
                      _buildInfoRow(
                        Icons.medical_services_outlined,
                        'Dokter',
                        dokter,
                      ),

                      const SizedBox(height: 10),

                      // ==========================================
                      // TANGGAL
                      // ==========================================
                      _buildInfoRow(
                        Icons.calendar_today_outlined,
                        'Tanggal',
                        tanggal,
                      ),

                      const SizedBox(height: 10),

                      // ==========================================
                      // JAM
                      // ==========================================
                      _buildInfoRow(Icons.access_time, 'Jam', jam),

                      const SizedBox(height: 10),

                      // ==========================================
                      // KELUHAN
                      // ==========================================
                      _buildInfoRow(
                        Icons.chat_bubble_outline,
                        'Keluhan',
                        keluhan,
                      ),

                      // ==========================================
                      // TOMBOL AKSI
                      // ==========================================
                      if (status == 'Menunggu') ...[
                        const SizedBox(height: 18),

                        Row(
                          children: [
                            // ================================
                            // JADWALKAN
                            // ================================

                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _ubahStatus(
                                    context,
                                    document.id,
                                    'Dijadwalkan',
                                  );
                                },

                                icon: const Icon(
                                  Icons.event_available,
                                  size: 18,
                                ),

                                label: const Text('Jadwalkan'),

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,

                                  foregroundColor: Colors.white,

                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // ================================
                            // BATALKAN
                            // ================================
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  _ubahStatus(
                                    context,
                                    document.id,
                                    'Dibatalkan',
                                  );
                                },

                                icon: const Icon(
                                  Icons.cancel_outlined,
                                  size: 18,
                                ),

                                label: const Text('Batalkan'),

                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,

                                  side: const BorderSide(color: Colors.red),

                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      // ==========================================
                      // TOMBOL SELESAI
                      // ==========================================
                      if (status == 'Dijadwalkan') ...[
                        const SizedBox(height: 18),

                        SizedBox(
                          width: double.infinity,

                          child: ElevatedButton.icon(
                            onPressed: () {
                              _ubahStatus(context, document.id, 'Selesai');
                            },

                            icon: const Icon(Icons.check_circle_outline),

                            label: const Text('Tandai Selesai'),

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,

                              foregroundColor: Colors.white,

                              padding: const EdgeInsets.symmetric(vertical: 13),

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  // ==========================================================
  // INFO ROW
  // ==========================================================

  static Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Icon(icon, size: 20, color: Colors.blue),

        const SizedBox(width: 10),

        SizedBox(
          width: 70,

          child: Text(
            label,

            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),

        Expanded(
          child: Text(
            value,

            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // UBAH STATUS
  // ==========================================================

  static Future<void> _ubahStatus(
    BuildContext context,
    String documentId,
    String statusBaru,
  ) async {
    // ================================================
    // KONFIRMASI
    // ================================================

    final bool? konfirmasi = await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: Text(
            statusBaru == 'Dijadwalkan'
                ? 'Jadwalkan Konsultasi?'
                : statusBaru == 'Selesai'
                ? 'Tandai Selesai?'
                : 'Batalkan Konsultasi?',
          ),

          content: Text(
            statusBaru == 'Dijadwalkan'
                ? 'Apakah kamu yakin ingin menjadwalkan konsultasi ini?'
                : statusBaru == 'Selesai'
                ? 'Apakah kamu yakin konsultasi ini sudah selesai?'
                : 'Apakah kamu yakin ingin membatalkan konsultasi ini?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },

              child: const Text('Tidak'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },

              child: const Text('Ya'),
            ),
          ],
        );
      },
    );

    if (konfirmasi != true) {
      return;
    }

    // ================================================
    // UPDATE FIRESTORE
    // ================================================

    try {
      await KonsultasiService.updateStatusKonsultasi(
        documentId: documentId,
        status: statusBaru,
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status berhasil diubah menjadi $statusBaru'),

          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah status: $e'),

          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
