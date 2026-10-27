
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ==========================================================
// ADMIN DATA PASIEN PAGE
// ==========================================================

class AdminDataPasienPage extends StatefulWidget {
  const AdminDataPasienPage({super.key});

  @override
  State<AdminDataPasienPage> createState() => _AdminDataPasienPageState();
}

class _AdminDataPasienPageState extends State<AdminDataPasienPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _kataKunci = '';
  String _filterJenisKelamin = 'Semua';

  final List<String> _pilihanJenisKelamin = [
    'Semua',
    'Laki-laki',
    'Perempuan',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // ==========================================================
  // FILTER DATA PASIEN
  // ==========================================================

  bool _cocokDenganPencarian(Map<String, dynamic> data) {
    final nama = (data['nama'] ?? '').toString().toLowerCase();
    final email = (data['email'] ?? '').toString().toLowerCase();
    final telepon =
        (data['nomorTelepon'] ?? '').toString().toLowerCase();
    final alamat = (data['alamat'] ?? '').toString().toLowerCase();
    final jenisKelamin =
        (data['jenisKelamin'] ?? '').toString().toLowerCase();

    final cocokKataKunci = nama.contains(_kataKunci) ||
        email.contains(_kataKunci) ||
        telepon.contains(_kataKunci) ||
        alamat.contains(_kataKunci);

    final filter = _filterJenisKelamin.toLowerCase();

    final cocokJenisKelamin = _filterJenisKelamin == 'Semua' ||
        jenisKelamin == filter;

    return cocokKataKunci && cocokJenisKelamin;
  }

  // ==========================================================
  // BUILD HALAMAN
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),

      appBar: AppBar(
        title: const Text(
          'Data Pasien',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: Column(
        children: [
          // ====================================================
          // HEADER DAN PENCARIAN
          // ====================================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),

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
                  'Kelola Data Pasien',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Cari dan lihat informasi pasien terdaftar.',
                  style: TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 16),

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
                    hintText: 'Cari nama, email, telepon, alamat...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),

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
                  'Jenis Kelamin',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                // Filter jenis kelamin
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,

                  child: Row(
                    children: _pilihanJenisKelamin.map((jenis) {
                      final terpilih = _filterJenisKelamin == jenis;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),

                        child: ChoiceChip(
                          label: Text(jenis),
                          selected: terpilih,

                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _filterJenisKelamin = jenis;
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

          // ====================================================
          // DAFTAR PASIEN DARI FIRESTORE
          // ====================================================

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'pasien')
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
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

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState(
                    icon: Icons.people_outline,
                    judul: 'Belum ada data pasien',
                    deskripsi:
                        'Data pasien yang terdaftar akan muncul di sini.',
                  );
                }

                final semuaPasien = snapshot.data!.docs;

                // Filter dilakukan di sisi aplikasi.
                // Controller pencarian tetap berada di luar StreamBuilder.
                final pasien = semuaPasien.where((document) {
                  final data =
                      document.data() as Map<String, dynamic>;

                  return _cocokDenganPencarian(data);
                }).toList();

                if (pasien.isEmpty) {
                  return _buildEmptyState(
                    icon: Icons.person_search,
                    judul: 'Pasien tidak ditemukan',
                    deskripsi:
                        'Coba kata kunci lain atau ubah filter jenis kelamin.',
                  );
                }

                return Column(
                  children: [
                    // Jumlah pasien
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        16,
                        20,
                        4,
                      ),

                      child: Row(
                        children: [
                          const Icon(
                            Icons.people_alt_outlined,
                            color: Colors.blue,
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              '${pasien.length} pasien ditemukan',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Daftar kartu pasien
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: pasien.length,

                        itemBuilder: (context, index) {
                          final document = pasien[index];

                          final Map<String, dynamic> data =
                              document.data()
                                  as Map<String, dynamic>;

                          final String nama =
                              (data['nama'] ?? 'Nama belum diisi')
                                  .toString();

                          final String email =
                              (data['email'] ?? '-').toString();

                          final String jenisKelamin =
                              (data['jenisKelamin'] ?? '').toString();

                          return Card(
                            margin: const EdgeInsets.only(bottom: 14),
                            elevation: 2,
                            color: Colors.white,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: BorderSide(
                                color: Colors.blue.shade50,
                              ),
                            ),

                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),

                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailPasienPage(data: data),
                                  ),
                                );
                              },

                              child: Padding(
                                padding: const EdgeInsets.all(16),

                                child: Row(
                                  children: [
                                    // Foto atau ikon pasien
                                    Container(
                                      width: 58,
                                      height: 58,

                                      decoration: BoxDecoration(
                                        color: Colors.blue.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),

                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.blue,
                                        size: 32,
                                      ),
                                    ),

                                    const SizedBox(width: 14),

                                    // Informasi pasien
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          Text(
                                            nama,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                          ),

                                          const SizedBox(height: 5),

                                          Text(
                                            email,
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 13,
                                            ),
                                          ),

                                          if (jenisKelamin.isNotEmpty) ...[
                                            const SizedBox(height: 5),

                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 9,
                                                vertical: 4,
                                              ),

                                              decoration: BoxDecoration(
                                                color: Colors.blue
                                                    .withValues(alpha: 0.08),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),

                                              child: Text(
                                                jenisKelamin,
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 11,
                                                  fontWeight:
                                                      FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
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

  // ==========================================================
  // TAMPILAN KETIKA DATA KOSONG
  // ==========================================================

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
}

// ==========================================================
// DETAIL PASIEN PAGE
// ==========================================================

class DetailPasienPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const DetailPasienPage({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final String nama = (data['nama'] ?? '-').toString();
    final String email = (data['email'] ?? '-').toString();
    final String jenisKelamin =
        (data['jenisKelamin'] ?? '-').toString();
    final String tempatLahir =
        (data['tempatLahir'] ?? '-').toString();
    final String tanggalLahir =
        (data['tanggalLahir'] ?? '-').toString();
    final String golonganDarah =
        (data['golonganDarah'] ?? '-').toString();
    final String nomorTelepon =
        (data['nomorTelepon'] ?? '-').toString();
    final String alamat = (data['alamat'] ?? '-').toString();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),

      appBar: AppBar(
        title: const Text(
          'Detail Pasien',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // Header pasien
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1976D2),
                    Color(0xFF42A5F5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),

              child: Column(
                children: [
                  Container(
                    width: 85,
                    height: 85,

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),

                    child: const Icon(
                      Icons.person,
                      size: 48,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    nama,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            _buildSectionTitle('Informasi Pribadi'),
            const SizedBox(height: 12),

            _buildInfoCard(
              icon: Icons.person_outline,
              title: 'Jenis Kelamin',
              value: jenisKelamin,
            ),

            _buildInfoCard(
              icon: Icons.location_city_outlined,
              title: 'Tempat Lahir',
              value: tempatLahir,
            ),

            _buildInfoCard(
              icon: Icons.calendar_today_outlined,
              title: 'Tanggal Lahir',
              value: tanggalLahir,
            ),

            _buildInfoCard(
              icon: Icons.bloodtype_outlined,
              title: 'Golongan Darah',
              value: golonganDarah,
            ),

            const SizedBox(height: 15),

            _buildSectionTitle('Informasi Kontak'),
            const SizedBox(height: 12),

            _buildInfoCard(
              icon: Icons.phone_outlined,
              title: 'Nomor Telepon',
              value: nomorTelepon,
            ),

            _buildInfoCard(
              icon: Icons.home_outlined,
              title: 'Alamat',
              value: alamat,
            ),
          ],
        ),
      ),
    );
  }

  // Judul bagian
  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,

      child: Text(
        title,
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Kartu informasi pasien
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),

        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,

            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(icon, color: Colors.blue),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}