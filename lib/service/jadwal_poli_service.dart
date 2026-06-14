import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/jadwal_poli.dart';
import '../helpers/queue_algorithm.dart';

class JadwalPoliService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addJadwal(JadwalPoli jadwal) async {
    await _db.collection("jadwal_poli").add(jadwal.toMap());
  }

  Future<void> updateJadwal(JadwalPoli jadwal) async {
    await _db.collection("jadwal_poli").doc(jadwal.id).update(jadwal.toMap());
  }

  Future<void> deleteJadwal(String id) async {
    await _db.collection("jadwal_poli").doc(id).delete();
  }

  Stream<List<JadwalPoli>> streamJadwal() {
    return _db.collection("jadwal_poli").snapshots().map((snap) =>
        snap.docs.map((d) => JadwalPoli.fromDocumentSnapshot(d)).toList());
  }

  Future<bool> hasConflict(JadwalPoli jadwalBaru) async {
    final snap = await _db
        .collection("jadwal_poli")
        .where('pegawaiId', isEqualTo: jadwalBaru.pegawaiId)
        .where('hari', isEqualTo: jadwalBaru.hari)
        .get();
    final existingList =
        snap.docs.map((d) => JadwalPoli.fromDocumentSnapshot(d)).toList();
    return isJadwalConflict(jadwalBaru, existingList);
  }

  Future<List<JadwalPoli>> retrieveJadwalAktif(String poliId, String hari) async {
    final snap = await _db
        .collection("jadwal_poli")
        .where('poliId', isEqualTo: poliId)
        .where('hari', isEqualTo: hari)
        .where('statusAktif', isEqualTo: true)
        .get();
    return snap.docs.map((d) => JadwalPoli.fromDocumentSnapshot(d)).toList();
  }
}
