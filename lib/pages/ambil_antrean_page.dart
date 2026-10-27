
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/poli.dart';
import 'detail_poli_page.dart';

// ============================================================
// HALAMAN AMBIL ANTREAN
// ============================================================

class AmbilAntreanPage extends StatelessWidget {
  AmbilAntreanPage({super.key});

  static const Color primary = Color(0xFF1769AA);
  static const Color primaryLight = Color(0xFFE8F3FC);
  static const Color background = Color(0xFFF4F8FC);
  static const Color textPrimary = Color(0xFF172B4D);
  static const Color textSecondary = Color(0xFF718096);
  static const Color borderColor = Color(0xFFE2EAF2);

  // ============================================================
  // DAFTAR POLI
  // ============================================================

  final List<Poli> daftarPoli = [
    PoliUmum(dokter: 'dr. Andi', jumlahAntrian: 0),
    PoliGigi(dokter: 'drg. Sinta', jumlahAntrian: 0),
    PoliMata(dokter: 'dr. Budi', jumlahAntrian: 0),
    PoliJantung(dokter: 'dr. Rina', jumlahAntrian: 0),
    PoliAnak(dokter: 'dr. Dimas', jumlahAntrian: 0),
    PoliSaraf(dokter: 'dr. Fajar', jumlahAntrian: 0),
  ];

  // Satu listener bersama untuk semua poli.
  // Ini menghindari enam listener terpisah pada halaman ini.
  Stream<QuerySnapshot<Map<String, dynamic>>> _streamAntrean() {
    return FirebaseFirestore.instance
        .collection('antrean')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        title: const Text(
          'Ambil Antrean',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 19,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Poli',
              style: TextStyle(
                color: textPrimary,
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Silakan pilih poli yang ingin Anda gunakan.',
              style: TextStyle(
                color: textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),

            // ==================================================
            // GRID POLI DENGAN SATU STREAM FIRESTORE
            // ==================================================

            Expanded(
              child: StreamBuilder<
                  QuerySnapshot<Map<String, dynamic>>>(
                stream: _streamAntrean(),
                builder: (context, snapshot) {
                  // Tetap tampilkan daftar poli saat data dimuat.
                  final bool sedangMemuat =
                      snapshot.connectionState ==
                              ConnectionState.waiting &&
                          !snapshot.hasData;

                  final bool terjadiError = snapshot.hasError;

                  // Hitung antrean aktif per poli satu kali
                  // dari hasil listener bersama.
                  final Map<String, int> jumlahPerPoli = {};

                  if (snapshot.hasData) {
                    for (final doc in snapshot.data!.docs) {
                      final data = doc.data();

                      final String namaPoli =
                          data['namaPoli'] as String? ?? '';

                      final String status =
                          data['status'] as String? ?? 'Menunggu';

                      if (status == 'Menunggu' ||
                          status == 'Dipanggil') {
                        jumlahPerPoli.update(
                          namaPoli,
                          (jumlah) => jumlah + 1,
                          ifAbsent: () => 1,
                        );
                      }
                    }
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      // Desktop: dua kolom.
                      // Layar sempit: satu kolom.
                      final int jumlahKolom =
                          constraints.maxWidth >= 650 ? 2 : 1;

                      return GridView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: daftarPoli.length,
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: jumlahKolom,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,

                          // Kartu dibuat lebih pendek dari 300 px.
                          mainAxisExtent: 260,
                        ),
                        itemBuilder: (context, index) {
                          final Poli poli = daftarPoli[index];

                          final int? jumlahAntrean =
                              snapshot.hasData
                                  ? jumlahPerPoli[poli.nama] ?? 0
                                  : null;

                          return _buildKartuPoli(
                            context: context,
                            poli: poli,
                            jumlahAntrean: jumlahAntrean,
                            sedangMemuat: sedangMemuat,
                            terjadiError: terjadiError,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // KARTU POLI
  // ============================================================

  Widget _buildKartuPoli({
    required BuildContext context,
    required Poli poli,
    required int? jumlahAntrean,
    required bool sedangMemuat,
    required bool terjadiError,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 1.5,
      shadowColor: const Color(0xFF203B5C).withValues(alpha: 0.10),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: borderColor),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPoliPage(poli: poli),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================================================
            // GAMBAR POLI
            // ================================================

            SizedBox(
              width: double.infinity,
              height: 112,
              child: Image.asset(
                poli.gambar,
                fit: BoxFit.cover,

                // Batasi resolusi gambar untuk mengurangi
                // pekerjaan decoding yang tidak diperlukan.
                cacheWidth: 640,
                cacheHeight: 224,
                filterQuality: FilterQuality.medium,

                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: primaryLight,
                    alignment: Alignment.center,
                    child: Icon(
                      poli.icon,
                      size: 46,
                      color: primary,
                    ),
                  );
                },
              ),
            ),

            // ================================================
            // INFORMASI POLI
            // ================================================

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      poli.nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          size: 18,
                          color: textSecondary,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            poli.dokter,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 7),

                    Row(
                      children: [
                        Icon(
                          Icons.people_alt_rounded,
                          size: 18,
                          color: terjadiError
                              ? Colors.orange
                              : primary,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            terjadiError
                                ? 'Antrean tidak tersedia'
                                : jumlahAntrean == null
                                    ? 'Memuat antrean...'
                                    : '$jumlahAntrean orang antre',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: terjadiError
                                  ? Colors.orange.shade800
                                  : primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // ========================================
                    // TOMBOL LIHAT DETAIL
                    // ========================================

                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Lihat detail',
                            style: TextStyle(
                              color: primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 17,
                            color: primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}