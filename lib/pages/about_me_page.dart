import 'package:flutter/material.dart';

class AboutMePage extends StatelessWidget {
  const AboutMePage({super.key});

  @override
  Widget build(BuildContext context) {
    // ==========================================================
    // DATA ANGGOTA KELOMPOK 5
    // ==========================================================
    final List<Map<String, String>> anggotaKelompok = [
      {
        'nama': 'Purnama Riyan Suprapto',
        'nim': '25051204436',
      },
      {
       
      },
      {
        'nama': 'Reivandani Aji Prakoso',
        'nim': '25051204422',
      },
      {
        'nama': 'Maulana Halim',
        'nim': '25051204386',
 
      },
      {
        
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tentang Kelompok',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F9FF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header / Logo Aplikasi
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_hospital,
                size: 60,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Sistem Antrian Klinik',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Proyek Akhir / Tugas Besar',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),

            // Judul List Anggota
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Anggota Kelompok 5:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Looping untuk menampilkan 5 anggota
            ...anggotaKelompok.map((anggota) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
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
                  children: [
                    // Avatar Inisial
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        anggota['nama']!.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    
                    // Info Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            anggota['nama']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'NIM: ${anggota['nim']}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            anggota['peran']!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),
            
            // Footer
            const Text(
              'Dibuat untuk memenuhi tugas mata kuliah',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}