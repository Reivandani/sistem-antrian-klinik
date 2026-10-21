
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/kepuasan_service.dart';

class PenilaianLayananPage extends StatefulWidget {
  final String idAntrean;
  final String namaPoli;
  final String dokter;

  const PenilaianLayananPage({
    super.key,
    required this.idAntrean,
    required this.namaPoli,
    required this.dokter,
  });

  @override
  State<PenilaianLayananPage> createState() =>
      _PenilaianLayananPageState();
}

class _PenilaianLayananPageState extends State<PenilaianLayananPage> {
  final KepuasanService _service = KepuasanService();
  final TextEditingController _komentarController = TextEditingController();

  int _ratingKeseluruhan = 0;
  int _ratingPetugas = 0;
  int _ratingWaktuTunggu = 0;
  int _ratingDokter = 0;

  bool _memuat = true;
  bool _mengirim = false;
  bool _sudahDinilai = false;
  String? _pesanError;

  @override
  void initState() {
    super.initState();
    _periksaPenilaian();
  }

  Future<void> _periksaPenilaian() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('Silakan login terlebih dahulu.');
      }

      final antreanDoc = await FirebaseFirestore.instance
          .collection('antrean')
          .doc(widget.idAntrean)
          .get();

      if (!antreanDoc.exists) {
        throw Exception('Data antrean tidak ditemukan.');
      }

      final data = antreanDoc.data()!;
      if (data['uid'] != user.uid || data['status'] != 'Selesai') {
        throw Exception(
          'Penilaian hanya tersedia untuk antrean milikmu yang sudah selesai.',
        );
      }

      final sudahDinilai = await _service.sudahDinilai(widget.idAntrean);

      if (mounted) {
        setState(() {
          _sudahDinilai = sudahDinilai;
          _memuat = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _pesanError = e.toString().replaceFirst('Exception: ', '');
          _memuat = false;
        });
      }
    }
  }

  Future<void> _kirim() async {
    if (_ratingKeseluruhan == 0 ||
        _ratingPetugas == 0 ||
        _ratingWaktuTunggu == 0 ||
        _ratingDokter == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua rating terlebih dahulu.')),
      );
      return;
    }

    setState(() => _mengirim = true);

    try {
      await _service.kirimPenilaian(
        idAntrean: widget.idAntrean,
        ratingKeseluruhan: _ratingKeseluruhan,
        ratingPetugas: _ratingPetugas,
        ratingWaktuTunggu: _ratingWaktuTunggu,
        ratingDokter: _ratingDokter,
        komentar: _komentarController.text,
      );

      if (!mounted) return;

      setState(() {
        _sudahDinilai = true;
        _mengirim = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terima kasih! Penilaian berhasil dikirim.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _mengirim = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  Widget _rating(String judul, String deskripsi, int nilai,
      ValueChanged<int> onChanged) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              judul,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(deskripsi, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            Row(
              children: List.generate(5, (index) {
                final nomor = index + 1;
                return IconButton(
                  tooltip: '$nomor bintang',
                  onPressed: _mengirim ? null : () => onChanged(nomor),
                  icon: Icon(
                    nomor <= nilai ? Icons.star : Icons.star_border,
                    color: Colors.amber.shade700,
                    size: 32,
                  ),
                );
              }),
            ),
            Text(
              nilai == 0 ? 'Pilih rating 1–5' : '$nilai dari 5 bintang',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _komentarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: const Text('Kepuasan Layanan'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _memuat
          ? const Center(child: CircularProgressIndicator())
          : _pesanError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _pesanError!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _sudahDinilai
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle,
                                color: Colors.green, size: 72),
                            SizedBox(height: 16),
                            Text(
                              'Penilaian sudah dikirim',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Terima kasih atas masukanmu untuk meningkatkan layanan klinik.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Bagaimana pengalaman layananmu?',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text('Poli: ${widget.namaPoli}'),
                                Text('Dokter: ${widget.dokter}'),
                                const SizedBox(height: 8),
                                const Text(
                                  'Berikan penilaian yang sesuai dengan pengalamanmu.',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _rating(
                          'Kepuasan keseluruhan',
                          'Bagaimana penilaianmu terhadap layanan klinik?',
                          _ratingKeseluruhan,
                          (v) => setState(() => _ratingKeseluruhan = v),
                        ),
                        _rating(
                          'Pelayanan petugas',
                          'Keramahan dan bantuan petugas klinik',
                          _ratingPetugas,
                          (v) => setState(() => _ratingPetugas = v),
                        ),
                        _rating(
                          'Waktu tunggu',
                          'Kenyamanan waktu menunggu antrean',
                          _ratingWaktuTunggu,
                          (v) => setState(() => _ratingWaktuTunggu = v),
                        ),
                        _rating(
                          'Pelayanan dokter',
                          'Komunikasi dan pelayanan dokter',
                          _ratingDokter,
                          (v) => setState(() => _ratingDokter = v),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Komentar atau saran (opsional)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _komentarController,
                          maxLines: 4,
                          maxLength: 500,
                          decoration: const InputDecoration(
                            hintText: 'Tuliskan saran untuk klinik...',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _mengirim ? null : _kirim,
                            icon: _mengirim
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.send),
                            label: Text(
                              _mengirim
                                  ? 'Mengirim...'
                                  : 'Kirim Penilaian',
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
}