class Antrean {
  final String id;
  final String uid;
  final String nomorAntrean;
  final String namaPoli;
  final String dokter;
  final String status;
  final DateTime waktuAmbil;
  final DateTime? waktuDipanggil;
  final DateTime? waktuSelesai;

  Antrean({
    required this.id,
    required this.uid,
    required this.nomorAntrean,
    required this.namaPoli,
    required this.dokter,
    required this.status,
    required this.waktuAmbil,
    this.waktuDipanggil,
    this.waktuSelesai,
  });

  factory Antrean.fromFirestore(String id, Map<String, dynamic> data) {
    return Antrean(
      id: id,
      uid: data['uid'] ?? '',
      nomorAntrean: data['nomorAntrean'] ?? '',
      namaPoli: data['namaPoli'] ?? '',
      dokter: data['dokter'] ?? '',
      status: data['status'] ?? 'Menunggu',
      waktuAmbil: (data['waktuAmbil'] as dynamic).toDate(),
      waktuDipanggil: data['waktuDipanggil'] != null
          ? (data['waktuDipanggil'] as dynamic).toDate()
          : null,
      waktuSelesai: data['waktuSelesai'] != null
          ? (data['waktuSelesai'] as dynamic).toDate()
          : null,
    );
  }
}
