

class Pegawai {
  String? id;
  String? nipPegawai;
  String? namaPegawai;
  String? tglLahirPegawai;
  String? telpPegawai;
  String? emailPegawai;
  String? passwordPegawai;
  String jabatanPegawai;
  String? poliId;

  Pegawai({
    this.id,
    this.nipPegawai,
    this.namaPegawai,
    this.tglLahirPegawai,
    this.telpPegawai,
    this.emailPegawai,
    this.passwordPegawai,
    this.jabatanPegawai = 'Perawat',
    this.poliId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nip_pegawai': nipPegawai,
      'nama_pegawai': namaPegawai,
      'tgllhr_pegawai': tglLahirPegawai,
      'telp_pegawai': telpPegawai,
      'email_pegawai': emailPegawai,
      'password_pegawai': passwordPegawai,
      'jabatan_pegawai': jabatanPegawai,
      'poli_id': poliId,
    };
  }

  Pegawai.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        nipPegawai = json['nip_pegawai'] ?? json['nipPegawai'],
        namaPegawai = json['nama_pegawai'] ?? json['namaPegawai'],
        tglLahirPegawai = json['tgllhr_pegawai'] ?? json['tglLahirPegawai'],
        telpPegawai = json['telp_pegawai'] ?? json['telpPegawai'],
        emailPegawai = json['email_pegawai'] ?? json['emailPegawai'],
        passwordPegawai = json['password_pegawai'] ?? json['passwordPegawai'],
        jabatanPegawai = json['jabatan_pegawai'] ?? json['jabatanPegawai'] ?? 'Perawat',
        poliId = json['poli_id'] ?? json['poliId'];
}