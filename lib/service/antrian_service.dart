import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/antrian.dart';
import '../model/poli.dart';
import '../model/jadwal_poli.dart';
import '../helpers/queue_algorithm.dart';

class AntrianService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> daftarAntrian({
    required Poli poli,
    JadwalPoli? jadwal,
    required String pasienId,
    required String tanggal,
    required bool prioritas,
  }) async {
    final dup = await _db
        .collection("antrian")
        .where('poliId', isEqualTo: poli.id)
        .where('pasienId', isEqualTo: pasienId)
        .where('tanggal', isEqualTo: tanggal)
        .where('status', whereIn: [AntrianStatus.menunggu, AntrianStatus.dipanggil])
        .get();
    if (dup.docs.isNotEmpty) {
      throw Exception('Pasien ini sudah terdaftar di antrian poli ini hari ini.');
    }

    final kuotaMax = jadwal != null ? jadwal.kuota : poli.kuota_harian;
    Query<Map<String, dynamic>> countQuery = _db
        .collection("antrian")
        .where('poliId', isEqualTo: poli.id)
        .where('tanggal', isEqualTo: tanggal)
        .where('status', isNotEqualTo: AntrianStatus.batal);
    if (jadwal != null) {
      countQuery = countQuery.where('jadwalId', isEqualTo: jadwal.id);
    }
    final existingSnap = await countQuery.get();
    if (existingSnap.docs.length >= kuotaMax) {
      throw Exception('Kuota antrian sudah penuh untuk hari ini.');
    }

    return _db.runTransaction<String>((trx) async {
      final counterRef =
          _db.collection('counters').doc('${poli.id}_$tanggal');
      final counterSnap = await trx.get(counterRef);
      final current =
          counterSnap.exists ? (counterSnap.data()!['current'] as int) : 0;
      final next = current + 1;
      final nomor = formatNomorAntrian(poli.kode_poli ?? 'POL', next);

      trx.set(counterRef, {
        'poliId': poli.id,
        'tanggal': tanggal,
        'current': next,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final antrianRef = _db.collection("antrian").doc();
      trx.set(antrianRef, {
        'poliId': poli.id,
        'jadwalId': jadwal?.id,
        'pasienId': pasienId,
        'tanggal': tanggal,
        'nomorAntrian': nomor,
        'status': AntrianStatus.menunggu,
        'prioritas': prioritas,
        'waktuDaftar': FieldValue.serverTimestamp(),
        'waktuDipanggil': null,
        'catatan': null,
      });

      return nomor;
    });
  }

  Stream<List<Antrian>> streamAntrianHariIni(String poliId, String tanggal) {
    return _db
        .collection("antrian")
        .where('poliId', isEqualTo: poliId)
        .where('tanggal', isEqualTo: tanggal)
        .orderBy('waktuDaftar')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Antrian.fromDocumentSnapshot(d)).toList());
  }

  Future<Antrian?> panggilBerikutnya(String poliId, String tanggal) async {
    return _db.runTransaction<Antrian?>((trx) async {
      final menungguSnap = await _db
          .collection("antrian")
          .where('poliId', isEqualTo: poliId)
          .where('tanggal', isEqualTo: tanggal)
          .where('status', isEqualTo: AntrianStatus.menunggu)
          .get();

      final dipanggilSnap = await _db
          .collection("antrian")
          .where('poliId', isEqualTo: poliId)
          .where('tanggal', isEqualTo: tanggal)
          .where('status', isEqualTo: AntrianStatus.dipanggil)
          .get();

      for (final doc in dipanggilSnap.docs) {
        trx.update(doc.reference, {'status': AntrianStatus.selesai});
      }

      if (menungguSnap.docs.isEmpty) return null;

      final daftarMenunggu =
          menungguSnap.docs.map((d) => Antrian.fromDocumentSnapshot(d)).toList();
      final terurut = sortAntrianQueue(daftarMenunggu);
      final berikutnya = terurut.first;

      trx.update(_db.collection("antrian").doc(berikutnya.id), {
        'status': AntrianStatus.dipanggil,
        'waktuDipanggil': FieldValue.serverTimestamp(),
      });

      berikutnya.status = AntrianStatus.dipanggil;
      return berikutnya;
    });
  }

  Future<void> updateStatus(String id, String status) async {
    await _db.collection("antrian").doc(id).update({'status': status});
  }

  Stream<List<Antrian>> streamRiwayat(String poliId, String tanggal) {
    return _db
        .collection("antrian")
        .where('poliId', isEqualTo: poliId)
        .where('tanggal', isEqualTo: tanggal)
        .orderBy('nomorAntrian')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Antrian.fromDocumentSnapshot(d)).toList());
  }
}
