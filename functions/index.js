// ==========================================================
// CLOUD FUNCTION - NOTIFIKASI ANTREAN KLINIK
// ==========================================================

// Mengambil trigger Firestore dari Firebase Functions
const {onDocumentUpdated} = require("firebase-functions/v2/firestore");

// Firebase Admin SDK
const {initializeApp} = require("firebase-admin/app");
const {
  getFirestore,
  FieldValue,
} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");

// ==========================================================
// INISIALISASI FIREBASE ADMIN
// ==========================================================

initializeApp();

// Membuat koneksi ke Firestore
const db = getFirestore();


// ==========================================================
// CLOUD FUNCTION
// ==========================================================
//
// Function ini akan berjalan setiap kali dokumen di:
//
// antrean/{documentId}
//
// mengalami perubahan.
//
// Contoh:
//
// Menunggu
//    ↓
// Dipanggil
//
// ==========================================================

exports.kirimNotifikasiAntrean = onDocumentUpdated(
    "antrean/{documentId}",
    async (event) => {
    // ======================================================
      // CEK DATA EVENT
      // ======================================================

      if (!event.data) {
        console.log("Data event tidak tersedia.");
        return;
      }


      // ======================================================
      // DATA SEBELUM PERUBAHAN
      // ======================================================

      const beforeData = event.data.before.data();


      // ======================================================
      // DATA SETELAH PERUBAHAN
      // ======================================================

      const afterData = event.data.after.data();


      // ======================================================
      // AMBIL STATUS
      // ======================================================

      const statusSebelumnya = beforeData.status;
      const statusSekarang = afterData.status;


      console.log(
          "Status sebelumnya:",
          statusSebelumnya,
      );

      console.log(
          "Status sekarang:",
          statusSekarang,
      );


      // ======================================================
      // HANYA PROSES JIKA STATUS MENJADI "Dipanggil"
      // ======================================================

      if (
        statusSebelumnya === statusSekarang ||
      statusSekarang !== "Dipanggil"
      ) {
        console.log(
            "Perubahan bukan menjadi status Dipanggil.",
        );

        return;
      }


      // ======================================================
      // AMBIL DATA ANTREAN
      // ======================================================

      const uid = afterData.uid;

      const nomorAntrean =
      afterData.nomorAntrean || "-";

      const namaPoli =
      afterData.namaPoli || "Poli";

      const dokter =
      afterData.dokter || "Dokter";


      console.log(
          "UID pasien:",
          uid,
      );

      console.log(
          "Nomor antrean:",
          nomorAntrean,
      );

      console.log(
          "Poli:",
          namaPoli,
      );

      console.log(
          "Dokter:",
          dokter,
      );


      // ======================================================
      // CEK UID
      // ======================================================

      if (!uid) {
        console.log(
            "UID pasien tidak ditemukan.",
        );

        return;
      }


      // ======================================================
      // AMBIL DATA USER
      // ======================================================

      const userRef = db
          .collection("users")
          .doc(uid);

      const userSnapshot =
      await userRef.get();


      // ======================================================
      // CEK USER
      // ======================================================

      if (!userSnapshot.exists) {
        console.log(
            `User dengan UID ${uid} tidak ditemukan.`,
        );

        return;
      }


      // ======================================================
      // DATA USER
      // ======================================================

      const userData =
      userSnapshot.data();


      // ======================================================
      // AMBIL FCM TOKEN
      // ======================================================

      const fcmTokens =
      userData.fcmTokens || [];


      console.log(
          "Jumlah FCM Token:",
          fcmTokens.length,
      );


      // ======================================================
      // CEK TOKEN
      // ======================================================

      if (
        !Array.isArray(fcmTokens) ||
      fcmTokens.length === 0
      ) {
        console.log(
            "Pasien belum mempunyai FCM Token.",
        );

        return;
      }


      // ======================================================
      // BUAT PESAN NOTIFIKASI
      // ======================================================

      const message = {

        // ----------------------------------------------------
        // NOTIFIKASI YANG AKAN DITAMPILKAN
        // ----------------------------------------------------

        notification: {

          title:
          "Sekarang Giliran Anda!",

          body:
          `Nomor ${nomorAntrean} - ${namaPoli}. ` +
          `Silakan menuju ${dokter}.`,

        },


        // ----------------------------------------------------
        // DATA TAMBAHAN
        // ----------------------------------------------------

        data: {

          nomorAntrean:
          String(nomorAntrean),

          namaPoli:
          String(namaPoli),

          dokter:
          String(dokter),

          status:
          String(statusSekarang),

        },


        // ----------------------------------------------------
        // SEMUA DEVICE PASIEN
        // ----------------------------------------------------

        tokens: fcmTokens,

      };


      // ======================================================
      // KIRIM NOTIFIKASI
      // ======================================================

      try {
        const response =
        await getMessaging()
            .sendEachForMulticast(message);


        // ====================================================
        // HASIL PENGIRIMAN
        // ====================================================

        console.log(
            "Jumlah notifikasi berhasil:",
            response.successCount,
        );

        console.log(
            "Jumlah notifikasi gagal:",
            response.failureCount,
        );


        // ====================================================
        // CARI TOKEN YANG SUDAH TIDAK VALID
        // ====================================================

        const tokenTidakValid = [];


        response.responses.forEach(
            (result, index) => {
              if (!result.success) {
                const errorCode =
  result.error ? result.error.code : "";

                console.log(
                    `Token ke-${index + 1} gagal:`,
                    errorCode,
                );


                // ----------------------------------------------
                // TOKEN SUDAH TIDAK BERLAKU
                // ----------------------------------------------

                if (
                  errorCode.includes(
                      "registration-token-not-registered",
                  ) ||
              errorCode.includes(
                  "invalid-registration-token",
              )
                ) {
                  tokenTidakValid.push(
                      fcmTokens[index],
                  );
                }
              }
            },
        );


        // ====================================================
        // HAPUS TOKEN YANG TIDAK VALID
        // ====================================================

        if (tokenTidakValid.length > 0) {
          await userRef.update({

            fcmTokens:
            FieldValue.arrayRemove(
                ...tokenTidakValid,
            ),

          });


          console.log(
              "Token tidak valid berhasil dihapus:",
              tokenTidakValid.length,
          );
        }


        // ====================================================
        // SELESAI
        // ====================================================

        console.log(
            "Proses pengiriman notifikasi selesai.",
        );
      } catch (error) {
      // ====================================================
        // ERROR
        // ====================================================

        console.error(
            "Gagal mengirim notifikasi:",
            error,
        );
      }
    },
);
