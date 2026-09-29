import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../services/database_service.dart';
import '../services/profile_photo_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // ==========================================================
  // CONTROLLER
  // ==========================================================

  final TextEditingController namaController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController tempatLahirController = TextEditingController();

  final TextEditingController nomorTeleponController = TextEditingController();

  final TextEditingController alamatController = TextEditingController();

  // ==========================================================
  // DATA PROFIL
  // ==========================================================

  String? jenisKelamin;

  String? golonganDarah;

  DateTime? tanggalLahir;

  // ==========================================================
  // FOTO PROFIL
  // ==========================================================

  final ImagePicker imagePicker = ImagePicker();

  Uint8List? fotoPreview;

  // ==========================================================
  // STATUS
  // ==========================================================

  bool isLoading = true;

  bool isSaving = false;

  // ==========================================================
  // INIT STATE
  // ==========================================================

  @override
  void initState() {
    super.initState();

    ambilDataUser();

    // Mengambil foto yang sebelumnya sudah dipilih
    fotoPreview = ProfilePhotoService.fotoProfil.value;
  }

  // ==========================================================
  // AMBIL DATA USER DARI FIRESTORE
  // ==========================================================

  Future<void> ambilDataUser() async {
    try {
      // Mengambil user yang sedang login
      final User? user = FirebaseAuth.instance.currentUser;

      // Jika tidak ada user
      if (user == null) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }

        return;
      }

      // Mengambil data user dari Firestore
      final document = await DatabaseService.ambilUser(user.uid);

      // ======================================================
      // JIKA DATA USER ADA
      // ======================================================

      if (document.exists) {
        final data = document.data() as Map<String, dynamic>;

        // ====================================================
        // NAMA
        // ====================================================

        namaController.text = data['nama'] ?? '';

        // ====================================================
        // EMAIL
        // ====================================================

        emailController.text = data['email'] ?? user.email ?? '';

        // ====================================================
        // TEMPAT LAHIR
        // ====================================================

        tempatLahirController.text = data['tempatLahir'] ?? '';

        // ====================================================
        // NOMOR TELEPON
        // ====================================================

        nomorTeleponController.text = data['nomorTelepon'] ?? '';

        // ====================================================
        // ALAMAT
        // ====================================================

        alamatController.text = data['alamat'] ?? '';

        // ====================================================
        // JENIS KELAMIN
        //
        // Jika Firestore berisi "",
        // maka dibuat null.
        //
        // Karena dropdown hanya menerima:
        // Laki-laki / Perempuan
        // ====================================================

        final String jenisKelaminData = data['jenisKelamin'] ?? '';

        if (jenisKelaminData == 'Laki-laki' ||
            jenisKelaminData == 'Perempuan') {
          jenisKelamin = jenisKelaminData;
        } else {
          jenisKelamin = null;
        }

        // ====================================================
        // GOLONGAN DARAH
        //
        // Jika Firestore berisi "",
        // maka dibuat null.
        // ====================================================

        final String golonganDarahData = data['golonganDarah'] ?? '';

        if (golonganDarahData == 'A' ||
            golonganDarahData == 'B' ||
            golonganDarahData == 'AB' ||
            golonganDarahData == 'O') {
          golonganDarah = golonganDarahData;
        } else {
          golonganDarah = null;
        }

        // ====================================================
        // TANGGAL LAHIR
        // ====================================================

        final String tanggal = data['tanggalLahir'] ?? '';

        if (tanggal.isNotEmpty) {
          tanggalLahir = DateTime.tryParse(tanggal);
        }
      }
      // ======================================================
      // JIKA DATA FIRESTORE BELUM ADA
      // ======================================================
      else {
        namaController.text = user.displayName ?? '';

        emailController.text = user.email ?? '';

        // Dropdown tetap null
        jenisKelamin = null;

        golonganDarah = null;
      }
    }
    // ========================================================
    // ERROR
    // ========================================================
    catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil data profil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    // ========================================================
    // SELESAI LOADING
    // ========================================================

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // ==========================================================
  // PILIH FOTO DARI GALERI
  // ==========================================================

  Future<void> pilihFoto() async {
    try {
      final XFile? foto = await imagePicker.pickImage(
        source: ImageSource.gallery,

        // Mengurangi ukuran foto
        imageQuality: 80,

        // Membatasi ukuran foto
        maxWidth: 1000,
        maxHeight: 1000,
      );

      // Jika user membatalkan pemilihan foto
      if (foto == null) {
        return;
      }

      // Membaca foto menjadi bytes
      final Uint8List bytes = await foto.readAsBytes();

      // Menampilkan preview
      setState(() {
        fotoPreview = bytes;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ==========================================================
  // PILIH TANGGAL LAHIR
  // ==========================================================

  Future<void> pilihTanggalLahir() async {
    final DateTime sekarang = DateTime.now();

    final DateTime? hasil = await showDatePicker(
      context: context,

      // Jika sudah memiliki tanggal,
      // gunakan tanggal tersebut.
      // Jika belum, gunakan 1 Januari 2000.
      initialDate: tanggalLahir ?? DateTime(2000, 1, 1),

      // Tanggal paling awal
      firstDate: DateTime(1940),

      // Tidak boleh memilih tanggal
      // yang belum terjadi.
      lastDate: sekarang,
    );

    // Jika user memilih tanggal
    if (hasil != null) {
      setState(() {
        tanggalLahir = hasil;
      });
    }
  }

  // ==========================================================
  // FORMAT TANGGAL UNTUK TAMPILAN
  // ==========================================================

  String formatTanggal(DateTime? tanggal) {
    // Jika belum memilih tanggal
    if (tanggal == null) {
      return 'Pilih tanggal lahir';
    }

    return '${tanggal.day.toString().padLeft(2, '0')}-'
        '${tanggal.month.toString().padLeft(2, '0')}-'
        '${tanggal.year}';
  }

  // ==========================================================
  // FORMAT TANGGAL UNTUK FIRESTORE
  // ==========================================================

  String tanggalUntukDatabase(DateTime tanggal) {
    return '${tanggal.year}-'
        '${tanggal.month.toString().padLeft(2, '0')}-'
        '${tanggal.day.toString().padLeft(2, '0')}';
  }

  // ==========================================================
  // SIMPAN PERUBAHAN
  // ==========================================================

  Future<void> simpanPerubahan() async {
    // ========================================================
    // VALIDASI NAMA
    // ========================================================

    if (namaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama tidak boleh kosong.'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    // ========================================================
    // AMBIL USER YANG LOGIN
    // ========================================================

    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User tidak ditemukan.'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    // ========================================================
    // AKTIFKAN LOADING
    // ========================================================

    setState(() {
      isSaving = true;
    });

    try {
      // ======================================================
      // SIMPAN FOTO PROFIL
      // ======================================================

      if (fotoPreview != null) {
        ProfilePhotoService.simpanFoto(fotoPreview!);
      }

      // ======================================================
      // UPDATE NAMA DI FIREBASE AUTHENTICATION
      // ======================================================

      await user.updateDisplayName(namaController.text.trim());

      // ======================================================
      // UPDATE DATA DI FIRESTORE
      // ======================================================

      await DatabaseService.updateUser(
        uid: user.uid,

        // Nama
        nama: namaController.text.trim(),

        // Jenis kelamin
        jenisKelamin: jenisKelamin ?? '',

        // Tempat lahir
        tempatLahir: tempatLahirController.text.trim(),

        // Tanggal lahir
        tanggalLahir: tanggalLahir == null
            ? ''
            : tanggalUntukDatabase(tanggalLahir!),

        // Golongan darah
        golonganDarah: golonganDarah ?? '',

        // Nomor telepon
        nomorTelepon: nomorTeleponController.text.trim(),

        // Alamat
        alamat: alamatController.text.trim(),
      );

      // ======================================================
      // CEK WIDGET MASIH ADA
      // ======================================================

      if (!mounted) {
        return;
      }

      // ======================================================
      // PESAN BERHASIL
      // ======================================================

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui.'),
          backgroundColor: Colors.green,
        ),
      );

      // Kembali ke About Me
      Navigator.pop(context);
    }
    // ========================================================
    // ERROR SAAT SIMPAN
    // ========================================================
    catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan profil: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    // ========================================================
    // MATIKAN LOADING
    // ========================================================

    if (mounted) {
      setState(() {
        isSaving = false;
      });
    }
  }

  // ==========================================================
  // WIDGET FOTO PROFIL
  // ==========================================================

  Widget buildFotoProfil() {
    // Jika user sudah memilih foto
    if (fotoPreview != null) {
      return CircleAvatar(
        radius: 55,

        backgroundColor: Colors.blue.shade100,

        backgroundImage: MemoryImage(fotoPreview!),
      );
    }

    // Jika belum memilih foto,
    // gunakan foto default.
    return const CircleAvatar(
      radius: 55,

      backgroundColor: Colors.blue,

      backgroundImage: AssetImage('assets/profile/profil.png'),
    );
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    namaController.dispose();

    emailController.dispose();

    tempatLahirController.dispose();

    nomorTeleponController.dispose();

    alamatController.dispose();

    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ======================================================
      // APP BAR
      // ======================================================

      appBar: AppBar(
        title: const Text(
          'Edit Profil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // ======================================================
      // BODY
      // ======================================================
      body: isLoading
          // ==================================================
          // LOADING
          // ==================================================
          ? const Center(child: CircularProgressIndicator())
          // ==================================================
          // FORM
          // ==================================================
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // ==================================================
                  // FOTO PROFIL
                  // ==================================================

                  Center(child: buildFotoProfil()),

                  const SizedBox(height: 15),

                  // ==================================================
                  // TOMBOL PILIH FOTO
                  // ==================================================
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: pilihFoto,

                      icon: const Icon(Icons.photo_library),

                      label: const Text('Pilih Foto dari Galeri'),

                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,

                        side: const BorderSide(color: Colors.blue),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ==================================================
                  // NAMA
                  // ==================================================
                  const Text(
                    'Nama Lengkap',

                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: namaController,

                    decoration: InputDecoration(
                      hintText: 'Masukkan nama lengkap',

                      prefixIcon: const Icon(Icons.person),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // EMAIL
                  // ==================================================
                  const Text(
                    'Email',

                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: emailController,

                    // Email tidak bisa diedit
                    readOnly: true,

                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email),

                      suffixIcon: const Icon(
                        Icons.lock_outline,
                        color: Colors.grey,
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),

                      filled: true,

                      fillColor: Colors.grey.shade100,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // JENIS KELAMIN
                  // ==================================================
                  const Text(
                    'Jenis Kelamin',

                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    initialValue: jenisKelamin,

                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.people),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    hint: const Text('Pilih jenis kelamin'),

                    items: const [
                      DropdownMenuItem<String>(
                        value: 'Laki-laki',

                        child: Text('Laki-laki'),
                      ),

                      DropdownMenuItem<String>(
                        value: 'Perempuan',

                        child: Text('Perempuan'),
                      ),
                    ],

                    onChanged: (String? value) {
                      setState(() {
                        jenisKelamin = value;
                      });
                    },
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // TEMPAT LAHIR
                  // ==================================================
                  const Text(
                    'Tempat Lahir',

                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: tempatLahirController,

                    decoration: InputDecoration(
                      hintText: 'Contoh: Surakarta',

                      prefixIcon: const Icon(Icons.location_city),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // TANGGAL LAHIR
                  // ==================================================
                  const Text(
                    'Tanggal Lahir',

                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  InkWell(
                    onTap: pilihTanggalLahir,

                    child: InputDecorator(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.calendar_month),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      child: Text(
                        formatTanggal(tanggalLahir),

                        style: TextStyle(
                          color: tanggalLahir == null
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // GOLONGAN DARAH
                  // ==================================================
                  const Text(
                    'Golongan Darah',

                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    initialValue: golonganDarah,

                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.bloodtype),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    hint: const Text('Pilih golongan darah'),

                    items: const [
                      DropdownMenuItem<String>(value: 'A', child: Text('A')),

                      DropdownMenuItem<String>(value: 'B', child: Text('B')),

                      DropdownMenuItem<String>(value: 'AB', child: Text('AB')),

                      DropdownMenuItem<String>(value: 'O', child: Text('O')),
                    ],

                    onChanged: (String? value) {
                      setState(() {
                        golonganDarah = value;
                      });
                    },
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // NOMOR TELEPON
                  // ==================================================
                  const Text(
                    'Nomor Telepon',

                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: nomorTeleponController,

                    keyboardType: TextInputType.phone,

                    decoration: InputDecoration(
                      hintText: 'Contoh: 081234567890',

                      prefixIcon: const Icon(Icons.phone),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // ALAMAT
                  // ==================================================
                  const Text(
                    'Alamat',

                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: alamatController,

                    maxLines: 3,

                    decoration: InputDecoration(
                      hintText: 'Masukkan alamat lengkap',

                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 45),

                        child: Icon(Icons.home),
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ==================================================
                  // TOMBOL SIMPAN
                  // ==================================================
                  SizedBox(
                    width: double.infinity,

                    height: 52,

                    child: ElevatedButton(
                      // Ketika sedang menyimpan,
                      // tombol dinonaktifkan.
                      onPressed: isSaving ? null : simpanPerubahan,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,

                        foregroundColor: Colors.white,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      child: isSaving
                          // ==============================
                          // LOADING
                          // ==============================
                          ? const SizedBox(
                              width: 24,

                              height: 24,

                              child: CircularProgressIndicator(
                                color: Colors.white,

                                strokeWidth: 2,
                              ),
                            )
                          // ==============================
                          // TEXT
                          // ==============================
                          : const Text(
                              'Simpan Perubahan',

                              style: TextStyle(
                                fontSize: 16,

                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ==================================================
                  // TOMBOL BATAL
                  // ==================================================
                  SizedBox(
                    width: double.infinity,

                    height: 52,

                    child: OutlinedButton(
                      onPressed: isSaving
                          ? null
                          : () {
                              Navigator.pop(context);
                            },

                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      child: const Text(
                        'Batal',

                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
