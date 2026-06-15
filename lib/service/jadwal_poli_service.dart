import '../model/jadwal_poli.dart';
import '../helpers/queue_algorithm.dart';
import '../helpers/api_client.dart';

class JadwalPoliService {
  Future<void> addJadwal(JadwalPoli jadwal) async {
    await ApiClient().post("?entity=jadwal_poli", jadwal.toMap());
  }

  Future<void> updateJadwal(JadwalPoli jadwal) async {
    await ApiClient().put("?entity=jadwal_poli", jadwal.toMap());
  }

  Future<void> deleteJadwal(String id) async {
    await ApiClient().delete("?entity=jadwal_poli&id=$id");
  }

  Future<List<JadwalPoli>> _retrieve() async {
    final response = await ApiClient().get("?entity=jadwal_poli");
    final data = response.data['data'] as List;
    return data.map((json) => JadwalPoli.fromJson(json)).toList();
  }

  Stream<List<JadwalPoli>> streamJadwal() async* {
    yield await _retrieve();
  }

  Future<bool> hasConflict(JadwalPoli jadwalBaru) async {
    final all = await _retrieve();
    final existingList = all.where((j) => j.pegawaiId == jadwalBaru.pegawaiId && j.hari == jadwalBaru.hari).toList();
    return isJadwalConflict(jadwalBaru, existingList);
  }

  Future<List<JadwalPoli>> retrieveJadwalAktif(String poliId, String hari) async {
    final all = await _retrieve();
    return all.where((j) => j.poliId == poliId && j.hari == hari && j.statusAktif).toList();
  }
}
