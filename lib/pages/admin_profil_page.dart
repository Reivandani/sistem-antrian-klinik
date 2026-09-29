import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../services/profile_photo_service.dart';

import 'login_page.dart';

// ==========================================================
// ADMIN PROFILE PAGE
// ==========================================================

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() =>
      _AdminProfilePageState();
}

// ==========================================================
// STATE ADMIN PROFILE PAGE
// ==========================================================

class _AdminProfilePageState
    extends State<AdminProfilePage> {

  // ========================================================
  // FIREBASE AUTH
  // ========================================================

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ========================================================
  // FIRESTORE
  // ========================================================

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ========================================================
  // IMAGE PICKER
  // ========================================================

  final ImagePicker _imagePicker =
      ImagePicker();

  // ========================================================
  // BUILD
  // ========================================================

  @override
  Widget build(BuildContext context) {

    // ======================================================
    // MENGAMBIL USER YANG SEDANG LOGIN
    // ======================================================

    final User? user =
        _auth.currentUser;

    // ======================================================
    // JIKA BELUM LOGIN
    // ======================================================

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Profil Petugas',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          backgroundColor:
              Colors.blue,

          foregroundColor:
              Colors.white,
        ),

        body: const Center(
          child: Text(
            'Silakan login terlebih dahulu.',
          ),
        ),
      );
    }

    // ======================================================
    // MENGAMBIL DATA PETUGAS DARI FIRESTORE
    // ======================================================

    return Scaffold(

      // ====================================================
      // APP BAR
      // ====================================================

      appBar: AppBar(
        title: const Text(
          'Profil Petugas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor:
            Colors.blue,

        foregroundColor:
            Colors.white,
      ),

      // ====================================================
      // BODY
      // ====================================================

      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection('users')
            .doc(user.uid)
            .snapshots(),

        builder: (
          context,
          snapshot,
        ) {

          // =================================================
          // LOADING
          // =================================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          // =================================================
          // ERROR
          // =================================================

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(20),

                child: Text(
                  'Terjadi kesalahan:\n'
                  '${snapshot.error}',

                  textAlign:
                      TextAlign.center,
                ),
              ),
            );
          }

          // =================================================
          // DATA TIDAK DITEMUKAN
          // =================================================

          if (!snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [

                  Icon(
                    Icons.person_off_outlined,
                    size: 70,
                    color: Colors.grey,
                  ),

                  SizedBox(height: 15),

                  Text(
                    'Data profil tidak ditemukan',

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Data petugas belum tersedia '
                    'di Firestore.',

                    textAlign:
                        TextAlign.center,

                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          // =================================================
          // MENGAMBIL DATA FIRESTORE
          // =================================================

          final Map<String, dynamic> data =
              snapshot.data!.data()
                  as Map<String, dynamic>;

          // =================================================
          // DATA PETUGAS
          // =================================================

          final String nama =
              data['nama'] ??
                  'Petugas Klinik';

          final String email =
              data['email'] ??
                  user.email ??
                  '-';

          final String role =
              data['role'] ??
                  'petugas';

          final String jenisKelamin =
              data['jenisKelamin'] ??
                  '-';

          // =================================================
          // TEMPAT + TANGGAL LAHIR
          // =================================================
          //
          // Sekarang tempat lahir dan tanggal lahir
          // disimpan menjadi satu field.
          //
          // Field Firestore:
          //
          // tempatTanggalLahir
          //
          // Contoh:
          // Magetan, 12 Mei 2006
          // =================================================

          final String tempatTanggalLahir =
              data['tempatTanggalLahir'] ??
                  '-';

          final String nomorTelepon =
              data['nomorTelepon'] ??
                  '-';

          final String alamat =
              data['alamat'] ??
                  '-';

          // =================================================
          // TAMPILAN PROFIL
          // =================================================

          return SingleChildScrollView(
            padding:
                const EdgeInsets.all(20),

            child: Column(
              children: [

                // ===========================================
                // HEADER PROFIL
                // ===========================================

                Container(
                  width: double.infinity,

                  padding:
                      const EdgeInsets.all(25),

                  decoration:
                      BoxDecoration(
                    color: Colors.blue,

                    borderRadius:
                        BorderRadius.circular(22),
                  ),

                  child: Column(
                    children: [

                      // =====================================
                      // FOTO / AVATAR
                      // =====================================

                      ValueListenableBuilder<
                          Uint8List?>(
                        valueListenable:
                            ProfilePhotoService
                                .fotoProfil,

                        builder: (
                          context,
                          foto,
                          child,
                        ) {
                          return GestureDetector(
                            onTap:
                                _pilihFoto,

                            child: Container(
                              width: 90,
                              height: 90,

                              decoration:
                                  BoxDecoration(
                                color:
                                    Colors.white,

                                shape:
                                    BoxShape.circle,

                                image: foto != null
                                    ? DecorationImage(
                                        image:
                                            MemoryImage(
                                          foto,
                                        ),
                                        fit: BoxFit
                                            .cover,
                                      )
                                    : null,
                              ),

                              child: foto == null
                                  ? const Icon(
                                      Icons
                                          .admin_panel_settings,

                                      color:
                                          Colors.blue,

                                      size: 52,
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      // =====================================
                      // PETUNJUK FOTO
                      // =====================================

                      const Text(
                        'Ketuk foto untuk mengganti',

                        style: TextStyle(
                          color:
                              Colors.white70,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      // =====================================
                      // NAMA
                      // =====================================

                      Text(
                        nama,

                        textAlign:
                            TextAlign.center,

                        style:
                            const TextStyle(
                          color:
                              Colors.white,

                          fontSize: 22,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      // =====================================
                      // EMAIL
                      // =====================================

                      Text(
                        email,

                        textAlign:
                            TextAlign.center,

                        style:
                            const TextStyle(
                          color:
                              Colors.white70,

                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      // =====================================
                      // BADGE ROLE
                      // =====================================

                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),

                        decoration:
                            BoxDecoration(
                          color: Colors.white
                              .withValues(
                            alpha: 0.18,
                          ),

                          borderRadius:
                              BorderRadius
                                  .circular(20),
                        ),

                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min,

                          children: [

                            const Icon(
                              Icons
                                  .verified_user,

                              color:
                                  Colors.white,

                              size: 17,
                            ),

                            const SizedBox(
                              width: 7,
                            ),

                            Text(
                              role == 'petugas'
                                  ? 'Petugas Klinik'
                                  : role,

                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,

                                fontWeight:
                                    FontWeight.bold,

                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                // ===========================================
                // JUDUL INFORMASI AKUN
                // ===========================================

                _buildSectionTitle(
                  'Informasi Akun',
                ),

                const SizedBox(
                  height: 10,
                ),

                // ===========================================
                // NAMA
                // ===========================================

                _buildInfoCard(
                  icon:
                      Icons.person_outline,

                  title: 'Nama',

                  value: nama,
                ),

                // ===========================================
                // EMAIL
                // ===========================================

                _buildInfoCard(
                  icon:
                      Icons.email_outlined,

                  title: 'Email',

                  value: email,
                ),

                // ===========================================
                // ROLE
                // ===========================================

                _buildInfoCard(
                  icon:
                      Icons
                          .admin_panel_settings_outlined,

                  title: 'Role',

                  value: role == 'petugas'
                      ? 'Petugas'
                      : role,
                ),

                const SizedBox(
                  height: 15,
                ),

                // ===========================================
                // JUDUL DATA PRIBADI
                // ===========================================

                _buildSectionTitle(
                  'Informasi Pribadi',
                ),

                const SizedBox(
                  height: 10,
                ),

                // ===========================================
                // JENIS KELAMIN
                // ===========================================

                _buildInfoCard(
                  icon:
                      Icons.person_outline,

                  title: 'Jenis Kelamin',

                  value:
                      jenisKelamin,
                ),

                // ===========================================
                // TEMPAT DAN TANGGAL LAHIR
                // ===========================================

                _buildInfoCard(
                  icon:
                      Icons.cake_outlined,

                  title:
                      'Tempat, Tanggal Lahir',

                  value:
                      tempatTanggalLahir,
                ),

                // ===========================================
                // NOMOR TELEPON
                // ===========================================

                _buildInfoCard(
                  icon:
                      Icons.phone_outlined,

                  title:
                      'Nomor Telepon',

                  value:
                      nomorTelepon,
                ),

                // ===========================================
                // ALAMAT
                // ===========================================

                _buildInfoCard(
                  icon:
                      Icons.home_outlined,

                  title: 'Alamat',

                  value:
                      alamat,
                ),

                const SizedBox(
                  height: 20,
                ),

                // ===========================================
                // TOMBOL EDIT PROFIL
                // ===========================================

                SizedBox(
                  width:
                      double.infinity,

                  height: 52,

                  child:
                      ElevatedButton.icon(
                    onPressed: () {
                      _showEditProfileDialog(
                        context,
                        user.uid,
                        data,
                      );
                    },

                    icon: const Icon(
                      Icons.edit,
                    ),

                    label: const Text(
                      'Edit Profil',
                    ),

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.blue,

                      foregroundColor:
                          Colors.white,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(15),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                // ===========================================
                // TOMBOL LOGOUT
                // ===========================================

                SizedBox(
                  width:
                      double.infinity,

                  height: 52,

                  child:
                      OutlinedButton.icon(
                    onPressed: () {
                      _showLogoutDialog(
                        context,
                      );
                    },

                    icon: const Icon(
                      Icons.logout,
                    ),

                    label: const Text(
                      'Logout',
                    ),

                    style:
                        OutlinedButton.styleFrom(
                      foregroundColor:
                          Colors.red,

                      side:
                          const BorderSide(
                        color: Colors.red,
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          15,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==========================================================
  // MEMILIH FOTO DARI GALERI
  // ==========================================================

  Future<void> _pilihFoto() async {
    try {

      // ======================================================
      // MEMBUKA GALERI
      // ======================================================

      final XFile? foto =
          await _imagePicker.pickImage(
        source:
            ImageSource.gallery,

        imageQuality: 80,

        maxWidth: 1000,

        maxHeight: 1000,
      );

      // ======================================================
      // JIKA USER MEMBATALKAN
      // ======================================================

      if (foto == null) {
        return;
      }

      // ======================================================
      // MEMBACA FOTO
      // ======================================================

      final Uint8List bytes =
          await foto.readAsBytes();

      // ======================================================
      // MENYIMPAN FOTO SEMENTARA
      // ======================================================

      ProfilePhotoService
          .simpanFoto(bytes);

      // ======================================================
      // PESAN BERHASIL
      // ======================================================

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Foto profil berhasil dipilih.',
            ),
          ),
        );
      }

    } catch (e) {

      // ======================================================
      // ERROR
      // ======================================================

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memilih foto: $e',
            ),
          ),
        );
      }
    }
  }

  // ==========================================================
  // SECTION TITLE
  // ==========================================================

  Widget _buildSectionTitle(
    String title,
  ) {

    return Align(
      alignment:
          Alignment.centerLeft,

      child: Text(
        title,

        style:
            const TextStyle(
          fontSize: 19,

          fontWeight:
              FontWeight.bold,
        ),
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
      width:
          double.infinity,

      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),

      padding:
          const EdgeInsets.all(15),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(15),

        boxShadow: [
          BoxShadow(
            color:
                Colors.grey.withValues(
              alpha: 0.1,
            ),

            blurRadius:
                8,

            offset:
                const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          // ================================================
          // ICON
          // ================================================

          Container(
            width: 45,

            height: 45,

            decoration:
                BoxDecoration(
              color:
                  Colors.blue.withValues(
                alpha: 0.1,
              ),

              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),

            child: Icon(
              icon,

              color:
                  Colors.blue,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          // ================================================
          // TEXT
          // ================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  title,

                  style:
                      const TextStyle(
                    color:
                        Colors.grey,

                    fontSize: 12,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  value,

                  style:
                      const TextStyle(
                    fontSize: 15,

                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // DIALOG EDIT PROFIL
  // ==========================================================

  void _showEditProfileDialog(
    BuildContext context,
    String uid,
    Map<String, dynamic> data,
  ) {

    // ========================================================
    // CONTROLLER NAMA
    // ========================================================

    final TextEditingController
        namaController =
        TextEditingController(
      text:
          data['nama'] ?? '',
    );

    // ========================================================
    // CONTROLLER TEMPAT DAN TANGGAL LAHIR
    // ========================================================

    final TextEditingController
        tempatTanggalLahirController =
        TextEditingController(
      text:
          data['tempatTanggalLahir'] ??
              '',
    );

    // ========================================================
    // CONTROLLER NOMOR TELEPON
    // ========================================================

    final TextEditingController
        teleponController =
        TextEditingController(
      text:
          data['nomorTelepon'] ?? '',
    );

    // ========================================================
    // CONTROLLER ALAMAT
    // ========================================================

    final TextEditingController
        alamatController =
        TextEditingController(
      text:
          data['alamat'] ?? '',
    );

    // ========================================================
    // JENIS KELAMIN
    // ========================================================

    String jenisKelamin =
        data['jenisKelamin'] ?? '';

    // ========================================================
    // DIALOG
    // ========================================================

    showDialog(
      context: context,

      builder: (dialogContext) {

        bool sedangMenyimpan =
            false;

        return StatefulBuilder(
          builder: (
            context,
            setState,
          ) {

            return AlertDialog(

              // ==============================================
              // JUDUL
              // ==============================================

              title: const Text(
                'Edit Profil',

                style:
                    TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              // ==============================================
              // ISI
              // ==============================================

              content:
                  SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,

                  children: [

                    // ========================================
                    // FOTO PROFIL
                    // ========================================

                    ValueListenableBuilder<
                        Uint8List?>(
                      valueListenable:
                          ProfilePhotoService
                              .fotoProfil,

                      builder: (
                        context,
                        foto,
                        child,
                      ) {

                        return GestureDetector(
                          onTap: () async {

                            await _pilihFoto();

                            // Memperbarui tampilan
                            // dialog setelah memilih foto.

                            setState(() {});
                          },

                          child: Container(
                            width: 90,

                            height: 90,

                            decoration:
                                BoxDecoration(
                              color:
                                  Colors.blue.shade100,

                              shape:
                                  BoxShape.circle,

                              image: foto != null
                                  ? DecorationImage(
                                      image:
                                          MemoryImage(
                                        foto,
                                      ),

                                      fit:
                                          BoxFit.cover,
                                    )
                                  : null,
                            ),

                            child: foto == null
                                ? const Icon(
                                    Icons.camera_alt,

                                    color:
                                        Colors.blue,

                                    size: 35,
                                  )
                                : null,
                          ),
                        );
                      },
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    const Text(
                      'Ketuk foto untuk memilih '
                      'dari galeri',

                      textAlign:
                          TextAlign.center,

                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // ========================================
                    // NAMA
                    // ========================================

                    TextField(
                      controller:
                          namaController,

                      decoration:
                          const InputDecoration(
                        labelText:
                            'Nama',

                        prefixIcon:
                            Icon(
                          Icons.person,
                        ),

                        border:
                            OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    // ========================================
                    // JENIS KELAMIN
                    // ========================================

                    DropdownButtonFormField<String>(
                      initialValue:
                          jenisKelamin.isEmpty
                              ? null
                              : jenisKelamin,

                      decoration:
                          const InputDecoration(
                        labelText:
                            'Jenis Kelamin',

                        prefixIcon:
                            Icon(
                          Icons.people,
                        ),

                        border:
                            OutlineInputBorder(),
                      ),

                      items: const [

                        DropdownMenuItem(
                          value:
                              'Laki-laki',

                          child:
                              Text(
                            'Laki-laki',
                          ),
                        ),

                        DropdownMenuItem(
                          value:
                              'Perempuan',

                          child:
                              Text(
                            'Perempuan',
                          ),
                        ),
                      ],

                      onChanged:
                          (value) {

                        if (value != null) {

                          setState(() {
                            jenisKelamin =
                                value;
                          });
                        }
                      },
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    // ========================================
                    // TEMPAT DAN TANGGAL LAHIR
                    // ========================================

                    TextField(
                      controller:
                          tempatTanggalLahirController,

                      decoration:
                          const InputDecoration(
                        labelText:
                            'Tempat, Tanggal Lahir',

                        hintText:
                            'Contoh: Magetan, 12 Mei 2006',

                        prefixIcon:
                            Icon(
                          Icons.cake_outlined,
                        ),

                        border:
                            OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    // ========================================
                    // NOMOR TELEPON
                    // ========================================

                    TextField(
                      controller:
                          teleponController,

                      keyboardType:
                          TextInputType.phone,

                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly,
                      ],

                      decoration:
                          const InputDecoration(
                        labelText:
                            'Nomor Telepon',

                        prefixIcon:
                            Icon(
                          Icons.phone,
                        ),

                        border:
                            OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    // ========================================
                    // ALAMAT
                    // ========================================

                    TextField(
                      controller:
                          alamatController,

                      maxLines: 3,

                      decoration:
                          const InputDecoration(
                        labelText:
                            'Alamat',

                        prefixIcon:
                            Icon(
                          Icons.home,
                        ),

                        border:
                            OutlineInputBorder(),

                        alignLabelWithHint:
                            true,
                      ),
                    ),
                  ],
                ),
              ),

              // ==============================================
              // TOMBOL
              // ==============================================

              actions: [

                // ============================================
                // BATAL
                // ============================================

                TextButton(
                  onPressed:
                      sedangMenyimpan
                          ? null
                          : () {
                              Navigator.pop(
                                dialogContext,
                              );
                            },

                  child:
                      const Text(
                    'Batal',
                  ),
                ),

                // ============================================
                // SIMPAN
                // ============================================

                ElevatedButton(
                  onPressed:
                      sedangMenyimpan
                          ? null
                          : () async {

                              // ==============================
                              // VALIDASI NAMA
                              // ==============================

                              if (namaController
                                  .text
                                  .trim()
                                  .isEmpty) {

                                ScaffoldMessenger
                                    .of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text(
                                      'Nama tidak boleh kosong.',
                                    ),
                                  ),
                                );

                                return;
                              }

                              // ==============================
                              // VALIDASI TEMPAT TANGGAL LAHIR
                              // ==============================

                              if (tempatTanggalLahirController
                                  .text
                                  .trim()
                                  .isEmpty) {

                                ScaffoldMessenger
                                    .of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text(
                                      'Tempat dan tanggal lahir '
                                      'tidak boleh kosong.',
                                    ),
                                  ),
                                );

                                return;
                              }

                              // ==============================
                              // LOADING
                              // ==============================

                              setState(() {
                                sedangMenyimpan =
                                    true;
                              });

                              try {

                                // ============================
                                // UPDATE FIRESTORE
                                // ============================

                                await _firestore
                                    .collection(
                                      'users',
                                    )
                                    .doc(uid)
                                    .update({

                                  'nama':
                                      namaController
                                          .text
                                          .trim(),

                                  'jenisKelamin':
                                      jenisKelamin,

                                  // ==================================
                                  // FIELD TEMPAT + TANGGAL LAHIR
                                  // ==================================

                                  'tempatTanggalLahir':
                                      tempatTanggalLahirController
                                          .text
                                          .trim(),

                                  'nomorTelepon':
                                      teleponController
                                          .text
                                          .trim(),

                                  'alamat':
                                      alamatController
                                          .text
                                          .trim(),
                                });

                                // ============================
                                // TUTUP DIALOG
                                // ============================

                                if (context.mounted) {

                                  Navigator.pop(
                                    dialogContext,
                                  );

                                  ScaffoldMessenger
                                      .of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text(
                                        'Profil berhasil diperbarui.',
                                      ),
                                    ),
                                  );
                                }

                              } catch (e) {

                                // ============================
                                // MATIKAN LOADING
                                // ============================

                                setState(() {
                                  sedangMenyimpan =
                                      false;
                                });

                                // ============================
                                // PESAN ERROR
                                // ============================

                                if (context.mounted) {

                                  ScaffoldMessenger
                                      .of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content:
                                          Text(
                                        'Gagal memperbarui profil: $e',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },

                  child: sedangMenyimpan
                      ? const SizedBox(
                          width: 20,
                          height: 20,

                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Simpan',
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================================
  // DIALOG LOGOUT
  // ==========================================================

  void _showLogoutDialog(
    BuildContext context,
  ) {

    showDialog(
      context: context,

      builder: (dialogContext) {

        return AlertDialog(

          // ================================================
          // JUDUL
          // ================================================

          title: const Text(
            'Logout',

            style:
                TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          // ================================================
          // ISI
          // ================================================

          content: const Text(
            'Apakah Anda yakin ingin keluar '
            'dari akun petugas?',
          ),

          // ================================================
          // TOMBOL
          // ================================================

          actions: [

            // ==============================================
            // BATAL
            // ==============================================

            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },

              child:
                  const Text(
                'Batal',
              ),
            ),

            // ==============================================
            // LOGOUT
            // ==============================================

            ElevatedButton(
              onPressed: () async {

                // ==========================================
                // LOGOUT FIREBASE
                // ==========================================

                await _auth.signOut();

                // ==========================================
                // KEMBALI KE LOGIN
                // ==========================================

                if (context.mounted) {

                  Navigator.pushAndRemoveUntil(
                    context,

                    MaterialPageRoute(
                      builder:
                          (context) =>
                              const LoginPage(),
                    ),

                    (route) => false,
                  );
                }
              },

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,

                foregroundColor:
                    Colors.white,
              ),

              child:
                  const Text(
                'Logout',
              ),
            ),
          ],
        );
      },
    );
  }
}