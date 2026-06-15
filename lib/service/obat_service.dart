import '../model/obat.dart';
import '../helpers/api_client.dart';

class ObatService {
  Future<void> addObat(Obat obat) async {
    await ApiClient().post("?entity=obat", obat.toMap());
  }

  Future<void> updateObat(Obat obat) async {
    await ApiClient().put("?entity=obat", obat.toMap());
  }

  Future<void> deleteObat(String id) async {
    await ApiClient().delete("?entity=obat&id=$id");
  }

  Future<List<Obat>> retrieveObat() async {
    final response = await ApiClient().get("?entity=obat");
    final data = response.data['data'] as List;
    return data.map((json) => Obat.fromJson(json)).toList();
  }
}
