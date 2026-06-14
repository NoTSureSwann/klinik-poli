import 'package:cloud_firestore/cloud_firestore.dart';
import '../helpers/queue_algorithm.dart';

class JadwalPoli {
  String? id;
  String poliId;
  String pegawaiId;
  String hari;
  String jamMulai;
  String jamSelesai;
  int kuota;
  bool statusAktif;

  JadwalPoli({
    this.id,
    required this.poliId,
    required this.pegawaiId,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    this.kuota = 10,
    this.statusAktif = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'poliId': poliId,
      'pegawaiId': pegawaiId,
      'hari': hari,
      'jamMulai': jamMulai,
      'jamSelesai': jamSelesai,
      'kuota': kuota,
      'statusAktif': statusAktif,
    };
  }

  JadwalPoli.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.id,
        poliId = doc.data()!['poliId'],
        pegawaiId = doc.data()!['pegawaiId'],
        hari = doc.data()!['hari'],
        jamMulai = doc.data()!['jamMulai'],
        jamSelesai = doc.data()!['jamSelesai'],
        kuota = doc.data()!['kuota'] ?? 10,
        statusAktif = doc.data()!['statusAktif'] ?? true;

  int get jamMulaiMenit => timeToMinutes(jamMulai);
  int get jamSelesaiMenit => timeToMinutes(jamSelesai);
}
