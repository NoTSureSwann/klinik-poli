import 'obat.dart';

class RekamMedis {
  String? id;
  String antrianId;
  String pasienId;
  String pegawaiId;
  String diagnosa;
  double biayaJasa;
  double totalBiayaObat;
  String statusPembayaran;
  List<ResepObat>? resep;

  RekamMedis({
    this.id,
    required this.antrianId,
    required this.pasienId,
    required this.pegawaiId,
    required this.diagnosa,
    required this.biayaJasa,
    required this.totalBiayaObat,
    this.statusPembayaran = 'Belum Lunas',
    this.resep,
  });

  factory RekamMedis.fromJson(Map<String, dynamic> json) {
    return RekamMedis(
      id: json['id'],
      antrianId: json['antrian_id'],
      pasienId: json['pasien_id'],
      pegawaiId: json['pegawai_id'],
      diagnosa: json['diagnosa'],
      biayaJasa: double.parse(json['biaya_jasa'].toString()),
      totalBiayaObat: double.parse(json['total_biaya_obat'].toString()),
      statusPembayaran: json['status_pembayaran'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'antrian_id': antrianId,
      'pasien_id': pasienId,
      'pegawai_id': pegawaiId,
      'diagnosa': diagnosa,
      'biaya_jasa': biayaJasa,
      'total_biaya_obat': totalBiayaObat,
      'status_pembayaran': statusPembayaran,
      'resep': resep?.map((r) => r.toMap()).toList(),
    };
  }
}

class ResepObat {
  String? id;
  String? rekamMedisId;
  String obatId;
  int jumlah;
  double hargaSatuan;
  double subtotal;
  Obat? obat;

  ResepObat({
    this.id,
    this.rekamMedisId,
    required this.obatId,
    required this.jumlah,
    required this.hargaSatuan,
    required this.subtotal,
    this.obat,
  });

  factory ResepObat.fromJson(Map<String, dynamic> json) {
    return ResepObat(
      id: json['id'],
      rekamMedisId: json['rekam_medis_id'],
      obatId: json['obat_id'],
      jumlah: int.parse(json['jumlah'].toString()),
      hargaSatuan: double.parse(json['harga_satuan'].toString()),
      subtotal: double.parse(json['subtotal'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rekam_medis_id': rekamMedisId,
      'obat_id': obatId,
      'jumlah': jumlah,
      'harga_satuan': hargaSatuan,
      'subtotal': subtotal,
    };
  }
}
