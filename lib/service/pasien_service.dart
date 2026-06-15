import '../model/pasien.dart';
import '../helpers/api_client.dart';

class PasienService {
  Future<void> addPasien(Pasien pasien) async {
    await ApiClient().post("?entity=pasien", pasien.toMap());
  }

  Future<void> updatePasien(Pasien pasien) async {
    await ApiClient().put("?entity=pasien", pasien.toMap());
  }

  Future<void> deletePasien(String id) async {
    await ApiClient().delete("?entity=pasien&id=$id");
  }

  Future<List<Pasien>> retrievePasien() async {
    final response = await ApiClient().get("?entity=pasien");
    final data = response.data['data'] as List;
    return data.map((json) => Pasien.fromJson(json)).toList();
  }
}
