
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/antrean_service.dart';

class AdminAntreanPage extends StatefulWidget {
  const AdminAntreanPage({super.key});

  @override
  State<AdminAntreanPage> createState() => _AdminAntreanPageState();
}

class _AdminAntreanPageState extends State<AdminAntreanPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _kataKunci = '';
  String _filterStatus = 'Semua';

  final List<String> _pilihanStatus = [
    'Semua',
    'Menunggu',
    'Dipanggil',
    'Selesai',
    'Dibatalkan',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // ============================================================
  // MEMERIKSA DATA SESUAI PENCARIAN
  // ============================================================

  bool _cocokDenganPencarian(Map<String, dynamic> data) {
    final nomorAntrean =
        (data['nomorAntrean'] ?? '-').toString().toLowerCase();

    final namaPoli = (data['namaPoli'] ?? '-').toString().toLowerCase();

    final dokter = (data['dokter'] ?? '-').toString().toLowerCase();

    final status = (data['status'] ?? 'Menunggu').toString();

    final cocokKataKunci = nomorAntrean.contains(_kataKunci) ||
        namaPoli.contains(_kataKunci) ||
        dokter.contains(_kataKunci) ||
        status.toLowerCase().contains(_kataKunci);

    final cocokStatus =
        _filterStatus == 'Semua' || status == _filterStatus;

    return cocokKataKunci && cocokStatus;
  }

  // ============================================================
  // MEMBANGUN HALAMAN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),

      appBar: AppBar(
        title: const Text(
          'Kelola Antrean',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: Column(
        children: [
          // ======================================================
          // BAGIAN PENCARIAN DAN FILTER
          // ======================================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cari Antrean Pasien',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // Kolom pencarian
                TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,

                  onChanged: (value) {
                    setState(() {
                      _kataKunci = value.trim().toLowerCase();
                    });
                  },

                  decoration: InputDecoration(
                    hintText: 'Nomor antrean, poli, atau dokter...',
                    hintStyle: TextStyle(color: Colors.grey.shade600),

                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.blue,
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

                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 15,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Colors.lightBlueAccent,
                        width: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                const Text(
                  'Filter berdasarkan status',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                // Filter status yang dapat digeser secara horizontal
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,

                  child: Row(
                    children: _pilihanStatus.map((status) {
                      final terpilih = _filterStatus == status;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),

                        child: ChoiceChip(
                          label: Text(status),
                          selected: terpilih,

                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _filterStatus = status;
                              });
                            }
                          },

                          selectedColor: Colors.white,
                          backgroundColor: Colors.blue.shade400,

                          labelStyle: TextStyle(
                            color: terpilih
                                ? Colors.blue.shade800
                                : Colors.white,
                            fontWeight: FontWeight.w600,
                          ),

                          side: BorderSide(
                            color: terpilih
                                ? Colors.white
                                : Colors.blue.shade300,
                          ),

                          showCheckmark: false,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // ======================================================
          // DAFTAR ANTREAN REAL-TIME
          // ======================================================

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('antrean')
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Terjadi kesalahan:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState(
                    icon: Icons.queue_outlined,
                    judul: 'Belum ada antrean',
                    deskripsi: 'Antrean pasien akan muncul di sini.',
                  );
                }

                final semuaDocs = snapshot.data!.docs;

                // Terapkan pencarian dan filter pada data Firestore
                final docs = semuaDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _cocokDenganPencarian(data);
                }).toList();

                if (docs.isEmpty) {
                  return _buildEmptyState(
                    icon: Icons.search_off,
                    judul: 'Antrean tidak ditemukan',
                    deskripsi:
                        'Coba kata kunci lain atau ubah filter status.',
                  );
                }

                return Column(
                  children: [
                    // Informasi jumlah antrean
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),

                      child: Row(
                        children: [
                          const Icon(
                            Icons.queue,
                            color: Colors.blue,
                            size: 21,
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              '${docs.length} antrean ditemukan',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Daftar kartu antrean
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: docs.length,

                        itemBuilder: (context, index) {
                          final doc = docs[index];

                          final data =
                              doc.data() as Map<String, dynamic>;

                          final nomorAntrean =
                              (data['nomorAntrean'] ?? '-').toString();

                          final namaPoli =
                              (data['namaPoli'] ?? '-').toString();

                          final dokter =
                              (data['dokter'] ?? '-').toString();

                          final status =
                              (data['status'] ?? 'Menunggu').toString();

                          return Card(
                            margin: const EdgeInsets.only(bottom: 15),
                            elevation: 2,

                            color: Colors.white,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: BorderSide(
                                color: Colors.blue.shade50,
                              ),
                            ),

                            child: Padding(
                              padding: const EdgeInsets.all(18),

                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,

                                children: [
                                  // Nomor antrean dan status
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Expanded(
                                        child: Text(
                                          nomorAntrean,
                                          style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 8),

                                      _buildStatus(status),
                                    ],
                                  ),

                                  const Divider(height: 26),

                                  // Informasi poli
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.local_hospital,
                                        color: Colors.blue,
                                        size: 22,
                                      ),

                                      const SizedBox(width: 10),

                                      Expanded(
                                        child: Text(
                                          namaPoli,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  // Informasi dokter
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person_outline,
                                        color: Colors.grey,
                                        size: 22,
                                      ),

                                      const SizedBox(width: 10),

                                      Expanded(
                                        child: Text(
                                          dokter,
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 18),

                                  // Tombol aksi tetap dipertahankan
                                  _buildActionButton(
                                    context,
                                    doc.id,
                                    status,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAMPILAN KETIKA DATA KOSONG
  // ============================================================

  Widget _buildEmptyState({
    required IconData icon,
    required String judul,
    required String deskripsi,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 70,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 15),

            Text(
              judul,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              deskripsi,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TAMPILAN STATUS
  // ============================================================

  Widget _buildStatus(String status) {
    Color warna;
    IconData icon;

    switch (status) {
      case 'Dipanggil':
        warna = Colors.orange;
        icon = Icons.volume_up;
        break;

      case 'Selesai':
        warna = Colors.green;
        icon = Icons.check_circle;
        break;

      case 'Dibatalkan':
        warna = Colors.red;
        icon = Icons.cancel;
        break;

      default:
        warna = Colors.blue;
        icon = Icons.access_time;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),

      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(icon, size: 16, color: warna),

          const SizedBox(width: 5),

          Text(
            status,
            style: TextStyle(
              color: warna,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOMBOL AKSI ANTREAN
  // ============================================================

  Widget _buildActionButton(
    BuildContext context,
    String documentId,
    String status,
  ) {
    // Menunggu -> Panggil
    if (status == 'Menunggu') {
      return SizedBox(
        width: double.infinity,

        child: ElevatedButton.icon(
          onPressed: () async {
            try {
              await AntreanService.panggilAntrean(documentId);

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Antrean berhasil dipanggil.'),
                ),
              );
            } catch (e) {
              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal memanggil antrean: $e'),
                ),
              );
            }
          },

          icon: const Icon(Icons.volume_up),
          label: const Text('Panggil Antrean'),

          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      );
    }

    // Dipanggil -> Selesaikan
    if (status == 'Dipanggil') {
      return SizedBox(
        width: double.infinity,

        child: ElevatedButton.icon(
          onPressed: () async {
            try {
              await AntreanService.selesaikanAntrean(documentId);

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Antrean berhasil diselesaikan.'),
                ),
              );
            } catch (e) {
              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal menyelesaikan antrean: $e'),
                ),
              );
            }
          },

          icon: const Icon(Icons.check),
          label: const Text('Selesaikan Antrean'),

          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      );
    }

    // Selesai atau dibatalkan
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.center,

      child: Text(
        status == 'Selesai'
            ? 'Antrean selesai dilayani'
            : status == 'Dibatalkan'
                ? 'Antrean dibatalkan'
                : 'Tidak ada aksi tersedia',

        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}