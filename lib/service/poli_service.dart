import '../model/poli.dart';
import '../helpers/api_client.dart';

class PoliService {
  Future<void> addPoli(Poli poli) async {
    await ApiClient().post("?entity=poli", poli.toMap());
  }

  Future<void> updatePoli(Poli poli) async {
    await ApiClient().put("?entity=poli", poli.toMap());
  }

  Future<void> deletePoli(String id) async {
    await ApiClient().delete("?entity=poli&id=$id");
  }

  Future<List<Poli>> retrievePoli() async {
    final response = await ApiClient().get("?entity=poli");
    final data = response.data['data'] as List;
    return data.map((json) => Poli.fromJson(json)).toList();
  }

  Stream<List<Poli>> streamPoli() async* {
    yield await retrievePoli();
  }

  Future<bool> isKodePoliUnique(String kode, {String? excludeId}) async {
    final list = await retrievePoli();
    final matching = list.where((p) => p.kode_poli == kode).toList();
    if (matching.isEmpty) return true;
    if (excludeId != null && matching.length == 1 && matching.first.id == excludeId) {
      return true;
    }
    return false;
  }

  Future<bool> hasActiveJadwal(String poliId) async {
    final response = await ApiClient().get("?entity=jadwal_poli");
    final data = response.data['data'] as List;
    for (var j in data) {
      if (j['id_poli'] == poliId && (j['status_aktif'] == 1 || j['status_aktif'] == true)) {
        return true;
      }
    }
    return false;
  }
}
