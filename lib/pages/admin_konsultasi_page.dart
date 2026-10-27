
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/konsultasi_service.dart';

class AdminKonsultasiPage extends StatefulWidget {
  const AdminKonsultasiPage({super.key});

  @override
  State<AdminKonsultasiPage> createState() =>
      _AdminKonsultasiPageState();
}

class _AdminKonsultasiPageState extends State<AdminKonsultasiPage> {
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
    return Scaffold(
      backgroundColor: const Color(0xffF5F9FF),
      appBar: AppBar(
        title: const Text(
          'Kelola Konsultasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xff1769AA),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      // Pencarian dan filter berada di luar StreamBuilder.
      body: Column(
        children: [
          _buildHeader(),
          _buildFilterStatus(),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('konsultasi')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xff1769AA),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return _buildPesan(
                    icon: Icons.error_outline,
                    judul: 'Gagal Memuat Konsultasi',
                    deskripsi:
                        'Terjadi kesalahan saat mengambil data.\n'
                        '${snapshot.error}',
                    warna: Colors.red,
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return _buildPesan(
                    icon: Icons.calendar_today_outlined,
                    judul: 'Belum Ada Konsultasi',
                    deskripsi:
                        'Belum ada pasien yang membuat konsultasi.',
                    warna: const Color(0xff1769AA),
                  );
                }

                final daftarDokumen = snapshot.data!.docs;
                final kataKunci = _kataKunci.trim().toLowerCase();

                // Pencarian dan filter data.
                final daftarKonsultasi = daftarDokumen.where((doc) {
                  final data =
                      doc.data() as Map<String, dynamic>;

                  final namaPasien =
                      (data['namaPasien'] ?? 'Pasien').toString();
                  final poli = (data['poli'] ?? '-').toString();
                  final dokter = (data['dokter'] ?? '-').toString();
                  final tanggal = (data['tanggal'] ?? '-').toString();
                  final jam = (data['jam'] ?? '-').toString();
                  final keluhan = (data['keluhan'] ?? '-').toString();
                  final status =
                      (data['status'] ?? 'Menunggu').toString();

                  final cocokPencarian = kataKunci.isEmpty ||
                      namaPasien.toLowerCase().contains(kataKunci) ||
                      poli.toLowerCase().contains(kataKunci) ||
                      dokter.toLowerCase().contains(kataKunci) ||
                      tanggal.toLowerCase().contains(kataKunci) ||
                      jam.toLowerCase().contains(kataKunci) ||
                      keluhan.toLowerCase().contains(kataKunci) ||
                      status.toLowerCase().contains(kataKunci);

                  final cocokStatus = _filterStatus == 'Semua' ||
                      status.toLowerCase() ==
                          _filterStatus.toLowerCase();

                  return cocokPencarian && cocokStatus;
                }).toList();

                if (daftarKonsultasi.isEmpty) {
                  return _buildPesan(
                    icon: Icons.search_off,
                    judul: 'Konsultasi Tidak Ditemukan',
                    deskripsi:
                        'Coba kata kunci lain atau ubah filter status.',
                    warna: Colors.orange,
                    tampilkanReset: true,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: daftarKonsultasi.length,
                  itemBuilder: (context, index) {
                    final document = daftarKonsultasi[index];
                    final data =
                        document.data() as Map<String, dynamic>;

                    final namaPasien =
                        (data['namaPasien'] ?? 'Pasien').toString();
                    final poli = (data['poli'] ?? '-').toString();
                    final dokter = (data['dokter'] ?? '-').toString();
                    final tanggal = (data['tanggal'] ?? '-').toString();
                    final jam = (data['jam'] ?? '-').toString();
                    final keluhan = (data['keluhan'] ?? '-').toString();
                    final status =
                        (data['status'] ?? 'Menunggu').toString();

                    return _buildKartuKonsultasi(
                      documentId: document.id,
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
  // HEADER DAN PENCARIAN
  // ==========================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: const BoxDecoration(
        color: Color(0xff1769AA),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
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
                      'Manajemen Konsultasi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Cari dan kelola permintaan konsultasi pasien.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.medical_information_outlined,
                size: 42,
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 18),
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
              hintText: 'Cari pasien, poli, dokter, status...',
              hintStyle: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
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
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
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
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 13,
      ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            labelStyle: TextStyle(
              color: terpilih ? Colors.white : Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w600,
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
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      color: Colors.white,
      shadowColor:
          const Color(0xff1769AA).withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: Colors.blueGrey.withValues(alpha: 0.08),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color(0xffE5F1FF),
                  child: const Icon(
                    Icons.person_outline,
                    color: Color(0xff1769AA),
                    size: 27,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    namaPasien,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff183B56),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 13),

            // Status konsultasi.
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: warnaStatus.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _ikonStatus(status),
                    size: 16,
                    color: warnaStatus,
                  ),
                  const SizedBox(width: 6),
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
            const SizedBox(height: 15),

            _buildInfoRow(
              Icons.local_hospital_outlined,
              'Poli',
              poli,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.medical_services_outlined,
              'Dokter',
              dokter,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.calendar_today_outlined,
              'Tanggal',
              tanggal,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.access_time,
              'Jam',
              jam,
            ),
            const SizedBox(height: 15),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xffF5F9FF),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 17,
                        color: Color(0xff1769AA),
                      ),
                      SizedBox(width: 7),
                      Text(
                        'Keluhan Pasien',
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
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Tombol Jadwalkan dan Batalkan.
            if (status == 'Menunggu') ...[
              const SizedBox(height: 17),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _ubahStatus(
                          context,
                          documentId,
                          'Dijadwalkan',
                        );
                      },
                      icon: const Icon(
                        Icons.event_available,
                        size: 18,
                      ),
                      label: const Text('Jadwalkan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1769AA),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _ubahStatus(
                          context,
                          documentId,
                          'Dibatalkan',
                        );
                      },
                      icon: const Icon(
                        Icons.cancel_outlined,
                        size: 18,
                      ),
                      label: const Text('Batalkan'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Tombol Tandai Selesai.
            if (status == 'Dijadwalkan') ...[
              const SizedBox(height: 17),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _ubahStatus(
                      context,
                      documentId,
                      'Selesai',
                    );
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Tandai Selesai'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // BARIS INFORMASI
  // ==========================================================

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 19,
          color: const Color(0xff1769AA),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 65,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.blueGrey,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xff263746),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // TAMPILAN KOSONG ATAU ERROR
  // ==========================================================

  Widget _buildPesan({
    required IconData icon,
    required String judul,
    required String deskripsi,
    required Color warna,
    bool tampilkanReset = false,
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
                color: warna.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 52, color: warna),
            ),
            const SizedBox(height: 18),
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
                color: Colors.blueGrey,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            if (tampilkanReset) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _resetPencarian,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset pencarian'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _resetPencarian() {
    _searchController.clear();
    setState(() {
      _kataKunci = '';
      _filterStatus = 'Semua';
    });
  }

  // ==========================================================
  // WARNA STATUS
  // ==========================================================

  Color _warnaStatus(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return Colors.orange.shade800;
      case 'dijadwalkan':
        return const Color(0xff1769AA);
      case 'selesai':
        return Colors.green.shade700;
      case 'dibatalkan':
        return Colors.red.shade700;
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

  // ==========================================================
  // UBAH STATUS KONSULTASI
  // ==========================================================

  static Future<void> _ubahStatus(
    BuildContext context,
    String documentId,
    String statusBaru,
  ) async {
    final bool? konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            statusBaru == 'Dijadwalkan'
                ? 'Jadwalkan Konsultasi?'
                : statusBaru == 'Selesai'
                    ? 'Tandai Selesai?'
                    : 'Batalkan Konsultasi?',
          ),
          content: Text(
            statusBaru == 'Dijadwalkan'
                ? 'Apakah kamu yakin ingin menjadwalkan konsultasi ini?'
                : statusBaru == 'Selesai'
                    ? 'Apakah kamu yakin konsultasi ini sudah selesai?'
                    : 'Apakah kamu yakin ingin membatalkan konsultasi ini?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Tidak'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );

    if (konfirmasi != true) return;

    try {
      await KonsultasiService.updateStatusKonsultasi(
        documentId: documentId,
        status: statusBaru,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status berhasil diubah menjadi $statusBaru'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}