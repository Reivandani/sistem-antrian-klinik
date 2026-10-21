
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/database_service.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _halamanPesan('Silakan login terlebih dahulu.');
    }

    // Pastikan yang membuka halaman adalah petugas.
    return FutureBuilder<String>(
      future: DatabaseService.ambilRole(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data != 'petugas') {
          return _halamanPesan(
            'Akses ditolak. Halaman ini hanya untuk petugas.',
          );
        }

        return const _IsiDashboard();
      },
    );
  }

  Widget _halamanPesan(String pesan) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Statistik')),
      body: Center(child: Text(pesan)),
    );
  }
}

class _IsiDashboard extends StatelessWidget {
  const _IsiDashboard();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        title: const Text(
          'Dashboard Statistik',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'pasien')
            .snapshots(),
        builder: (context, pasienSnapshot) {
          if (pasienSnapshot.hasError) {
            return const Center(
              child: Text('Gagal mengambil data pasien dari Firebase.'),
            );
          }

          if (!pasienSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final pasienDocs = pasienSnapshot.data!.docs;

          // UID pasien digunakan untuk mencari nama pasien.
          final namaPasien = <String, String>{
            for (final doc in pasienDocs)
              doc.id: (doc.data()['nama'] ?? 'Pasien').toString(),
          };

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('antrean')
                .snapshots(),
            builder: (context, antreanSnapshot) {
              if (antreanSnapshot.hasError) {
                return const Center(
                  child: Text('Gagal mengambil data antrean dari Firebase.'),
                );
              }

              if (!antreanSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = antreanSnapshot.data!.docs;
              final dataAntrean = docs.map((doc) => doc.data()).toList();

              int jumlahStatus(String status) {
                return dataAntrean
                    .where((data) => data['status'] == status)
                    .length;
              }

              final menunggu = jumlahStatus('Menunggu');
              final dipanggil = jumlahStatus('Dipanggil');
              final selesai = jumlahStatus('Selesai');
              final dibatalkan = jumlahStatus('Dibatalkan');

              final sekarang = DateTime.now();

              // Menghitung antrean yang dibuat hari ini.
              final antreanHariIni = dataAntrean.where((data) {
                final waktu = _ubahTanggal(data['waktuAmbil']);

                return waktu != null &&
                    waktu.year == sekarang.year &&
                    waktu.month == sekarang.month &&
                    waktu.day == sekarang.day;
              }).length;

              // Menghitung jumlah antrean untuk setiap poli.
              final statistikPoli = <String, int>{};

              for (final data in dataAntrean) {
                final poli =
                    (data['namaPoli'] ?? 'Poli tidak diketahui').toString();

                statistikPoli[poli] = (statistikPoli[poli] ?? 0) + 1;
              }

              final daftarPoli = statistikPoli.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));

              // Mengurutkan antrean dari yang terbaru.
              final antreanTerbaru = [...docs];

              antreanTerbaru.sort((a, b) {
                final waktuA =
                    _ubahTanggal(a.data()['waktuAmbil']) ?? DateTime(2000);

                final waktuB =
                    _ubahTanggal(b.data()['waktuAmbil']) ?? DateTime(2000);

                return waktuB.compareTo(waktuA);
              });

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Ringkasan Klinik',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Data statistik diperbarui otomatis dari Firebase.',
                  ),
                  const SizedBox(height: 18),

                  // KARTU STATISTIK
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final kolom = constraints.maxWidth >= 850
                          ? 4
                          : constraints.maxWidth >= 520
                              ? 3
                              : 2;

                      return GridView.count(
                        crossAxisCount: kolom,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.35,
                        children: [
                          _KartuStatistik(
                            judul: 'Total Pasien',
                            nilai: pasienDocs.length,
                            ikon: Icons.people_alt_outlined,
                            warna: Colors.blue,
                          ),
                          _KartuStatistik(
                            judul: 'Total Antrean',
                            nilai: docs.length,
                            ikon: Icons.confirmation_num_outlined,
                            warna: Colors.deepPurple,
                          ),
                          _KartuStatistik(
                            judul: 'Menunggu',
                            nilai: menunggu,
                            ikon: Icons.hourglass_top,
                            warna: Colors.orange,
                          ),
                          _KartuStatistik(
                            judul: 'Dipanggil',
                            nilai: dipanggil,
                            ikon: Icons.campaign_outlined,
                            warna: Colors.teal,
                          ),
                          _KartuStatistik(
                            judul: 'Selesai',
                            nilai: selesai,
                            ikon: Icons.check_circle_outline,
                            warna: Colors.green,
                          ),
                          _KartuStatistik(
                            judul: 'Dibatalkan',
                            nilai: dibatalkan,
                            ikon: Icons.cancel_outlined,
                            warna: Colors.red,
                          ),
                          _KartuStatistik(
                            judul: 'Antrean Hari Ini',
                            nilai: antreanHariIni,
                            ikon: Icons.today_outlined,
                            warna: Colors.indigo,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // GRAFIK SEDERHANA PER POLI
                  const Text(
                    'Statistik Antrean per Poli',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _Panel(
                    child: daftarPoli.isEmpty
                        ? const Text('Belum ada data antrean.')
                        : Column(
                            children: daftarPoli.map((item) {
                              final maksimum = daftarPoli
                                  .map((e) => e.value)
                                  .reduce((a, b) => a > b ? a : b);

                              final progress = maksimum == 0
                                  ? 0.0
                                  : item.value / maksimum;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(child: Text(item.key)),
                                        Text(
                                          '${item.value} antrean',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 12,
                                        backgroundColor: Colors.blue.shade50,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ),

                  const SizedBox(height: 28),

                  // DAFTAR ANTREAN TERBARU
                  const Text(
                    'Antrean Terbaru',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (antreanTerbaru.isEmpty)
                    const _Panel(
                      child: Text('Belum ada antrean yang tercatat.'),
                    ),

                  ...antreanTerbaru.take(10).map((doc) {
                    final data = doc.data();

                    final nomor =
                        (data['nomorAntrean'] ?? '-').toString();

                    final poli = (data['namaPoli'] ?? '-').toString();
                    final dokter = (data['dokter'] ?? '-').toString();
                    final status =
                        (data['status'] ?? 'Menunggu').toString();

                    final uid = (data['uid'] ?? '').toString();
                    final nama = namaPasien[uid] ?? 'Pasien';

                    final waktu = _ubahTanggal(data['waktuAmbil']);

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade50,
                          child: FittedBox(
                            child: Text(
                              nomor,
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          nama,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '$poli • $dokter\n${_formatTanggal(waktu)}',
                        ),
                        isThreeLine: true,
                        trailing: _LabelStatus(status: status),
                      ),
                    );
                  }),
                ],
              );
            },
          );
        },
      ),
    );
  }

  static DateTime? _ubahTanggal(dynamic nilai) {
    if (nilai is Timestamp) return nilai.toDate();
    if (nilai is DateTime) return nilai;
    if (nilai is String) return DateTime.tryParse(nilai);
    return null;
  }

  static String _formatTanggal(DateTime? waktu) {
    if (waktu == null) return 'Waktu tidak tersedia';

    final tanggal = waktu.day.toString().padLeft(2, '0');
    final bulan = waktu.month.toString().padLeft(2, '0');
    final jam = waktu.hour.toString().padLeft(2, '0');
    final menit = waktu.minute.toString().padLeft(2, '0');

    return '$tanggal/$bulan/${waktu.year} • $jam:$menit';
  }
}

// KOMPONEN KARTU STATISTIK
class _KartuStatistik extends StatelessWidget {
  const _KartuStatistik({
    required this.judul,
    required this.nilai,
    required this.ikon,
    required this.warna,
  });

  final String judul;
  final int nilai;
  final IconData ikon;
  final Color warna;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(ikon, color: warna, size: 28),
          Text(
            '$nilai',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: warna,
            ),
          ),
          Text(
            judul,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

// PANEL PUTIH UNTUK MEMBUNGKUS KONTEN
class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

// LABEL STATUS ANTREAN
class _LabelStatus extends StatelessWidget {
  const _LabelStatus({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color warna;

    switch (status) {
      case 'Menunggu':
        warna = Colors.orange;
        break;
      case 'Dipanggil':
        warna = Colors.blue;
        break;
      case 'Selesai':
        warna = Colors.green;
        break;
      case 'Dibatalkan':
        warna = Colors.red;
        break;
      default:
        warna = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: warna,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}