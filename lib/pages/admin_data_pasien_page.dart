import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ==========================================================
// ADMIN DATA PASIEN PAGE
// ==========================================================

class AdminDataPasienPage extends StatelessWidget {
  const AdminDataPasienPage({super.key});

  // ========================================================
  // BUILD
  // ========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ======================================================
      // APP BAR
      // ======================================================

      appBar: AppBar(
        title: const Text(
          'Data Pasien',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        backgroundColor: Colors.blue,

        foregroundColor: Colors.white,
      ),

      // ======================================================
      // BODY
      // ======================================================
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'pasien')
            .snapshots(),

        builder: (context, snapshot) {
          // ==================================================
          // LOADING
          // ==================================================

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ==================================================
          // ERROR
          // ==================================================

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Text(
                  'Terjadi kesalahan:\n'
                  '${snapshot.error}',

                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // ==================================================
          // DATA KOSONG
          // ==================================================

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Icon(Icons.people_outline, size: 70, color: Colors.grey),

                  SizedBox(height: 15),

                  Text(
                    'Belum ada data pasien',

                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Data pasien yang terdaftar '
                    'akan muncul di sini.',

                    textAlign: TextAlign.center,

                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // ==================================================
          // DATA PASIEN
          // ==================================================

          final List<QueryDocumentSnapshot> pasien = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),

            itemCount: pasien.length,

            itemBuilder: (context, index) {
              // ==============================================
              // MENGAMBIL DATA
              // ==============================================

              final QueryDocumentSnapshot document = pasien[index];

              final Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;

              final String nama = data['nama'] ?? 'Nama belum diisi';

              final String email = data['email'] ?? '-';

              final String jenisKelamin = data['jenisKelamin'] ?? '';

              // ==============================================
              // CARD PASIEN
              // ==============================================

              return Card(
                margin: const EdgeInsets.only(bottom: 15),

                elevation: 3,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),

                child: InkWell(
                  borderRadius: BorderRadius.circular(18),

                  onTap: () {
                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (context) => DetailPasienPage(data: data),
                      ),
                    );
                  },

                  child: Padding(
                    padding: const EdgeInsets.all(18),

                    child: Row(
                      children: [
                        // ====================================
                        // FOTO / ICON PASIEN
                        // ====================================

                        Container(
                          width: 55,

                          height: 55,

                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),

                            borderRadius: BorderRadius.circular(15),
                          ),

                          child: const Icon(
                            Icons.person,

                            color: Colors.blue,

                            size: 30,
                          ),
                        ),

                        const SizedBox(width: 15),

                        // ====================================
                        // INFORMASI PASIEN
                        // ====================================
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                nama,

                                style: const TextStyle(
                                  fontSize: 17,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                email,

                                style: const TextStyle(
                                  color: Colors.grey,

                                  fontSize: 13,
                                ),
                              ),

                              if (jenisKelamin.isNotEmpty) ...[
                                const SizedBox(height: 4),

                                Text(
                                  jenisKelamin,

                                  style: const TextStyle(
                                    color: Colors.grey,

                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // ====================================
                        // ARROW
                        // ====================================
                        const Icon(
                          Icons.arrow_forward_ios,

                          size: 18,

                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ==========================================================
// DETAIL PASIEN PAGE
// ==========================================================

class DetailPasienPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const DetailPasienPage({super.key, required this.data});

  // ========================================================
  // BUILD
  // ========================================================

  @override
  Widget build(BuildContext context) {
    final String nama = data['nama'] ?? '-';

    final String email = data['email'] ?? '-';

    final String jenisKelamin = data['jenisKelamin'] ?? '-';

    final String tempatLahir = data['tempatLahir'] ?? '-';

    final String tanggalLahir = data['tanggalLahir'] ?? '-';

    final String golonganDarah = data['golonganDarah'] ?? '-';

    final String nomorTelepon = data['nomorTelepon'] ?? '-';

    final String alamat = data['alamat'] ?? '-';

    return Scaffold(
      // ======================================================
      // APP BAR
      // ======================================================

      appBar: AppBar(
        title: const Text(
          'Detail Pasien',

          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        backgroundColor: Colors.blue,

        foregroundColor: Colors.white,
      ),

      // ======================================================
      // BODY
      // ======================================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // ==================================================
            // HEADER PASIEN
            // ==================================================

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.blue,

                borderRadius: BorderRadius.circular(20),
              ),

              child: Column(
                children: [
                  // ==========================================
                  // ICON
                  // ==========================================

                  Container(
                    width: 80,

                    height: 80,

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(40),
                    ),

                    child: const Icon(
                      Icons.person,

                      size: 45,

                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ==========================================
                  // NAMA
                  // ==========================================
                  Text(
                    nama,

                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      color: Colors.white,

                      fontSize: 21,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // ==========================================
                  // EMAIL
                  // ==========================================
                  Text(
                    email,

                    textAlign: TextAlign.center,

                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // INFORMASI PRIBADI
            // ==================================================
            _buildSectionTitle('Informasi Pribadi'),

            const SizedBox(height: 10),

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

            // ==================================================
            // KONTAK
            // ==================================================
            _buildSectionTitle('Informasi Kontak'),

            const SizedBox(height: 10),

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

  // ==========================================================
  // JUDUL SECTION
  // ==========================================================

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,

      child: Text(
        title,

        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ==========================================================
  // INFO CARD
  // ==========================================================

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
          // ================================================
          // ICON
          // ================================================

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

          // ================================================
          // TEXT
          // ================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: const TextStyle(color: Colors.grey, fontSize: 12),
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
