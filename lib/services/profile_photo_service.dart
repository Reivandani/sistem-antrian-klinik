import 'package:flutter/foundation.dart';

class ProfilePhotoService {
  // Menyimpan foto profil selama aplikasi sedang berjalan.
  static final ValueNotifier<Uint8List?> fotoProfil = ValueNotifier<Uint8List?>(
    null,
  );

  // Menyimpan foto baru.
  static void simpanFoto(Uint8List foto) {
    fotoProfil.value = foto;
  }

  // Menghapus foto.
  static void hapusFoto() {
    fotoProfil.value = null;
  }
}
