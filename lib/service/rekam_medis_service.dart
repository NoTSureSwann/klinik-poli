import '../model/rekam_medis.dart';
import '../helpers/api_client.dart';

class RekamMedisService {
  Future<String> simpanRekamMedis(RekamMedis rm) async {
    final response = await ApiClient().post("?action=simpan_rekam_medis", rm.toMap());
    final data = response.data;
    if (data['status'] == true) {
      return data['id'];
    } else {
      throw Exception(data['message'] ?? 'Gagal menyimpan rekam medis');
    }
  }

  Future<RekamMedis?> getRekamMedisByAntrian(String antrianId) async {
    // Custom endpoint might be better for JOINs, but we'll filter here for simplicity since search uses LIKE on certain columns.
    // Actually, our API does NOT support filtering by antrian_id properly unless we add it. Let's do a fetch all and filter for now, or just use custom endpoint.
    // Wait, let's just fetch all rekam_medis and filter in client (since this is simple app)
    final res = await ApiClient().get("?entity=rekam_medis");
    final all = res.data['data'] as List;
    
    try {
      final found = all.firstWhere((element) => element['antrian_id'] == antrianId);
      final rm = RekamMedis.fromJson(found);
      
      // Fetch resep if any
      final resResep = await ApiClient().get("?entity=resep_obat");
      final allResep = resResep.data['data'] as List;
      final resepList = allResep
          .where((r) => r['rekam_medis_id'] == rm.id)
          .map((r) => ResepObat.fromJson(r))
          .toList();
          
      rm.resep = resepList;
      return rm;
    } catch (e) {
      return null; // Not found
    }
  }
  
  Future<void> updateStatusPembayaran(String id, String status) async {
    await ApiClient().put("?entity=rekam_medis", {
      'id': id,
      'status_pembayaran': status
    });
  }
}
