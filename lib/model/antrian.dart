

class AntrianStatus {
  static const menunggu = 'menunggu';
  static const dipanggil = 'dipanggil';
  static const selesai = 'selesai';
  static const batal = 'batal';
  static const tidakHadir = 'tidak_hadir';
}

class Antrian {
  String? id;
  String poliId;
  String? jadwalId;
  String pasienId;
  String tanggal;
  String nomorAntrian;
  String status;
  DateTime waktuDaftar;
  DateTime? waktuPanggil;
  DateTime? waktuSelesai;
  bool prioritas;
  String? keluhan;

  Antrian({
    this.id,
    required this.poliId,
    this.jadwalId,
    required this.pasienId,
    required this.tanggal,
    required this.nomorAntrian,
    this.status = AntrianStatus.menunggu,
    required this.waktuDaftar,
    this.waktuPanggil,
    this.waktuSelesai,
    this.prioritas = false,
    this.keluhan,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'poli_id': poliId,
      'jadwal_id': jadwalId,
      'pasien_id': pasienId,
      'tanggal': tanggal,
      'nomor_antrian': nomorAntrian,
      'status': status,
      'waktu_daftar': waktuDaftar.toIso8601String(),
      'waktu_panggil': waktuPanggil?.toIso8601String(),
      'waktu_selesai': waktuSelesai?.toIso8601String(),
      'prioritas': prioritas ? 1 : 0,
      'keluhan': keluhan,
    };
  }

  Antrian.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        poliId = json['poli_id'] ?? json['poliId'],
        jadwalId = json['jadwal_id'] ?? json['jadwalId'],
        pasienId = json['pasien_id'] ?? json['pasienId'],
        tanggal = json['tanggal'],
        nomorAntrian = json['nomor_antrian'] ?? json['nomorAntrian'],
        status = json['status'],
        waktuDaftar = DateTime.parse(json['waktu_daftar']),
        waktuPanggil = json['waktu_panggil'] != null ? DateTime.parse(json['waktu_panggil']) : null,
        waktuSelesai = json['waktu_selesai'] != null ? DateTime.parse(json['waktu_selesai']) : null,
        prioritas = json['prioritas'] == 1 || json['prioritas'] == true,
        keluhan = json['keluhan'];
}
