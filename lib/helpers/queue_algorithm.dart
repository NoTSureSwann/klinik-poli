import '../model/jadwal_poli.dart';
import '../model/antrian.dart';
import 'api_client.dart';

String formatNomorAntrian(String kodePoli, int counter) {
  return '$kodePoli-${counter.toString().padLeft(3, '0')}';
}

Future<int> getNextCounter(String poliId, String tanggal) async {
  final response = await ApiClient().get("?action=next_counter&poli_id=$poliId&tanggal=$tanggal");
  final data = response.data;
  if (data['status'] == true) {
    return data['counter'];
  } else {
    throw Exception("Gagal mendapatkan nomor antrian");
  }
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

