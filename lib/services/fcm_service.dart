import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'database_service.dart';

class FcmService {
  // ==========================================================
  // INSTANCE FIREBASE MESSAGING
  // ==========================================================

  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  // ==========================================================
  // VAPID PUBLIC KEY UNTUK WEB
  // ==========================================================
  //
  // Nanti isi dengan VAPID public key dari Firebase Console.
  //
  // Untuk sementara dikosongkan terlebih dahulu.
  //
  // Contoh:
  //
  // static const String vapidKey =
  //     'Bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
  //
  // ==========================================================

  static const String vapidKey = 'BDOOsGjQdd5nn6pRJiNeyxAEEKLW4wvDDNqHCPBcRfZnvfFEZGkkHy2oPD60XrbR2NWanusn80lIyri4DpXEdts';

  // ==========================================================
  // INITIALIZE FCM
  // ==========================================================

  static Future<void> initialize() async {
    try {
      // ======================================================
      // AMBIL USER YANG SEDANG LOGIN
      // ======================================================

      final User? user = FirebaseAuth.instance.currentUser;

      // Jika belum login, tidak perlu mengambil token.
      if (user == null) {
        debugPrint('FCM: Tidak ada user yang sedang login.');
        return;
      }

      // ======================================================
      // REQUEST PERMISSION
      // ======================================================
      //
      // Android 13+ dan Web membutuhkan izin notifikasi.
      //
      // ======================================================

      final NotificationSettings settings =
          await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint(
        'FCM permission: ${settings.authorizationStatus}',
      );

      // ======================================================
      // CEK STATUS PERMISSION
      // ======================================================

      if (settings.authorizationStatus ==
          AuthorizationStatus.denied) {
        debugPrint('FCM: Izin notifikasi ditolak.');
        return;
      }

      // ======================================================
      // MENGAMBIL TOKEN FCM
      // ======================================================

      String? token;

      if (kIsWeb) {
        // ====================================================
        // WEB
        // ====================================================
        //
        // Web membutuhkan VAPID public key.
        //
        // ====================================================

        if (vapidKey.isEmpty) {
          debugPrint(
            'FCM: VAPID key belum diisi. '
            'Konfigurasi Web belum lengkap.',
          );
          return;
        }

        token = await _messaging.getToken(
          vapidKey: vapidKey,
        );
      } else {
        // ====================================================
        // ANDROID
        // ====================================================

        token = await _messaging.getToken();
      }

      // ======================================================
      // SIMPAN TOKEN KE FIRESTORE
      // ======================================================

      if (token != null && token.isNotEmpty) {
        debugPrint('FCM Token berhasil didapatkan.');
        debugPrint(token);

        await DatabaseService.simpanFcmToken(
          uid: user.uid,
          token: token,
        );

        debugPrint(
          'FCM Token berhasil disimpan ke Firestore.',
        );
      } else {
        debugPrint('FCM: Token tidak tersedia.');
      }

      // ======================================================
      // TOKEN REFRESH
      // ======================================================
      //
      // Firebase dapat mengganti token perangkat.
      // Karena itu kita harus menyimpan token terbaru.
      //
      // ======================================================

      _messaging.onTokenRefresh.listen(
        (newToken) async {
          try {
            debugPrint('FCM Token diperbarui.');

            await DatabaseService.simpanFcmToken(
              uid: user.uid,
              token: newToken,
            );

            debugPrint(
              'FCM Token baru berhasil disimpan.',
            );
          } catch (e) {
            debugPrint(
              'Gagal menyimpan FCM Token baru: $e',
            );
          }
        },
      );
    } catch (e) {
      // ======================================================
      // ERROR HANDLING
      // ======================================================

      debugPrint(
        'FCM initialization error: $e',
      );
    }
  }
}