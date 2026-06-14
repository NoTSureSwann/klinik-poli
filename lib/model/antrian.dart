import 'package:cloud_firestore/cloud_firestore.dart';

class AntrianStatus {
  static const menunggu = 'menunggu';
  static const dipanggil = 'dipanggil';
  static const selesai = 'selesai';
  static const batal = 'batal';
  static const tidakHadir = 'tidak_hadir';
}

class Antrian {
  String? id;
  String poliId;
  String? jadwalId;
  String pasienId;
  String tanggal;
  String nomorAntrian;
  String status;
  bool prioritas;
  Timestamp waktuDaftar;
  Timestamp? waktuDipanggil;
  String? catatan;

  Antrian({
    this.id,
    required this.poliId,
    this.jadwalId,
    required this.pasienId,
    required this.tanggal,
    required this.nomorAntrian,
    required this.status,
    required this.prioritas,
    required this.waktuDaftar,
    this.waktuDipanggil,
    this.catatan,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'poliId': poliId,
      'jadwalId': jadwalId,
      'pasienId': pasienId,
      'tanggal': tanggal,
      'nomorAntrian': nomorAntrian,
      'status': status,
      'prioritas': prioritas,
      'waktuDaftar': waktuDaftar,
      'waktuDipanggil': waktuDipanggil,
      'catatan': catatan,
    };
  }

  Antrian.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.id,
        poliId = doc.data()!['poliId'],
        jadwalId = doc.data()!['jadwalId'],
        pasienId = doc.data()!['pasienId'],
        tanggal = doc.data()!['tanggal'],
        nomorAntrian = doc.data()!['nomorAntrian'],
        status = doc.data()!['status'],
        prioritas = doc.data()!['prioritas'] ?? false,
        waktuDaftar = doc.data()!['waktuDaftar'] as Timestamp? ?? Timestamp.now(),
        waktuDipanggil = doc.data()!['waktuDipanggil'] as Timestamp?,
        catatan = doc.data()!['catatan'];
}
