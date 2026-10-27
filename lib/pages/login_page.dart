
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_page.dart';
import 'register_page.dart';
import 'admin_home_page.dart';

import '../services/database_service.dart';
import '../services/fcm_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // ======================================================
  // CONTROLLER DAN STATUS
  // ======================================================

  final TextEditingController usernameController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool isPasswordVisible = false;
  bool isLoading = false;

  static const Color primary = Color(0xFF1769AA);
  static const Color primaryDark = Color(0xFF104B7A);
  static const Color textPrimary = Color(0xFF172B4D);
  static const Color textSecondary = Color(0xFF718096);

  // ======================================================
  // FUNGSI LOGIN FIREBASE
  // ======================================================

  Future<void> login() async {
    if (usernameController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email dan password harus diisi'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: usernameController.text.trim(),
        password: passwordController.text,
      );

      if (userCredential.user != null) {
        final String uid = userCredential.user!.uid;

        // Ambil role dari Firestore.
        final String role = await DatabaseService.ambilRole(uid);

        // Inisialisasi notifikasi untuk pasien.
        if (role != 'petugas') {
          await FcmService.initialize();
        }

        final String username =
            userCredential.user!.displayName ??
                userCredential.user!.email ??
                'Pengguna';

        if (!mounted) return;

        // Arahkan pengguna sesuai role.
        if (role == 'petugas') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminHomePage(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                username: username,
              ),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
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
        pesanError =
            'Terlalu banyak percobaan login. Coba lagi nanti.';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(pesanError),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFB42318),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan. Silakan coba lagi.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ======================================================
  // DISPOSE CONTROLLER
  // ======================================================

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ======================================================
  // BUILD
  // ======================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ================================================
          // BACKGROUND FOTO KLINIK
          // ================================================

          Image.asset(
            'assets/images/background_klinik.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF104B7A),
                      Color(0xFF2589D8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              );
            },
          ),

          // ================================================
          // LAPISAN BIRU TRANSPARAN
          // ================================================

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF104B7A).withValues(alpha:0.65),
                  const Color(0xFF1769AA).withValues(alpha:0.40),
                  const Color(0xFF104B7A).withValues(alpha:0.72),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ================================================
          // KONTEN LOGIN
          // ================================================

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool layarLebar =
                    constraints.maxWidth >= 800;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: layarLebar ? 40 : 22,
                    vertical: 28,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 56,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 460,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Judul di atas kartu
                            _buildHeader(),

                            const SizedBox(height: 28),

                            // Form login
                            _buildLoginCard(),

                            const SizedBox(height: 22),

                            const Text(
                              'Sistem Antrean Klinik • Versi 1.0',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // HEADER APLIKASI
  // ======================================================

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:0.96),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.local_hospital_rounded,
            color: primary,
            size: 46,
          ),
        ),

        const SizedBox(height: 18),

        const Text(
          'Sistem Antrean Klinik',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Layanan kesehatan lebih mudah dan teratur',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha:0.92),
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ======================================================
  // KARTU FORM LOGIN
  // ======================================================

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 27, 24, 22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.97),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.white.withValues(alpha:0.75),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.17),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selamat Datang!',
            style: TextStyle(
              color: textPrimary,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'Silakan masuk ke akun Anda untuk melanjutkan.',
            style: TextStyle(
              color: textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 25),

          // ==============================================
          // EMAIL
          // ==============================================

          const Text(
            'Email',
            style: TextStyle(
              color: textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 9),

          TextField(
            controller: usernameController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            decoration: _inputDecoration(
              hint: 'Masukkan email Anda',
              icon: Icons.email_outlined,
            ),
          ),

          const SizedBox(height: 19),

          // ==============================================
          // PASSWORD
          // ==============================================

          const Text(
            'Password',
            style: TextStyle(
              color: textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 9),

          TextField(
            controller: passwordController,
            obscureText: !isPasswordVisible,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onSubmitted: (_) {
              if (!isLoading) login();
            },
            decoration: _inputDecoration(
              hint: 'Masukkan password Anda',
              icon: Icons.lock_outline_rounded,
            ).copyWith(
              suffixIcon: IconButton(
                tooltip: isPasswordVisible
                    ? 'Sembunyikan password'
                    : 'Tampilkan password',
                icon: Icon(
                  isPasswordVisible
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: textSecondary,
                  size: 21,
                ),
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 26),

          // ==============================================
          // TOMBOL LOGIN
          // ==============================================

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : login,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: primary.withValues(alpha:0.65),
                elevation: 2,
                shadowColor: primary.withValues(alpha:0.25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 23,
                      height: 23,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.login_rounded,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'MASUK',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.7,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 20),

          // ==============================================
          // PEMISAH
          // ==============================================

          Row(
            children: [
              Expanded(
                child: Divider(
                  color: Colors.blueGrey.withValues(alpha:0.20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'PENGGUNA BARU?',
                  style: TextStyle(
                    color: textSecondary.withValues(alpha:0.9),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: Colors.blueGrey.withValues(alpha:0.20),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ==============================================
          // NAVIGASI REGISTER
          // ==============================================

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterPage(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                side: const BorderSide(
                  color: primary,
                  width: 1.2,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 19,
                  ),
                  SizedBox(width: 9),
                  Text(
                    'Buat Akun Baru',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // STYLE KOLOM INPUT
  // ======================================================

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF9AA7B6),
        fontSize: 13,
      ),
      prefixIcon: Icon(
        icon,
        color: primary,
        size: 21,
      ),
      filled: true,
      fillColor: const Color(0xFFF7FAFD),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE0E8F0),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE0E8F0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: primary,
          width: 1.5,
        ),
      ),
    );
  }
}