import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/antrean_service.dart';
import '../services/notification_service.dart';
import '../widgets/status_badge.dart';

// ============================================================
// HALAMAN RIWAYAT ANTREAN
// ============================================================

class RiwayatAntreanPage extends StatefulWidget {
  const RiwayatAntreanPage({super.key});

  @override
  State<RiwayatAntreanPage> createState() =>
      _RiwayatAntreanPageState();
}

// ============================================================
// STATE HALAMAN RIWAYAT ANTREAN
// ============================================================

class _RiwayatAntreanPageState extends State<RiwayatAntreanPage> {
  // Menyimpan status antrean sebelumnya.
  // Key   = ID dokumen antrean
  // Value = status terakhir yang diketahui
  final Map<String, String> _statusSebelumnya = {};

  // ==========================================================
  // CEK PERUBAHAN STATUS ANTREAN
  // ==========================================================

  Future<void> _cekPerubahanStatus(
    List<QueryDocumentSnapshot> documents,
  ) async {
    for (final document in documents) {
      // Ambil data Firestore
      final Map<String, dynamic> antrean =
          document.data() as Map<String, dynamic>;

      // Status sekarang
      final String statusSekarang =
          antrean['status'] ?? 'Menunggu';

      // Status sebelumnya
      final String? statusLama =
          _statusSebelumnya[document.id];

      // ======================================================
      // JIKA DATA BARU PERTAMA KALI DIBACA
      // ======================================================
      //
      // Jangan tampilkan notifikasi.
      // Status hanya disimpan sebagai status awal.
      //

      if (statusLama == null) {
        _statusSebelumnya[document.id] =
            statusSekarang;

        continue;
      }

      // ======================================================
      // CEK PERUBAHAN MENJADI DIPANGGIL
      // ======================================================

      if (statusLama != 'Dipanggil' &&
          statusSekarang == 'Dipanggil') {
        // Ambil data antrean
        final String nomor =
            antrean['nomorAntrean'] ?? '-';

        final String namaPoli =
            antrean['namaPoli'] ?? '-';

        final String dokter =
            antrean['dokter'] ?? '-';

        // ====================================================
        // TAMPILKAN NOTIFIKASI
        // ====================================================

        await NotificationService
            .tampilkanNotifikasiGiliranAnda(
          nomorAntrean: nomor,
          namaPoli: namaPoli,
          dokter: dokter,
        );
      }

      // Simpan status terbaru
      _statusSebelumnya[document.id] =
          statusSekarang;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ============================================================
    // CEK USER YANG SEDANG LOGIN
    // ============================================================

    final User? user =
        FirebaseAuth.instance.currentUser;

    // ============================================================
    // JIKA USER BELUM LOGIN
    // ============================================================

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Riwayat Antrean',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const Center(
          child: Text(
            'Silakan login terlebih dahulu.',
          ),
        ),
      );
    }

    // ============================================================
    // SCAFFOLD
    // ============================================================

    return Scaffold(
      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        title: const Text(
          'Riwayat Antrean',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: StreamBuilder<QuerySnapshot>(
        stream:
            AntreanService.riwayatAntreanPasien(
          user.uid,
        ),
        builder: (
          context,
          snapshot,
        ) {
          // ======================================================
          // LOADING
          // ======================================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ======================================================
          // ERROR
          // ======================================================

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(20),
                child: Text(
                  'Terjadi kesalahan:\n'
                  '${snapshot.error}',
                  textAlign:
                      TextAlign.center,
                ),
              ),
            );
          }

          // ======================================================
          // BELUM ADA RIWAYAT
          // ======================================================

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    // ICON
                    Icon(
                      Icons.history,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // JUDUL
                    const Text(
                      'Belum Ada Riwayat Antrean',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    // KETERANGAN
                    const Text(
                      'Antrean yang pernah Anda ambil '
                      'akan muncul di halaman ini.',
                      textAlign:
                          TextAlign.center,
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

          // ======================================================
          // DATA RIWAYAT
          // ======================================================

          final List<QueryDocumentSnapshot>
              daftarRiwayat =
              snapshot.data!.docs;

          // ======================================================
          // CEK PERUBAHAN STATUS
          // ======================================================
          //
          // addPostFrameCallback digunakan supaya proses
          // notifikasi dilakukan setelah proses build selesai.
          //

          WidgetsBinding.instance
              .addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }

            _cekPerubahanStatus(
              daftarRiwayat,
            );
          });

          // ======================================================
          // TAMPILKAN LIST
          // ======================================================

          return ListView.builder(
            padding:
                const EdgeInsets.all(16),
            itemCount:
                daftarRiwayat.length,
            itemBuilder: (
              context,
              index,
            ) {
              // DOKUMEN FIRESTORE
              final QueryDocumentSnapshot
                  document =
                  daftarRiwayat[index];

              // DATA FIRESTORE
              final Map<String, dynamic>
                  antrean =
                  document.data()
                      as Map<String, dynamic>;

              // CARD RIWAYAT
              return _buildRiwayatCard(
                antrean,
              );
            },
          );
        },
      ),
    );
  }

  // ================================================================
  // CARD RIWAYAT
  // ================================================================

  Widget _buildRiwayatCard(
    Map<String, dynamic> antrean,
  ) {
    // ==============================================================
    // AMBIL DATA
    // ==============================================================

    final String nomor =
        antrean['nomorAntrean'] ?? '-';

    final String namaPoli =
        antrean['namaPoli'] ?? '-';

    final String dokter =
        antrean['dokter'] ?? '-';

    final String status =
        antrean['status'] ?? 'Menunggu';

    // ==============================================================
    // FORMAT WAKTU
    // ==============================================================

    String waktu =
        'Waktu tidak tersedia';

    final dynamic waktuAmbil =
        antrean['waktuAmbil'];

    if (waktuAmbil is Timestamp) {
      final DateTime tanggal =
          waktuAmbil.toDate();

      waktu =
          '${tanggal.day.toString().padLeft(2, '0')}/'
          '${tanggal.month.toString().padLeft(2, '0')}/'
          '${tanggal.year} '
          '${tanggal.hour.toString().padLeft(2, '0')}:'
          '${tanggal.minute.toString().padLeft(2, '0')}';
    }

    // ==============================================================
    // CARD
    // ==============================================================

    return Card(
      elevation: 3,
      margin:
          const EdgeInsets.only(
        bottom: 15,
      ),
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ========================================================
            // HEADER
            // ========================================================

            Row(
              children: [
                // ICON
                Container(
                  width: 50,
                  height: 50,
                  decoration:
                      BoxDecoration(
                    color:
                        Colors.blue.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                  child: const Icon(
                    Icons.confirmation_number,
                    color:
                        Colors.blue,
                    size: 27,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                // POLI + DOKTER
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        namaPoli,
                        style:
                            const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(
                        dokter,
                        style:
                            const TextStyle(
                          fontSize: 13,
                          color:
                              Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // NOMOR ANTREAN
                Text(
                  nomor,
                  style:
                      const TextStyle(
                    fontSize: 21,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 18,
            ),

            // ========================================================
            // GARIS
            // ========================================================

            Divider(
              color:
                  Colors.grey.shade300,
            ),

            const SizedBox(
              height: 12,
            ),

            // ========================================================
            // WAKTU AMBIL
            // ========================================================

            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color:
                      Colors.grey.shade600,
                ),

                const SizedBox(
                  width: 8,
                ),

                Text(
                  waktu,
                  style:
                      const TextStyle(
                    fontSize: 14,
                    color:
                        Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 12,
            ),

            // ========================================================
            // STATUS
            // ========================================================

            Row(
              children: [
                const Text(
                  'Status: ',
                  style:
                      TextStyle(
                    fontSize: 14,
                    color:
                        Colors.grey,
                  ),
                ),

                const SizedBox(
                  width: 5,
                ),

                StatusBadge(
                  status: status,
                ),
              ],
            ),

            const SizedBox(
              height: 12,
            ),

            // ========================================================
            // KETERANGAN STATUS
            // ========================================================

            Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets.all(12),
              decoration:
                  BoxDecoration(
                color:
                    Colors.grey.shade100,
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),
              child: Text(
                _getKeteranganStatus(
                  status,
                ),
                style:
                    const TextStyle(
                  fontSize: 13,
                  color:
                      Colors.grey,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // KETERANGAN STATUS
  // ================================================================

  String _getKeteranganStatus(
    String status,
  ) {
    switch (status) {
      case 'Menunggu':
        return 'Antrean Anda sedang menunggu '
            'dipanggil oleh petugas.';

      case 'Dipanggil':
        return 'Nomor antrean Anda sedang '
            'dilayani oleh petugas.';

      case 'Selesai':
        return 'Antrean Anda telah selesai '
            'dilayani.';

      case 'Dibatalkan':
        return 'Antrean ini telah dibatalkan.';

      default:
        return 'Status antrean tidak diketahui.';
    }
  }
}