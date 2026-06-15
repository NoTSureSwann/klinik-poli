import 'package:flutter/material.dart';
import '../model/poli.dart';
import '../model/antrian.dart';
import '../service/poli_service.dart';
import '../service/antrian_service.dart';
import '../service/pasien_service.dart';
import '../helpers/date_helper.dart';
import 'pemeriksaan_form_page.dart';


class AntrianRiwayatPage extends StatefulWidget {
  const AntrianRiwayatPage({super.key});

  @override
  State<AntrianRiwayatPage> createState() => _AntrianRiwayatPageState();
}

class _AntrianRiwayatPageState extends State<AntrianRiwayatPage> {
  String? _selectedPoliId;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  Map<String, String> _pasienMap = {};

  Future<List<Poli>>? _poliListFuture;
  Future<List<Antrian>>? _antrianListFuture;

  @override
  void initState() {
    super.initState();
    _loadPasienMap();
    _poliListFuture = PoliService().retrievePoli();
  }

  Future<void> _loadPasienMap() async {
    final list = await PasienService().retrievePasien();
    setState(() {
      _pasienMap = {
        for (var p in list) p.id!: "${p.namaPasien} (${p.nomorRMPasien})"
      };
    });
  }

  Future<void> _refreshAntrian() async {
    if (_selectedPoliId != null) {
      final tanggal = formatTanggal(DateTime.now());
      setState(() {
        _antrianListFuture = AntrianService().getRiwayat(_selectedPoliId!, tanggal);
      });
      await _antrianListFuture;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Riwayat Antrian Hari Ini")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              children: [
                _buildPoliDropdown(),
                SizedBox(height: 10),
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    labelText: "Cari No Antrian / Nama Pasien",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedPoliId == null
                ? Center(
                    child: Text("Pilih Poli untuk melihat riwayat antrian"))
                : RefreshIndicator(
                    onRefresh: _refreshAntrian,
                    child: FutureBuilder<List<Antrian>>(
                        future: _antrianListFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text("Error: ${snapshot.error}"));
                          }
                          if (!snapshot.hasData) {
                            return Center(child: Text("Belum ada data"));
                          }

                          var list = snapshot.data!;
                          if (_searchQuery.isNotEmpty) {
                            list = list.where((a) {
                              final pName = _pasienMap[a.pasienId] ?? '';
                              return a.nomorAntrian.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                                  pName.toLowerCase().contains(_searchQuery.toLowerCase());
                            }).toList();
                          }

                          if (list.isEmpty) {
                            return ListView(children: [Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Tidak ada data antrian.")))]);
                          }

                          return ListView.builder(
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              final a = list[index];
                              final pName = _pasienMap[a.pasienId] ?? 'Memuat...';

                              return Card(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 5),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        a.status == AntrianStatus.menunggu
                                            ? Colors.orange
                                            : a.status == AntrianStatus.dipanggil
                                                ? Colors.blue
                                                : a.status == AntrianStatus.selesai
                                                    ? Colors.green
                                                    : Colors.red,
                                    foregroundColor: Colors.white,
                                    child: Text(a.nomorAntrian.split('-').last),
                                  ),
                                  title: Text(pName),
                                  subtitle: Text(
                                      "Status: ${a.status} ${a.prioritas ? '(Prioritas)' : ''}"),
                                  trailing: Icon(Icons.more_vert),
                                  onTap: () => _showActionSheet(context, a),
                                ),
                              );
                            },
                          );
                        },
                      ),
                  ),
          )
        ],
      ),
    );
  }

  Widget _buildPoliDropdown() {
    return FutureBuilder<List<Poli>>(
        future: _poliListFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          final list = snapshot.data!;
          return DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: "Pilih Poli",
              border: OutlineInputBorder(),
            ),
            initialValue: _selectedPoliId,
            items: list
                .map((e) =>
                    DropdownMenuItem(value: e.id, child: Text(e.nm_poli ?? '')))
                .toList(),
            onChanged: (val) {
              setState(() {
                _selectedPoliId = val;
                _refreshAntrian();
              });
            },
          );
        });
  }

  void _showActionSheet(BuildContext context, Antrian a) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text("Ubah Status Antrian ${a.nomorAntrian}",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ListTile(
                  leading: Icon(Icons.medical_services, color: Colors.blue),
                  title: Text("Mulai Pemeriksaan"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PemeriksaanFormPage(antrian: a)));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text("Tandai Selesai"),
                  onTap: () {
                    AntrianService().updateStatus(a.id!, AntrianStatus.selesai);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.cancel, color: Colors.red),
                  title: Text("Batalkan Antrian"),
                  onTap: () {
                    AntrianService().updateStatus(a.id!, AntrianStatus.batal);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person_off, color: Colors.grey),
                  title: Text("Tandai Tidak Hadir"),
                  onTap: () {
                    AntrianService()
                        .updateStatus(a.id!, AntrianStatus.tidakHadir);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        });
  }
}
