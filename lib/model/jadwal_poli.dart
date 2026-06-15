
import '../helpers/queue_algorithm.dart';

class JadwalPoli {
  String? id;
  String poliId;
  String pegawaiId;
  String hari;
  String jamMulai;
  String jamSelesai;
  int kuota;
  bool statusAktif;

  JadwalPoli({
    this.id,
    required this.poliId,
    required this.pegawaiId,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    this.kuota = 10,
    this.statusAktif = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_poli': poliId,
      'id_pegawai': pegawaiId,
      'hari': hari,
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
      'kuota': kuota,
      'status_aktif': statusAktif ? 1 : 0,
    };
  }

  JadwalPoli.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        poliId = json['id_poli'] ?? json['poliId'] ?? '',
        pegawaiId = json['id_pegawai'] ?? json['pegawaiId'] ?? '',
        hari = json['hari'] ?? '',
        jamMulai = json['jam_mulai'] ?? json['jamMulai'] ?? '',
        jamSelesai = json['jam_selesai'] ?? json['jamSelesai'] ?? '',
        kuota = json['kuota'] ?? 10,
        statusAktif = json['status_aktif'] == 1 || json['statusAktif'] == true;

  int get jamMulaiMenit => timeToMinutes(jamMulai);
  int get jamSelesaiMenit => timeToMinutes(jamSelesai);
}
