import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'pages/login_page.dart';

import 'services/notification_service.dart';

import 'themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ==========================================================
  // INISIALISASI FIREBASE
  // ==========================================================

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ==========================================================
  // INISIALISASI NOTIFIKASI
  // ==========================================================

  await NotificationService.initialize();

  // ==========================================================
  // MENJALANKAN APLIKASI
  // ==========================================================

  runApp(const KlinikApp());
}

class KlinikApp extends StatelessWidget {
  const KlinikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ======================================================
      // PENGATURAN DASAR APLIKASI
      // ======================================================

      debugShowCheckedModeBanner: false,

      title: 'Sistem Antrian Klinik',

      // ======================================================
      // THEME APLIKASI
      // ======================================================

      // Sebelumnya ThemeData ditulis langsung di sini.
      //
      // Sekarang pengaturan tampilan dipindahkan
      // ke themes/app_theme.dart
      theme: AppTheme.lightTheme,

      // ======================================================
      // HALAMAN AWAL
      // ======================================================
      home: const LoginPage(),
    );
  }
}
