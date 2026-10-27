
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/konsultasi_service.dart';
import 'detail_konsultasi_page.dart';

class RiwayatKonsultasiPage extends StatefulWidget {
  const RiwayatKonsultasiPage({super.key});

  @override
  State<RiwayatKonsultasiPage> createState() =>
      _RiwayatKonsultasiPageState();
}

class _RiwayatKonsultasiPageState extends State<RiwayatKonsultasiPage> {
  // Controller dan FocusNode dibuat sekali agar pencarian tetap stabil.
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _kataKunci = '';
  String _filterStatus = 'Semua';

  final List<String> _daftarFilter = [
    'Semua',
    'Menunggu',
    'Dijadwalkan',
    'Selesai',
    'Dibatalkan',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xffF5F9FF),
        appBar: AppBar(
          title: const Text(
            'Riwayat Konsultasi',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: const Center(
          child: Text('Silakan login terlebih dahulu.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF5F9FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xff1769AA),
        foregroundColor: Colors.white,
        title: const Text(
          'Riwayat Konsultasi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header dan pencarian berada di luar StreamBuilder.
          _buildHeader(),

          // Filter status.
          _buildFilterStatus(),

          // Hanya bagian daftar yang mengikuti perubahan Firestore.
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: KonsultasiService.ambilRiwayatKonsultasi(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xff1769AA),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return _buildPesan(
                    icon: Icons.error_outline,
                    judul: 'Gagal memuat riwayat',
                    deskripsi:
                        'Terjadi kesalahan saat mengambil data konsultasi. '
                        'Silakan coba lagi.',
                    warna: Colors.red,
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildPesan(
                    icon: Icons.history,
                    judul: 'Belum Ada Riwayat',
                    deskripsi:
                        'Konsultasi yang Anda lakukan akan muncul '
                        'di halaman ini.',
                    warna: const Color(0xff1769AA),
                  );
                }

                final daftarDokumen = snapshot.data!.docs;

                // Pencarian dan filter dilakukan pada data yang diterima.
                final daftarKonsultasi = daftarDokumen.where((dokumen) {
                  final data = dokumen.data() as Map<String, dynamic>;

                  final namaPasien =
                      (data['namaPasien'] ?? 'Pasien').toString();
                  final poli = (data['poli'] ?? 'Poli').toString();
                  final dokter = (data['dokter'] ?? 'Dokter').toString();
                  final tanggal = (data['tanggal'] ?? '-').toString();
                  final jam = (data['jam'] ?? '-').toString();
                  final keluhan = (data['keluhan'] ?? '-').toString();
                  final status = (data['status'] ?? 'Menunggu').toString();

                  final kataKunci = _kataKunci.trim().toLowerCase();

                  final cocokPencarian = kataKunci.isEmpty ||
                      namaPasien.toLowerCase().contains(kataKunci) ||
                      poli.toLowerCase().contains(kataKunci) ||
                      dokter.toLowerCase().contains(kataKunci) ||
                      tanggal.toLowerCase().contains(kataKunci) ||
                      jam.toLowerCase().contains(kataKunci) ||
                      keluhan.toLowerCase().contains(kataKunci) ||
                      status.toLowerCase().contains(kataKunci);

                  final cocokStatus = _filterStatus == 'Semua' ||
                      status.toLowerCase() == _filterStatus.toLowerCase();

                  return cocokPencarian && cocokStatus;
                }).toList();

                if (daftarKonsultasi.isEmpty) {
                  return _buildPesan(
                    icon: Icons.search_off,
                    judul: 'Konsultasi Tidak Ditemukan',
                    deskripsi:
                        'Coba kata kunci lain atau ubah filter status '
                        'yang sedang dipilih.',
                    warna: Colors.orange,
                    tombol: true,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: daftarKonsultasi.length,
                  itemBuilder: (context, index) {
                    final dokumen = daftarKonsultasi[index];
                    final data = dokumen.data() as Map<String, dynamic>;

                    final documentId = dokumen.id;
                    final namaPasien =
                        (data['namaPasien'] ?? 'Pasien').toString();
                    final poli = (data['poli'] ?? 'Poli').toString();
                    final dokter = (data['dokter'] ?? 'Dokter').toString();
                    final tanggal = (data['tanggal'] ?? '-').toString();
                    final jam = (data['jam'] ?? '-').toString();
                    final keluhan = (data['keluhan'] ?? '-').toString();
                    final status = (data['status'] ?? 'Menunggu').toString();

                    return _buildKartuKonsultasi(
                      documentId: documentId,
                      namaPasien: namaPasien,
                      poli: poli,
                      dokter: dokter,
                      tanggal: tanggal,
                      jam: jam,
                      keluhan: keluhan,
                      status: status,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // HEADER DAN KOLOM PENCARIAN
  // ==========================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      decoration: const BoxDecoration(
        color: Color(0xff1769AA),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(26),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Riwayat Medis Anda',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Pantau jadwal dan status konsultasi Anda.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.medical_information_outlined,
                color: Colors.white,
                size: 42,
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: (value) {
              setState(() {
                _kataKunci = value;
              });
            },
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Cari poli, dokter, keluhan...',
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xff1769AA),
              ),
              suffixIcon: _kataKunci.isNotEmpty
                  ? IconButton(
                      tooltip: 'Hapus pencarian',
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _kataKunci = '';
                        });
                        _searchFocusNode.requestFocus();
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xffB8DFFF),
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FILTER STATUS
  // ==========================================================

  Widget _buildFilterStatus() {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: _daftarFilter.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = _daftarFilter[index];
          final terpilih = _filterStatus == status;

          return ChoiceChip(
            label: Text(status),
            selected: terpilih,
            showCheckmark: false,
            onSelected: (_) {
              setState(() {
                _filterStatus = status;
              });
            },
            backgroundColor: Colors.white,
            selectedColor: const Color(0xff1769AA),
            side: BorderSide(
              color: terpilih
                  ? const Color(0xff1769AA)
                  : Colors.grey.shade300,
            ),
            labelStyle: TextStyle(
              color: terpilih ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }

  // ==========================================================
  // KARTU KONSULTASI
  // ==========================================================

  Widget _buildKartuKonsultasi({
    required String documentId,
    required String namaPasien,
    required String poli,
    required String dokter,
    required String tanggal,
    required String jam,
    required String keluhan,
    required String status,
  }) {
    final warnaStatus = _warnaStatus(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      elevation: 2,
      shadowColor: const Color(0xff1769AA).withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.blueGrey.withValues(alpha: 0.08),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailKonsultasiPage(
                documentId: documentId,
                namaPasien: namaPasien,
                dokter: dokter,
                poli: poli,
                tanggal: tanggal,
                jam: jam,
                keluhan: keluhan,
                status: status,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xffE4F2FF),
                          Color(0xffD2E8FF),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.medical_services_outlined,
                      color: Color(0xff1769AA),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          poli,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff183B56),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          dokter,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xff1769AA),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                    size: 25,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: warnaStatus.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _ikonStatus(status),
                      color: warnaStatus,
                      size: 17,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      status,
                      style: TextStyle(
                        color: warnaStatus,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 14),
              _buildBarisInfo(
                Icons.person_outline,
                'Nama pasien',
                namaPasien,
              ),
              const SizedBox(height: 12),
              _buildBarisInfo(
                Icons.calendar_month_outlined,
                'Tanggal',
                tanggal,
              ),
              const SizedBox(height: 12),
              _buildBarisInfo(
                Icons.access_time,
                'Jam konsultasi',
                jam,
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xffF5F9FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.notes,
                          color: Color(0xff1769AA),
                          size: 17,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'Keluhan',
                          style: TextStyle(
                            color: Color(0xff1769AA),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      keluhan,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: Color(0xff394B59),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Lihat detail',
                      style: TextStyle(
                        color: Color(0xff1769AA),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 5),
                    Icon(
                      Icons.arrow_forward,
                      color: Color(0xff1769AA),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // BARIS INFORMASI
  // ==========================================================

  Widget _buildBarisInfo(
    IconData icon,
    String label,
    String nilai,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.blueGrey,
          size: 19,
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 105,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.blueGrey,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            nilai,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Color(0xff263746),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // PESAN KOSONG DAN ERROR
  // ==========================================================

  Widget _buildPesan({
    required IconData icon,
    required String judul,
    required String deskripsi,
    required Color warna,
    bool tombol = false,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: warna.withValues(alpha: 0.09),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 52,
                color: warna,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              judul,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xff183B56),
              ),
            ),
            const SizedBox(height: 9),
            Text(
              deskripsi,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Colors.blueGrey,
              ),
            ),
            if (tombol) ...[
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _kataKunci = '';
                    _filterStatus = 'Semua';
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reset pencarian'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // WARNA STATUS
  // ==========================================================

  Color _warnaStatus(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return const Color(0xff1976D2);
      case 'dijadwalkan':
        return const Color(0xffEF8C00);
      case 'selesai':
        return const Color(0xff218838);
      case 'dibatalkan':
        return const Color(0xffD32F2F);
      default:
        return Colors.blueGrey;
    }
  }

  // ==========================================================
  // IKON STATUS
  // ==========================================================

  IconData _ikonStatus(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return Icons.schedule;
      case 'dijadwalkan':
        return Icons.event_available;
      case 'selesai':
        return Icons.check_circle_outline;
      case 'dibatalkan':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }
}
