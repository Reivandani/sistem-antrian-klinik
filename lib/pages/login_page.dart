import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_page.dart';
import 'register_page.dart';
import 'admin_home_page.dart';

import '../services/database_service.dart';
import '../services/fcm_service.dart';

// ======================================================
// LOGIN PAGE
// ======================================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // ==================================================
  // CONTROLLER
  // ==================================================

  // Controller untuk mengambil input email
  final TextEditingController usernameController = TextEditingController();

  // Controller untuk mengambil input password
  final TextEditingController passwordController = TextEditingController();

  // Menentukan apakah password ditampilkan
  // atau disembunyikan
  bool isPasswordVisible = false;

  // Menentukan apakah proses login sedang berjalan
  bool isLoading = false;

  // ==================================================
  // FUNGSI LOGIN FIREBASE
  // ==================================================

  Future<void> login() async {
    // ==================================================
    // VALIDASI INPUT
    // ==================================================

    if (usernameController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password harus diisi')),
      );

      return;
    }

    // ==================================================
    // MULAI LOADING
    // ==================================================

    setState(() {
      isLoading = true;
    });

    try {
      // ==================================================
      // LOGIN MENGGUNAKAN FIREBASE AUTHENTICATION
      // ==================================================

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: usernameController.text.trim(),
            password: passwordController.text,
          );

      // ==================================================
      // CEK LOGIN BERHASIL
      // ==================================================

      if (userCredential.user != null) {
        // ==================================================
        // MENGAMBIL UID USER
        // ==================================================

        final String uid = userCredential.user!.uid;

        // ==================================================
        // MENGAMBIL ROLE USER DARI FIRESTORE
        // ==================================================

        final String role = await DatabaseService.ambilRole(uid);

if (role != 'petugas') {
  await FcmService.initialize();
}

        // ==================================================
        // MENGAMBIL NAMA USER
        // ==================================================

        final String username =
            userCredential.user!.displayName ??
            userCredential.user!.email ??
            'Pengguna';

        // ==================================================
        // MEMASTIKAN WIDGET MASIH AKTIF
        // ==================================================

        if (!mounted) return;

        // ==================================================
        // CEK ROLE USER
        // ==================================================

        if (role == 'petugas') {
          // ==================================================
          // PETUGAS KLINIK
          // ==================================================

          Navigator.pushReplacement(
            context,

            MaterialPageRoute(builder: (context) => const AdminHomePage()),
          );
        } else {
          // ==================================================
          // PASIEN
          // ==================================================

          Navigator.pushReplacement(
            context,

            MaterialPageRoute(
              builder: (context) => HomePage(username: username),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      // ==================================================
      // PESAN ERROR FIREBASE
      // ==================================================

      String pesanError = 'Login gagal. Silakan coba lagi.';

      if (e.code == 'invalid-credential') {
        pesanError = 'Email atau password salah.';
      } else if (e.code == 'user-not-found') {
        pesanError = 'Akun dengan email tersebut tidak ditemukan.';
      } else if (e.code == 'wrong-password') {
        pesanError = 'Password yang dimasukkan salah.';
      } else if (e.code == 'invalid-email') {
        pesanError = 'Format email tidak valid.';
      } else if (e.code == 'user-disabled') {
        pesanError = 'Akun ini telah dinonaktifkan.';
      } else if (e.code == 'too-many-requests') {
        pesanError = 'Terlalu banyak percobaan login. Coba lagi nanti.';
      }

      // ==================================================
      // CEK WIDGET
      // ==================================================

      if (!mounted) return;

      // ==================================================
      // TAMPILKAN ERROR
      // ==================================================

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(pesanError)));
    } catch (e) {
      // ==================================================
      // ERROR LAINNYA
      // ==================================================

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan. Silakan coba lagi.')),
      );
    } finally {
      // ==================================================
      // SELESAI LOADING
      // ==================================================

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ==================================================
  // DISPOSE CONTROLLER
  // ==================================================

  @override
  void dispose() {
    usernameController.dispose();

    passwordController.dispose();

    super.dispose();
  }

  // ==================================================
  // BUILD
  // ==================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ==================================================
      // BODY
      // ==================================================

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                const SizedBox(height: 50),

                // ==================================================
                // ICON KLINIK
                // ==================================================
                Container(
                  width: 100,
                  height: 100,

                  decoration: BoxDecoration(
                    color: Colors.blue,

                    borderRadius: BorderRadius.circular(25),
                  ),

                  child: const Icon(
                    Icons.local_hospital,

                    size: 55,

                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 25),

                // ==================================================
                // JUDUL
                // ==================================================
                const Text(
                  'Sistem Antrian Klinik',

                  style: TextStyle(
                    fontSize: 26,

                    fontWeight: FontWeight.bold,

                    color: Colors.blue,
                  ),
                ),

                const SizedBox(height: 10),

                // ==================================================
                // SUBJUDUL
                // ==================================================
                const Text(
                  'Silakan login untuk melanjutkan',

                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),

                const SizedBox(height: 40),

                // ==================================================
                // EMAIL
                // ==================================================
                TextField(
                  controller: usernameController,

                  keyboardType: TextInputType.emailAddress,

                  decoration: InputDecoration(
                    labelText: 'Email',

                    hintText: 'Masukkan email',

                    prefixIcon: const Icon(Icons.email, color: Colors.blue),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),

                      borderSide: const BorderSide(
                        color: Colors.blue,

                        width: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // PASSWORD
                // ==================================================
                TextField(
                  controller: passwordController,

                  // Menyembunyikan password
                  obscureText: !isPasswordVisible,

                  decoration: InputDecoration(
                    labelText: 'Password',

                    hintText: 'Masukkan password',

                    prefixIcon: const Icon(Icons.lock, color: Colors.blue),

                    // ==================================================
                    // TOMBOL LIHAT PASSWORD
                    // ==================================================
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),

                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),

                      borderSide: const BorderSide(
                        color: Colors.blue,

                        width: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ==================================================
                // BUTTON LOGIN
                // ==================================================
                SizedBox(
                  width: double.infinity,

                  height: 55,

                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,

                      foregroundColor: Colors.white,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),

                    // Saat loading tombol tidak dapat ditekan
                    onPressed: isLoading ? null : login,

                    child:
                        // ==================================================
                        // LOADING
                        // ==================================================
                        isLoading
                        ? const SizedBox(
                            width: 25,

                            height: 25,

                            child: CircularProgressIndicator(
                              color: Colors.white,

                              strokeWidth: 3,
                            ),
                          )
                        // ==================================================
                        // TEXT LOGIN
                        // ==================================================
                        : const Text(
                            'LOGIN',

                            style: TextStyle(
                              fontSize: 17,

                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // REGISTER
                // ==================================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    const Text('Belum punya akun? '),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },

                      child: const Text('Daftar'),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ==================================================
                // VERSI APLIKASI
                // ==================================================
                const Text(
                  'Sistem Antrian Klinik v1.0',

                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
