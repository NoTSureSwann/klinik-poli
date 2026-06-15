import '../model/antrian.dart';
import '../model/poli.dart';
import '../model/jadwal_poli.dart';
import '../helpers/queue_algorithm.dart';
import '../helpers/api_client.dart';

class AntrianService {
  Future<String> daftarAntrian({
    required Poli poli,
    JadwalPoli? jadwal,
    required String pasienId,
    required String tanggal,
    required bool prioritas,
  }) async {
    final resAll = await ApiClient().get("?entity=antrian&poli_id=${poli.id}&tanggal=$tanggal");
    final allAntrian = (resAll.data['data'] as List).map((e) => Antrian.fromJson(e)).toList();

    final dup = allAntrian.where((a) => a.pasienId == pasienId && (a.status == AntrianStatus.menunggu || a.status == AntrianStatus.dipanggil));
    if (dup.isNotEmpty) {
      throw Exception('Pasien ini sudah terdaftar di antrian poli ini hari ini.');
    }

    final kuotaMax = jadwal != null ? jadwal.kuota : poli.kuota_harian;
    final activeAntrian = allAntrian.where((a) => a.status != AntrianStatus.batal);
    final count = jadwal != null ? activeAntrian.where((a) => a.jadwalId == jadwal.id).length : activeAntrian.length;

    if (count >= kuotaMax) {
      throw Exception('Kuota antrian sudah penuh untuk hari ini.');
    }

    final next = await getNextCounter(poli.id!, tanggal);
    final nomor = formatNomorAntrian(poli.kode_poli ?? 'POL', next);

    final antrian = Antrian(
      poliId: poli.id!,
      jadwalId: jadwal?.id,
      pasienId: pasienId,
      tanggal: tanggal,
      nomorAntrian: nomor,
      status: AntrianStatus.menunggu,
      prioritas: prioritas,
      waktuDaftar: DateTime.now(),
    );

    await ApiClient().post("?entity=antrian", antrian.toMap());

    return nomor;
  }

  Future<List<Antrian>> getAntrianHariIni(String poliId, String tanggal) async {
    final response = await ApiClient().get("?entity=antrian&poli_id=$poliId&tanggal=$tanggal");
    final data = response.data['data'] as List;
    final list = data.map((json) => Antrian.fromJson(json)).toList();
    list.sort((a, b) => a.waktuDaftar.compareTo(b.waktuDaftar));
    return list;
  }

  Future<Antrian?> panggilBerikutnya(String poliId, String tanggal) async {
    final response = await ApiClient().get("?entity=antrian&poli_id=$poliId&tanggal=$tanggal");
    final data = response.data['data'] as List;
    final all = data.map((json) => Antrian.fromJson(json)).toList();

    final dipanggil = all.where((a) => a.status == AntrianStatus.dipanggil).toList();
    for (final doc in dipanggil) {
      await updateStatus(doc.id!, AntrianStatus.selesai);
    }

    final menunggu = all.where((a) => a.status == AntrianStatus.menunggu).toList();
    if (menunggu.isEmpty) return null;

    final terurut = sortAntrianQueue(menunggu);
    final berikutnya = terurut.first;

    await ApiClient().put("?entity=antrian", {
      'id': berikutnya.id,
      'status': AntrianStatus.dipanggil,
      'waktu_panggil': DateTime.now().toString(),
    });

    berikutnya.status = AntrianStatus.dipanggil;
    return berikutnya;
  }

  Future<void> updateStatus(String id, String status) async {
    await ApiClient().put("?entity=antrian", {
      'id': id,
      'status': status,
    });
  }

  Future<List<Antrian>> getRiwayat(String poliId, String tanggal) async {
    final response = await ApiClient().get("?entity=antrian&poli_id=$poliId&tanggal=$tanggal");
    final data = response.data['data'] as List;
    final list = data.map((json) => Antrian.fromJson(json)).toList();
    list.sort((a, b) => a.nomorAntrian.compareTo(b.nomorAntrian));
    return list;
  }
}
