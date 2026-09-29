import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // ============================================================
  // INITIALIZATION
  // ============================================================

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  // ============================================================
  // NOTIFIKASI ANTREAN BERHASIL DIAMBIL
  // ============================================================

  static Future<void> tampilkanNotifikasiAntrean({
    required String nomorAntrean,
    required String namaPoli,
    required String dokter,
    required int jumlahDiDepan,
    required int estimasiMenit,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'antrean_klinik',
          'Antrean Klinik',
          channelDescription: 'Notifikasi mengenai antrean pasien',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id: 1,
      title: 'Antrean Berhasil Diambil',
      body:
          'Nomor $nomorAntrean - $namaPoli\n'
          '$dokter • $jumlahDiDepan orang di depan\n'
          'Estimasi ±$estimasiMenit menit',
      notificationDetails: notificationDetails,
    );
  }

  // ============================================================
  // NOTIFIKASI MENDEKATI GILIRAN
  // ============================================================

  static Future<void> tampilkanNotifikasiMendekatiGiliran({
    required String nomorAntrean,
    required String namaPoli,
    required int jumlahDiDepan,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'antrean_mendekati',
          'Antrean Mendekati Giliran',
          channelDescription: 'Notifikasi ketika antrean mendekati giliran',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id: 2,
      title: 'Antrean Mendekati Giliran',
      body:
          'Nomor $nomorAntrean - $namaPoli\n'
          'Tinggal $jumlahDiDepan orang di depan Anda.',
      notificationDetails: notificationDetails,
    );
  }

  // ============================================================
  // NOTIFIKASI SUDAH GILIRAN
  // ============================================================

  static Future<void> tampilkanNotifikasiGiliranAnda({
    required String nomorAntrean,
    required String namaPoli,
    required String dokter,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'antrean_giliran',
          'Giliran Antrean',
          channelDescription: 'Notifikasi ketika sudah tiba giliran pasien',
          importance: Importance.max,
          priority: Priority.max,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id: 3,
      title: 'Sekarang Giliran Anda!',
      body:
          'Nomor $nomorAntrean - $namaPoli\n'
          'Silakan menuju $dokter.',
      notificationDetails: notificationDetails,
    );
  }
}
