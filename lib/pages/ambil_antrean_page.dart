import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/poli.dart';
import '../services/antrean_service.dart';
import 'detail_poli_page.dart';

// ============================================================
// HALAMAN AMBIL ANTREAN
// ============================================================

class AmbilAntreanPage extends StatelessWidget {
  AmbilAntreanPage({
    super.key,
  });

  // ============================================================
  // DAFTAR POLI
  // ============================================================

  // Data poli digunakan untuk menampilkan pilihan poli.
  //
  // jumlahAntrian dibuat 0 karena jumlah antrean sebenarnya
  // akan diambil langsung dari Firestore secara realtime.
  //
  // Jadi angka 0 di sini BUKAN berarti antrean selalu 0.
  // Angka tersebut hanya nilai awal dari object Poli.

  final List<Poli> daftarPoli = [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        title: const Text(
          'Ambil Antrean',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // ======================================================
            // JUDUL HALAMAN
            // ======================================================

            const Text(
              'Pilih Poli',

              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Silakan pilih poli yang ingin Anda gunakan.',

              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            // ======================================================
            // GRID DAFTAR POLI
            // ======================================================

            Expanded(
              child: GridView.builder(

                // --------------------------------------------------
                // PADDING GRID
                // --------------------------------------------------

                padding: const EdgeInsets.only(
                  bottom: 20,
                ),

                // --------------------------------------------------
                // JUMLAH ITEM
                // --------------------------------------------------

                itemCount:
                    daftarPoli.length,

                // --------------------------------------------------
                // PENGATURAN GRID
                // --------------------------------------------------

                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(

                  // Dua kolom
                  crossAxisCount: 2,

                  // Jarak antar kolom
                  crossAxisSpacing: 15,

                  // Jarak antar baris
                  mainAxisSpacing: 15,

                  // Tinggi card
                  mainAxisExtent: 300,
                ),

                // ==================================================
                // PEMBUATAN ITEM GRID
                // ==================================================

                itemBuilder: (
                  context,
                  index,
                ) {

                  // Mengambil data poli berdasarkan index.
                  final Poli poli =
                      daftarPoli[index];

                  // ==================================================
                  // CARD POLI
                  // ==================================================

                  return Card(
                    elevation: 3,

                    margin:
                        EdgeInsets.zero,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),

                    child: InkWell(
                      borderRadius:
                          BorderRadius.circular(15),

                      // ==================================================
                      // KETIKA CARD DITEKAN
                      // ==================================================

                      onTap: () {

                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (context) =>
                                DetailPoliPage(
                              poli: poli,
                            ),
                          ),
                        );
                      },

                      // ==================================================
                      // ISI CARD
                      // ==================================================

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          // ==================================================
                          // GAMBAR POLI
                          // ==================================================

                          ClipRRect(
                            borderRadius:
                                const BorderRadius.vertical(
                              top:
                                  Radius.circular(15),
                            ),

                            child: Image.asset(
                              poli.gambar,

                              width:
                                  double.infinity,

                              height: 130,

                              fit:
                                  BoxFit.cover,

                              // ==================================================
                              // FALLBACK GAMBAR
                              // ==================================================

                              errorBuilder: (
                                context,
                                error,
                                stackTrace,
                              ) {

                                return Container(
                                  width:
                                      double.infinity,

                                  height: 130,

                                  color:
                                      Colors.grey.shade200,

                                  child: Icon(
                                    poli.icon,

                                    size: 60,

                                    color:
                                        Colors.blue,
                                  ),
                                );
                              },
                            ),
                          ),

                          // ==================================================
                          // INFORMASI POLI
                          // ==================================================

                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.all(12),

                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,

                                children: [

                                  // ==================================================
                                  // NAMA POLI
                                  // ==================================================

                                  Text(
                                    poli.nama,

                                    maxLines: 1,

                                    overflow:
                                        TextOverflow.ellipsis,

                                    style:
                                        const TextStyle(
                                      fontSize: 17,
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

                                      Icon(
                                        Icons.person,

                                        size: 18,

                                        color:
                                            Colors.grey.shade600,
                                      ),

                                      const SizedBox(
                                        width: 5,
                                      ),

                                      Expanded(
                                        child: Text(
                                          poli.dokter,

                                          maxLines: 1,

                                          overflow:
                                              TextOverflow.ellipsis,

                                          style:
                                              TextStyle(
                                            color:
                                                Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(
                                    height: 7,
                                  ),

                                  // ==================================================
                                  // JUMLAH ANTREAN REAL-TIME
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
                                          ConnectionState.waiting) {

                                        return Row(
                                          children: [

                                            const Icon(
                                              Icons.people,
                                              size: 18,
                                              color:
                                                  Colors.blue,
                                            ),

                                            const SizedBox(
                                              width: 5,
                                            ),

                                            const Expanded(
                                              child: Text(
                                                'Memuat antrean...',
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style:
                                                    TextStyle(
                                                  color:
                                                      Colors.blue,
                                                  fontWeight:
                                                      FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }

                                      // ==================================================
                                      // ERROR FIRESTORE
                                      // ==================================================

                                      if (snapshot.hasError) {

                                        return Row(
                                          children: [

                                            const Icon(
                                              Icons.people,
                                              size: 18,
                                              color:
                                                  Colors.blue,
                                            ),

                                            const SizedBox(
                                              width: 5,
                                            ),

                                            const Expanded(
                                              child: Text(
                                                '0 orang antre',
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style:
                                                    TextStyle(
                                                  color:
                                                      Colors.blue,
                                                  fontWeight:
                                                      FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }

                                      // ==================================================
                                      // HITUNG ANTREAN AKTIF
                                      // ==================================================

                                      int jumlahAntrean = 0;

                                      if (snapshot.hasData) {

                                        final QuerySnapshot
                                            querySnapshot =
                                            snapshot.data!;

                                        // Mengecek semua dokumen
                                        // antrean pada poli ini.

                                        for (
                                          final doc
                                              in querySnapshot.docs
                                        ) {

                                          final Map<String, dynamic>
                                              data =
                                              doc.data()
                                                  as Map<String, dynamic>;

                                          final String status =
                                              data['status'] ??
                                                  'Menunggu';

                                          // ------------------------------------------------
                                          // ANTREAN AKTIF
                                          // ------------------------------------------------
                                          //
                                          // Menunggu = pasien masih menunggu
                                          //
                                          // Dipanggil = pasien sedang dilayani
                                          //
                                          // Selesai dan Dibatalkan tidak
                                          // dihitung sebagai antrean aktif.

                                          if (status ==
                                                  'Menunggu' ||
                                              status ==
                                                  'Dipanggil') {

                                            jumlahAntrean++;
                                          }
                                        }
                                      }

                                      // ==================================================
                                      // TAMPILKAN JUMLAH ANTREAN
                                      // ==================================================

                                      return Row(
                                        children: [

                                          const Icon(
                                            Icons.people,
                                            size: 18,
                                            color:
                                                Colors.blue,
                                          ),

                                          const SizedBox(
                                            width: 5,
                                          ),

                                          Expanded(
                                            child: Text(
                                              '$jumlahAntrean orang antre',

                                              maxLines: 1,

                                              overflow:
                                                  TextOverflow.ellipsis,

                                              style:
                                                  const TextStyle(
                                                color:
                                                    Colors.blue,
                                                fontWeight:
                                                    FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),

                                  // ==================================================
                                  // MEMBERIKAN RUANG KOSONG
                                  // ==================================================

                                  const Spacer(),

                                  // ==================================================
                                  // LIHAT DETAIL
                                  // ==================================================

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.end,

                                    children: [

                                      const Text(
                                        'Lihat detail',

                                        style:
                                            TextStyle(
                                          color:
                                              Colors.blue,
                                          fontSize: 12,
                                          fontWeight:
                                              FontWeight.w500,
                                        ),
                                      ),

                                      const SizedBox(
                                        width: 4,
                                      ),

                                      const Icon(
                                        Icons
                                            .arrow_forward_ios,

                                        size: 12,

                                        color:
                                            Colors.blue,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}