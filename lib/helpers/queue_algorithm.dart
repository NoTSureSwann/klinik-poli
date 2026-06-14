import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/jadwal_poli.dart';
import '../model/antrian.dart';

String formatNomorAntrian(String kodePoli, int counter) {
  return '$kodePoli-${counter.toString().padLeft(3, '0')}';
}

Future<int> getNextCounter(
    FirebaseFirestore db, String poliId, String tanggal) async {
  final ref = db.collection('counters').doc('${poliId}_$tanggal');
  return db.runTransaction<int>((trx) async {
    final snap = await trx.get(ref);
    final current = snap.exists ? (snap.data()!['current'] as int) : 0;
    final next = current + 1;
    trx.set(ref, {
      'poliId': poliId,
      'tanggal': tanggal,
      'current': next,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return next;
  });
}

int timeToMinutes(String hhmm) {
  final p = hhmm.split(':');
  return int.parse(p[0]) * 60 + int.parse(p[1]);
}

bool isJadwalConflict(
    JadwalPoli jadwalBaru, List<JadwalPoli> jadwalLainSamaDokterSamaHari) {
  final mulaiBaru = timeToMinutes(jadwalBaru.jamMulai);
  final selesaiBaru = timeToMinutes(jadwalBaru.jamSelesai);
  for (final existing in jadwalLainSamaDokterSamaHari) {
    if (existing.id == jadwalBaru.id) continue;
    final mulaiLain = timeToMinutes(existing.jamMulai);
    final selesaiLain = timeToMinutes(existing.jamSelesai);
    if (mulaiBaru < selesaiLain && mulaiLain < selesaiBaru) return true;
  }
  return false;
}

List<Antrian> sortAntrianQueue(List<Antrian> daftar) {
  final hasil = List<Antrian>.from(daftar);
  hasil.sort((a, b) {
    if (a.prioritas != b.prioritas) {
      return a.prioritas ? -1 : 1;
    }
    return a.waktuDaftar.compareTo(b.waktuDaftar);
  });
  return hasil;
}

bool boyerMooreContains(String text, String pattern) {
  if (pattern.isEmpty) return true;
  final t = text.toLowerCase();
  final p = pattern.toLowerCase();
  final n = t.length;
  final m = p.length;
  if (m > n) return false;

  final Map<String, int> badChar = {};
  for (int i = 0; i < m; i++) {
    badChar[p[i]] = i;
  }

  int s = 0;
  while (s <= n - m) {
    int j = m - 1;
    while (j >= 0 && p[j] == t[s + j]) {
      j--;
    }
    if (j < 0) {
      return true;
    } else {
      final mismatch = t[s + j];
      final lastOcc = badChar[mismatch] ?? -1;
      final shift = j - lastOcc;
      s += shift > 0 ? shift : 1;
    }
  }
  return false;
}
