import 'package:flutter/material.dart';
import '../model/antrian.dart';
import '../model/rekam_medis.dart';

class StrukPembayaranPage extends StatelessWidget {
  final RekamMedis rekamMedis;
  final Antrian antrian;

  const StrukPembayaranPage({Key? key, required this.rekamMedis, required this.antrian}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double totalBayar = rekamMedis.biayaJasa + rekamMedis.totalBiayaObat;

    return Scaffold(
      appBar: AppBar(title: Text('Struk Pembayaran')),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey, style: BorderStyle.solid),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.5),
                spreadRadius: 2,
                blurRadius: 5,
              )
            ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('POLIKLINIK SEHAT', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text('Jl. Sehat Selalu No. 123', textAlign: TextAlign.center),
              Divider(thickness: 2),
              SizedBox(height: 10),
              Text('No. Antrian : ${antrian.nomorAntrian}'),
              Text('Tanggal     : ${antrian.tanggal}'),
              Text('Status      : ${rekamMedis.statusPembayaran}', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Text('Rincian Biaya:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Biaya Jasa Dokter'),
                  Text('Rp ${rekamMedis.biayaJasa.toStringAsFixed(0)}'),
                ],
              ),
              SizedBox(height: 10),
              Text('Resep Obat:'),
              if (rekamMedis.resep != null)
                ...rekamMedis.resep!.map((r) => Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('- ${r.obat?.namaObat ?? r.obatId} (${r.jumlah}x)'),
                      Text('Rp ${r.subtotal.toStringAsFixed(0)}'),
                    ],
                  ),
                )),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Biaya Obat'),
                  Text('Rp ${rekamMedis.totalBiayaObat.toStringAsFixed(0)}'),
                ],
              ),
              Divider(thickness: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('TOTAL TAGIHAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Rp ${totalBayar.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('TUTUP / KEMBALI')
              )
            ],
          ),
        ),
      ),
    );
  }
}
