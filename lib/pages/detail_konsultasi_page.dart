import 'package:flutter/material.dart';

import '../services/konsultasi_service.dart';

class DetailKonsultasiPage extends StatelessWidget {
  final String documentId;
  final String namaPasien;
  final String dokter;
  final String poli;
  final String tanggal;
  final String jam;
  final String keluhan;
  final String status;

  const DetailKonsultasiPage({
    super.key,
    required this.documentId,
    required this.namaPasien,
    required this.dokter,
    required this.poli,
    required this.tanggal,
    required this.jam,
    required this.keluhan,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    // =========================================================
    // MENENTUKAN WARNA DAN ICON STATUS
    // =========================================================

    Color warnaStatus;
    IconData iconStatus;

    if (status == 'Menunggu') {
      warnaStatus = Colors.orange;
      iconStatus = Icons.schedule;
    } else if (status == 'Dijadwalkan') {
      warnaStatus = Colors.blue;
      iconStatus = Icons.event_available;
    } else if (status == 'Selesai') {
      warnaStatus = Colors.green;
      iconStatus = Icons.check_circle;
    } else if (status == 'Dibatalkan') {
      warnaStatus = Colors.red;
      iconStatus = Icons.cancel;
    } else {
      warnaStatus = Colors.grey;
      iconStatus = Icons.info_outline;
    }

    // =========================================================
    // MENENTUKAN APAKAH PASIEN BOLEH MEMBATALKAN
    // =========================================================
    //
    // Pasien boleh membatalkan:
    //
    // Menunggu     → boleh
    // Dijadwalkan  → boleh
    //
    // Selesai      → tidak boleh
    // Dibatalkan   → tidak perlu
    //
    // =========================================================

    final bool bisaDibatalkan = status == 'Menunggu' || status == 'Dijadwalkan';

    return Scaffold(
      // =======================================================
      // APP BAR
      // =======================================================

      appBar: AppBar(
        title: const Text(
          'Detail Konsultasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        backgroundColor: Colors.blue,

        foregroundColor: Colors.white,
      ),

      // =======================================================
      // BODY
      // =======================================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // =================================================
            // HEADER KONSULTASI
            // =================================================

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.blue,

                borderRadius: BorderRadius.circular(20),
              ),

              child: Column(
                children: [
                  const Icon(
                    Icons.medical_services,
                    color: Colors.white,
                    size: 50,
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Konsultasi Dokter',

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    poli,

                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // =================================================
            // INFORMASI PASIEN
            // =================================================
            const Text(
              'Informasi Pasien',

              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _buildInfoCard(
              icon: Icons.person,
              title: 'Nama Pasien',
              value: namaPasien,
            ),

            const SizedBox(height: 20),

            // =================================================
            // INFORMASI DOKTER
            // =================================================
            const Text(
              'Informasi Dokter',

              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _buildInfoCard(
              icon: Icons.medical_services,
              title: 'Dokter',
              value: dokter,
            ),

            _buildInfoCard(
              icon: Icons.local_hospital,
              title: 'Poli',
              value: poli,
            ),

            const SizedBox(height: 20),

            // =================================================
            // JADWAL KONSULTASI
            // =================================================
            const Text(
              'Jadwal Konsultasi',

              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // =============================================
                // TANGGAL
                // =============================================

                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.calendar_today,
                    title: 'Tanggal',
                    value: tanggal,
                  ),
                ),

                const SizedBox(width: 12),

                // =============================================
                // JAM
                // =============================================
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.access_time,
                    title: 'Jam',
                    value: jam,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // =================================================
            // KELUHAN
            // =================================================
            const Text(
              'Keluhan',

              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(16),

                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.15),

                    blurRadius: 10,

                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Text(
                keluhan.isEmpty ? 'Tidak ada keluhan' : keluhan,

                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            ),

            const SizedBox(height: 30),

            // =================================================
            // STATUS KONSULTASI
            // =================================================
            const Text(
              'Status Konsultasi',

              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: warnaStatus.withValues(alpha: 0.10),

                borderRadius: BorderRadius.circular(15),
              ),

              child: Row(
                children: [
                  // ===========================================
                  // ICON STATUS
                  // ===========================================

                  Icon(iconStatus, color: warnaStatus),

                  const SizedBox(width: 12),

                  // ===========================================
                  // INFORMASI STATUS
                  // ===========================================
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          status,

                          style: TextStyle(
                            color: warnaStatus,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          _getStatusDescription(status),

                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // =================================================
            // TOMBOL BATALKAN
            // =================================================
            //
            // Tombol hanya muncul ketika:
            //
            // Menunggu
            // atau
            // Dijadwalkan
            //
            // Pasien tidak bisa membatalkan ketika:
            //
            // Selesai
            // Dibatalkan
            //
            // =================================================
            if (bisaDibatalkan) ...[
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  onPressed: () {
                    _tampilkanDialogPembatalan(context);
                  },

                  icon: const Icon(Icons.cancel_outlined),

                  label: const Text('Batalkan Konsultasi'),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,

                    foregroundColor: Colors.white,

                    padding: const EdgeInsets.symmetric(vertical: 15),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // =================================================
            // INFORMASI TAMBAHAN
            // =================================================
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(15),

                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.12),

                    blurRadius: 8,

                    offset: const Offset(0, 3),
                  ),
                ],
              ),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      _getInformationText(status),

                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        height: 1.5,
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
    );
  }

  // ===========================================================
  // DIALOG PEMBATALAN
  // ===========================================================

  void _tampilkanDialogPembatalan(BuildContext context) {
    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Batalkan Konsultasi?'),

          content: const Text(
            'Apakah kamu yakin ingin membatalkan konsultasi ini?',
          ),

          actions: [
            // =================================================
            // TOMBOL TIDAK
            // =================================================

            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },

              child: const Text('Tidak'),
            ),

            // =================================================
            // TOMBOL YA, BATALKAN
            // =================================================
            ElevatedButton(
              onPressed: () async {
                // Tutup dialog terlebih dahulu
                Navigator.pop(dialogContext);

                try {
                  // ===========================================
                  // UPDATE STATUS FIRESTORE
                  // ===========================================

                  await KonsultasiService.updateStatusKonsultasi(
                    documentId: documentId,

                    status: 'Dibatalkan',
                  );

                  // ===========================================
                  // KEMBALI KE HALAMAN SEBELUMNYA
                  // ===========================================

                  if (context.mounted) {
                    Navigator.pop(context);

                    // =========================================
                    // TAMPILKAN NOTIFIKASI
                    // =========================================

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Konsultasi berhasil dibatalkan.'),
                      ),
                    );
                  }
                } catch (e) {
                  // ===========================================
                  // JIKA TERJADI ERROR
                  // ===========================================

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal membatalkan konsultasi: $e'),
                      ),
                    );
                  }
                }
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,

                foregroundColor: Colors.white,
              ),

              child: const Text('Ya, Batalkan'),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================
  // DESKRIPSI STATUS
  // ===========================================================

  String _getStatusDescription(String status) {
    if (status == 'Menunggu') {
      return 'Konsultasi menunggu diproses oleh petugas.';
    }

    if (status == 'Dijadwalkan') {
      return 'Konsultasi telah dijadwalkan oleh petugas.';
    }

    if (status == 'Selesai') {
      return 'Konsultasi telah selesai.';
    }

    if (status == 'Dibatalkan') {
      return 'Konsultasi telah dibatalkan.';
    }

    return 'Status konsultasi.';
  }

  // ===========================================================
  // INFORMASI TAMBAHAN
  // ===========================================================

  String _getInformationText(String status) {
    if (status == 'Menunggu') {
      return 'Konsultasi sedang menunggu diproses oleh petugas. Kamu masih dapat membatalkan konsultasi jika diperlukan.';
    }

    if (status == 'Dijadwalkan') {
      return 'Konsultasi telah dijadwalkan oleh petugas. Kamu masih dapat membatalkan konsultasi jika diperlukan.';
    }

    if (status == 'Selesai') {
      return 'Konsultasi telah selesai dan tidak dapat dibatalkan lagi.';
    }

    if (status == 'Dibatalkan') {
      return 'Konsultasi ini telah dibatalkan.';
    }

    return 'Informasi mengenai status konsultasi.';
  }

  // ===========================================================
  // WIDGET INFORMATION CARD
  // ===========================================================

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(bottom: 10),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(15),

        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),

            blurRadius: 8,

            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // =================================================
          // ICON
          // =================================================

          Icon(icon, color: Colors.blue, size: 25),

          const SizedBox(width: 12),

          // =================================================
          // TEXT
          // =================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),

                const SizedBox(height: 4),

                Text(
                  value,

                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
