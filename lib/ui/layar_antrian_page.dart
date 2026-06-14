import 'package:flutter/material.dart';
import '../model/poli.dart';
import '../model/antrian.dart';
import '../service/poli_service.dart';
import '../service/antrian_service.dart';
import '../helpers/date_helper.dart';
import '../helpers/queue_algorithm.dart';

class LayarAntrianPage extends StatefulWidget {
  const LayarAntrianPage({super.key});

  @override
  State<LayarAntrianPage> createState() => _LayarAntrianPageState();
}

class _LayarAntrianPageState extends State<LayarAntrianPage> {
  String? _selectedPoliId;

  @override
  Widget build(BuildContext context) {
    final tanggal = formatTanggal(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: Text("Layar Antrian")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(15),
            child: _buildPoliDropdown(),
          ),
          Expanded(
            child: _selectedPoliId == null 
              ? Center(child: Text("Pilih Poli untuk melihat antrian"))
              : StreamBuilder<List<Antrian>>(
                  stream: AntrianService().streamAntrianHariIni(_selectedPoliId!, tanggal),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
                    if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                    final list = snapshot.data!;
                    final dipanggil = list.where((a) => a.status == AntrianStatus.dipanggil).toList();
                    final menunggu = list.where((a) => a.status == AntrianStatus.menunggu).toList();
                    // menunggu is already sorted by stream (waktuDaftar), but we need to sort by priority locally
                    final menungguSorted = sortAntrianQueue(menunggu);

                    final nomorDipanggil = dipanggil.isNotEmpty ? dipanggil.first.nomorAntrian : "-";

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          margin: EdgeInsets.all(15),
                          color: Colors.blue.shade50,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 30),
                            child: Column(
                              children: [
                                Text("SEDANG DILAYANI", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                                SizedBox(height: 20),
                                AnimatedSwitcher(
                                  duration: Duration(milliseconds: 500),
                                  transitionBuilder: (Widget child, Animation<double> animation) {
                                    return ScaleTransition(scale: animation, child: child);
                                  },
                                  child: Text(
                                    nomorDipanggil,
                                    key: ValueKey<String>(nomorDipanggil),
                                    style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Text("DAFTAR MENUNGGU (${menungguSorted.length})", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.all(15),
                            itemCount: menungguSorted.length,
                            itemBuilder: (context, index) {
                              final a = menungguSorted[index];
                              return Container(
                                margin: EdgeInsets.only(right: 10),
                                child: Chip(
                                  label: Text(a.nomorAntrian, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                  backgroundColor: a.prioritas ? Colors.orange.shade200 : Colors.grey.shade200,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(color: a.prioritas ? Colors.orange : Colors.grey.shade400, width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(15),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              final next = await AntrianService().panggilBerikutnya(_selectedPoliId!, tanggal);
                              if (next == null) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tidak ada antrian yang menunggu.")));
                              }
                            },
                            child: Text("PANGGIL ANTRIAN SELANJUTNYA", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ),
                        )
                      ],
                    );
                  },
                ),
          )
        ],
      ),
    );
  }

  Widget _buildPoliDropdown() {
    return StreamBuilder<List<Poli>>(
      stream: PoliService().streamPoli(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        final list = snapshot.data!.where((p) => p.status_aktif).toList();
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: "Pilih Poli",
            border: OutlineInputBorder(),
          ),
          value: _selectedPoliId,
          items: list.map((e) => DropdownMenuItem(value: e.id, child: Text(e.nm_poli ?? ''))).toList(),
          onChanged: (val) {
            setState(() { _selectedPoliId = val; });
          },
        );
      }
    );
  }
}
