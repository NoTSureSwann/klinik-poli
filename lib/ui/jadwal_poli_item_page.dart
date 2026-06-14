import 'package:flutter/material.dart';
import '../model/jadwal_poli.dart';
import 'jadwal_poli_form_update_page.dart';

class JadwalPoliItemPage extends StatelessWidget {
  final JadwalPoli jadwal;
  final String namaPoli;
  final String namaDokter;

  const JadwalPoliItemPage({
    super.key, 
    required this.jadwal,
    required this.namaPoli,
    required this.namaDokter,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: ListTile(
        title: Text("$namaPoli - dr. $namaDokter", style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hari: ${jadwal.hari} (${jadwal.jamMulai} - ${jadwal.jamSelesai})"),
            Text("Kuota: ${jadwal.kuota} Pasien"),
          ],
        ),
        trailing: Chip(
          label: Text(jadwal.statusAktif ? "Aktif" : "Non-Aktif", style: TextStyle(color: Colors.white, fontSize: 10)),
          backgroundColor: jadwal.statusAktif ? Colors.green : Colors.grey,
        ),
        onTap: () {
          // implement navigation to detail or edit page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => JadwalPoliFormUpdatePage(jadwal: jadwal))
          );
        },
      ),
    );
  }
}
