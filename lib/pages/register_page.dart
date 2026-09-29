import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_page.dart';
import '../services/database_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // ============================================================
  // CONTROLLER
  // Digunakan untuk mengambil isi dari TextField
  // ============================================================

  final TextEditingController namaController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController konfirmasiPasswordController =
      TextEditingController();

  // ============================================================
  // VARIABLE
  // ============================================================

  bool isLoading = false;

  bool passwordVisible = false;

  bool konfirmasiPasswordVisible = false;

  // ============================================================
  // REGISTER
  // ============================================================

  Future<void> register() async {
    // Menghilangkan keyboard
    FocusScope.of(context).unfocus();

    // Mengambil data dari TextField
    final String nama = namaController.text.trim();

    final String email = emailController.text.trim();

    final String password = passwordController.text.trim();

    final String konfirmasiPassword = konfirmasiPasswordController.text.trim();

    // ==========================================================
    // VALIDASI NAMA
    // ==========================================================

    if (nama.isEmpty) {
      tampilkanPesan('Nama tidak boleh kosong.');
      return;
    }

    // ==========================================================
    // VALIDASI EMAIL
    // ==========================================================

    if (email.isEmpty) {
      tampilkanPesan('Email tidak boleh kosong.');
      return;
    }

    // Validasi sederhana format email
    if (!email.contains('@')) {
      tampilkanPesan('Masukkan email yang valid.');
      return;
    }

    // ==========================================================
    // VALIDASI PASSWORD
    // ==========================================================

    if (password.isEmpty) {
      tampilkanPesan('Password tidak boleh kosong.');
      return;
    }

    if (password.length < 6) {
      tampilkanPesan('Password minimal 6 karakter.');
      return;
    }

    // ==========================================================
    // VALIDASI KONFIRMASI PASSWORD
    // ==========================================================

    if (konfirmasiPassword.isEmpty) {
      tampilkanPesan('Konfirmasi password tidak boleh kosong.');
      return;
    }

    if (password != konfirmasiPassword) {
      tampilkanPesan('Konfirmasi password tidak sama.');
      return;
    }

    // ==========================================================
    // MULAI PROSES REGISTER
    // ==========================================================

    setState(() {
      isLoading = true;
    });

    try {
      // ========================================================
      // 1. MEMBUAT AKUN DI FIREBASE AUTHENTICATION
      // ========================================================

      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Mengambil user yang baru dibuat
      final User? user = userCredential.user;

      // Pastikan user berhasil dibuat
      if (user == null) {
        throw Exception('User gagal dibuat.');
      }

      // ========================================================
      // 2. MENYIMPAN NAMA KE FIREBASE AUTH
      // ========================================================

      await user.updateDisplayName(nama);

      // ========================================================
      // 3. MENYIMPAN DATA USER KE FIRESTORE
      // ========================================================

      await DatabaseService.simpanUser(uid: user.uid, nama: nama, email: email);

      // ========================================================
      // 4. CEK APAKAH WIDGET MASIH ADA
      // ========================================================

      if (!mounted) {
        return;
      }

      // ========================================================
      // 5. MENAMPILKAN PESAN BERHASIL
      // ========================================================

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil!'),
          backgroundColor: Colors.green,
        ),
      );

      // ========================================================
      // 6. KEMBALI KE LOGIN PAGE
      // ========================================================

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
    // ==========================================================
    // ERROR FIREBASE AUTHENTICATION
    // ==========================================================
    on FirebaseAuthException catch (e) {
      String pesan;

      switch (e.code) {
        case 'email-already-in-use':
          pesan = 'Email tersebut sudah terdaftar.';
          break;

        case 'invalid-email':
          pesan = 'Format email tidak valid.';
          break;

        case 'weak-password':
          pesan = 'Password terlalu lemah.';
          break;

        case 'operation-not-allowed':
          pesan =
              'Registrasi dengan email/password belum diaktifkan di Firebase.';
          break;

        case 'network-request-failed':
          pesan = 'Tidak ada koneksi internet.';
          break;

        default:
          pesan = 'Registrasi gagal: ${e.message ?? 'Terjadi kesalahan.'}';
      }

      if (mounted) {
        tampilkanPesan(pesan);
      }
    }
    // ==========================================================
    // ERROR LAINNYA
    // ==========================================================
    catch (e) {
      if (mounted) {
        tampilkanPesan('Terjadi kesalahan: $e');
      }
    }
    // ==========================================================
    // SELESAI LOADING
    // ==========================================================
    finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // FUNGSI MENAMPILKAN PESAN
  // ============================================================

  void tampilkanPesan(String pesan) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(pesan), backgroundColor: Colors.red));
  }

  // ============================================================
  // DISPOSE CONTROLLER
  // ============================================================

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    passwordController.dispose();
    konfirmasiPasswordController.dispose();

    super.dispose();
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F9FF),

      appBar: AppBar(
        title: const Text('Registrasi'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              // ==================================================
              // ICON
              // ==================================================

              const SizedBox(height: 20),

              const Icon(Icons.local_hospital, size: 80, color: Colors.blue),

              const SizedBox(height: 15),

              // ==================================================
              // JUDUL
              // ==================================================
              const Text(
                'Buat Akun Baru',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Silakan isi data untuk membuat akun',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // NAMA
              // ==================================================
              TextField(
                controller: namaController,

                textInputAction: TextInputAction.next,

                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  hintText: 'Masukkan nama lengkap',
                  prefixIcon: const Icon(Icons.person),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // EMAIL
              // ==================================================
              TextField(
                controller: emailController,

                keyboardType: TextInputType.emailAddress,

                textInputAction: TextInputAction.next,

                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Masukkan email',
                  prefixIcon: const Icon(Icons.email),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // PASSWORD
              // ==================================================
              TextField(
                controller: passwordController,

                obscureText: !passwordVisible,

                textInputAction: TextInputAction.next,

                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Masukkan password',

                  prefixIcon: const Icon(Icons.lock),

                  suffixIcon: IconButton(
                    icon: Icon(
                      passwordVisible ? Icons.visibility : Icons.visibility_off,
                    ),

                    onPressed: () {
                      setState(() {
                        passwordVisible = !passwordVisible;
                      });
                    },
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // KONFIRMASI PASSWORD
              // ==================================================
              TextField(
                controller: konfirmasiPasswordController,

                obscureText: !konfirmasiPasswordVisible,

                textInputAction: TextInputAction.done,

                onSubmitted: (_) {
                  if (!isLoading) {
                    register();
                  }
                },

                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password',

                  hintText: 'Masukkan kembali password',

                  prefixIcon: const Icon(Icons.lock_outline),

                  suffixIcon: IconButton(
                    icon: Icon(
                      konfirmasiPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),

                    onPressed: () {
                      setState(() {
                        konfirmasiPasswordVisible = !konfirmasiPasswordVisible;
                      });
                    },
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ==================================================
              // BUTTON REGISTER
              // ==================================================
              SizedBox(
                height: 52,

                child: ElevatedButton(
                  onPressed: isLoading ? null : register,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,

                    foregroundColor: Colors.white,

                    disabledBackgroundColor: Colors.blue.shade200,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,

                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Daftar',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // LINK LOGIN
              // ==================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  const Text(
                    'Sudah punya akun? ',
                    style: TextStyle(color: Colors.grey),
                  ),

                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },

                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ==================================================
              // INFORMASI
              // ==================================================
              Container(
                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: Colors.blue.shade50,

                  borderRadius: BorderRadius.circular(12),
                ),

                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),

                    SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        'Password harus memiliki minimal 6 karakter.',
                        style: TextStyle(fontSize: 13, color: Colors.blue),
                      ),
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
}
