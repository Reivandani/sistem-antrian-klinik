import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/poli.dart';
import '../services/antrean_service.dart';

class DetailPoliPage extends StatelessWidget {
  final Poli poli;

  const DetailPoliPage({
    super.key,
    required this.poli,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        title: Text(poli.nama),
        centerTitle: true,
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ======================================================
            // GAMBAR POLI
            // ======================================================

            SizedBox(
              width: double.infinity,
              height: 260,

              child: Image.asset(
                poli.gambar,

                fit: BoxFit.cover,

                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return Container(
                    color:
                        Colors.blue.shade50,

                    child: Icon(
                      poli.icon,
                      size: 100,
                      color: Colors.blue,
                    ),
                  );
                },
              ),
            ),

            // ======================================================
            // ISI DETAIL POLI
            // ======================================================

            Padding(
              padding:
                  const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // ==================================================
                  // NAMA POLI
                  // ==================================================

                  Text(
                    poli.nama,

                    style:
                        const TextStyle(
                      fontSize: 26,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  // ==================================================
                  // DOKTER
                  // ==================================================

                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        color: Colors.blue,
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      Text(
                        poli.dokter,

                        style:
                            const TextStyle(
                          fontSize: 16,
                          color:
                              Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // ==================================================
                  // TENTANG POLI
                  // ==================================================

                  const Text(
                    'Tentang Poli',

                    style:
                        TextStyle(
                      fontSize: 19,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    poli.deskripsi,

                    style:
                        const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  // ==================================================
                  // INFORMASI POLI
                  // ==================================================

                  const Text(
                    'Informasi Poli',

                    style:
                        TextStyle(
                      fontSize: 19,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  // ==================================================
                  // ANTREAN DAN SEDANG DILAYANI
                  // ==================================================

                  StreamBuilder<QuerySnapshot>(
                    stream:
                        AntreanService
                            .semuaAntreanPoli(
                      poli.nama,
                    ),

                    builder: (
                      context,
                      snapshot,
                    ) {
                      // ==================================================
                      // LOADING
                      // ==================================================

                      if (snapshot
                              .connectionState ==
                          ConnectionState
                              .waiting) {
                        return Row(
                          children: [
                            Expanded(
                              child:
                                  _infoCard(
                                icon:
                                    Icons.people,

                                title:
                                    'Antrean',

                                value:
                                    'Memuat...',
                              ),
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Expanded(
                              child:
                                  _infoCard(
                                icon:
                                    Icons.record_voice_over,

                                title:
                                    'Sedang Dilayani',

                                value:
                                    'Memuat...',
                              ),
                            ),
                          ],
                        );
                      }

                      // ==================================================
                      // ERROR
                      // ==================================================

                      if (snapshot
                          .hasError) {
                        return Row(
                          children: [
                            Expanded(
                              child:
                                  _infoCard(
                                icon:
                                    Icons.people,

                                title:
                                    'Antrean',

                                value:
                                    '0 orang',
                              ),
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Expanded(
                              child:
                                  _infoCard(
                                icon:
                                    Icons.record_voice_over,

                                title:
                                    'Sedang Dilayani',

                                value:
                                    '-',
                              ),
                            ),
                          ],
                        );
                      }

                      // ==================================================
                      // VARIABEL DATA
                      // ==================================================

                      int jumlahAntrean =
                          0;

                      String
                          nomorSedangDilayani =
                          '-';

                      // ==================================================
                      // BACA DATA FIRESTORE
                      // ==================================================

                      if (snapshot
                          .hasData) {
                        final QuerySnapshot
                            querySnapshot =
                            snapshot.data!;

                        // ==================================================
                        // LOOP DATA ANTREAN
                        // ==================================================

                        for (
                          final QueryDocumentSnapshot
                              doc
                              in querySnapshot
                                  .docs
                        ) {
                          final Map<
                              String,
                              dynamic> data =
                              doc.data()
                                  as Map<
                                      String,
                                      dynamic>;

                          // ==============================================
                          // AMBIL STATUS
                          // ==============================================

                          final String
                              status =
                              data['status'] ??
                                  'Menunggu';

                          // ==============================================
                          // HITUNG ANTREAN AKTIF
                          //
                          // Menunggu dan Dipanggil
                          // masih dianggap antrean aktif.
                          // ==============================================

                          if (status ==
                                  'Menunggu' ||
                              status ==
                                  'Dipanggil') {
                            jumlahAntrean++;
                          }

                          // ==============================================
                          // CARI ANTREAN YANG SEDANG DILAYANI
                          // ==============================================

                          if (status ==
                              'Dipanggil') {
                            nomorSedangDilayani =
                                data[
                                        'nomorAntrean'] ??
                                    '-';
                          }
                        }
                      }

                      // ==================================================
                      // TAMPILKAN INFORMASI
                      // ==================================================

                      return Row(
                        children: [
                          // ==============================================
                          // JUMLAH ANTREAN
                          // ==============================================

                          Expanded(
                            child:
                                _infoCard(
                              icon:
                                  Icons.people,

                              title:
                                  'Antrean',

                              value:
                                  '$jumlahAntrean orang',
                            ),
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          // ==============================================
                          // SEDANG DILAYANI
                          // ==============================================

                          Expanded(
                            child:
                                _infoCard(
                              icon:
                                  Icons.record_voice_over,

                              title:
                                  'Sedang Dilayani',

                              value:
                                  nomorSedangDilayani,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  // ==================================================
                  // JAM PELAYANAN DAN LOKASI
                  // ==================================================

                  Row(
                    children: [
                      Expanded(
                        child:
                            _infoCard(
                          icon:
                              Icons.schedule,

                          title:
                              'Jam Pelayanan',

                          value:
                              poli.jamPelayanan,
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child:
                            _infoCard(
                          icon:
                              Icons.location_on,

                          title:
                              'Lokasi',

                          value:
                              poli.lokasi,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  // ==================================================
                  // LAYANAN TERSEDIA
                  // ==================================================

                  const Text(
                    'Layanan Tersedia',

                    style:
                        TextStyle(
                      fontSize: 19,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  ...poli.layanan.map(
                    (layanan) {
                      return Padding(
                        padding:
                            const EdgeInsets
                                .only(
                          bottom: 8,
                        ),

                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [
                            const Icon(
                              Icons.check_circle,

                              color:
                                  Colors.green,

                              size: 20,
                            ),

                            const SizedBox(
                              width: 8,
                            ),

                            Expanded(
                              child: Text(
                                layanan,

                                style:
                                    const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  // ==================================================
                  // TOMBOL AMBIL ANTREAN
                  // ==================================================

                  SizedBox(
                    width:
                        double.infinity,

                    height: 55,

                    child:
                        ElevatedButton.icon(
                      onPressed: () {
                        _konfirmasiAmbilAntrean(
                          context,
                        );
                      },

                      icon:
                          const Icon(
                        Icons.confirmation_number,
                      ),

                      label:
                          const Text(
                        'Ambil Antrean',

                        style:
                            TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.blue,

                        foregroundColor:
                            Colors.white,

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // WIDGET INFO CARD
  // ============================================================

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(14),

      decoration:
          BoxDecoration(
        color:
            Colors.blue.shade50,

        borderRadius:
            BorderRadius.circular(12),

        border:
            Border.all(
          color:
              Colors.blue.shade100,
        ),
      ),

      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // ========================================================
          // ICON
          // ========================================================

          Icon(
            icon,
            color: Colors.blue,
            size: 26,
          ),

          const SizedBox(
            height: 8,
          ),

          // ========================================================
          // JUDUL
          // ========================================================

          Text(
            title,

            style:
                const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),

          const SizedBox(
            height: 3,
          ),

          // ========================================================
          // NILAI
          // ========================================================

          Text(
            value,

            style:
                const TextStyle(
              fontSize: 14,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // KONFIRMASI AMBIL ANTREAN
  // ============================================================

  Future<void> _konfirmasiAmbilAntrean(
    BuildContext context,
  ) async {
    // ==========================================================
    // CEK USER LOGIN
    // ==========================================================

    final User? user =
        FirebaseAuth
            .instance
            .currentUser;

    // ==========================================================
    // JIKA BELUM LOGIN
    // ==========================================================

    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Silakan login terlebih dahulu.',
          ),
        ),
      );

      return;
    }

    // ==========================================================
    // DIALOG KONFIRMASI
    // ==========================================================

    final bool? konfirmasi =
        await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title:
              const Text(
            'Konfirmasi Antrean',
          ),

          content:
              Column(
            mainAxisSize:
                MainAxisSize.min,

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // --------------------------------------------------
              // PERTANYAAN
              // --------------------------------------------------

              const Text(
                'Apakah Anda yakin ingin mengambil antrean?',
              ),

              const SizedBox(
                height: 15,
              ),

              // --------------------------------------------------
              // POLI
              // --------------------------------------------------

              Text(
                'Poli: ${poli.nama}',
              ),

              const SizedBox(
                height: 5,
              ),

              // --------------------------------------------------
              // DOKTER
              // --------------------------------------------------

              Text(
                'Dokter: ${poli.dokter}',
              ),

              const SizedBox(
                height: 15,
              ),

              // --------------------------------------------------
              // INFORMASI
              // --------------------------------------------------

              const Text(
                'Nomor antrean akan diberikan secara otomatis oleh sistem.',

                style:
                    TextStyle(
                  color:
                      Colors.grey,

                  fontSize:
                      13,
                ),
              ),
            ],
          ),

          actions: [
            // ====================================================
            // BATAL
            // ====================================================

            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },

              child:
                  const Text(
                'Batal',
              ),
            ),

            // ====================================================
            // AMBIL ANTREAN
            // ====================================================

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },

              child:
                  const Text(
                'Ambil Antrean',
              ),
            ),
          ],
        );
      },
    );

    // ==========================================================
    // JIKA DIBATALKAN
    // ==========================================================

    if (konfirmasi != true) {
      return;
    }

    // ==========================================================
    // CEK CONTEXT SEBELUM MEMBUKA DIALOG
    // ==========================================================

    if (!context.mounted) {
      return;
    }

    // ==========================================================
    // TAMPILKAN LOADING
    // ==========================================================

    showDialog(
      context: context,

      barrierDismissible:
          false,

      builder: (context) {
        return const AlertDialog(
          content:
              Row(
            children: [
              CircularProgressIndicator(),

              SizedBox(
                width: 20,
              ),

              Expanded(
                child: Text(
                  'Mengambil nomor antrean...',
                ),
              ),
            ],
          ),
        );
      },
    );

    try {
      // ========================================================
      // SIMPAN ANTREAN KE FIRESTORE
      // ========================================================

      final String nomorAntrean =
          await AntreanService
              .ambilAntrean(
        uid: user.uid,

        namaPoli:
            poli.nama,

        dokter:
            poli.dokter,
      );

      // ========================================================
      // CEK CONTEXT SETELAH ASYNC
      // ========================================================

      if (!context.mounted) {
        return;
      }

      // ========================================================
      // TUTUP LOADING
      // ========================================================

      Navigator.pop(
        context,
      );

      // ========================================================
      // CEK CONTEXT LAGI
      // ========================================================

      if (!context.mounted) {
        return;
      }

      // ========================================================
      // DIALOG BERHASIL
      // ========================================================

      await showDialog(
        context: context,

        builder: (context) {
          return AlertDialog(
            // ====================================================
            // ICON BERHASIL
            // ====================================================

            icon:
                const Icon(
              Icons.check_circle,

              color:
                  Colors.green,

              size: 60,
            ),

            // ====================================================
            // JUDUL
            // ====================================================

            title:
                const Text(
              'Antrean Berhasil Diambil',
            ),

            // ====================================================
            // ISI
            // ====================================================

            content:
                Column(
              mainAxisSize:
                  MainAxisSize.min,

              children: [
                // ----------------------------------------------
                // NOMOR ANTREAN
                // ----------------------------------------------

                Text(
                  nomorAntrean,

                  style:
                      const TextStyle(
                    fontSize: 32,

                    fontWeight:
                        FontWeight.bold,

                    color:
                        Colors.blue,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                // ----------------------------------------------
                // POLI
                // ----------------------------------------------

                Text(
                  poli.nama,

                  style:
                      const TextStyle(
                    fontSize: 16,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                // ----------------------------------------------
                // DOKTER
                // ----------------------------------------------

                Text(
                  poli.dokter,
                ),

                const SizedBox(
                  height: 15,
                ),

                // ----------------------------------------------
                // STATUS
                // ----------------------------------------------

                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        Colors.orange.shade50,

                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),

                  child:
                      const Text(
                    'Menunggu',

                    style:
                        TextStyle(
                      color:
                          Colors.orange,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                // ----------------------------------------------
                // INFORMASI
                // ----------------------------------------------

                const Text(
                  'Silakan menunggu sampai petugas memanggil nomor antrean Anda.',

                  textAlign:
                      TextAlign.center,

                  style:
                      TextStyle(
                    color:
                        Colors.grey,
                  ),
                ),
              ],
            ),

            // ====================================================
            // TOMBOL MENGERTI
            // ====================================================

            actions: [
              SizedBox(
                width:
                    double.infinity,

                child:
                    ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  },

                  child:
                      const Text(
                    'Mengerti',
                  ),
                ),
              ),
            ],
          );
        },
      );

      // ========================================================
      // CEK CONTEXT SETELAH DIALOG
      // ========================================================

      if (!context.mounted) {
        return;
      }

      // ========================================================
      // KEMBALI KE HALAMAN SEBELUMNYA
      // ========================================================

      Navigator.pop(
        context,
      );
    } catch (e) {
      // ========================================================
      // CEK CONTEXT SEBELUM MENUTUP LOADING
      // ========================================================

      if (!context.mounted) {
        return;
      }

      // ========================================================
      // TUTUP LOADING
      // ========================================================

      Navigator.pop(
        context,
      );

      // ========================================================
      // CEK CONTEXT
      // ========================================================

      if (!context.mounted) {
        return;
      }

      // ========================================================
      // TAMPILKAN ERROR
      // ========================================================

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal mengambil antrean: $e',
          ),

          backgroundColor:
              Colors.red,
        ),
      );
    }
  }
}