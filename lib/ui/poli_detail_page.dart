import 'package:flutter/material.dart';
import 'package:klinik_app/service/poli_service.dart';
import 'package:klinik_app/ui/poli_form_page.dart';
import 'package:klinik_app/ui/poli_form_update_page.dart';
import 'package:klinik_app/ui/jadwal_poli_page.dart';
import '../model/poli.dart';

class PoliDetailPage extends StatefulWidget {
  final Poli poli;

  const PoliDetailPage({super.key, required this.poli});

  @override
  State<PoliDetailPage> createState() => _PoliDetailPageState();
}

class _PoliDetailPageState extends State<PoliDetailPage> {
  PoliService _poliServiceNew = PoliService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detail Poli"),),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              "Nama Poli : ${widget.poli.nm_poli ?? '-'}",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              "Kode Poli : ${widget.poli.kode_poli ?? '-'}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              "Deskripsi : ${widget.poli.deskripsi_poli ?? '-'}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              "Kuota Harian : ${widget.poli.kuota_harian}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Chip(
              label: Text(widget.poli.status_aktif ? "Aktif" : "Non-Aktif", style: TextStyle(color: Colors.white)),
              backgroundColor: widget.poli.status_aktif ? Colors.green : Colors.grey,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => JadwalPoliPage(poliFilter: widget.poli))
                );
              },
              child: Text("Lihat Jadwal Poli Ini"),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _tombolubah(),
                _tombolhapus()
              ],
            )
          ],
        ),
      )
    );
  }

  _tombolubah(){
    return ElevatedButton(
      onPressed: (){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PoliUpdateForm(poli: widget.poli))
        );
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
      child: Text("Ubah"),
    );
  }

  _tombolhapus(){
    return ElevatedButton(
      onPressed: () async {
        bool hasJadwal = await _poliServiceNew.hasActiveJadwal(widget.poli.id!);
        if (hasJadwal) {
          showDialog(context: context, builder: (context) => AlertDialog(
            content: Text("Tidak dapat menghapus poli ini karena masih memiliki jadwal dokter aktif. Nonaktifkan/hapus jadwal terkait terlebih dahulu."),
            actions: [
              ElevatedButton(onPressed: () => Navigator.pop(context), child: Text("OK"))
            ],
          ));
          return;
        }

        AlertDialog alertDialog = AlertDialog(
          content: Text("Yakin ingin menghapus data ini?"),
          actions: [
            // tombol ya
            ElevatedButton(
              onPressed: () async {
                await _poliServiceNew.deletePoli(widget.poli.id!);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PoliForm()));
              },
              child: Text("YA"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            ),

            // tombol batal
            ElevatedButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: Text("Tidak"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, foregroundColor: Colors.black),
            )
          ],
        );
        showDialog(context: context, builder: (context) => alertDialog);
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
      child: Text("Hapus"),
    );
  }
}
