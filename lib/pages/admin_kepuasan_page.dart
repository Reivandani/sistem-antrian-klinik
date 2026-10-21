
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/kepuasan_layanan.dart';
import '../services/database_service.dart';
import '../services/kepuasan_service.dart';

class AdminKepuasanPage extends StatefulWidget {
  const AdminKepuasanPage({super.key});

  @override
  State<AdminKepuasanPage> createState() => _AdminKepuasanPageState();
}

class _AdminKepuasanPageState extends State<AdminKepuasanPage> {
  final KepuasanService _service = KepuasanService();

  bool _memeriksaAkses = true;
  bool _aksesDiizinkan = false;
  String _pesanAkses = '';

  @override
  void initState() {
    super.initState();
    _periksaAkses();
  }

  Future<void> _periksaAkses() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('Silakan login terlebih dahulu.');
      }

      final role = await DatabaseService.ambilRole(user.uid);

      if (role != 'petugas') {
        throw Exception('Halaman ini hanya dapat diakses petugas.');
      }

      if (!mounted) return;

      setState(() {
        _aksesDiizinkan = true;
        _memeriksaAkses = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _pesanAkses = e.toString().replaceFirst('Exception: ', '');
        _memeriksaAkses = false;
      });
    }
  }

  double _rataRata(
    List<KepuasanLayanan> data,
    int Function(KepuasanLayanan) ambilRating,
  ) {
    if (data.isEmpty) return 0;

    final total = data.fold<int>(
      0,
      (jumlah, item) => jumlah + ambilRating(item),
    );

    return total / data.length;
  }

  Widget _kartuStatistik({
    required String judul,
    required String nilai,
    required IconData ikon,
    required Color warna,
    String? keterangan,
  }) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: warna.withValues(alpha: 0.12),
              child: Icon(ikon, color: warna),
            ),
            const SizedBox(height: 12),
            Text(
              nilai,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              judul,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (keterangan != null) ...[
              const SizedBox(height: 4),
              Text(
                keterangan,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _ratingAspek(String judul, double nilai) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(judul),
              Text(
                '${nilai.toStringAsFixed(1)} / 5',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: nilai / 5,
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
            backgroundColor: Colors.grey.shade200,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  String _tanggal(Timestamp? timestamp) {
    if (timestamp == null) return 'Baru saja';

    final date = timestamp.toDate().toLocal();
    final tanggal = date.day.toString().padLeft(2, '0');
    final bulan = date.month.toString().padLeft(2, '0');
    final tahun = date.year.toString();
    final jam = date.hour.toString().padLeft(2, '0');
    final menit = date.minute.toString().padLeft(2, '0');

    return '$tanggal/$bulan/$tahun • $jam:$menit';
  }

  Widget _kartuPenilaian(KepuasanLayanan item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  child: Icon(Icons.person_outline),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.namaPasien,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 3),
                      Text('${item.namaPoli} • ${item.dokter}'),
                      const SizedBox(height: 3),
                      Text(
                        _tanggal(item.tanggalPenilaian),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    Text(
                      '${item.ratingKeseluruhan}/5',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text('Petugas: ${item.ratingPetugas}/5'),
                ),
                Chip(
                  label: Text('Waktu: ${item.ratingWaktuTunggu}/5'),
                ),
                Chip(
                  label: Text('Dokter: ${item.ratingDokter}/5'),
                ),
              ],
            ),
            if (item.komentar.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Komentar pasien',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(item.komentar),
            ],
          ],
        ),
      ),
    );
  }

  Widget _isiDashboard(List<KepuasanLayanan> data) {
    final jumlah = data.length;

    final rataKeseluruhan = _rataRata(
      data,
      (item) => item.ratingKeseluruhan,
    );

    final rataPetugas = _rataRata(
      data,
      (item) => item.ratingPetugas,
    );

    final rataWaktu = _rataRata(
      data,
      (item) => item.ratingWaktuTunggu,
    );

    final rataDokter = _rataRata(
      data,
      (item) => item.ratingDokter,
    );

    final jumlahPuas = data
        .where((item) => item.ratingKeseluruhan >= 4)
        .length;

    final persentasePuas =
        jumlah == 0 ? 0.0 : jumlahPuas / jumlah * 100;

    // Mengelompokkan rata-rata kepuasan berdasarkan nama poli.
    final Map<String, List<KepuasanLayanan>> perPoli = {};

    for (final item in data) {
      perPoli.putIfAbsent(item.namaPoli, () => []);
      perPoli[item.namaPoli]!.add(item);
    }

    final daftarPoli = perPoli.keys.toList()..sort();

    return RefreshIndicator(
      onRefresh: () async {
        // Stream Firestore akan memperbarui data secara otomatis.
        await Future<void>.delayed(const Duration(milliseconds: 300));
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Dashboard Kepuasan Layanan',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pantau pengalaman pasien dan evaluasi kualitas layanan klinik.',
          ),
          const SizedBox(height: 18),

          LayoutBuilder(
            builder: (context, constraints) {
              final lebar = constraints.maxWidth;
              final kolom = lebar >= 900 ? 4 : lebar >= 520 ? 2 : 1;

              return GridView.count(
                crossAxisCount: kolom,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: kolom == 1 ? 2.1 : 1.25,
                children: [
                  _kartuStatistik(
                    judul: 'Total Penilaian',
                    nilai: '$jumlah',
                    ikon: Icons.rate_review_outlined,
                    warna: Colors.blue,
                  ),
                  _kartuStatistik(
                    judul: 'Rata-rata Rating',
                    nilai: '${rataKeseluruhan.toStringAsFixed(1)}/5',
                    ikon: Icons.star_rate_rounded,
                    warna: Colors.orange,
                  ),
                  _kartuStatistik(
                    judul: 'Persentase Puas',
                    nilai: '${persentasePuas.toStringAsFixed(1)}%',
                    ikon: Icons.sentiment_satisfied_alt,
                    warna: Colors.green,
                    keterangan: 'Rating keseluruhan minimal 4',
                  ),
                  _kartuStatistik(
                    judul: 'Belum Puas',
                    nilai: '${jumlah - jumlahPuas}',
                    ikon: Icons.feedback_outlined,
                    warna: Colors.red,
                    keterangan: 'Rating keseluruhan di bawah 4',
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),
          const Text(
            'Rating per Aspek',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _ratingAspek('Pelayanan petugas', rataPetugas),
                  _ratingAspek('Waktu tunggu', rataWaktu),
                  _ratingAspek('Pelayanan dokter', rataDokter),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Kepuasan per Poli',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          if (daftarPoli.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Belum ada data penilaian.'),
              ),
            )
          else
            ...daftarPoli.map((poli) {
              final dataPoli = perPoli[poli]!;
              final rata = _rataRata(
                dataPoli,
                (item) => item.ratingKeseluruhan,
              );

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.local_hospital_outlined),
                  title: Text(poli),
                  subtitle: Text('${dataPoli.length} penilaian'),
                  trailing: Text(
                    '${rata.toStringAsFixed(1)}/5',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }),

          const SizedBox(height: 24),
          const Text(
            'Komentar dan Penilaian Terbaru',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          if (data.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Belum ada pasien yang memberikan penilaian.',
                ),
              ),
            )
          else
            ...data.take(50).map(_kartuPenilaian),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_memeriksaAkses) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_aksesDiizinkan) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kepuasan Layanan')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_pesanAkses, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: const Text('Kepuasan Layanan'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<KepuasanLayanan>>(
        stream: _service.streamSemuaPenilaian(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Gagal memuat penilaian: ${snapshot.error}'),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return _isiDashboard(snapshot.data ?? []);
        },
      ),
    );
  }
}