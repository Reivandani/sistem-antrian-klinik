// ==========================================================
// FIREBASE MESSAGING SERVICE WORKER
// ==========================================================
//
// File ini digunakan oleh Firebase Cloud Messaging (FCM)
// untuk menerima notifikasi pada browser/Web.
//
// Lokasi file:
// web/firebase-messaging-sw.js
//
// ==========================================================


// ==========================================================
// IMPORT FIREBASE
// ==========================================================

importScripts(
  'https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js'
);

importScripts(
  'https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js'
);


// ==========================================================
// KONFIGURASI FIREBASE
// ==========================================================

firebase.initializeApp({
  apiKey: 'AIzaSyD9_tM5EnYVGrxTksfdR_HkTycjDmduPnQ',
  authDomain: 'sistem-antrean-klinik-7a8cc.firebaseapp.com',
  projectId: 'sistem-antrean-klinik-7a8cc',
  storageBucket: 'sistem-antrean-klinik-7a8cc.firebasestorage.app',
  messagingSenderId: '601746514629',
  appId: '1:601746514629:web:25c5072eab1a95bd9286ac',
});


// ==========================================================
// FIREBASE MESSAGING
// ==========================================================

const messaging = firebase.messaging();


// ==========================================================
// BACKGROUND MESSAGE
// ==========================================================
//
// Fungsi ini dijalankan ketika browser menerima pesan FCM
// saat aplikasi tidak sedang aktif di halaman.
//
// Contoh:
//
// Admin
//   ↓
// Panggil Antrean
//   ↓
// Firestore
//   ↓
// Cloud Function
//   ↓
// Firebase Cloud Messaging
//   ↓
// Browser
//   ↓
// Service Worker
//   ↓
// Notifikasi
//
// ==========================================================

messaging.onBackgroundMessage(function (payload) {

  console.log(
    '[firebase-messaging-sw.js] Pesan diterima:',
    payload
  );


  // ========================================================
  // JUDUL NOTIFIKASI
  // ========================================================

  const notificationTitle =
    payload.notification?.title ||
    'Sistem Antrean Klinik';


  // ========================================================
  // ISI NOTIFIKASI
  // ========================================================

  const notificationOptions = {

    body:
      payload.notification?.body ||
      'Ada informasi baru mengenai antrean Anda.',

    icon:
      '/icons/Icon-192.png',

    badge:
      '/icons/Icon-192.png',

    data:
      payload.data || {},

  };


  // ========================================================
  // TAMPILKAN NOTIFIKASI
  // ========================================================

  self.registration.showNotification(
    notificationTitle,
    notificationOptions
  );

});