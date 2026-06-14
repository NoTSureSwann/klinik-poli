import 'package:cloud_firestore/cloud_firestore.dart';

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
      'nomorRMPasien': nomorRMPasien,
      'namaPasien': namaPasien,
      'tgllhrPasien': tgllhrPasien,
      'telpPasien': telpPasien,
      'alamatPasien': alamatPasien,
      'username': username,
      'password': password,
    };
  }

  Pasien.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.id,
        nomorRMPasien = doc.data()!['nomorRMPasien'],
        namaPasien = doc.data()!['namaPasien'],
        tgllhrPasien = doc.data()!['tgllhrPasien'],
        telpPasien = doc.data()!['telpPasien'],
        alamatPasien = doc.data()!['alamatPasien'],
        username = doc.data()!['username'],
        password = doc.data()!['password'];
}
