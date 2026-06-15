import '../model/pegawai.dart';
import '../helpers/api_client.dart';

class PegawaiService {
  Future<void> addPegawai(Pegawai pegawai) async {
    await ApiClient().post("?entity=pegawai", pegawai.toMap());
  }

  Future<void> updatePegawai(Pegawai pegawai) async {
    await ApiClient().put("?entity=pegawai", pegawai.toMap());
  }

  Future<void> deletePegawai(String id) async {
    await ApiClient().delete("?entity=pegawai&id=$id");
  }

  Future<List<Pegawai>> retrievePegawai() async {
    final response = await ApiClient().get("?entity=pegawai");
    final data = response.data['data'] as List;
    return data.map((json) => Pegawai.fromJson(json)).toList();
  }

  Stream<List<Pegawai>> streamPegawai() async* {
    yield await retrievePegawai();
  }

  Future<List<Pegawai>> retrieveDokter() async {
    final response = await ApiClient().get("?entity=pegawai");
    final data = response.data['data'] as List;
    final all = data.map((json) => Pegawai.fromJson(json)).toList();
    return all.where((p) => p.jabatanPegawai == 'Dokter').toList();
  }
}
