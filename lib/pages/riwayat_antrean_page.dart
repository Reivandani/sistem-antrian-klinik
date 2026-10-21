
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/antrean_service.dart';
import '../services/notification_service.dart';
import '../widgets/status_badge.dart';
import 'penilaian_layanan_page.dart';

// ============================================================
// HALAMAN RIWAYAT ANTREAN
// ============================================================

class RiwayatAntreanPage extends StatefulWidget {
  const RiwayatAntreanPage({super.key});

  @override
  State<RiwayatAntreanPage> createState() =>
      _RiwayatAntreanPageState();
}

class _RiwayatAntreanPageState
    extends State<RiwayatAntreanPage> {
  // Menyimpan status antrean sebelumnya untuk notifikasi.
  final Map<String, String> _statusSebelumnya = {};

  // Mencegah proses pengecekan status yang sama berjalan bersamaan.
  bool _sedangMemeriksaStatus = false;

  // ==========================================================
  // CEK PERUBAHAN STATUS ANTREAN
  // ==========================================================

  Future<void> _cekPerubahanStatus(
    List<QueryDocumentSnapshot> documents,
  ) async {
    if (_sedangMemeriksaStatus) return;

    _sedangMemeriksaStatus = true;

    try {
      for (final document in documents) {
        final Map<String, dynamic> antrean =
            document.data() as Map<String, dynamic>;

        final String statusSekarang =
            antrean['status']?.toString() ?? 'Menunggu';

        final String? statusLama =
            _statusSebelumnya[document.id];

        // Status awal hanya disimpan, tidak memicu notifikasi.
        if (statusLama == null) {
          _statusSebelumnya[document.id] = statusSekarang;
          continue;
        }

        // Notifikasi saat status berubah menjadi Dipanggil.
        if (statusLama != 'Dipanggil' &&
            statusSekarang == 'Dipanggil') {
          final String nomor =
              antrean['nomorAntrean']?.toString() ?? '-';

          final String namaPoli =
              antrean['namaPoli']?.toString() ?? '-';

          final String dokter =
              antrean['dokter']?.toString() ?? '-';

          await NotificationService
              .tampilkanNotifikasiGiliranAnda(
            nomorAntrean: nomor,
            namaPoli: namaPoli,
            dokter: dokter,
          );
        }

        _statusSebelumnya[document.id] = statusSekarang;
      }
    } catch (e) {
      debugPrint('Gagal memeriksa status antrean: $e');
    } finally {
      _sedangMemeriksaStatus = false;
    }
  }

  // ==========================================================
  // MEMBUKA HALAMAN PENILAIAN
  // ==========================================================

  Future<void> _bukaPenilaian({
    required String idAntrean,
    required String namaPoli,
    required String dokter,
  }) async {
    // Pastikan pengguna masih login.
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan login terlebih dahulu.'),
        ),
      );
      return;
    }

    // Pastikan antrean sudah selesai dan belum dinilai.
    try {
      final DocumentSnapshot<Map<String, dynamic>> antreanDoc =
          await FirebaseFirestore.instance
              .collection('antrean')
              .doc(idAntrean)
              .get();

      if (!antreanDoc.exists) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data antrean tidak ditemukan.'),
          ),
        );
        return;
      }

      final dataAntrean = antreanDoc.data()!;

      // Pastikan antrean benar-benar milik pasien yang login.
      if (dataAntrean['uid'] != user.uid) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Anda tidak memiliki akses ke antrean ini.',
            ),
          ),
        );
        return;
      }

      if (dataAntrean['status'] != 'Selesai') {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Penilaian hanya tersedia setelah pelayanan selesai.',
            ),
          ),
        );
        return;
      }

      final DocumentSnapshot<Map<String, dynamic>> penilaianDoc =
          await FirebaseFirestore.instance
              .collection('penilaian_layanan')
              .doc(idAntrean)
              .get();

      if (!mounted) return;

      if (penilaianDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Antrean ini sudah Anda nilai.',
            ),
          ),
        );
        return;
      }

      // Buka halaman penilaian.
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PenilaianLayananPage(
            idAntrean: idAntrean,
            namaPoli: namaPoli,
            dokter: dokter,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuka penilaian: $e'),
        ),
      );
    }
  }

  // ==========================================================
  // MEMBANGUN TOMBOL PENILAIAN BERDASARKAN STATUS
  // ==========================================================

  Widget _buildTombolPenilaian({
    required String idAntrean,
    required String namaPoli,
    required String dokter,
    required String status,
  }) {
    // Tombol hanya tersedia untuk antrean yang selesai.
    if (status != 'Selesai') {
      return const SizedBox.shrink();
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('penilaian_layanan')
          .doc(idAntrean)
          .snapshots(),
      builder: (context, snapshot) {
        // Status penilaian belum diketahui.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(top: 12),
            child: LinearProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Status penilaian tidak dapat dimuat.',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 12,
              ),
            ),
          );
        }

        final bool sudahDinilai =
            snapshot.data?.exists ?? false;

        if (sudahDinilai) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.shade200,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Penilaian Terkirim',
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _bukaPenilaian(
                  idAntrean: idAntrean,
                  namaPoli: namaPoli,
                  dokter: dokter,
                );
              },
              icon: const Icon(Icons.star_outline),
              label: const Text('Beri Penilaian'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // BUILD HALAMAN
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Riwayat Antrean',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: const Center(
          child: Text('Silakan login terlebih dahulu.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Antrean',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: AntreanService.riwayatAntreanPasien(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

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

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Belum Ada Riwayat Antrean',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Antrean yang pernah Anda ambil akan muncul '
                      'di halaman ini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final List<QueryDocumentSnapshot> daftarRiwayat =
              snapshot.data!.docs;

          // Periksa perubahan status setelah build selesai.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _cekPerubahanStatus(daftarRiwayat);
            }
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: daftarRiwayat.length,
            itemBuilder: (context, index) {
              final QueryDocumentSnapshot document =
                  daftarRiwayat[index];

              final Map<String, dynamic> antrean =
                  document.data() as Map<String, dynamic>;

              // ID dokumen penting untuk menghubungkan penilaian.
              return _buildRiwayatCard(
                idAntrean: document.id,
                antrean: antrean,
              );
            },
          );
        },
      ),
    );
  }

  // ==========================================================
  // CARD RIWAYAT ANTREAN
  // ==========================================================

  Widget _buildRiwayatCard({
    required String idAntrean,
    required Map<String, dynamic> antrean,
  }) {
    final String nomor =
        antrean['nomorAntrean']?.toString() ?? '-';

    final String namaPoli =
        antrean['namaPoli']?.toString() ?? '-';

    final String dokter =
        antrean['dokter']?.toString() ?? '-';

    final String status =
        antrean['status']?.toString() ?? 'Menunggu';

    // Format waktu pengambilan antrean.
    String waktu = 'Waktu tidak tersedia';

    final dynamic waktuAmbil = antrean['waktuAmbil'];

    if (waktuAmbil is Timestamp) {
      final DateTime tanggal = waktuAmbil.toDate();

      waktu =
          '${tanggal.day.toString().padLeft(2, '0')}/'
          '${tanggal.month.toString().padLeft(2, '0')}/'
          '${tanggal.year} '
          '${tanggal.hour.toString().padLeft(2, '0')}:'
          '${tanggal.minute.toString().padLeft(2, '0')}';
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header poli, dokter, dan nomor antrean.
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.confirmation_number,
                    color: Colors.blue,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        namaPoli,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dokter,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  nomor,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 12),

            // Waktu pengambilan antrean.
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    waktu,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Status antrean.
            Row(
              children: [
                const Text(
                  'Status: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 5),
                StatusBadge(status: status),
              ],
            ),

            const SizedBox(height: 12),

            // Keterangan sesuai status.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _getKeteranganStatus(status),
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  height: 1.4,
                ),
              ),
            ),

            // Tombol penilaian hanya muncul setelah pelayanan selesai.
            _buildTombolPenilaian(
              idAntrean: idAntrean,
              namaPoli: namaPoli,
              dokter: dokter,
              status: status,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // KETERANGAN STATUS
  // ==========================================================

  String _getKeteranganStatus(String status) {
    switch (status) {
      case 'Menunggu':
        return 'Antrean Anda sedang menunggu dipanggil oleh petugas.';

      case 'Dipanggil':
        return 'Nomor antrean Anda sedang dilayani oleh petugas.';

      case 'Selesai':
        return 'Antrean Anda telah selesai dilayani. '
            'Silakan berikan penilaian terhadap layanan klinik.';

      case 'Dibatalkan':
        return 'Antrean ini telah dibatalkan.';

      default:
        return 'Status antrean tidak diketahui.';
    }
  }
}