

class Pasien {
  String? id;
  String? nomorRMPasien;
  String? namaPasien;
  String? tgllhrPasien;
  String? telpPasien;
  String? alamatPasien;
  String? username;
  String? password;

  Pasien({this.id, this.nomorRMPasien, this.namaPasien, this.tgllhrPasien, this.telpPasien, this.alamatPasien, this.username, this.password});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nomor_rm': nomorRMPasien,
      'nama_pasien': namaPasien,
      'tgllhr_pasien': tgllhrPasien,
      'telp_pasien': telpPasien,
      'alamat_pasien': alamatPasien,
      'username': username,
      'password': password,
    };
  }

  Pasien.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        nomorRMPasien = json['nomor_rm'] ?? json['nomorRMPasien'],
        namaPasien = json['nama_pasien'] ?? json['namaPasien'],
        tgllhrPasien = json['tgllhr_pasien'] ?? json['tgllhrPasien'],
        telpPasien = json['telp_pasien'] ?? json['telpPasien'],
        alamatPasien = json['alamat_pasien'] ?? json['alamatPasien'],
        username = json['username'],
        password = json['password'];
}
