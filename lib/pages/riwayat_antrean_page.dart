import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/antrean_service.dart';
import '../services/notification_service.dart';
import '../widgets/status_badge.dart';
import 'penilaian_layanan_page.dart';

class RiwayatAntreanPage extends StatefulWidget {
  const RiwayatAntreanPage({super.key});

  @override
  State<RiwayatAntreanPage> createState() =>
      _RiwayatAntreanPageState();
}

class _RiwayatAntreanPageState
    extends State<RiwayatAntreanPage> {
  final Map<String, String> _statusSebelumnya = {};
  final Set<String> _notifikasiSudahDikirim = {};

  bool _sedangMemeriksaStatus = false;

  // Dibuat sekali dan dipertahankan selama halaman aktif.
  final TextEditingController _searchController =
      TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  String _kataKunci = '';
  String _filterStatus = 'Semua';

  final List<String> _daftarFilter = [
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
  // NOTIFIKASI PERUBAHAN STATUS
  // ============================================================

  Future<void> _cekPerubahanStatus(
    List<QueryDocumentSnapshot> documents,
  ) async {
    if (_sedangMemeriksaStatus) return;

    _sedangMemeriksaStatus = true;

    try {
      for (final document in documents) {
        final Map<String, dynamic> antrean =
            document.data() as Map<String, dynamic>;

        final String statusSekarang =
            antrean['status']?.toString() ?? 'Menunggu';

        final String? statusLama =
            _statusSebelumnya[document.id];

        if (statusLama == null) {
          _statusSebelumnya[document.id] = statusSekarang;
          continue;
        }

        if (statusLama != 'Dipanggil' &&
            statusSekarang == 'Dipanggil' &&
            !_notifikasiSudahDikirim.contains(document.id)) {
          _notifikasiSudahDikirim.add(document.id);

          await NotificationService
              .tampilkanNotifikasiGiliranAnda(
            nomorAntrean:
                antrean['nomorAntrean']?.toString() ?? '-',
            namaPoli:
                antrean['namaPoli']?.toString() ?? '-',
            dokter:
                antrean['dokter']?.toString() ?? '-',
          );
        }

        _statusSebelumnya[document.id] = statusSekarang;
      }
    } catch (e) {
      debugPrint('Gagal memeriksa status antrean: $e');
    } finally {
      _sedangMemeriksaStatus = false;
    }
  }

  // ============================================================
  // PENILAIAN LAYANAN
  // ============================================================

  Future<void> _bukaPenilaian({
    required String idAntrean,
    required String namaPoli,
    required String dokter,
  }) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;
      _tampilkanPesan('Silakan login terlebih dahulu.');
      return;
    }

    try {
      final antreanDoc = await FirebaseFirestore.instance
          .collection('antrean')
          .doc(idAntrean)
          .get();

      if (!mounted) return;

      if (!antreanDoc.exists) {
        _tampilkanPesan('Data antrean tidak ditemukan.');
        return;
      }

      final dataAntrean = antreanDoc.data()!;

      if (dataAntrean['uid'] != user.uid) {
        _tampilkanPesan(
          'Anda tidak memiliki akses ke antrean ini.',
        );
        return;
      }

      if (dataAntrean['status'] != 'Selesai') {
        _tampilkanPesan(
          'Penilaian hanya tersedia setelah pelayanan selesai.',
        );
        return;
      }

      final penilaianDoc = await FirebaseFirestore.instance
          .collection('penilaian_layanan')
          .doc(idAntrean)
          .get();

      if (!mounted) return;

      if (penilaianDoc.exists) {
        _tampilkanPesan('Antrean ini sudah Anda nilai.');
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PenilaianLayananPage(
            idAntrean: idAntrean,
            namaPoli: namaPoli,
            dokter: dokter,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      _tampilkanPesan('Gagal membuka penilaian: $e');
    }
  }

  void _tampilkanPesan(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan)),
    );
  }

  Widget _buildTombolPenilaian({
    required String idAntrean,
    required String namaPoli,
    required String dokter,
    required String status,
  }) {
    if (status != 'Selesai') {
      return const SizedBox.shrink();
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('penilaian_layanan')
          .doc(idAntrean)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(top: 12),
            child: LinearProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Status penilaian tidak dapat dimuat.',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 12,
              ),
            ),
          );
        }

        if (snapshot.data?.exists ?? false) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.shade200,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Penilaian Terkirim',
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _bukaPenilaian(
                idAntrean: idAntrean,
                namaPoli: namaPoli,
                dokter: dokter,
              ),
              icon: const Icon(Icons.star_outline),
              label: const Text('Beri Penilaian'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // SEARCH BAR
  // ============================================================

  Widget _buildSearchBar() {
    return TextField(
      key: const ValueKey('search_riwayat_antrean'),
      controller: _searchController,
      focusNode: _searchFocusNode,
      textInputAction: TextInputAction.search,
      onChanged: (value) {
        // Perubahan kata kunci tidak membuat controller baru.
        setState(() {
          _kataKunci = value.toLowerCase();
        });
      },
      decoration: InputDecoration(
        hintText: 'Cari nomor, poli, atau dokter...',
        prefixIcon: const Icon(
          Icons.search,
          color: Color(0xFF0875BD),
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
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF0875BD),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FILTER STATUS
  // ============================================================

  Widget _buildFilterStatus() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _daftarFilter.map((filter) {
          final bool terpilih = _filterStatus == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: terpilih,
              showCheckmark: false,
              selectedColor: const Color(0xFF0875BD),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: terpilih
                    ? Colors.white
                    : Colors.black87,
                fontWeight: terpilih
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
              side: BorderSide(
                color: terpilih
                    ? const Color(0xFF0875BD)
                    : Colors.grey.shade300,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              onSelected: (_) {
                setState(() {
                  _filterStatus = filter;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // FILTER DATA
  // ============================================================

  bool _cocokDenganPencarian(
    Map<String, dynamic> antrean,
  ) {
    final String nomor =
        antrean['nomorAntrean']?.toString().toLowerCase() ?? '';

    final String namaPoli =
        antrean['namaPoli']?.toString().toLowerCase() ?? '';

    final String dokter =
        antrean['dokter']?.toString().toLowerCase() ?? '';

    final String status =
        antrean['status']?.toString() ?? 'Menunggu';

    final String kataKunci = _kataKunci.trim();

    final bool cocokKataKunci = kataKunci.isEmpty ||
        nomor.contains(kataKunci) ||
        namaPoli.contains(kataKunci) ||
        dokter.contains(kataKunci);

    final bool cocokStatus =
        _filterStatus == 'Semua' ||
        status == _filterStatus;

    return cocokKataKunci && cocokStatus;
  }

  // ============================================================
  // TAMPILAN KOSONG
  // ============================================================

  Widget _buildKosong({
    required IconData icon,
    required String judul,
    required String deskripsi,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 72,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 18),
            Text(
              judul,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              deskripsi,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Riwayat Antrean'),
        ),
        body: const Center(
          child: Text('Silakan login terlebih dahulu.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FC),
      appBar: AppBar(
        title: const Text(
          'Riwayat Antrean',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF4F8FC),
      ),
      body: Column(
        children: [
          // Search dan filter berada di luar StreamBuilder.
          // Perubahan data Firestore tidak mengganti widget
          // pencarian yang sedang menerima input.
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16, 16, 16, 8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                const SizedBox(height: 14),
                _buildFilterStatus(),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: AntreanService
                  .riwayatAntreanPasien(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                        ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return _buildKosong(
                    icon: Icons.error_outline,
                    judul: 'Gagal Memuat Riwayat',
                    deskripsi:
                        'Terjadi kesalahan saat mengambil data antrean.',
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return _buildKosong(
                    icon: Icons.history,
                    judul: 'Belum Ada Riwayat Antrean',
                    deskripsi:
                        'Antrean yang pernah Anda ambil akan muncul '
                        'di halaman ini.',
                  );
                }

                final List<QueryDocumentSnapshot> daftarRiwayat =
                    snapshot.data!.docs;

                // Periksa status setelah frame selesai.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _cekPerubahanStatus(daftarRiwayat);
                  }
                });

                final List<QueryDocumentSnapshot> hasilFilter =
                    daftarRiwayat.where((document) {
                  final data =
                      document.data() as Map<String, dynamic>;

                  return _cocokDenganPencarian(data);
                }).toList();

                if (hasilFilter.isEmpty) {
                  return _buildKosong(
                    icon: Icons.search_off,
                    judul: 'Data Tidak Ditemukan',
                    deskripsi:
                        'Coba kata kunci lain atau ubah filter status.',
                  );
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        18, 4, 18, 10,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${hasilFilter.length} riwayat ditemukan',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          16, 0, 16, 20,
                        ),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: hasilFilter.length,
                        itemBuilder: (context, index) {
                          final document = hasilFilter[index];

                          final Map<String, dynamic> antrean =
                              document.data()
                                  as Map<String, dynamic>;

                          return _buildRiwayatCard(
                            idAntrean: document.id,
                            antrean: antrean,
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
  // KARTU RIWAYAT
  // ============================================================

  Widget _buildRiwayatCard({
    required String idAntrean,
    required Map<String, dynamic> antrean,
  }) {
    final String nomor =
        antrean['nomorAntrean']?.toString() ?? '-';

    final String namaPoli =
        antrean['namaPoli']?.toString() ?? '-';

    final String dokter =
        antrean['dokter']?.toString() ?? '-';

    final String status =
        antrean['status']?.toString() ?? 'Menunggu';

    String waktu = 'Waktu tidak tersedia';

    final dynamic waktuAmbil = antrean['waktuAmbil'];

    if (waktuAmbil is Timestamp) {
      final DateTime tanggal = waktuAmbil.toDate();

      waktu =
          '${tanggal.day.toString().padLeft(2, '0')}/'
          '${tanggal.month.toString().padLeft(2, '0')}/'
          '${tanggal.year} '
          '${tanggal.hour.toString().padLeft(2, '0')}:'
          '${tanggal.minute.toString().padLeft(2, '0')}';
    }

    return Card(
      elevation: 2,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5F2FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.confirmation_number,
                    color: Color(0xFF0875BD),
                    size: 27,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        namaPoli,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dokter,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  nomor,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0875BD),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Divider(color: Colors.grey.shade200),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    waktu,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Status:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: status),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F8FC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _getKeteranganStatus(status),
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  height: 1.4,
                ),
              ),
            ),
            _buildTombolPenilaian(
              idAntrean: idAntrean,
              namaPoli: namaPoli,
              dokter: dokter,
              status: status,
            ),
          ],
        ),
      ),
    );
  }

  String _getKeteranganStatus(String status) {
    switch (status) {
      case 'Menunggu':
        return 'Antrean Anda sedang menunggu dipanggil oleh petugas.';
      case 'Dipanggil':
        return 'Nomor antrean Anda sedang dilayani oleh petugas.';
      case 'Selesai':
        return 'Antrean Anda telah selesai dilayani. '
            'Silakan berikan penilaian terhadap layanan klinik.';
      case 'Dibatalkan':
        return 'Antrean ini telah dibatalkan.';
      default:
        return 'Status antrean tidak diketahui.';
    }
  }
}