import 'package:cloud_firestore/cloud_firestore.dart';

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
      'nipPegawai': nipPegawai,
      'namaPegawai': namaPegawai,
      'tglLahirPegawai': tglLahirPegawai,
      'telpPegawai': telpPegawai,
      'emailPegawai': emailPegawai,
      'passwordPegawai': passwordPegawai,
      'jabatanPegawai': jabatanPegawai,
      'poliId': poliId,
    };
  }

  Pegawai.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.id,
        nipPegawai = doc.data()!['nipPegawai'],
        namaPegawai = doc.data()!['namaPegawai'],
        tglLahirPegawai = doc.data()!['tglLahirPegawai'],
        telpPegawai = doc.data()!['telpPegawai'],
        emailPegawai = doc.data()!['emailPegawai'],
        passwordPegawai = doc.data()!['passwordPegawai'],
        jabatanPegawai = doc.data()!['jabatanPegawai'] ?? 'Perawat',
        poliId = doc.data()!['poliId'];
}