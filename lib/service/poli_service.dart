import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/poli.dart';

final FirebaseFirestore _db = FirebaseFirestore.instance;

class PoliService{
  addPoli(Poli poli) async {
    await _db.collection("poli").add(poli.toMap());
  }

  updatePoli(Poli poli) async {
    await _db.collection("poli").doc(poli.id).update(poli.toMap());
  }

  Future<void> deletePoli(String id) async {
    await _db.collection("poli").doc(id).delete();
  }

  Future<List<Poli>> retrievePoli() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
    await _db.collection("poli").get();
    return snapshot.docs
        .map((docSnapshot) => Poli.fromDocumentSnapshot(docSnapshot))
        .toList();
  }

  Stream<List<Poli>> streamPoli() {
    return _db.collection("poli").snapshots().map((snap) =>
        snap.docs.map((d) => Poli.fromDocumentSnapshot(d)).toList());
  }

  Future<bool> isKodePoliUnique(String kode, {String? excludeId}) async {
    final snap = await _db
        .collection("poli")
        .where('kode_poli', isEqualTo: kode)
        .get();
    if (snap.docs.isEmpty) return true;
    if (excludeId != null &&
        snap.docs.length == 1 &&
        snap.docs.first.id == excludeId) {
      return true;
    }
    return false;
  }

  Future<bool> hasActiveJadwal(String poliId) async {
    final snap = await _db
        .collection("jadwal_poli")
        .where('poliId', isEqualTo: poliId)
        .where('statusAktif', isEqualTo: true)
        .get();
    return snap.docs.isNotEmpty;
  }
}