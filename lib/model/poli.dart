

class Poli {
  final String? id;
  final String? nm_poli;
  final String? kode_poli;
  final String? deskripsi_poli;
  final int kuota_harian;
  final bool status_aktif;

  Poli({
    this.id,
    this.nm_poli,
    this.kode_poli,
    this.deskripsi_poli,
    this.kuota_harian = 30,
    this.status_aktif = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_poli': nm_poli,
      'kode_poli': kode_poli,
      'deskripsi_poli': deskripsi_poli,
      'kuota_harian': kuota_harian,
      'status_aktif': status_aktif ? 1 : 0,
    };
  }

  Poli.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        nm_poli = json['nama_poli'] ?? json['nm_poli'],
        kode_poli = json['kode_poli'],
        deskripsi_poli = json['deskripsi_poli'] ?? '',
        kuota_harian = json['kuota_harian'] != null ? int.tryParse(json['kuota_harian'].toString()) ?? 30 : 30,
        status_aktif = json['status_aktif'] == 1 || json['status_aktif'] == true;
}