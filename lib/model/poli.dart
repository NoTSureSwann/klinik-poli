import 'package:cloud_firestore/cloud_firestore.dart';

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
      'nm_poli': nm_poli,
      'kode_poli': kode_poli,
      'deskripsi_poli': deskripsi_poli,
      'kuota_harian': kuota_harian,
      'status_aktif': status_aktif,
    };
  }

  Poli.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.id,
        nm_poli = doc.data()!['nm_poli'],
        kode_poli = doc.data()!['kode_poli'],
        deskripsi_poli = doc.data()!['deskripsi_poli'] ?? '',
        kuota_harian = doc.data()!['kuota_harian'] ?? 30,
        status_aktif = doc.data()!['status_aktif'] ?? true;
}