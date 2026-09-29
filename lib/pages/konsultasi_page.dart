import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/poli.dart';
import '../models/konsultasi.dart';
import '../services/konsultasi_service.dart';

// ==========================================================
// KONSULTASI PAGE
// ==========================================================

class KonsultasiPage extends StatefulWidget {
  final List<Poli> daftarPoli;

  const KonsultasiPage({super.key, required this.daftarPoli});

  @override
  State<KonsultasiPage> createState() => _KonsultasiPageState();
}

// ==========================================================
// STATE KONSULTASI PAGE
// ==========================================================

class _KonsultasiPageState extends State<KonsultasiPage> {
  // ========================================================
  // DATA YANG DIPILIH USER
  // ========================================================

  Poli? poliTerpilih;

  DateTime? tanggalTerpilih;

  String? jamTerpilih;

  // ========================================================
  // CONTROLLER KELUHAN
  // ========================================================

  final TextEditingController keluhanController = TextEditingController();

  // ========================================================
  // DAFTAR JAM KONSULTASI
  // ========================================================

  final List<String> daftarJam = [
    '08.00',
    '09.00',
    '10.00',
    '11.00',
    '13.00',
    '14.00',
  ];

  // ========================================================
  // DISPOSE CONTROLLER
  // ========================================================

  @override
  void dispose() {
    keluhanController.dispose();

    super.dispose();
  }

  // ========================================================
  // FORMAT TANGGAL
  // ========================================================

  String formatTanggal(DateTime tanggal) {
    const List<String> namaBulan = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${tanggal.day} '
        '${namaBulan[tanggal.month - 1]} '
        '${tanggal.year}';
  }

  // ========================================================
  // PILIH TANGGAL
  // ========================================================

  Future<void> pilihTanggal() async {
    final DateTime sekarang = DateTime.now();

    final DateTime? tanggal = await showDatePicker(
      context: context,

      initialDate: tanggalTerpilih ?? sekarang,

      firstDate: sekarang,

      lastDate: sekarang.add(const Duration(days: 30)),
    );

    if (tanggal != null) {
      setState(() {
        tanggalTerpilih = tanggal;
      });
    }
  }

  // ========================================================
  // MENAMPILKAN PESAN
  // ========================================================

  void tampilkanPesan(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  // ========================================================
  // KONFIRMASI KONSULTASI
  // ========================================================

  Future<void> konfirmasiKonsultasi() async {
    // ------------------------------------------------------
    // VALIDASI POLI
    // ------------------------------------------------------

    if (poliTerpilih == null) {
      tampilkanPesan('Silakan pilih poli terlebih dahulu.');

      return;
    }

    // ------------------------------------------------------
    // VALIDASI TANGGAL
    // ------------------------------------------------------

    if (tanggalTerpilih == null) {
      tampilkanPesan('Silakan pilih tanggal konsultasi.');

      return;
    }

    // ------------------------------------------------------
    // VALIDASI JAM
    // ------------------------------------------------------

    if (jamTerpilih == null) {
      tampilkanPesan('Silakan pilih jam konsultasi.');

      return;
    }

    // ------------------------------------------------------
    // VALIDASI KELUHAN
    // ------------------------------------------------------

    if (keluhanController.text.trim().isEmpty) {
      tampilkanPesan('Silakan masukkan keluhan Anda.');

      return;
    }

    // ------------------------------------------------------
    // MENGAMBIL USER YANG SEDANG LOGIN
    // ------------------------------------------------------

    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      tampilkanPesan('Silakan login terlebih dahulu.');

      return;
    }

    try {
      // ----------------------------------------------------
      // MENGAMBIL NAMA PASIEN DARI FIRESTORE
      // ----------------------------------------------------

      final String namaPasien = await KonsultasiService.ambilNamaPasien(
        user.uid,
      );

      // ----------------------------------------------------
      // MEMBUAT OBJECT KONSULTASI
      // ----------------------------------------------------

      final Konsultasi konsultasiBaru = Konsultasi(
        namaPasien: namaPasien,

        dokter: poliTerpilih!.dokter,

        poli: poliTerpilih!.nama,

        tanggal: formatTanggal(tanggalTerpilih!),

        jam: jamTerpilih!,

        keluhan: keluhanController.text.trim(),
      );

      // ----------------------------------------------------
      // MENAMPILKAN DIALOG KONFIRMASI
      // ----------------------------------------------------

      if (!mounted) return;

      showDialog(
        context: context,

        builder: (context) {
          return AlertDialog(
            // ==================================================
            // JUDUL DIALOG
            // ==================================================

            title: const Text(
              'Konfirmasi Konsultasi',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            // ==================================================
            // INFORMASI KONSULTASI
            // ==================================================
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // ------------------------------------------------
                  // NAMA PASIEN
                  // ------------------------------------------------

                  const Text(
                    'Nama Pasien',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    konsultasiBaru.namaPasien,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  // ------------------------------------------------
                  // POLI
                  // ------------------------------------------------
                  const Text(
                    'Poli',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    konsultasiBaru.poli,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  // ------------------------------------------------
                  // DOKTER
                  // ------------------------------------------------
                  const Text(
                    'Dokter',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    konsultasiBaru.dokter,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  // ------------------------------------------------
                  // TANGGAL
                  // ------------------------------------------------
                  const Text(
                    'Tanggal',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    konsultasiBaru.tanggal,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  // ------------------------------------------------
                  // JAM
                  // ------------------------------------------------
                  const Text(
                    'Jam',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    konsultasiBaru.jam,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  // ------------------------------------------------
                  // KELUHAN
                  // ------------------------------------------------
                  const Text(
                    'Keluhan',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    konsultasiBaru.keluhan,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // ==================================================
            // TOMBOL DIALOG
            // ==================================================
            actions: [
              // ------------------------------------------------
              // BATAL
              // ------------------------------------------------

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },

                child: const Text('Batal'),
              ),

              // ------------------------------------------------
              // KONFIRMASI
              // ------------------------------------------------
              ElevatedButton(
                onPressed: () async {
                  // Menutup dialog
                  Navigator.pop(context);

                  try {
                    // ------------------------------------------------
                    // MENYIMPAN DATA KE FIRESTORE
                    // ------------------------------------------------

                    await KonsultasiService.simpanKonsultasi(
                      uid: user.uid,
                      konsultasi: konsultasiBaru,
                    );

                    if (!mounted) return;

                    // ------------------------------------------------
                    // PESAN BERHASIL
                    // ------------------------------------------------

                    tampilkanPesan('Konsultasi berhasil disimpan.');

                    // ------------------------------------------------
                    // RESET FORM
                    // ------------------------------------------------

                    setState(() {
                      poliTerpilih = null;
                      tanggalTerpilih = null;
                      jamTerpilih = null;
                      keluhanController.clear();
                    });
                  } catch (e) {
                    if (!mounted) return;

                    // ------------------------------------------------
                    // PESAN GAGAL
                    // ------------------------------------------------

                    tampilkanPesan('Gagal menyimpan konsultasi.');
                  }
                },

                child: const Text('Konfirmasi'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // ======================================================
      // ERROR MENGAMBIL NAMA PASIEN
      // ======================================================

      tampilkanPesan('Gagal mengambil data pasien.');
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ======================================================
      // APP BAR
      // ======================================================

      appBar: AppBar(
        title: const Text(
          'Konsultasi Dokter',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
            // HEADER
            // ==================================================

            const Text(
              'Konsultasi dengan Dokter',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            const Text(
              'Pilih poli, tanggal, dan waktu '
              'konsultasi yang tersedia.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // PILIH POLI
            // ==================================================
            const Text(
              'Pilih Poli',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),

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

              child: DropdownButtonHideUnderline(
                child: DropdownButton<Poli>(
                  value: poliTerpilih,

                  isExpanded: true,

                  hint: const Text('Pilih poli yang ingin dikunjungi'),

                  items: widget.daftarPoli.map((Poli poli) {
                    return DropdownMenuItem<Poli>(
                      value: poli,

                      child: Text(poli.nama),
                    );
                  }).toList(),

                  onChanged: (Poli? value) {
                    setState(() {
                      poliTerpilih = value;
                    });
                  },
                ),
              ),
            ),

            // ==================================================
            // INFORMASI DOKTER
            // ==================================================
            if (poliTerpilih != null) ...[
              const SizedBox(height: 20),

              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.blue,

                  borderRadius: BorderRadius.circular(18),
                ),

                child: Row(
                  children: [
                    // ------------------------------------------------
                    // ICON
                    // ------------------------------------------------

                    Container(
                      padding: const EdgeInsets.all(12),

                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),

                        shape: BoxShape.circle,
                      ),

                      child: Icon(
                        poliTerpilih!.icon,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 15),

                    // ------------------------------------------------
                    // INFORMASI
                    // ------------------------------------------------
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            poliTerpilih!.nama,

                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            poliTerpilih!.dokter,

                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            poliTerpilih!.jamPelayanan,

                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 25),

            // ==================================================
            // PILIH TANGGAL
            // ==================================================
            const Text(
              'Tanggal Konsultasi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            GestureDetector(
              onTap: pilihTanggal,

              child: Container(
                width: double.infinity,

                padding: const EdgeInsets.all(17),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(15),

                  border: Border.all(color: Colors.grey.shade200),
                ),

                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Colors.blue),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        tanggalTerpilih == null
                            ? 'Pilih tanggal'
                            : formatTanggal(tanggalTerpilih!),

                        style: TextStyle(
                          color: tanggalTerpilih == null
                              ? Colors.grey
                              : Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),

                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // PILIH JAM
            // ==================================================
            const Text(
              'Pilih Jam Konsultasi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,

              physics: const NeverScrollableScrollPhysics(),

              itemCount: daftarJam.length,

              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,

                crossAxisSpacing: 10,

                mainAxisSpacing: 10,

                childAspectRatio: 2.2,
              ),

              itemBuilder: (context, index) {
                final String jam = daftarJam[index];

                final bool terpilih = jamTerpilih == jam;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      jamTerpilih = jam;
                    });
                  },

                  child: Container(
                    alignment: Alignment.center,

                    decoration: BoxDecoration(
                      color: terpilih ? Colors.blue : Colors.white,

                      borderRadius: BorderRadius.circular(12),

                      border: Border.all(
                        color: terpilih ? Colors.blue : Colors.grey.shade300,
                      ),
                    ),

                    child: Text(
                      jam,

                      style: TextStyle(
                        color: terpilih ? Colors.white : Colors.black,

                        fontWeight: terpilih
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 25),

            // ==================================================
            // KELUHAN
            // ==================================================
            const Text(
              'Keluhan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: keluhanController,

              maxLines: 5,

              decoration: InputDecoration(
                hintText: 'Tuliskan keluhan atau kondisi Anda...',

                filled: true,

                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),

                  borderSide: BorderSide.none,
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),

                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),

                  borderSide: const BorderSide(color: Colors.blue),
                ),

                contentPadding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 30),

            // ==================================================
            // TOMBOL KONFIRMASI
            // ==================================================
            SizedBox(
              width: double.infinity,

              height: 55,

              child: ElevatedButton(
                onPressed: konfirmasiKonsultasi,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,

                  foregroundColor: Colors.white,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),

                child: const Text(
                  'Konfirmasi Konsultasi',

                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
